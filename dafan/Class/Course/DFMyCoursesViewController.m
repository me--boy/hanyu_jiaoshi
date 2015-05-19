//
//  DFMyCoursesViewController.m
//  dafan
//
//  Created by iMac on 14-9-24.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFMyCoursesViewController.h"
#import "DFNotificationDefines.h"
#import "UIView+SYShape.h"
#import "DFPreference.h"
#import "DFColorDefine.h"
#import "DFTeachersViewController.h"
#import "DFMyCourseTableViewCell.h"
#import "DFCourseViewController.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "DFUserProfile.h"
#import "DFUrlDefine.h"
#import "SYHttpRequest.h"
#import "UIAlertView+SYExtension.h"
#import "DFCreateCourseViewController.h"
#import "DFCourseItem.h"

@interface DFMyCoursesViewController ()

@property(nonatomic, strong) NSMutableArray* courses;
@property(nonatomic, strong) NSMutableArray* animatingImages;
@property(nonatomic,strong) UIView* noCourseView;

@end

#define kTableViewHeight 105.0f
#define kTableViewSectionHeaderHeight 20.f

@implementation DFMyCoursesViewController
@dynamic courses;
@dynamic animatingImages;

- (void) setCourses:(NSMutableArray *)courses
{
    if (_courses != courses)
    {
        _courses = courses;
    }
}

- (NSMutableArray *) courses
{
    return _courses;
}

- (void) setAnimatingImages:(NSMutableArray *)animatingImages
{
    if (_animatingImages != animatingImages)
    {
        _animatingImages = animatingImages;
    }
}

- (NSMutableArray *) animatingImages
{
    return _animatingImages;
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
    
    [self registerObservers];
    [self configMyCustomNavigationBar];
    [self configMyTableView];
    [self requestMyCourses];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configMyCustomNavigationBar
{
    self.title = @"我的课程";
    if ([DFPreference sharedPreference].currentUser.role == DFUserRoleTeacher)
    {
        [self.customNavigationBar setRightButtonWithStandardTitle:@"创建课程"];
    }
}

- (void) rightButtonClicked:(id)sender
{
    DFCreateCourseViewController* controller = [[DFCreateCourseViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) configMyTableView
{
    self.tableView.rowHeight = kTableViewHeight;
    [self setClickToFetchMoreTableFooterView];
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    self.tableView.sectionHeaderHeight = kTableViewSectionHeaderHeight;
}

- (void) reloadDataForRefresh
{
    [self requestMyCourses];
}

#define kRegisterButtonMarginLeftRight 50

- (void) showNoCourseView
{
    if (self.noCourseView == nil)
    {
        self.noCourseView = [[UIView alloc] initWithFrame:self.tableView.frame];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 54, self.noCourseView.bounds.size.width, 40)];
        label.font = [UIFont systemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = RGBCOLOR(119, 119, 119);
        label.text = @"您还没有报名任何课程，赶紧去报名吧！";
        label.textAlignment = NSTextAlignmentCenter;
        [self.noCourseView addSubview:label];
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(kRegisterButtonMarginLeftRight, 116, self.noCourseView.bounds.size.width - 2 * kRegisterButtonMarginLeftRight, 36)];
        button.backgroundColor = kMainDarkColor;
        [button setTitle:@"现在去报名" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button addTarget:self action:@selector(gotoRegisterableTeachersViewController) forControlEvents:UIControlEventTouchUpInside];
        [button makeViewASCircle:button.layer withRaduis:3 color:kMainDarkColor.CGColor strokeWidth:1];
        [self.noCourseView addSubview:button];
        
        [self.view addSubview:self.noCourseView];
    }
}

- (void) hideNoCourseView
{
    [self.noCourseView removeFromSuperview];
    self.noCourseView = nil;
}

- (void) gotoRegisterableTeachersViewController
{
//    DFTeachersViewController* controller = [[DFTeachersViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
    
    DFCoursesViewController* controller = [[DFCoursesViewController alloc] initWithStyle:DFCourseStyleRegisterable];
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - observers

- (void) registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCourseAdded:) name:kNotificationNewCourseAdded object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newCourseAdded:) name:kNotificationRegisterCourseSucceed object:nil];
}

- (void) newCourseAdded:(NSNotification *)notification
{
    [self requestMyCourses];
}

- (void) requestMyCourses
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForMyCourses] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success)
        {
            [bself.courses removeAllObjects];
            
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            
            NSArray* cousesForStudent = [bself coursesWithInfos:[info objectForKey:@"signcourse"]];
            NSArray* cousesForTeacher = [bself coursesWithInfos:[info objectForKey:@"teachercourse"]];
            if (cousesForTeacher.count > 0)
            {
                [bself.courses addObject:cousesForTeacher];
            }
            if (cousesForStudent.count > 0)
            {
                [bself.courses addObject:cousesForStudent];
            }
            
            if (bself.courses.count > 1)
            {
                bself.tableView.sectionHeaderHeight = kTableViewSectionHeaderHeight;
            }
            else
            {
                bself.tableView.sectionHeaderHeight = 0;
            }
            [bself.tableView reloadData];
            
            [bself setTableFooterStauts:NO empty:(cousesForTeacher.count + cousesForStudent.count == 0)];
            if ([DFPreference sharedPreference].currentUser.role != DFUserRoleTeacher)
            {
                if (cousesForTeacher.count + cousesForStudent.count == 0)
                {
                    [bself showNoCourseView];
                }
                else
                {
                    [bself hideNoCourseView];
                }
            }
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
            
            [bself setTableFooterStauts:NO empty:YES];
        }
        
        [bself hideProgress];
        
    }];
    [self.requests addObject:request];
}

- (DFCourseItem *) courseItemForIndexPath:(NSIndexPath *)indexPath
{
    return [[self.courses objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.courses.count;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.tableView.frame.size.width, 20)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize:14];
    
    if (self.courses.count > 1 && section == 0)
    {
        label.text = @"  我教授的课程";
    }
    else
    {
        label.text = @"  我学习的课程";
    }
    return label;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.courses objectAtIndex:section] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFMyCourseTableViewCell* cell = (DFMyCourseTableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
    DFCourseItem* item = [self courseItemForIndexPath:indexPath];
    cell.gotoClassroomButton.hidden = item.hasFinished;
    switch ([DFPreference sharedPreference].currentUser.role) {
        case DFUserRoleTeacher:
            cell.gotoClassroomButton.selected = (indexPath.section == 0 ? NO : (item.classroomStatus == DFClassroomStatusDone));
            break;
        case DFUserRoleStudent:
            cell.gotoClassroomButton.selected = (item.classroomStatus == DFClassroomStatusDone);
            break;
            
        default:
            cell.gotoClassroomButton.hidden = YES;
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFCourseItem* item = [self courseItemForIndexPath:indexPath];
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (user.role == DFUserRoleTeacher)
    {
        DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:(indexPath.section == 0 ? DFCalendarModeEdit : DFCalendarModeRead)];
        controller.courseId = item.persistentId;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeRead];
        controller.courseId = item.persistentId;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (NSString *) emptyFooterTitle
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (user.role == DFUserRoleTeacher)
    {
        return @"您还没有开设任何课程，点击右上角按钮可创建课程";
    }
    else
    {
        return @"";
    }
}


@end
