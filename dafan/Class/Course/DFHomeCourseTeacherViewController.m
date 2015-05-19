//
//  DFCourseViewController.m
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFHomeCourseTeacherViewController.h"
#import "SYStandardNavigationBar.h"
//#import "DFPayViewController.h"
#import "DFHomeTabController.h"
#import "DFSelfStudyViewController.h"
#import "DFTeacherCoursesViewController.h"
#import "DFMyCourseTableViewCell.h"
#import "DFCourseTeacherTableViewCell.h"
#import "DFCourseIntroductionViewController.h"
#import "SYTabBarController.h"
#import "DFActivityViewController.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "SYBannerBar.h"
#import "SYBaseContentViewController+DFLogInOut.h"
#import "DFClassroomViewController.h"
#import "DFCommonImages.h"
#import "SYBaseNavigationController.h"
#import "DFUrlDefine.h"
#import "SYWebviewViewController.h"
#import "DFColorDefine.h"
#import "DFCourseViewController.h"
#import "DFCoursesViewController.h"
#import "DFUserSettingsViewController.h"
#import "DFPreference.h"
#import "SYHttpRequest.h"
#import "DFTeachersViewController.h"
#import "DFTeacherItem.h"
#import "SYPopoverMenu.h"
#import "DFChapterSectionViewController.h"
#import "UIImageView+WebCache.h"
#import "DFAgreementViewController.h"
#import "DFCourseItem.h"
#import "DFFilePath.h"
#import "UIAlertView+SYExtension.h"
#import "DFChannelZoneViewController.h"
#import "UIButton+WebCache.h"

typedef NS_ENUM(NSInteger, DFBannerType)
{
    DFBannerTypeNone,
    DFBannerTypeWeb,
    DFBannerTypeClassroom,
    DFBannerTypeChatroom,
    DFBannerTypeTeacher,
    DFBannerTypeCourseHours,
    DFBannerTypeFilmClips,
    DFBannerTypeCourseIntroduction
};
/**
 Section HeaderView
 */
#define kTableViewHeight 105.0f

@interface DFHomeTableHeaderView : UITableViewHeaderFooterView

@property(nonatomic, strong) UIButton* moreButton;
@property(nonatomic, strong) UILabel* titleLabel;

@property(nonatomic) id moreButtonTarget;
@property(nonatomic) SEL moreButtonAction;

@end

#define kTableHeaderTitleColor RGBCOLOR(132, 143, 149.f)

@implementation DFHomeTableHeaderView

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.contentView.backgroundColor = RGBCOLOR(236, 237, 237);
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 200.f, self.frame.size.height)];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    self.titleLabel.textColor = kTableHeaderTitleColor;
    self.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.contentView addSubview:self.titleLabel];
    
    self.moreButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 54.f, 0, 54.f, self.frame.size.height)];
    self.moreButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    self.moreButton.backgroundColor = [UIColor clearColor];
    [self.moreButton setTitleColor:kTableHeaderTitleColor forState:UIControlStateNormal];
    self.moreButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    [self.moreButton setTitle:@"更多" forState:UIControlStateNormal];
    [self.contentView addSubview:self.moreButton];
    [self.moreButton addTarget:self action:@selector(moreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) moreButtonClicked:(id)sender
{
    [self.moreButtonTarget performSelector:self.moreButtonAction withObject:sender];
}
@end

@interface DFHomeCourseTeacherViewController ()<SYPopoverMenuDelegate>
//焦点图
@property(nonatomic, strong) SYBannerBar* headerBannerBar;
/**
 *  存储的是TableViewCell的数据源
 */
@property(nonatomic, strong) NSMutableArray* items;
/**
 *  存储的时sectionHeaderView 的数据源
 */
@property(nonatomic, strong) NSMutableArray* titles;
/**
 *  教师的表图
 */
@property(nonatomic, strong) NSMutableArray* animatingImages;

@end

@implementation DFHomeCourseTeacherViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = [NSMutableArray array];
    
    self.titles = [NSMutableArray array];
    
    self.animatingImages = [NSMutableArray array];
    
    for (NSInteger idx = 0; idx < 7; ++idx)
    {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"class_doing_%d.png", idx]];
        [self.animatingImages addObject:image];
    }
    //添加监听事件
    [self addObservers];
    
    [self registerLogInOutObservers];
    
    [self configCustomNavigationBar];
    
    [self configTableView];
    
    [self requestData];
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}
/**
 *  当APP 从后台 进入前台
 *
 *  @param notification <#notification description#>
 */
