//
//  DFTeacherCoursesViewController.m
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFTeacherCoursesViewController.h"
#import "DFStarRatingView.h"
#import "DFPreference.h"
#import "DFTeacherItem.h"
#import "DFCourseItem.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "SYEnum.h"
#import "DFCommonImages.h"
#import "UIButton+WebCache.h"
#import "DFClassroomViewController.h"
#import "UIAlertView+SYExtension.h"
#import "DFCourseViewController.h"
#import "DFTeacherCourseTableViewCell.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "SYPopoverImageViewController.h"

@interface DFTeacherCoursesViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *teacherInfoBackgroundView;
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCountLabel;
@property (weak, nonatomic) IBOutlet UIImageView *verifyImageView;
@property (weak, nonatomic) IBOutlet UILabel *teacherIntroLabel;
@property (weak, nonatomic) IBOutlet DFStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;

@property(nonatomic, strong) UIView* teacherHeaderView;

@property(nonatomic) NSInteger teacherId;
@property(nonatomic) SYFocusState focusedStatus;
@property(nonatomic, strong) DFTeacherItem* teacherInfo;
@property(nonatomic, strong) NSMutableArray* courses;

@end

#define kCellIdentfifier @"TeacherCourseCell"

@implementation DFTeacherCoursesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithTeacherId:(NSInteger)teacherId
{
    self = [super init];
    if (self)
    {
        self.teacherId = teacherId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configTableView];
    
    [self requestDatas];
}

- (void) configTableView
{
    [self initTableHeaderView];
    self.tableView.rowHeight = 100;
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
    
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    
    self.teacherInfo = self.defaultTeacherItem;
    [self reloadTableHeaderView];
}

