//
//  DFCreateCourseViewController.m
//  dafan
//
//  Created by iMac on 14-8-19.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCourseViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"
#import "SYDeviceDescription.h"
#import "SYDashLineView.h"
#import "DFNotificationDefines.h"
#import "UIView+SYShape.h"
#import "SYContextMenu.h"
#import "SYHttpRequest.h"
#import "MBProgressHUD.h"
#import "DFCalendarEvent.h"
#import "DFColorDefine.h"
#import "DFUrlDefine.h"
#import "DFCalendarView.h"
#import "DFCourseIntroductionViewController.h"
#import "NSDate+SYExtension.h"
#import "DFPreference.h"
#import "DFRegisterCourseViewController.h"
#import "SYPrompt.h"
#import "DFCourseHoursItem.h"
#import "UIAlertView+SYExtension.h"
#import "UIImage+SYExtension.h"

@interface DFCourseViewController ()

//preview
@property(nonatomic, strong) DFCalendarView* scrollView;

@property(nonatomic, strong) UILabel* noteTitleLabel;
@property(nonatomic, strong) UILabel* noteLabel;
@property(nonatomic, strong) UIButton* courseActionButton;
@property(nonatomic, strong) UIButton* callButton;

@property(nonatomic) DFCalendarMode mode;

//edit


@end

@implementation DFCourseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithMode:(DFCalendarMode)mode
{
    self = [super init];
    if (self)
    {
        self.mode = mode;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObservers];
    [self initSubviews];
    [self configCustomNavigationBar];
    if (self.currentCourseHoursItem == nil)
    {
        [self requestCourseDetailInfo];
    }
    else
    {
        [self reloadSubviews];
    }
}

- (void) configCustomNavigationBar
{
    [self.customNavigationBar setRightButtonWithStandardTitle:@"课程介绍"];
}

- (void) rightButtonClicked:(id)sender
{
    DFCourseIntroductionViewController* controller = [[DFCourseIntroductionViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredCourse:) name:kNotificationRegisterCourseFinished object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredCourse:) name:kNotificationRegisterCourseSucceed object:nil];
}

- (void) registeredCourse:(NSNotification *)notification
{
    NSInteger courseId = [[notification.userInfo objectForKey:@"courseId"] integerValue];
    if (courseId == self.courseId && self.mode == DFCalendarModeRead)
    {
        [self.courseActionButton setTitle:@"已报名" forState:UIControlStateDisabled];
        [self setBottomButtonEnabled:NO];
    }
}

