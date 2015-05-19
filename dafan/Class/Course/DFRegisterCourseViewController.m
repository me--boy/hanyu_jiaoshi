//
//  DFRegisterCourseViewController.m
//  dafan
//
//  Created by iMac on 14-9-4.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFRegisterCourseViewController.h"
#import "SYBaseContentViewController+Keyboard.h"
#import "DFPreference.h"
//#import "AlixLibService.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFAppDelegate.h"
#import "SYPrompt.h"
#import "AlixPayOrder.h"
#import "DataVerifier.h"
#import "DFColorDefine.h"
#import "AlixPayResult.h"
#import "PartnerConfig.h"
#import "DFPayManager.h"
#import "DFPreference.h"
#import "DFNotificationDefines.h"
#import "UIAlertView+SYExtension.h"

@interface DFRegisterCourseViewController ()
@property (weak, nonatomic) IBOutlet UIButton *payWithNoInviteCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *payWithInviteCodeButton;
@property (weak, nonatomic) IBOutlet UITextField *inviteCodeField;

@property (weak, nonatomic) IBOutlet UILabel *courseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *classPeriodLabel;
@property (weak, nonatomic) IBOutlet UILabel *startClassDateLabel;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation DFRegisterCourseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) configCustomNavigationBar
{
    self.title = @"报名";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self registerKeyboardObservers];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self unregisterKeyboardObservers];
}

- (void) configSubviews
{
    self.courseNameLabel.text = [NSString stringWithFormat:@"欢迎报名%@课程", self.courseItem.courseName];
    self.teacherNameLabel.text = [NSString stringWithFormat:@"授课人：%@", self.courseItem.teacherName];
    self.classPeriodLabel.text = [NSString stringWithFormat:@"授课时间：%@", self.courseItem.classPeriodText];
    
    NSDate* firstDate = [[self.courseItem.hoursEvents firstObject] date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM月dd日";
    self.startClassDateLabel.text = [NSString stringWithFormat:@"预计开课时间：%@  %@", [formatter stringFromDate:firstDate], [self.courseItem.classPeriodText substringToIndex:5]];
    
    [self.payWithNoInviteCodeButton setTitle:[NSString stringWithFormat:@"我没有邀请码，支付%.2f元", self.courseItem.tuition] forState:UIControlStateNormal];
    
    [self.payWithInviteCodeButton setTitle:[NSString stringWithFormat:@"支付%d元", (self.courseItem.tuition - [DFPreference sharedPreference].inviteCodeWorth)] forState:UIControlStateNormal];
}

- (void) layoutView:(UIView *)view originY:(CGFloat)originY
{
    CGRect frame = view.frame;
    frame.origin.y = originY;
    view.frame = frame;
}

- (void) layoutSubviews
{
    CGSize size = self.view.frame.size;
    
    CGRect navigationFrame = self.customNavigationBar.frame;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = navigationFrame.size.height;
    scrollFrame.size.height = size.height - navigationFrame.size.height;
    self.scrollView.frame = scrollFrame;
    self.scrollView.contentSize = self.scrollView.bounds.size;
//
//    [self.courseNameLabel sizeToFit];
//    CGRect courseNameFrame = self.courseNameLabel.frame;
//    courseNameFrame.origin.x = (size.width - courseNameFrame.size.width) / 2;
//    self.courseNameLabel.frame = courseNameFrame;
//    
//    CGRect teacherFrame = self.teacherNameLabel.frame;
//    teacherFrame.origin.x = courseNameFrame.origin.x;
//    self.teacherNameLabel.frame = teacherFrame;
//    
//    CGRect classPeriodFrame = self.classPeriodLabel.frame;
//    classPeriodFrame.origin.x = courseNameFrame.origin.x;
//    self.classPeriodLabel.frame = classPeriodFrame;
//    
//    CGRect startClassDateFrame = self.startClassDateLabel.frame;
//    startClassDateFrame.origin.x = courseNameFrame.origin.x;
//    self.startClassDateLabel.frame = startClassDateFrame;
    
    [self layoutView:self.payWithNoInviteCodeButton originY:150.f];
    [self layoutView:self.payWithInviteCodeButton originY:222.f];
    [self layoutView:self.inviteCodeField originY:222.f];
    
    NSString* inviteCodePlaceHolderText = [NSString stringWithFormat:@"输入邀请码立省%d元", [DFPreference sharedPreference].inviteCodeWorth];
    self.inviteCodeField.placeholder = inviteCodePlaceHolderText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self addObservers];
    [self configCustomNavigationBar];
    [self configSubviews];
    [self layoutSubviews];
    //暂时隐藏邀请码
    self.inviteCodeField.hidden = YES;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewGestureRecognized:)];
    [self.scrollView addGestureRecognizer:tap];
}

- (void) scrollViewGestureRecognized:(UIGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.view];
    
    if (!(CGRectContainsPoint(self.customNavigationBar.frame, point) || CGRectContainsPoint(self.payWithInviteCodeButton.frame, point) || CGRectContainsPoint(self.payWithNoInviteCodeButton.frame, point) || CGRectContainsPoint(self.inviteCodeField.frame, point)))
    {
        [self.view endEditing:YES];
    }
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredCourse:) name:kNotificationRegisterCourseFinished object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registeredCourse:) name:kNotificationRegisterCourseSucceed object:nil];
}

- (void) registeredCourse:(NSNotification *)notification
{
    NSInteger courseId = [[notification.userInfo objectForKey:@"courseId"] integerValue];
    if (courseId == self.courseItem.courseId)
    {
        [self leftButtonClicked:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)payWithNoInviteCodeButtonClicked:(id)sender {
    
    if (self.inviteCodeField.isFirstResponder)
    {
        [self.inviteCodeField resignFirstResponder];
        return;
    }
    
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"0.01" forKey:@"money"];
    [dict setObject:[NSNumber numberWithInt:self.courseItem.courseId] forKey:@"course_id"];
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAliPay] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            NSString* params = [info objectForKey:@"params"];
            
            [[DFPayManager sharedPreference] payWithTradeNo:[info objectForKey:@"out_trade_no"] params:params forCourse:self.courseItem.courseId];
        }
        else
        {
            [UIAlertView showWithTitle:@"报名" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (IBAction)payWithInviteCodeButtonClicked:(id)sender
{
    NSString* inviteCode = [self.inviteCodeField text];
    if (inviteCode.length == 0)
    {
        [UIAlertView showNOPWithText:@"请输入邀请码"];
        return;
    }
    
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
//    [dict setObject:@"30.02" forKey:@"money"];
    [dict setObject:[NSNumber numberWithInt:self.courseItem.courseId] forKey:@"course_id"];
    [dict setObject:inviteCode forKey:@"invitecode"];
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAliPay] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"前往支付宝"];
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            NSString* params = [info objectForKey:@"params"];
            
            [[DFPayManager sharedPreference] payWithTradeNo:[info objectForKey:@"out_trade_no"] params:params forCourse:self.courseItem.courseId];
        }
        else
        {
            [UIAlertView showWithTitle:@"报名" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) keyboardWillChangeFrame:(CGRect)frame inDuration:(NSTimeInterval)duration
{
    
}

- (void) keyboardWithFrame:(CGRect)frame willHideInDuration:(NSTimeInterval)duration
{
    self.scrollView.contentOffset = CGPointZero;
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    self.scrollView.contentOffset = CGPointMake(0, 110);
}

@end
