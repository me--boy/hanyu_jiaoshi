//
//  DFCreateCourseViewController.m
//  dafan
//
//  Created by iMac on 14-9-4.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCreateCourseViewController.h"
#import "DFCalendarView.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFCourseViewController.h"
#import "DFPreference.h"
#import "DFUserProfile.h"
#import "SYContextMenu.h"
#import "DFColorDefine.h"
#import "UIAlertView+SYExtension.h"
#import "DFCourseHoursItem.h"
#import "DFCalendarEvent.h"

@interface DFCreateCourseViewController ()<SYContextMenuDelegate>

@property (nonatomic, strong) UILabel* hoursSetLabel;
@property (nonatomic, strong) DFCalendarView* scrollView;

@property(nonatomic, strong) NSMutableArray* availableCourseItems;

@property (nonatomic, strong) UIButton* courseNameButton;
@property (nonatomic, strong) UIButton* beginDateTimeButton;
@property (nonatomic, strong) UIButton* endDateTimeButton;

@property(nonatomic, strong) UIView* pickerFrameView;
@property(nonatomic, strong) UIDatePicker* datePickerView;
@property(nonatomic, strong) NSDate* beginDate;
@property(nonatomic, strong) NSDate* endDate;

@property(nonatomic, strong) UITapGestureRecognizer* tapGesture;
//@property(nonatomic, strong) NSDate* pickedDate;

@property(nonatomic, strong) DFCourseHoursItem* currentCourseHoursItem; //mode == new

@end

@implementation DFCreateCourseViewController

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
    
    [self configCustomNavigationBar];
    [self requestAvailableCourses];
    [self initSubviews];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) configCustomNavigationBar
{
    self.title = @"创建课程";
    self.availableCourseItems = [NSMutableArray array];
    [self.customNavigationBar setRightButtonWithStandardTitle:@"预览"];
}

- (void) requestAvailableCourses
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAvailableCourses] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            NSArray* infos = [resultInfo objectForKey:@"info"];
            for (NSDictionary* info in infos)
            {
                DFCourseHoursItem* item = [[DFCourseHoursItem alloc] initWithAvailableCourseInfo:info];
                [bself.availableCourseItems addObject:item];
            }
            //            [bself.courseNameButton setTitle:[(DFCourseHoursItem *)bself.availableCourseItems.firstObject courseName] forState:UIControlStateNormal];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) initSubviews
{
    CGSize navigationSize = self.customNavigationBar.frame.size;
    
    self.scrollView = [[DFCalendarView alloc] initWithFrame:CGRectMake(0, navigationSize.height, navigationSize.width, self.view.frame.size.height - navigationSize.height) mode:DFCalendarModeNew];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.scrollView];
    
    [self initCourseNameViews];
    [self initClassPeriodViews];
    [self initCalendarViews];
    
}

- (void) initCourseNameViews
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 8, self.view.frame.size.width, 15)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = @"选择课程类型";
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = RGBCOLOR(117, 127, 129);
    [self.scrollView addSubview:nameLabel];
    
    self.courseNameButton = [[UIButton alloc] initWithFrame:CGRectMake(8, 26, self.view.frame.size.width - 16, 29)];
    self.courseNameButton.backgroundColor = [UIColor clearColor];
    [self.courseNameButton setBackgroundImage:[UIImage imageNamed:@"course_picker_bkg.png"] forState:UIControlStateNormal];
    [self.courseNameButton setTitle:@"选择课程" forState:UIControlStateNormal];
    self.courseNameButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.courseNameButton setTitleColor:RGBCOLOR(143, 161, 175) forState:UIControlStateNormal];
    [self.courseNameButton addTarget:self action:@selector(courseNameButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.courseNameButton];
    
    UIImageView* arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(282, 10, 14, 8)];
    arrowImageView.image = [UIImage imageNamed:@"course_time_arrow.png"];
    [self.courseNameButton addSubview:arrowImageView];
}

#define kContentMarginX 8.f
#define kTimeButtonWidth 132.f