- (void) requestCourseDetailInfo
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCourseDetailInfo] postValues:@{@"course_id": [NSNumber numberWithInt:self.courseId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            bself.currentCourseHoursItem = [[DFCourseHoursItem alloc] initWithCourseDetailInfo:info];
            bself.hoursViewBeginDate = [(DFCalendarEvent *)self.currentCourseHoursItem.hoursEvents.firstObject date];
            
            [bself reloadSubviews];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) reloadSubviews
{
    self.title = self.currentCourseHoursItem.courseName;

    self.scrollView.events = self.currentCourseHoursItem.hoursEvents;
    
    CGFloat endY = [self.scrollView drawDaysFromOriginY:40.f];
    
    CGRect noteTitleFrame = self.noteTitleLabel.frame;
    CGRect noteFrame = self.noteLabel.frame;
    
    noteTitleFrame.origin.y = endY + 8;
    self.noteTitleLabel.frame = noteTitleFrame;
    
    noteFrame.origin.y = endY + 22.f;
    self.noteLabel.frame = noteFrame;
    
    
    NSString* hourTuitionText = [NSString stringWithFormat:@"¥%d/%d课时，", self.currentCourseHoursItem.tuition, self.currentCourseHoursItem.hoursCount];
    //授课时间
    NSString* pureText = [NSString stringWithFormat:@"%@授课时段均为 %@", hourTuitionText, self.currentCourseHoursItem.classPeriodText];
    NSMutableAttributedString* attributedText = [[NSMutableAttributedString alloc] initWithString:pureText];
    
    [attributedText setAttributes:@{UITextAttributeTextColor :  RGBCOLOR(171, 187, 200)} range:NSMakeRange(0, 6 + hourTuitionText.length)];
    [attributedText setAttributes:@{UITextAttributeTextColor : kMainDarkColor} range:NSMakeRange(6 + hourTuitionText.length, pureText.length - 6 - hourTuitionText.length)];
    self.noteLabel.attributedText = attributedText;
    
    self.courseActionButton.hidden = NO;
    NSDate* currentDate = [NSDate date];
    switch (self.mode) {
        case DFCalendarModeRead:
        {
            if ([DFPreference sharedPreference].currentUser.role == DFUserRoleTeacher)
            {
                CGRect scrollFrame = self.scrollView.frame;
                scrollFrame.size.height = self.view.frame.size.height - self.customNavigationBar.frame.size.height;
                self.scrollView.frame = scrollFrame;
                self.courseActionButton.hidden = YES;
            }
            else
            {
                if (self.currentCourseHoursItem.registered)
                {
                    [self.courseActionButton setTitle:@"已报名" forState:UIControlStateDisabled];
                }
                else
                {
                    if (([[self.currentCourseHoursItem.hoursEvents.firstObject date] earlierDate:currentDate] == currentDate))
                    {
                         [self.courseActionButton setTitle:@"报名已满" forState:UIControlStateDisabled];
                    }
                    else
                    {
                        [self.courseActionButton setTitle:@"报名已结束" forState:UIControlStateDisabled];
                    }
                }
            }
            
            [self setBottomButtonEnabled:[DFPreference sharedPreference].currentUser.role != DFUserRoleTeacher && !self.currentCourseHoursItem.registered && !self.currentCourseHoursItem.fullStrength && ([[self.currentCourseHoursItem.hoursEvents.firstObject date] earlierDate:currentDate] == currentDate)];
        }
            break;
        case DFCalendarModeEdit:
        {
            [self setBottomButtonEnabled:self.currentCourseHoursItem.teacherUserId == [DFPreference sharedPreference].currentUser.persistentId && ([[self.currentCourseHoursItem.hoursEvents.lastObject date] earlierDate:currentDate] == currentDate)];
            if (!self.courseActionButton.enabled)
            {
                [self.scrollView setItemDisabledForEditMode];
            }
        }
            break;
        case DFCalendarModeNew:
        {
            [self.scrollView setItemDisabledForEditMode];
            [self setBottomButtonEnabled:YES];
        }
            break;
            
        default:
            break;
    }
}


#define kBottomBarButtonMargin 20.f
#define kBottomBarMarginBottom 51.f
//#define kBottomBarButtonHeight 30.f

- (void) initSubviews
{
    CGSize navigationSize = self.customNavigationBar.frame.size;
    
    self.scrollView = [[DFCalendarView alloc] initWithFrame:CGRectMake(0, navigationSize.height, navigationSize.width, self.view.frame.size.height - navigationSize.height - 60) mode:(self.mode == DFCalendarModeNew ? DFCalendarModeEdit : self.mode)];
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.scrollView];
    
    
    //课程安排
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 20, self.view.frame.size.width, 16)];
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.text = @"课时安排";
    nameLabel.font = [UIFont systemFontOfSize:15];
    nameLabel.textColor = RGBCOLOR(117, 127, 129);
    [self.scrollView addSubview:nameLabel];
    
    if (self.mode != DFCalendarModeNew)
    {
        [nameLabel sizeToFit];
        CGRect nameFrame = nameLabel.frame;
        
        UILabel* modifyNoteLabel = [[UILabel alloc] initWithFrame:CGRectMake(nameFrame.origin.x + nameFrame.size.width + 2, 22, self.view.frame.size.width, 16)];
        modifyNoteLabel.backgroundColor = [UIColor clearColor];
        modifyNoteLabel.text = self.mode == DFCalendarModeEdit ? @"(按下拖动方块可修改课时安排，已开课则不可修改)" : @"(上课前15分钟才能进入课堂)";
        modifyNoteLabel.font = [UIFont systemFontOfSize:10];
        modifyNoteLabel.textColor = RGBCOLOR(117, 127, 129);
        [self.scrollView addSubview:modifyNoteLabel];
    }
    
    //课程说明
    self.noteTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 400, self.view.frame.size.width, 14)];
    self.noteTitleLabel.backgroundColor = [UIColor clearColor];
    self.noteTitleLabel.font = [UIFont systemFontOfSize:12];
    self.noteTitleLabel.text = @"课程说明";
    self.noteTitleLabel.textColor = RGBCOLOR(117, 127, 129);
    [self.scrollView addSubview:self.noteTitleLabel];
    
    //[学费]
    self.noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 422, self.view.frame.size.width, 15)];
    self.noteLabel.backgroundColor = [UIColor clearColor];
    self.noteLabel.font = [UIFont systemFontOfSize:13];
    self.noteLabel.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:self.noteLabel];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 460.f);
    //报名课程按钮
    self.courseActionButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.courseActionButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.courseActionButton setBackgroundImage:[UIImage imageWithColor:kMainDarkColor size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
    [self.courseActionButton setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(117, 127, 129) size:CGSizeMake(1, 1)] forState:UIControlStateDisabled];
    [self.courseActionButton addTarget:self action:@selector(courseActionButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.courseActionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:self.courseActionButton];
    //电话咨询按钮
    self.callButton = [[UIButton alloc] initWithFrame:CGRectZero];
    self.callButton.backgroundColor = [UIColor clearColor];
    self.callButton.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    self.callButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
    [self.callButton setTitle:@"电话咨询" forState:UIControlStateNormal];
    [self.callButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.callButton setImage:[UIImage imageNamed:@"icon_call.png"] forState:UIControlStateNormal];
    [self.callButton setBackgroundImage:[UIImage imageNamed:@"bkg_short_call.png"] forState:UIControlStateNormal];
    self.callButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.callButton addTarget:self action:@selector(callButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.callButton];
    
    if (self.mode == DFCalendarModeRead)
    {
        if ([DFPreference sharedPreference].currentUser.role == DFUserRoleTeacher)
        {
            self.courseActionButton.frame = CGRectMake(15, self.view.frame.size.height - 51, self.view.frame.size.width - 30, 43);
        }
        else
        {
            CGFloat buttonWidth = (self.view.frame.size.width - 2 * 15 - 9) / 2;
            self.courseActionButton.frame = CGRectMake(15, self.view.frame.size.height - 51, buttonWidth, 43);
            self.callButton.frame = CGRectMake(15 + buttonWidth + 9, self.view.frame.size.height - 51, buttonWidth, 43);
        }
        [self.courseActionButton setTitle:@"报名该课程" forState:UIControlStateNormal];
        self.courseActionButton.hidden = YES;
    }
    else
    {
        self.courseActionButton.frame = CGRectMake(15, self.view.frame.size.height - 51, self.view.frame.size.width - 30, 43);
        [self.courseActionButton setTitle:@"保存" forState:UIControlStateNormal];
        [self.courseActionButton setTitle:@"保存" forState:UIControlStateDisabled];
    }
}

