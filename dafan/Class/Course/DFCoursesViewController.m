//
//  DFMyCoursesViewController.m
//  dafan
//
//  Created by iMac on 14-8-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCoursesViewController.h"
#import "DFCourseItem.h"
#import "DFClassroomViewController.h"
#import "UIButton+WebCache.h"
#import "DFCommonImages.h"
#import "DFUrlDefine.h"
#import "DFTeacherCoursesViewController.h"
#import "UIAlertView+SYExtension.h"
#import "SYHttpRequest.h"
#import "SYDeviceDescription.h"
#import "DFCreateCourseViewController.h"
//#import "SYBaseContentViewController+DFNavigationBar.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "DFMyCourseTableViewCell.h"
#import "SYStandardNavigationBar.h"
#import "DFPreference.h"
#import "DFChapterSectionViewController.h"
#import "DFNotificationDefines.h"
#import "DFCourseViewController.h"

@interface DFCoursesViewController ()

@property(nonatomic, strong) NSMutableArray* courses;
@property(nonatomic, strong) NSMutableArray* animatingImages;

@property(nonatomic) DFCourseStyle courseStyle;

@property(nonatomic) NSInteger offsetId;

@end

#define kTableViewHeight 105.0f
#define kTableViewSectionHeaderHeight 20.f

@implementation DFCoursesViewController
@synthesize courses = _courses;
@synthesize animatingImages = _animatingImages;

- (id) initWithStyle:(DFCourseStyle)style
{
    self = [super init];
    if (self)
    {
        self.courseStyle = style;
    }
    return self;
}

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
    
    self.courses = [NSMutableArray array];
    self.animatingImages = [NSMutableArray array];
    for (NSInteger idx = 0; idx < 7; ++idx)
    {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"class_doing_%d.png", idx]];
        [self.animatingImages addObject:image];
    }
    
    if (![self isMemberOfClass:[DFCoursesViewController class]])
    {
        return;
    }
    [self configCustomNavigationBar];
    [self configTableView];
    
    [self requestData:YES];
}


- (void) configCustomNavigationBar
{
    switch (self.courseStyle) {
            
        case DFCourseStyleInClass:
            self.title = @"正在上课";
            break;
            
        case DFCourseStyleRecommend:
            self.title = @"其他老师课程";
            break;
            
        case DFCourseStyleRegisterable:
            self.title = @"可报名的课程";
            break;
            
        default:
            break;
    }
}

- (void) configTableView
{
    self.tableView.rowHeight = kTableViewHeight;
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    [self setClickToFetchMoreTableFooterView];
    self.tableView.sectionHeaderHeight = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) reloadDataForRefresh
{
    [self requestData:YES];
}

- (void) requestMoreDataForTableFooterClicked
{
    [self requestData:NO];
}

- (void) requestData:(BOOL)reload
{
    switch (self.courseStyle) {
            
        case DFCourseStyleInClass:
            [self requestCourses:[DFUrlDefine urlForDoingClassrooms] reload:reload];
            break;
            
        case DFCourseStyleRecommend:
            [self requestCourses:[DFUrlDefine urlForOtherTeacherCourses] reload:reload];
            break;
            
        case DFCourseStyleRegisterable:
            [self requestCourses:[DFUrlDefine urlForRegisterableTeachers] reload:reload];
            break;
            
        default:
            break;
    }
    
}

- (void) requestCourses:(NSString *)url reload:(BOOL)reload
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    NSDictionary* dict = nil;
    if (!reload)
    {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.offsetId] forKey:@"offsetid"];
    }
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:url postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success)
        {
            if (reload)
            {
                [bself.courses removeAllObjects];
            }
            bself.offsetId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];;
            NSArray* info = [resultInfo objectForKey:@"info"];
            [bself.courses addObjectsFromArray:[bself coursesWithInfos:info]];
            [bself.tableView reloadData];
            [self setTableFooterStauts:bself.offsetId > 0 empty:bself.courses.count == 0];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
            [self setTableFooterStauts:YES empty:NO];
        }
        
        [bself hideProgress];
        
    }];
    [self.requests addObject:request];
}

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

- (void) cellAvatarButtonClicked:(UIButton *)sender
{
    DFTeacherCoursesViewController* controller = [[DFTeacherCoursesViewController alloc] initWithTeacherId:sender.tag];
    [self.navigationController pushViewController:controller animated:YES];
}

#define kMyCourseTableCell @"MyCourseCell"

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.courses.count;
}

- (DFCourseItem *)courseItemForIndexPath:(NSIndexPath *)indexPath
{
    return [self.courses objectAtIndex:indexPath.row];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFMyCourseTableViewCell* cell = (DFMyCourseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kMyCourseTableCell];
    if (cell == nil)
    {
        NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"DFMyCourseTableViewCell" owner:self options:nil];
        cell = array.firstObject;
        cell.backgroundColor = [UIColor clearColor];
//        cell.avatarButton.userInteractionEnabled = NO;
        [cell.avatarButton addTarget:self action:@selector(cellAvatarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [cell.gotoClassroomButton addTarget:self action:@selector(cellGotoClassroomButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        cell.classingImageView.animationImages = self.animatingImages;
        cell.classingImageView.animationRepeatCount = INT16_MAX;
        cell.classingImageView.animationDuration = 2.1;
    }
    DFCourseItem* item = [self courseItemForIndexPath:indexPath];
    
    cell.gotoClassroomButton.hidden = item.classroomStatus == DFClassroomStatusDone;
    cell.gotoClassroomButton.userInfo = item;
    cell.classingImageView.hidden = item.classroomStatus != DFClassroomStatusDoing;
    if (!cell.classingImageView.hidden)
    {
        [cell.classingImageView startAnimating];
    }
    else
    {
        [cell.classingImageView stopAnimating];
    }
    
    cell.courseTitleLabel.text = item.courseName;
    cell.dateTimeLabel.text = [NSString stringWithFormat:@"上课时间: %@", item.coursePeriod];
    cell.statusLabel.text = item.statusDescription;
    cell.subjectLabel.text = [NSString stringWithFormat:@"主题: %@", item.currentHoursTitle];
    cell.avatarButton.tag = item.teacherId;
    [cell.avatarButton setImageWithURL:[NSURL URLWithString:item.teacherAvatarUrl] forState:UIControlStateNormal placeholderImage:[DFCommonImages defaultAvatarImage]];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFCourseItem* item = [self courseItemForIndexPath:indexPath];
    DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeRead];
    controller.courseId = item.persistentId;
    [self.navigationController pushViewController:controller animated:YES];
}

- (NSString *) emptyFooterTitle
{
    return @"还没有此类课程";
}

@end
