//
//  MYUserRegisterViewController.m
//  MY
//
//  Created by iMac on 14-5-23.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFUserRegisterViewController.h"
#import "UIView+SYShape.h"
#import "SYConstDefine.h"
#import "DFPreference.h"
#import "SYDeviceDescription.h"
#import "DFUserSettingsViewController.h"
#import "DFUrlDefine.h"
#import "SYHttpRequest.h"
#import "UIAlertView+SYExtension.h"
#import "SYPrompt.h"
#import "SYBaseContentViewController+Keyboard.h"
#import "DFColorDefine.h"
#import "DFAgreementViewController.h"

@interface DFUserRegisterViewController ()<UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *agreeUserAgreementButton;
@property (strong, nonatomic) IBOutlet UIView *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *userAgreementButton;
@property (weak, nonatomic) IBOutlet UITextField *nicknameField;
@property (weak, nonatomic) IBOutlet UITextField *genderField;
@property (weak, nonatomic) IBOutlet UITextField *mobileNoField;
@property (weak, nonatomic) IBOutlet UITextField *checkedCodeField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UITextField *confirmedPasswordField;
@property (weak, nonatomic) IBOutlet UIButton *genderPickedButton;
@property (weak, nonatomic) IBOutlet UIButton *randNicknameButton;
@property (weak, nonatomic) IBOutlet UIButton *sendCheckedCodeButton;
@property (weak, nonatomic) IBOutlet UIButton *helpButton;

@property (nonatomic, strong) UITapGestureRecognizer* tapGesture;

@property(nonatomic, strong) NSTimer* checkedCodeCountdownTimer;
@property(nonatomic, strong) UILabel* checkedCodeCountdownLabel;

@property(nonatomic) CGFloat keyboardHeight;

@end

@implementation DFUserRegisterViewController

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
    // Do any additional setup after loading the view from its nib.
    
    self.keyboardHeight = 216;
    
    [self registerKeyboardObservers];
    [self configCustomNavigationBar];
    
    [self configSubViews];
    [self initTapGesture];
}

- (void) configCustomNavigationBar
{
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
    [self.customNavigationBar.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
}

#define kMaxNicknameLength 12

- (void) rightButtonClicked:(id)sender
{
    if (!self.agreeUserAgreementButton.selected)
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"您还未勾选 \"我已阅读并同意用户使用协议\"\n同意后提交完成注册" delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
        [alert show];
        return;
    }
    
    NSString* mobileNo = [self validateMobileText];
    if (mobileNo.length == 0)
    {
        return;
    }
    if (self.checkedCodeField.text.length == 0)
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"请输入手机验证码"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    if (self.nicknameField.text.length > kMaxNicknameLength)
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"昵称过长"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        self.nicknameField.text = @"";
        [self.nicknameField becomeFirstResponder];
        return;
    }
    
    NSString* password = [self validatePassword];
    if (password.length == 0)
    {
        return;
    }
    
    typeof(self) __weak bself = self;
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:mobileNo forKey:@"mobileno"];
    [dict setObject:password forKey:@"password"];
    [dict setObject:self.checkedCodeField.text forKey:@"authcode"];
    [dict setObject:self.nicknameField.text forKey:@"nickname"];
    [dict setObject:(self.genderPickedButton.selected ? @"0" : @"1") forKey:@"gender"];
    
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUserRegister] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        [bself hideProgress];

        if (succeed)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            DFPreference* prefer = [DFPreference sharedPreference];
            [prefer loginWithDictionary:info password:(prefer.lastPassword != nil ? self.passwordField.text : @"")];
            [SYPrompt showWithText:@"注册、登录成功"];
            [bself popToUserSettingsOrDismissNavigationController];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
    }];
    
    [self.requests addObject:request];
}