- (void) applicationWillEnterForeground:(NSNotification *)notification
{
    [self requestData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.headerBannerBar startBannerPlayTimer];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.headerBannerBar stopBannerPlayTimer];
}

#define kTableSectionHeaderReuseId @"TableSectionHeader"

- (void) configTableView
{
    self.tableView.rowHeight = kTableViewHeight;
    //下拉刷新
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    
    [self.tableView registerClass:[DFHomeTableHeaderView class] forHeaderFooterViewReuseIdentifier:kTableSectionHeaderReuseId];
    self.tableView.sectionHeaderHeight = 27.f;
    
    self.headerBannerBar = [[SYBannerBar alloc] init];
    //设置焦点图
    SYBannerBarView* headerView = [[SYBannerBarView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 130)];
    headerView.pageImageViewTarget = self;
    headerView.pageControl.currentPageIndicatorTintColor = kMainDarkColor;
    headerView.pageImageViewAction = @selector(headerBannerItemTapped:);
    
    self.tableView.tableHeaderView = headerView;
    self.headerBannerBar.bannerView = headerView;
}
/**
 *  焦点图点击时间处理
 */
- (void) headerBannerItemTapped:(UIGestureRecognizer *)gesture
{
    UIImageView *temp = (UIImageView *)gesture.view;
//    NSInteger aa = temp.tag;
    
//    NSInteger tag = gesture.view.tag;
    
    NSInteger tag = [self.headerBannerBar.bannerView.pageImageViews indexOfObject:temp];
    
    SYBannerBarItem* item = [self.headerBannerBar.bannerView.loadingInfos  objectAtIndex:tag];
    
//    NSInteger index = item.type;
    
    switch (item.type) {
        case DFBannerTypeChatroom:
        {
            DFChannelZoneViewController* controller = [[DFChannelZoneViewController alloc] initWithChannelId:item.optionalId];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case DFBannerTypeCourseHours:
        {
            DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeRead];
            controller.courseId = item.optionalId;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case DFBannerTypeTeacher:
        {
            DFTeacherCoursesViewController* controller = [[DFTeacherCoursesViewController alloc] initWithTeacherId:item.optionalId];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        case DFBannerTypeClassroom:
        {
            DFClassroomViewController* controller = [[DFClassroomViewController alloc] initWithCourseId:item.optionalId];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        case DFBannerTypeFilmClips:
        {
            self.customTabBarController.selectedIndex = 1;
            [((DFHomeTabController *)self.customTabBarController).selfStudyViewController selectRight];
        }
            break;
            
        case DFBannerTypeCourseIntroduction:
        {
            DFCourseIntroductionViewController* controller = [[DFCourseIntroductionViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        case DFBannerTypeWeb:
        {
            SYWebviewViewController* controller = [[SYWebviewViewController alloc] initWithUrl:item.webViewUrl];
            controller.webTitle = item.title;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void) reloadDataForRefresh
{
    [self requestData];
}

- (void) configCustomNavigationBar
{
    self.title = NSLocalizedString(@"Courses & Teachers", @"我的课表");
    
    [self.customNavigationBar setLeftButtonWithStandardImage:[UIImage imageNamed:@"home_profile.png"]];
    

//    [self.customNavigationBar setRightButtonWithStandardTitle:@"test"];
}
/**
 *  用户登录成功 self监听 的回调
 */
- (void) userDidLogin
{
    [self requestData];
}
/**
 *  用户退出登录 self监听 的回调
 */
- (void) userDidLogout
{
    [self requestData];
}

- (void) requestData
{
    typeof(self) __weak bself = self;
    
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForMyCourseAndBanner] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [self.items removeAllObjects];
        [self.titles removeAllObjects];
        
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            
            [bself reloadDataWithInfo:info];
            //缓存到本地
            [info writeToFile:[DFFilePath homeCourseTeachersCacheFilePath] atomically:YES];
        }
        else
        {
            NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:[DFFilePath homeCourseTeachersCacheFilePath]];
            [bself reloadDataWithInfo:info];
            
            [UIAlertView showNOPWithText:errorMsg];
        }
        [bself hideProgress];
        
    }];
    [self.requests addObject:request];
}

- (void) reloadDataWithInfo:(NSDictionary *)info
{
    NSMutableArray* bannerItems = [NSMutableArray array];
    //焦点图
    NSArray* bannerInfos = [info objectForKey:@"banner"];
    for (NSDictionary* info in bannerInfos)
    {
        SYBannerBarItem* item = [[SYBannerBarItem alloc] initWithDictionary:info];
        [bannerItems addObject:item];
    }
    //设置数据源
    self.headerBannerBar.bannerView.loadingInfos = bannerItems;
    //开始定时滚动
    [self.headerBannerBar startBannerPlayTimer];
    if (bannerInfos.count > 0)
    {
        self.tableView.tableHeaderView = self.headerBannerBar.bannerView;
    }
    else
    {
        self.tableView.tableHeaderView = nil;
    }
    //tableView的 数据源处理
    NSArray* myRegisteredCourses = [self coursesWithInfos:[info objectForKey:@"usercourse"]];   //我正在学习的课程
    NSArray* classingCourses = [self coursesWithInfos:[info objectForKey:@"classcourse"]];      //正在上课的课程
    NSArray* registerableCourses = [self coursesWithInfos:[info objectForKey:@"signcourse"]];  //可报名的课程
    NSArray* teacherCourses = [self coursesWithInfos:[info objectForKey:@"teachercourse"]];     //教授的课程
    NSArray* otherTeacherCourses = [self coursesWithInfos:[info objectForKey:@"otherteachercourse"]];   //其他老师课程
    
    if (myRegisteredCourses.count > 0)
    {
        NSArray* myCourses = [NSArray arrayWithObjects:@"我学习的课程", [NSNumber numberWithInt:DFCourseStyleStudent], nil];
        [self.titles addObject:myCourses];
        [self.items addObject:myRegisteredCourses];
    }
    if (classingCourses.count > 0)
    {
        NSArray* myCourses = [NSArray arrayWithObjects:@"正在/正要上课", [NSNumber numberWithInt:DFCourseStyleInClass], nil];
        [self.titles addObject:myCourses];
        [self.items addObject:classingCourses];
    }
    if (registerableCourses.count > 0)
    {
        NSArray* myCourses = [NSArray arrayWithObjects:@"可报名的课程", [NSNumber numberWithInt:DFCourseStyleRegisterable], nil];
        [self.titles addObject:myCourses];
        [self.items addObject:registerableCourses];
    }
    if (teacherCourses.count > 0)
    {
        NSArray* myCourses = [NSArray arrayWithObjects:@"我教授的课程", [NSNumber numberWithInt:DFCourseStyleTeacher], nil];
        [self.titles addObject:myCourses];
        [self.items addObject:teacherCourses];
    }
    if (otherTeacherCourses.count > 0)
    {
        NSArray* myCourses = [NSArray arrayWithObjects:@"其他老师课程", [NSNumber numberWithInt:DFCourseStyleRecommend], nil];
        [self.titles addObject:myCourses];
        [self.items addObject:otherTeacherCourses];
    }
    
    [self.tableView reloadData];
}
/**
 *  字典转模型
 *
 *  @param infos 模型对象数组
 *
 *  @return 对象数组
 */
- (NSArray *) coursesWithInfos:(NSArray *)infos
{
    NSMutableArray* courses = [NSMutableArray array];
    for (NSDictionary* dict in infos)
    {
        DFCourseItem* course = [[DFCourseItem alloc] initWithDictionary:dict];
        [courses addObject:course];
    }
    return courses;
}
#pragma mark    左按钮 用户设置按钮点击
- (void) leftButtonClicked:(id)sender
{
    DFUserSettingsViewController* controller = [[DFUserSettingsViewController alloc] init];
    SYBaseNavigationController* navigationController = [[SYBaseNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
}
#pragma mark    右按钮
- (void) rightButtonClicked:(id)sender
{
    SYWebviewViewController* controller = [[SYWebviewViewController alloc] initWithUrl:@"http://m.dafanpx.com/?action=sharevod&id=206"];
    controller.webTitle = @"胡一菲的教师服";
    [self.navigationController pushViewController:controller animated:YES];
    return;
    
    SYPopoverMenuItem* requestTeacherItem = [[SYPopoverMenuItem alloc] init];
    requestTeacherItem.title = @"老师认证";
    requestTeacherItem.image = [UIImage imageNamed:@"menu_verfiy.png"];
    
    SYPopoverMenuItem* registerableTeacherItem = [[SYPopoverMenuItem alloc] init];
    registerableTeacherItem.title = @"可报名的课程";
    registerableTeacherItem.image = [UIImage imageNamed:@"menu_verfiy.png"];
    
    SYPopoverMenuItem* inclassCoursesItem = [[SYPopoverMenuItem alloc] init];
    inclassCoursesItem.title = @"正在上课";
    inclassCoursesItem.image = [UIImage imageNamed:@"menu_verfiy.png"];
    
    SYPopoverMenuItem* otherCoursesItem = [[SYPopoverMenuItem alloc] init];
    otherCoursesItem.title = @"其他老师课程";
    otherCoursesItem.image = [UIImage imageNamed:@"menu_verfiy.png"];
    
    SYPopoverMenuItem* activityItem = [[SYPopoverMenuItem alloc] init];
    activityItem.title = @"活动详情";
    activityItem.image = [UIImage imageNamed:@"menu_verfiy.png"];
    
    SYPopoverMenu* menu = [[SYPopoverMenu alloc] initWithMenuItems:@[requestTeacherItem, registerableTeacherItem, inclassCoursesItem, otherCoursesItem, activityItem]];
    menu.delegate = self;
    [menu showFromView:self.customNavigationBar.rightButton];
}
#pragma mark    SYPopoverMenuDelegate
- (void) popoverMenu:(SYPopoverMenu *)menu select:(NSInteger)menuId
{
    switch (menuId) {
        case 0:
        {
            DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
            SYBaseNavigationController* navigationController = [[SYBaseNavigationController alloc] initWithRootViewController:controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
        }
            break;
        case 1:
        {
            DFCoursesViewController* controller = [[DFCoursesViewController alloc] initWithStyle:DFCourseStyleRegisterable];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 2:
        {
            DFCoursesViewController* controller = [[DFCoursesViewController alloc] initWithStyle:DFCourseStyleInClass];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case 3:
        {
            DFCoursesViewController* controller = [[DFCoursesViewController alloc] initWithStyle:DFCourseStyleRecommend];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        case 4:
        {
            DFCourseIntroductionViewController* controller = [[DFCourseIntroductionViewController alloc] init];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview

- (void) cellGotoClassroomButtonClicked:(SYUserInfoButton *)sender
{
    if (![[DFPreference sharedPreference] validateLogin:^{
        return NO;
    }])
    {
        return;
    }
    
    if (sender.userInfo != nil)
    {
        DFCourseItem* courseItem = (DFCourseItem *)sender.userInfo;
        if (sender.selected)
        {
            DFChapterSectionViewController* controller = [[DFChapterSectionViewController alloc] initWithChapterSectionStyle:DFChapterSectionStylePrep];
            controller.courseId = courseItem.persistentId;
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            DFClassroomViewController* controller = [[DFClassroomViewController alloc] initWithCourseId:courseItem.persistentId];
            [self.navigationController pushViewController:controller animated:YES];
        }
    }
}
/**
 *  cell上面的头像点击事件
 */
- (void) cellAvatarButtonClicked:(UIButton *)sender
{
    DFTeacherCoursesViewController* controller = [[DFTeacherCoursesViewController alloc] initWithTeacherId:sender.tag];
    [self.navigationController pushViewController:controller animated:YES];
}

#define kMyCourseTableCell @"MyCourseCell"
#define kCourseTeacherCell @"CourseTeacherCell"

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    DFHomeTableHeaderView* headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kTableSectionHeaderReuseId];
    NSArray* titles = [self.titles objectAtIndex:section];
    headerView.titleLabel.text = [titles objectAtIndex:0];
    headerView.moreButton.hidden = [[titles lastObject] integerValue] >= DFCourseStyleStudent;
    headerView.moreButton.tag = section;
    headerView.moreButtonTarget = self;
    headerView.moreButtonAction = @selector(sectionMoreButtonClicked:);
    return headerView;
}
/**
 *  更多按钮点击事件
 */
- (void) sectionMoreButtonClicked:(UIButton *)sender
{
    NSArray* titles = [self.titles objectAtIndex:sender.tag];
    
    DFCourseStyle style = [[titles lastObject] integerValue];
    DFCoursesViewController* controller = [[DFCoursesViewController alloc] initWithStyle:style];
    [self.navigationController pushViewController:controller animated:YES];
}
#pragma mark    UITableViewDelegate UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.items objectAtIndex:section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取得模型数据
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    DFCourseItem* courseItem = (DFCourseItem *)item;
    //cell
    DFMyCourseTableViewCell* cell = (DFMyCourseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kMyCourseTableCell];
    if (cell == nil)
    {
        NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"DFMyCourseTableViewCell" owner:self options:nil];
        cell = array.firstObject;
        cell.backgroundColor = [UIColor clearColor];
        //            cell.avatarButton.userInteractionEnabled = NO;
        
        [cell.avatarButton addTarget:self action:@selector(cellAvatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.gotoClassroomButton addTarget:self action:@selector(cellGotoClassroomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.classingImageView.animationImages = self.animatingImages;
        cell.classingImageView.animationRepeatCount = INT16_MAX;
        cell.classingImageView.animationDuration = 2.1;
    }
    cell.avatarButton.tag = courseItem.teacherId;
    
    cell.gotoClassroomButton.userInfo = courseItem;
    //不同的section对应与不同的cell
    NSArray* titles = [self.titles objectAtIndex:indexPath.section];
    DFCourseStyle sectionStyle = [[titles lastObject] integerValue];
    switch (sectionStyle) {
        case DFCourseStyleTeacher:
            cell.gotoClassroomButton.hidden = NO;
            cell.gotoClassroomButton.selected = NO;
            break;
        case DFCourseStyleStudent:
            cell.gotoClassroomButton.hidden = NO;
            cell.gotoClassroomButton.selected = (courseItem.classroomStatus == DFClassroomStatusDone);
            break;
        default:
            cell.gotoClassroomButton.hidden = courseItem.classroomStatus == DFClassroomStatusDone;
            cell.gotoClassroomButton.selected = NO;
            break;
    }
    
    cell.classingImageView.hidden = courseItem.classroomStatus != DFClassroomStatusDoing;
    if (!cell.classingImageView.hidden)
    {
        [cell.classingImageView startAnimating];
    }
    else
    {
        [cell.classingImageView stopAnimating];
    }
    
    cell.courseTitleLabel.text = courseItem.courseName;
    cell.dateTimeLabel.text = [NSString stringWithFormat:@"上课时间: %@", courseItem.coursePeriod];
    cell.statusLabel.text = courseItem.statusDescription;
    cell.subjectLabel.text = [NSString stringWithFormat:@"主题: %@", courseItem.currentHoursTitle];
    cell.avatarButton.tag = courseItem.teacherId;
    [cell.avatarButton setImageWithURL:[NSURL URLWithString:courseItem.teacherAvatarUrl] forState:UIControlStateNormal placeholderImage:[DFCommonImages defaultAvatarImage]];
    return cell;
}
#pragma mark    cell 选中事件
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //取消选中动画
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    id item = [[self.items objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    DFCourseItem* courseItem = (DFCourseItem *)item;
    DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeRead];
    controller.courseId = courseItem.persistentId;
    [self.navigationController pushViewController:controller animated:YES];
    
}

@end