- (void) initClassPeriodViews
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 71, self.view.frame.size.width, 15)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.textColor = RGBCOLOR(117, 127, 129);
    nameLabel.text = @"选择授课时间段(每节课时1小时)";
    [self.scrollView addSubview:nameLabel];
    
    self.beginDateTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(kContentMarginX, 91, kTimeButtonWidth, 29)];
    self.beginDateTimeButton.backgroundColor = [UIColor clearColor];
    self.beginDateTimeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.beginDateTimeButton setTitleColor:RGBCOLOR(143, 161, 175) forState:UIControlStateNormal];
    [self.beginDateTimeButton setBackgroundImage:[UIImage imageNamed:@"course_picker_bkg.png"] forState:UIControlStateNormal];
    [self.beginDateTimeButton setTitle:@"上课时间" forState:UIControlStateNormal];
    [self.beginDateTimeButton addTarget:self action:@selector(beginDateTimeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.beginDateTimeButton];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 28) / 2, 91, 28, 29)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBCOLOR(143, 161, 175);
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"-";
    [self.scrollView addSubview:label];
    
    UIImageView* arrowImageView0 = [[UIImageView alloc] initWithFrame:CGRectMake(103, 10, 14, 8)];
    arrowImageView0.image = [UIImage imageNamed:@"course_time_arrow.png"];
    [self.beginDateTimeButton addSubview:arrowImageView0];
    
    self.endDateTimeButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kContentMarginX - kTimeButtonWidth, 91, kTimeButtonWidth, 29)];
    self.endDateTimeButton.backgroundColor = [UIColor clearColor];
    self.endDateTimeButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.endDateTimeButton setTitleColor:RGBCOLOR(143, 161, 175) forState:UIControlStateNormal];
    [self.endDateTimeButton setBackgroundImage:[UIImage imageNamed:@"course_picker_bkg.png"] forState:UIControlStateNormal];
    [self.endDateTimeButton setTitle:@"下课时间" forState:UIControlStateNormal];
    [self.scrollView addSubview:self.endDateTimeButton];
    self.endDateTimeButton.enabled = NO;
    
    UIImageView* arrowImageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(103, 10, 14, 8)];
    arrowImageView1.image = [UIImage imageNamed:@"course_time_arrow.png"];
    [self.endDateTimeButton addSubview:arrowImageView1];
}

#define kCalendarOriginY 153.f

- (void) initCalendarViews
{
    self.hoursSetLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 134, self.view.frame.size.width, 15)];
    self.hoursSetLabel.backgroundColor = [UIColor clearColor];
    self.hoursSetLabel.font = [UIFont systemFontOfSize:14];
    self.hoursSetLabel.textColor = RGBCOLOR(117, 127, 129);
    self.hoursSetLabel.text = @"课时安排";
    [self.scrollView addSubview:self.hoursSetLabel];
    
    CGFloat endY = [self.scrollView drawDaysFromOriginY:kCalendarOriginY];
    
    [self initNoteLabelsAtOriginY:endY + 8];
}

- (void) courseNameButtonClicked:(id)sender
{
    NSMutableArray* items = [NSMutableArray array];
    
    NSInteger index = 0;
    for (DFCourseHoursItem* course in self.availableCourseItems)
    {
        SYContextMenuItem* menuItem = [[SYContextMenuItem alloc] init];
        menuItem.menutitle = course.courseName;
        menuItem.menuId = index;
        [items addObject:menuItem];
        ++index;
    }
    
    SYContextMenu* menu = [[SYContextMenu alloc] initWithTitle:@"选择课程" menuItems:items];
    menu.delegate = self;
    [menu showInView:self.view];
}

- (void) contextMenuDidDismiss:(SYContextMenu *)contextMenu
{
    
}

- (void) contextMenu:(SYContextMenu *)menu selectItem:(SYContextMenuItem *)item
{
    self.currentCourseHoursItem = [self.availableCourseItems objectAtIndex:item.menuId];
    self.currentCourseHoursItem.teacherUserId = [DFPreference sharedPreference].currentUser.persistentId;
    [self.courseNameButton setTitle:item.menutitle forState:UIControlStateNormal];
    self.scrollView.eventCountForNew = self.currentCourseHoursItem.hoursCount;
    self.hoursSetLabel.text = [NSString stringWithFormat:@"科时安排(共指定%d课时)", self.currentCourseHoursItem.hoursCount];
}

- (void) beginDateTimeButtonClicked:(id)sender
{
    [self showDatePicker];
}

- (void) initNoteLabelsAtOriginY:(CGFloat)originY
{
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, originY, self.view.frame.size.width - 16, 32)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:13];
    nameLabel.numberOfLines = 0;
    nameLabel.textColor = RGBCOLOR(117, 127, 129);
    nameLabel.text = @"灰色日期表示当天该时段已被其他课程占用\n选中日期设置或取消当天课时";
    [self.scrollView addSubview:nameLabel];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, nameLabel.frame.origin.y + nameLabel.frame.size.height + 18);
}

#pragma mark - date picker

//#define kBeginDatePicker 1024
//#define kEndDatePicker 1025

#define kTopButtonHeight 36
#define kTopButtonWidth 80
#define kTopButtonMarginHori 8
#define kTopButtonMarginVer 2

#define kDatePickerViewHeight 216

#define kDatePickerFrameViewHeight (kTopButtonHeight + kDatePickerViewHeight)