- (void) popToUserSettingsOrDismissNavigationController
{
    SYBaseContentViewController* firstController = [self.navigationController.viewControllers firstObject];
    
    if ([firstController isKindOfClass:[DFUserSettingsViewController class]])
    {
        for (SYBaseContentViewController* controller in self.navigationController.viewControllers)
        {
            if (firstController != controller)
            {
                [controller prepareToClose];
            }
        }
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        for (SYBaseContentViewController* controller in self.navigationController.viewControllers)
        {
            [controller prepareToClose];
        }
        [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) leftButtonClicked:(id)sender
{
    
    [self.checkedCodeCountdownTimer invalidate];
    self.checkedCodeCountdownTimer = nil;
    
    [super leftButtonClicked:sender];
}

- (void) configSubViews
{
    self.title = @"注册新用户";

    [self relayoutSubviews];
    [self configTextFields];
    [self configButtons];
}

- (void) configButtons
{
    [self.randNicknameButton addTarget:self action:@selector(randNicknameButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.genderPickedButton addTarget:self action:@selector(genderPickedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.sendCheckedCodeButton addTarget:self action:@selector(sendCheckedCodeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.helpButton addTarget:self action:@selector(helpButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.agreeUserAgreementButton addTarget:self action:@selector(agreeUserAgreementButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.userAgreementButton addTarget:self action:@selector(userAgreementButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) randNicknameButtonClicked:(id)sender
{
    typeof(self) __weak bself = self;
    [self.randNicknameButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    self.randNicknameButton.enabled = NO;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForGetRandNickname] postValues:nil finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        if (succeed)
        {
            NSString* nickname = [[resultInfo objectForKey:@"info"] objectForKey:@"nickname"];
            if (nickname.length > kMaxNicknameLength)
            {
                bself.nicknameField.text = [nickname substringToIndex:kMaxNicknameLength];
            }
            else
            {
                bself.nicknameField.text = nickname;
            }
        }
        else
        {
            [SYPrompt showWithText:[resultInfo objectForKey:@"errormsg"]];
        }
        bself.randNicknameButton.enabled = YES;
        [bself.randNicknameButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    }];
    
    [self.requests addObject:request];
}

- (void) genderPickedButtonClicked:(id)sender
{
    self.genderPickedButton.selected = !self.genderPickedButton.selected;
    self.genderField.text = (self.genderPickedButton.selected ? @"女" : @"男");
}

- (void) startCheckedCodeCountDown
{
    if (self.checkedCodeCountdownLabel == nil)
    {
        CGSize size = self.sendCheckedCodeButton.frame.size;
        self.checkedCodeCountdownLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width - 20, 0, 14, size.height)];
        self.checkedCodeCountdownLabel.textAlignment = NSTextAlignmentCenter;
        self.checkedCodeCountdownLabel.backgroundColor = [UIColor clearColor];
        self.checkedCodeCountdownLabel.textColor = kMainDarkColor;
        self.checkedCodeCountdownLabel.font = [UIFont systemFontOfSize:9];
        self.checkedCodeCountdownLabel.text = @"60";
        [self.sendCheckedCodeButton addSubview:self.checkedCodeCountdownLabel];
    }
    
    self.checkedCodeCountdownLabel.tag = 60;
    [self.checkedCodeCountdownTimer invalidate];
    self.checkedCodeCountdownTimer = nil;
    self.sendCheckedCodeButton.enabled = NO;
    
    self.checkedCodeCountdownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkedCodeCountdown:) userInfo:nil repeats:YES];
}

- (void) checkedCodeCountdown:(id)timer
{
    if (self.checkedCodeCountdownLabel.tag > 0)
    {
        NSInteger currentLeftSeconds = --self.checkedCodeCountdownLabel.tag;
        
        self.checkedCodeCountdownLabel.text = [NSString stringWithFormat:@"%d", currentLeftSeconds];
        self.checkedCodeCountdownLabel.tag = currentLeftSeconds;
    }
    else
    {
        [self stopCheckedCodeTimer];
    }
}

- (void) stopCheckedCodeTimer
{
    [self.checkedCodeCountdownTimer invalidate];
    self.checkedCodeCountdownTimer = nil;
    self.sendCheckedCodeButton.enabled = YES;
    
    [self.checkedCodeCountdownLabel removeFromSuperview];
    self.checkedCodeCountdownLabel = nil;
}

- (void) sendCheckedCodeButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    NSString* noText = [self validateMobileText];
    if (noText.length > 0)
    {
        [self.view endEditing:YES];
        
        typeof(self) __weak bself = self;
        
        [self startCheckedCodeCountDown];
        
        NSDictionary* dict = [NSDictionary dictionaryWithObject:noText forKey:@"mobileno"];
        
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSendCheckCode] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
            
            if (succeed)
            {
                [SYPrompt showWithText:@"验证码已发送至手机，请查收"];
            }
            else
            {
                [UIAlertView showNOPWithText:errorMessage];
                [bself stopCheckedCodeTimer];
            }
            
        }];
        
        [self.requests addObject:request];
    }
}

- (void) helpButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
    controller.agreementStyle = DFAgreementStyleGetNoCheckCode;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) agreeUserAgreementButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    self.agreeUserAgreementButton.selected = !self.agreeUserAgreementButton.selected;