- (void) initTableHeaderView
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"DFTeacherCourseHeaderView" owner:self options:nil];
    self.teacherHeaderView = views.firstObject;
    self.teacherHeaderView.backgroundColor = [UIColor clearColor];
    
    [self.avatarButton addTarget:self action:@selector(avatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
 
    UIImage* image = [[UIImage imageNamed:@"course_header_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 0, 10, 0) resizingMode:UIImageResizingModeStretch];
    self.teacherInfoBackgroundView.image = image;
    
    self.teacherIntroLabel.numberOfLines = 0;
    
    self.tableView.tableHeaderView = self.teacherHeaderView;
}

- (void) avatarButtonClicked:(UIButton *)sender
{
    SYPopoverImageViewController* controller = [[SYPopoverImageViewController alloc] initWithImageUrl:self.teacherInfo.avatarUrl];
    [controller popoverFromView:sender];
    [self addChildViewController:controller];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - requestData

- (void) reloadDataForRefresh
{
    [self requestDatas];
}

- (void) requestDatas
{
    [self showProgress];
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForTeacheInfo] postValues:@{@"id" : [NSNumber numberWithInt:self.teacherId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            bself.teacherInfo = [[DFTeacherItem alloc] initWithDictionary:info];
            bself.focusedStatus = [[info objectForKey:@"fav_type"] integerValue];
            [bself reloadTableHeaderView];
            
            [bself reloadCoursesWithInfos:[info objectForKey:@"courselist"]];
        }
        
        [bself hideProgress];
    }];
    [self.requests addObject:request];
}

- (void) reloadCoursesWithInfos:(NSArray *)infos
{
    if (self.courses == nil)
    {
        self.courses = [NSMutableArray array];
    }
    [self.courses removeAllObjects];
    
    for (NSDictionary* info in infos)
    {
        DFCourseItem* item = [[DFCourseItem alloc] initWithDictionary:info];
        [self.courses addObject:item];
    }
    [self.tableView reloadData];
}

#define kTeacherNameMargin 14.f

- (void) reloadTableHeaderView
{
    self.title = self.teacherInfo.nickname;
    
    [self.avatarButton setImageWithURL:[NSURL URLWithString:self.teacherInfo.avatarUrl] forState:UIControlStateNormal placeholderImage:[DFCommonImages defaultAvatarImage]];
    
    
    self.memberImageView.hidden = self.teacherInfo.member != DFMemberTypeVip;
    
    self.starView.pickedStarCount = self.teacherInfo.rate;
    self.starView.numberOfStars = 5;
    self.starView.starSpace = 4;
    
    self.studentCountLabel.text = [NSString stringWithFormat:@"%d人学习过", self.teacherInfo.studentsCount];
    
    [self layoutTeacherNameVerifyViews];
    
    self.teacherIntroLabel.text = self.teacherInfo.teacherDescription;
    CGSize introSize = [self.teacherIntroLabel sizeThatFits:CGSizeMake(278, 300)];
    CGRect introFrame = self.teacherIntroLabel.frame;
    introFrame.size = introSize;
    self.teacherIntroLabel.frame = introFrame;
    
    CGRect bkgImageFrame = self.teacherInfoBackgroundView.frame;
    bkgImageFrame.size.height = introFrame.origin.y + introFrame.size.height + 14;
    self.teacherInfoBackgroundView.frame = bkgImageFrame;
    
    CGRect teacherHeaderFrame = self.teacherHeaderView.frame;
    teacherHeaderFrame.size.height = bkgImageFrame.origin.y + bkgImageFrame.size.height + 32.f;
    self.teacherHeaderView.frame = teacherHeaderFrame;
    
    self.tableView.tableHeaderView = self.teacherHeaderView;
}

- (void) layoutTeacherNameVerifyViews
{
    self.teacherNameLabel.text = self.teacherInfo.nickname;
    [self.teacherNameLabel sizeToFit];
    CGRect teacherNameFrame = self.teacherNameLabel.frame;
    CGRect memberFrame = self.memberImageView.frame;
    CGSize headerSize = self.teacherHeaderView.frame.size;
    
    if (self.memberImageView.hidden)
    {
        if (teacherNameFrame.origin.x + teacherNameFrame.size.width + kTeacherNameMargin  > headerSize.width)
        {
            teacherNameFrame.size.width = headerSize.width - kTeacherNameMargin - teacherNameFrame.origin.x;
            self.teacherNameLabel.frame = teacherNameFrame;
        }
    }
    else
    {
        if (teacherNameFrame.origin.x + teacherNameFrame.size.width + kTeacherNameMargin + memberFrame.size.width + kTeacherNameMargin > headerSize.width)
        {
            memberFrame.origin.x = headerSize.width - kTeacherNameMargin - memberFrame.size.width;
            teacherNameFrame.size.width = memberFrame.origin.x - kTeacherNameMargin - teacherNameFrame.origin.x;
            
            self.teacherNameLabel.frame = teacherNameFrame;
            self.memberImageView.frame = memberFrame;
        }
        else
        {
            memberFrame.origin.x = teacherNameFrame.origin.x + teacherNameFrame.size.width + kTeacherNameMargin;
            self.memberImageView.frame = memberFrame;
        }
    }
}
/**
 *  进入教室的按钮点击
 */
- (void) cellGotoClassroomButtonClicked:(UIButton *)sender
{
    if (![[DFPreference sharedPreference] validateLogin:^{
        return NO;
    }])
    {
        return;
    }
    
    DFCourseItem* courseItem = [self.courses objectAtIndex:sender.tag];
    
    DFClassroomViewController* controller = [[DFClassroomViewController alloc] initWithCourseId:courseItem.persistentId];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - tableview

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.courses.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFTeacherCourseTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentfifier];
    if (cell == nil)
    {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:@"DFTeacherCourseTableViewCell" owner:self options:nil];
        cell = cells.firstObject;
        cell.backgroundColor = [UIColor clearColor];
        [cell.gotoClassroomButton addTarget:self action:@selector(cellGotoClassroomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.courseDetailButton.userInteractionEnabled = NO;
    }
    
    DFCourseItem* item = [self.courses objectAtIndex:indexPath.row];
    
    cell.gotoClassroomButton.hidden = item.classroomStatus == DFClassroomStatusDone;
    cell.gotoClassroomButton.tag = indexPath.row;
    cell.courseDetailButton.tag = indexPath.row;
    
    cell.courseTitleLabel.text = item.courseName;
    cell.dateTimeLabel.text = [NSString stringWithFormat:@"上课时间: %@", item.coursePeriod];
    cell.tuitionLabel.text = [NSString stringWithFormat:@"¥%d/%d课时", item.tuition, item.hoursCount];
    cell.studentCountLabel.text = [NSString stringWithFormat:@"已报名%d人/最多%d人", item.registersCount, item.maxRegisterCount];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFCourseItem* courseItem = [self.courses objectAtIndex:indexPath.row];
    
//    DFClassroomViewController* controller = [[DFClassroomViewController alloc] initWithCourseId:courseItem.persistentId];
//    [self.navigationController pushViewController:controller animated:YES];

    DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeRead];
    controller.courseId = courseItem.persistentId;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