- (void) showDatePicker
{
    CGSize size = self.view.frame.size;
    
    self.pickerFrameView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height, size.width, kDatePickerFrameViewHeight)];
    self.pickerFrameView.backgroundColor = [UIColor whiteColor];
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kTopButtonMarginHori, kTopButtonMarginVer, kTopButtonWidth, kTopButtonHeight)];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelButton addTarget:self action:@selector(pickerCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerFrameView addSubview:cancelButton];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width - kTopButtonMarginHori - kTopButtonWidth, kTopButtonMarginVer, kTopButtonWidth, kTopButtonHeight)];
    //    okButton.tag = isBeginDate ? kBeginDatePicker : kEndDatePicker;
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [okButton addTarget:self action:@selector(pickerOKButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerFrameView addSubview:okButton];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopButtonHeight - 1, size.width, 1)];
    lineView.backgroundColor = RGBCOLOR(241, 241, 241);
    [self.pickerFrameView addSubview:lineView];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    NSMutableString* string = [[NSMutableString alloc] initWithString:[formatter stringFromDate:[NSDate date]]];
    NSInteger minutes = [[string substringFromIndex:3] integerValue];
    [string replaceCharactersInRange:NSMakeRange(3, 2) withString:(minutes >= 30 ? @"30" : @"00")];
    NSDate* date = [formatter dateFromString:string];
    
    self.datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kTopButtonHeight, size.width, kDatePickerViewHeight)];
    self.datePickerView.backgroundColor = [UIColor whiteColor];
    self.datePickerView.datePickerMode = UIDatePickerModeTime;
    self.datePickerView.minuteInterval = 30;
    self.datePickerView.date = date;
    [self.datePickerView addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.pickerFrameView addSubview:self.datePickerView];
    
    [self.view addSubview:self.pickerFrameView];
    
    self.tapGesture.enabled = YES;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        self.pickerFrameView.frame = CGRectMake(0, size.height - kDatePickerFrameViewHeight, size.width, kDatePickerFrameViewHeight);
        
    }];
}

- (void) dateChanged:(UIDatePicker *)birthdayPicker
{
//    self.pickedDate = birthdayPicker.date;
}

- (void) hidePickerFrameView
{
    [UIView animateWithDuration:0.15 animations:^{
        
        CGSize size = self.view.frame.size;
        self.pickerFrameView.frame = CGRectMake(0, size.height, size.width, kDatePickerFrameViewHeight);
        
    } completion:^(BOOL finished){
        
        self.tapGesture.enabled = NO;
        
        [self.datePickerView removeFromSuperview];
        self.datePickerView = nil;
        
        [self.pickerFrameView removeFromSuperview];
        self.pickerFrameView = nil;
    }];
}

- (void) addTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void) tapOnView:(UIGestureRecognizer *)gesture
{
    if (self.pickerFrameView.superview == self.view)
    {
        [self hidePickerFrameView];
    }
}

- (void) pickerOKButtonClicked:(UIButton *)button
{
    self.beginDate = self.datePickerView.date;
    self.endDate = [NSDate dateWithTimeInterval:(60 * 60.f) sinceDate:self.beginDate];
    self.currentCourseHoursItem.beginDate = self.beginDate;
    
    [self hidePickerFrameView];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm";
    
    NSString* beginDateText = [formatter stringFromDate:self.beginDate];
    NSString* endDateText = [formatter stringFromDate:self.endDate];
    self.currentCourseHoursItem.classPeriodText = [NSString stringWithFormat:@"%@-%@", beginDateText, endDateText];
    
    [self.beginDateTimeButton setTitle:beginDateText forState:UIControlStateNormal];
    [self.endDateTimeButton setTitle:endDateText forState:UIControlStateDisabled];
}

- (void) pickerCancelButtonClicked:(id)sender
{
    [self hidePickerFrameView];
}

#pragma mark - preview

- (void) rightButtonClicked:(id)sender
{
    if (self.currentCourseHoursItem.bookId <= 0)
    {
        [UIAlertView showWithTitle:@"课程名称" message:@"请选择课程名称～"];
        return;
    }
    if (self.beginDate == nil)
    {
        [UIAlertView showWithTitle:@"上课时间" message:@"请选择上课时间～"];
        return;
    }
    self.currentCourseHoursItem.beginDate = self.beginDate;
    NSArray* dates = [self.scrollView newDates];
    if (dates.count != self.currentCourseHoursItem.hoursCount)
    {
        [UIAlertView showWithTitle:@"课时设置" message:[NSString stringWithFormat:@"必须设置为%d个课时", self.currentCourseHoursItem.hoursCount]];
        return;
    }
    for (NSInteger idx = dates.count - 1; idx >= 0; --idx)
    {
        DFCalendarEvent* event = [self.currentCourseHoursItem.hoursEvents objectAtIndex:idx];
        event.date = [dates objectAtIndex:idx];
    }
    DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeNew];
    controller.hoursViewBeginDate = [NSDate date];
    controller.currentCourseHoursItem = self.currentCourseHoursItem;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