//    self.rightButton.enabled = self.agreeUserAgreementButton.selected;
}

- (void) userAgreementButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
    controller.agreementStyle = DFAgreementStyleUser;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) configTextFields
{
    self.genderField.delegate = self;
    self.nicknameField.delegate = self;
    self.mobileNoField.delegate = self;
    self.passwordField.delegate = self;
    self.confirmedPasswordField.delegate = self;
    self.checkedCodeField.delegate = self;
}

- (void) relayoutSubviews
{
    CGRect navigationFrame = self.customNavigationBar.frame;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = navigationFrame.size.height;
    scrollFrame.size.height = self.view.frame.size.height - scrollFrame.origin.y;
    self.scrollView.frame = scrollFrame;
    self.scrollView.contentSize = self.scrollView.bounds.size;
    
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion >= 7)
    {
        self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    }
    
//    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
//    {
//        CGRect inputsRect = self.inputsFrameView.frame;
//        inputsRect.origin.y = 72;
//        self.inputsFrameView.frame = inputsRect;
//        
//        CGRect agreeButtonFrame = self.agreeUserAgreementButton.frame;
//        CGRect agreementsFrame = self.userAgreementButton.frame;
//        agreeButtonFrame.origin.y = inputsRect.origin.y + inputsRect.size.height + 16;
//        agreementsFrame.origin.y = inputsRect.origin.y + inputsRect.size.height + 16;
//        self.agreeUserAgreementButton.frame = agreeButtonFrame;
//        self.userAgreementButton.frame = agreementsFrame;
//    }
    
    [self.randNicknameButton makeViewASCircle:self.randNicknameButton.layer withRaduis:3 color:kMainDarkColor.CGColor strokeWidth:1];
    [self.sendCheckedCodeButton makeViewASCircle:self.sendCheckedCodeButton.layer withRaduis:3 color:kMainDarkColor.CGColor strokeWidth:1];
    [self.helpButton makeViewASCircle:self.helpButton.layer withRaduis:3 color:kMainDarkColor.CGColor strokeWidth:1];
}

- (void) initTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    self.tapGesture.delegate = self;
    [self.scrollView addGestureRecognizer:self.tapGesture];
}


- (void) tapOnView:(UIGestureRecognizer *)tap
{
    
    
    [self.view endEditing:YES];
    
//    CGRect rect = self.inputsFrameView.frame;
//    rect.origin.y =  [SYDeviceDescription sharedDeviceDescription].mainSystemVersion < 7 ? 8 : 72;
//    self.inputsFrameView.frame = rect;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return self.genderField != textField;
}

#define kVSpace 50.f

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.nicknameField == textField)
    {
        return;
    }
    
    CGRect textFieldFrame = textField.frame;
    
    CGPoint contentOffset = self.scrollView.contentOffset;
    if (textFieldFrame.origin.y + textFieldFrame.size.height + self.keyboardHeight + kVSpace - contentOffset.y > self.scrollView.contentSize.height)
    {
        contentOffset.y = textFieldFrame.origin.y + textFieldFrame.size.height + self.keyboardHeight + kVSpace - self.scrollView.frame.size.height;
        self.scrollView.contentOffset = contentOffset;
    }
}

- (void) keyboardWithFrame:(CGRect)frame willHideInDuration:(NSTimeInterval)duration
{
    self.scrollView.contentOffset = CGPointZero;
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = frame.size.height;
}

- (void) keyboardWillChangeFrame:(CGRect)frame inDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = frame.size.height;
}

- (NSString *) validateMobileText
{
    NSString* mobileText = self.mobileNoField.text;
    if (mobileText.length != 11 || ![mobileText hasPrefix:@"1"]) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"电话号码格式不对，请重新输入"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        [self.mobileNoField becomeFirstResponder];
        return nil;
    }
    return mobileText;
}

- (NSString *) validatePassword
{
    NSString* passwordText = self.passwordField.text;
    NSString* confirmText = self.confirmedPasswordField.text;
    
    if (![passwordText isEqualToString:confirmText])
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"前后密码不对，请重新输入"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        self.confirmedPasswordField.text = @"";
        [self.confirmedPasswordField becomeFirstResponder];
        return nil;
    }
    if (passwordText.length < 6 || passwordText.length > 15)
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"密码长度不对"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        self.passwordField.text = @"";
        [self.passwordField becomeFirstResponder];
        return nil;
    }
    
    
    return passwordText;
}



@end