- (void) callButtonClicked:(id)sender
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"电话咨询" message:@"呼叫 612-05-327 ？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        NSURL* telUrl = [NSURL URLWithString:@"tel://612052822"];
        [[UIApplication sharedApplication] openURL:telUrl];
    }
}

- (void) setBottomButtonEnabled:(BOOL)enabled
{
    self.courseActionButton.enabled = enabled;
    if (enabled)
    {
        self.courseActionButton.backgroundColor = kMainDarkColor;
        [self.courseActionButton makeViewASCircle:self.courseActionButton.layer withRaduis:3 color:kMainDarkColor.CGColor strokeWidth:1];
    }
    else
    {
        self.courseActionButton.backgroundColor = RGBCOLOR(117, 127, 129);
        [self.courseActionButton makeViewASCircle:self.courseActionButton.layer withRaduis:3 color:RGBCOLOR(117, 127, 129).CGColor strokeWidth:1];
    }
}

- (void) courseActionButtonClicked:(id)sender
{
    if (![[DFPreference sharedPreference] validateLogin:^{
        return NO;
    }])
    {
        return;
    }
    
    switch (self.mode) {
        case DFCalendarModeEdit:
        {
            [self updateCourseHours];
        }
            break;
        case DFCalendarModeNew:
        {
            [self createNewCourse];
        }
            break;
        case DFCalendarModeRead:
        {
            DFRegisterCourseViewController* controller = [[DFRegisterCourseViewController alloc] init];
            controller.courseItem = self.currentCourseHoursItem;
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void) updateCourseHours
{
    NSArray* editEvents = [self.scrollView editEvents];
    NSMutableArray* eventDicts = [NSMutableArray array];
    for (DFCalendarEvent* event in editEvents)
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionary];
        [dict setObject:[NSNumber numberWithInt:event.persistentId] forKey:@"id"];
        long timeInterval = [event.date timeIntervalSince1970];
        [dict setObject:[NSNumber numberWithLong:timeInterval] forKey:@"course_day"];
        [eventDicts addObject:dict];
    }
    
    NSError* error = nil;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:eventDicts options:NSJSONWritingPrettyPrinted error:&error];
    if (jsonData.length == 0)
    {
        [UIAlertView showNOPWithText:@"修改异常，请重新保存"];
        return;
    }
    
    NSString* jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    typeof(self) __weak bself = self;
    [self showProgress];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUpdateCourseHours] postValues:@{@"strhour": jsonString} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"修改课时成功"];
            [bself leftButtonClicked:nil];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationCourseInfoUpdated object:nil];
        }
        else
        {
            [UIAlertView showWithTitle:@"修改" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) popLast2ViewControllersForCreateCourse
{
    [self cancelAllRequest];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_progressActivity removeFromSuperview];
    
    if (self.navigationController.viewControllers.count >= 3)
    {
        UIViewController* controller = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3];
        [self.navigationController popToViewController:controller animated:YES];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void) createNewCourse
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    NSDateFormatter* timeFormatter = [[NSDateFormatter alloc] init];
    timeFormatter.dateFormat = @"HHmm";
    NSString* beginDateTimeText = [timeFormatter stringFromDate:self.currentCourseHoursItem.beginDate];
    
    NSMutableDictionary* dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:[NSNumber numberWithInt:self.currentCourseHoursItem.bookId] forKey:@"textbook_id"];
    [dictionary setObject:beginDateTimeText forKey:@"course_starttime"];
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    NSMutableString* hourTexts = [[NSMutableString alloc] init];
    for (DFCalendarEvent* event in self.currentCourseHoursItem.hoursEvents)
    {
        NSString* dateText = [dateFormatter stringFromDate:event.date];
        [hourTexts appendString:dateText];
        [hourTexts appendString:@","];
    }
    [hourTexts deleteCharactersInRange:NSMakeRange(hourTexts.length - 1, 1)];
    
    [dictionary setObject:hourTexts forKey:@"course_hour"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCreateNewCourse] postValues:dictionary finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"课程创建成功！"];
            [bself popLast2ViewControllersForCreateCourse];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewCourseAdded object:nil];
        }
        else
        {
            [UIAlertView showWithTitle:@"创建课程" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

@end
