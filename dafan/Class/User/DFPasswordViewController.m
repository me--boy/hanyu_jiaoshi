//
//  RegisterViewController.m
//  MY
//
//  Created by 胡少华 on 14-3-24.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFPasswordViewController.h"
#import "SYHttpRequest.h"
#import "UIView+SYAnimation.h"
#import "SYPrompt.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"
#import "UIView+SYShape.h"
#import "DFUrlDefine.h"
#import "UIAlertView+SYExtension.h"
#import "SYDeviceDescription.h"
#import "DFPreference.h"
#import "DFUserProfile.h"


@interface DFPasswordViewController ()<UITextFieldDelegate>


@property(nonatomic, strong) UITextField* mobileField;
@property(nonatomic, strong) UITextField* passwordFeild;
@property(nonatomic, strong) UITextField* confirmPasswordField;

@property(nonatomic, strong) UITextField* checkCodeField;

@property(nonatomic, strong) UIScrollView* scrollView;

@property(nonatomic, strong) UIButton* sendButton;
@property(nonatomic, strong) UILabel* checkCodeSendTips;
@property(nonatomic, strong) UIImageView* sendingImageView;
@property(nonatomic, strong) UILabel* leftSecondsLabel;
@property(nonatomic) NSInteger leftSeconds;
@property(nonatomic, strong) NSTimer* timer;

@end

@implementation DFPasswordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)setUpForDismissKeyboard {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    UITapGestureRecognizer *singleTapGR =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(tapAnywhereToDismissKeyboard:)];
    NSOperationQueue *mainQuene =[NSOperationQueue mainQueue];
    [nc addObserverForName:UIKeyboardWillShowNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view addGestureRecognizer:singleTapGR];
                    
                    
//                    [UIView animateWithDuration:0.2 animations:^{
//                        
//                        CGRect rect = self.scrollView.frame;
//                        rect.size.height = self.view.bounds.size.height - 216;
//                        self.scrollView.frame = rect;
//                    }];
//                    
                }];
    [nc addObserverForName:UIKeyboardWillHideNotification
                    object:nil
                     queue:mainQuene
                usingBlock:^(NSNotification *note){
                    [self.view removeGestureRecognizer:singleTapGR];
                    
                    [UIView animateWithDuration:0.2 animations:^{
                        
                        self.scrollView.frame = self.view.bounds;
                    }];
                }];
}

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect scrollFrame = self.scrollView.frame;


    if (self.checkCodeField == textField)
    {
        scrollFrame.origin.y = -80;
    }

    [UIView animateWithDuration:0.2 animations:^{
        self.scrollView.frame = scrollFrame;
    }];
    
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    
}

- (void)tapAnywhereToDismissKeyboard:(UIGestureRecognizer *)gestureRecognizer {
    //此method会将self.view里所有的subview的first responder都resign掉
    [self.view endEditing:YES];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self setUpForDismissKeyboard];
    [self configCustomNavigationBar];
    [self setupContentView];
}


- (void) configCustomNavigationBar
{
    switch (self.passwordSetType) {
        case PasswordSetTypeFind:
            self.title = @"找回密码";
            break;
        case PasswordSetTypeReset:
            self.title = @"修改密码";
            break;
        default:
            break;
    }
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
    [self.customNavigationBar.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
}

- (void) rightButtonClicked:(id)sender
{
    NSString* mobileNo = nil;
    if (self.passwordSetType != PasswordSetTypeReset)
    {
        mobileNo = [self validateMobileText];
        if (mobileNo.length == 0)
        {
            return;
        }
        if (self.checkCodeField.text.length == 0)
        {
            
        
            [UIAlertView showNOPWithText:@"请输入手机验证码"];
            
            self.confirmPasswordField.text = @"";
            [self.checkCodeField becomeFirstResponder];
            return;
        }
    }
    else
    {
        if (self.mobileField.text.length == 0)
        {
            [SYPrompt showWithText:@"旧密码不能为空"];
            [self.mobileField becomeFirstResponder];
            return;
        }
    }
    
    NSString* password = [self validatePassword];
    if (password.length == 0)
    {
        return;
    }
    
    NSMutableDictionary* params = [NSMutableDictionary dictionary];
    SYHttpRequest* request = nil;
    
    [self showProgress];
    typeof(self) __weak bself = self;
    switch (self.passwordSetType) {

        case PasswordSetTypeFind:
        {
            //请求数据
            [params setObject:mobileNo forKey:@"mobileno"];
            [params setObject:password forKey:@"password"];
            [params setObject:self.checkCodeField.text forKey:@"authcode"];
            
            request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForFindPassword] postValues:params finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
                
                if (success)
                {
                    [SYPrompt showWithText:@"密码已经找回，请使用新密码登录～"];
                    [bself leftButtonClicked:nil];
                }
                else
                {
                    [UIAlertView showNOPWithText:errorMsg];
                }
                
                [bself hideProgress];
                
            }];
            [self.requests addObject:request];

        }
            break;
        case PasswordSetTypeReset:
        {
            //请求数据
            [params setObject:self.mobileField.text forKey:@"oldpassword"];
            [params setObject:password forKey:@"newpassword"];
            request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUpdatePassword] postValues:params finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
                
                if (success)
                {
                    [SYPrompt showWithText:@"密码修改成功～"];
                    
                    [[DFPreference sharedPreference] loginWithDictionary:[resultInfo objectForKey:@"info"] password:password];
                    
                    [bself leftButtonClicked:nil];
                }
                else
                {
                    [UIAlertView showNOPWithText:errorMsg];
                }
                
                [bself hideProgress];
                
            }];
            [self.requests addObject:request];

        }
            break;
            
        default:
            [self hideProgress];
            break;
    }
}

#define kEntryHeight 48
#define kMarginLeft 16
#define kSpace 8

- (NSAttributedString *)underlineString:(NSString *)string
{
    NSDictionary* attr = @{NSFontAttributeName:[UIFont systemFontOfSize:12], NSForegroundColorAttributeName:RGBCOLOR(51, 153, 255), NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]};
    return [[NSAttributedString alloc] initWithString:string attributes:attr];
}

- (void) setupContentView
{
    CGFloat offsetY = 12;
    CGRect rect = self.customNavigationBar.frame;
    offsetY += rect.origin.y + rect.size.height;
    
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion < 7)
    {
        offsetY -= 8;
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    

    if (self.passwordSetType != PasswordSetTypeReset)
    {
        self.mobileField = [self entryForTag:@"手机号码" placeHolder:@"11位手机号码" offsetY:offsetY];
        self.mobileField.keyboardType = UIKeyboardTypeNumberPad;
        
        offsetY = self.mobileField.superview.frame.origin.y + self.mobileField.superview.frame.size.height;
        self.passwordFeild = [self entryForTag:@"密码" placeHolder:@"6到15位密码(限字符和数字)" offsetY:offsetY];
        self.passwordFeild.secureTextEntry = YES;
    }
    else
    {
        self.mobileField = [self entryForTag:@"旧密码" placeHolder:@"" offsetY:offsetY];
        self.mobileField.secureTextEntry = YES;
        
        offsetY = self.mobileField.superview.frame.origin.y + self.mobileField.superview.frame.size.height;
        self.passwordFeild = [self entryForTag:@"新密码" placeHolder:@"6到15位密码(限字符和数字)" offsetY:offsetY];
        self.passwordFeild.secureTextEntry = YES;
    }
    
    
    //===========
    offsetY = self.passwordFeild.superview.frame.origin.y + self.passwordFeild.superview.frame.size.height;
    self.confirmPasswordField = [self entryForTag:@"确认密码" placeHolder:@"6到15位密码(限字符和数字)" offsetY:offsetY];
    self.confirmPasswordField.secureTextEntry = YES;
    
    //===========
    if (self.passwordSetType != PasswordSetTypeReset)
    {
        
        
        offsetY = self.confirmPasswordField.superview.frame.origin.y + self.confirmPasswordField.superview.frame.size.height + kSpace;
        self.checkCodeField = [self entryForTag:@"验证码" placeHolder:@"手机验证码" offsetY:offsetY];
        self.checkCodeField.keyboardType = UIKeyboardTypeNumberPad;
        
        
        //===========
        [self addSendTextToPhone];
        
        offsetY = self.sendButton.frame.origin.y + self.sendButton.frame.size.height + kSpace + kSpace;
    }
    
    
    CGFloat contentHeight = offsetY;
    if (contentHeight < self.scrollView.frame.size.height)
    {
        contentHeight = self.scrollView.frame.size.height;
    }
    
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, contentHeight);
    
    [self.view addSubview:self.scrollView];
    
}



- (NSString *) validatePassword
{
    NSString* passwordText = self.passwordFeild.text;
    NSString* confirmText = self.confirmPasswordField.text;
    
    if (![passwordText isEqualToString:confirmText])
    {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"前后密码不对，请重新输入"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        self.confirmPasswordField.text = @"";
        [self.confirmPasswordField becomeFirstResponder];
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
        self.passwordFeild.text = @"";
        [self.passwordFeild becomeFirstResponder];
        return nil;
    }
    
    
    return passwordText;
}


#define kSendButtonWidth 180
#define kSendButtonX 70

- (NSAttributedString *) checkCodeTips
{
    NSDictionary* normalTextDict = @{NSFontAttributeName:[UIFont systemFontOfSize:11], NSForegroundColorAttributeName:RGBCOLOR(191, 191, 191)};
    NSDictionary* telTectDict = @{NSFontAttributeName:[UIFont systemFontOfSize:11], NSForegroundColorAttributeName:RGBCOLOR(112, 206, 220)};
    
    NSMutableAttributedString* tips = [[NSMutableAttributedString alloc] initWithString:@"验证码已发送至" attributes:normalTextDict];
    [tips appendAttributedString:[[NSAttributedString alloc] initWithString:self.mobileField.text attributes:telTectDict]];
    [tips appendAttributedString:[[NSAttributedString alloc] initWithString:@"的手机，请注意查收。有效时间约30分钟。" attributes:normalTextDict]];
    
    return tips;
}

- (void) addSendTextToPhone
{
    CGSize size = self.view.frame.size;
    
    CGFloat offsetY = self.checkCodeField.superview.frame.origin.y + self.checkCodeField.superview.frame.size.height + 16;
    
    self.checkCodeSendTips = [[UILabel alloc] initWithFrame:CGRectMake(67, offsetY, 188, 30)];
    self.checkCodeSendTips.backgroundColor = [UIColor clearColor];
    self.checkCodeSendTips.numberOfLines = 2;
    
//    self.checkCodeSendTips.hidden = YES;
//    [self.view addSubview:self.checkCodeSendTips];
    
    offsetY += 36;
    
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, offsetY, size.width, 48)];
    [self.sendButton setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.sendButton.backgroundColor = kMainDarkColor;
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.sendButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    self.sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [self.sendButton addTarget:self action:@selector(sendTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.sendingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(96, 14, 20, 20)];
    self.sendingImageView.image = [UIImage imageNamed:@"reg_refresh_icon.png"];
//    self.sendingImageView.backgroundColor = [UIColor whiteColor];
    self.sendingImageView.hidden = YES;
    [self.sendButton addSubview:self.sendingImageView];
    
    self.leftSecondsLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 17, 18, 14)];
    self.leftSecondsLabel.backgroundColor = [UIColor clearColor];
    self.leftSecondsLabel.font = [UIFont systemFontOfSize:12];
    self.leftSecondsLabel.textColor = [UIColor whiteColor];
    self.leftSecondsLabel.text = @"";
    [self.sendButton addSubview:self.leftSecondsLabel];
    
    [self.scrollView addSubview:self.sendButton];
}

- (NSString *) validateMobileText
{
    NSString* mobileText = self.mobileField.text;
    if (mobileText.length != 11 || ![mobileText hasPrefix:@"1"]) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"电话号码格式不对，请重新输入"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        [self.mobileField becomeFirstResponder];
        return nil;
    }
    return mobileText;
}

- (void) sendTextButtonClicked:(id)sender
{
    NSString* noText = [self validateMobileText];
    if (noText.length > 0)
    {
        [self.view endEditing:YES];
        
        NSDictionary* params = [NSDictionary dictionaryWithObject:noText forKey:@"mobileno"];
        
        typeof(self) __weak bself = self;
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSendCheckCode] postValues:params finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            if (success)
            {
                bself.checkCodeSendTips.attributedText = [self checkCodeTips];
                bself.checkCodeSendTips.hidden = NO;
                
                [SYPrompt showWithText:@"验证码已发送至手机，请查收"];
            }
            else
            {
                [bself stopTimerAndEnableButton];
                [UIAlertView showWithTitle:@"发送验证码" message:errorMsg];
            }
            [bself stopRotateIcon];
        }];
        [self.requests addObject:request];
        
        [self startTimerAndDisableButton];
        [self startRotateIcon];
    }
    
}

- (void) startRotateIcon
{
    self.sendingImageView.hidden = NO;
    [self.sendingImageView startRotate];
}

- (void) startTimerAndDisableButton
{
    self.sendButton.enabled = NO;
    
    [self startTimer];
}

- (void) startTimer
{
    self.leftSecondsLabel.text = @"60";
    self.leftSeconds = 60;
    if (self.timer != nil)
    {
        [self.timer invalidate];
    }
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(oneSecondPast) userInfo:nil repeats:YES];
}

- (void) oneSecondPast
{
    --self.leftSeconds;
    if (self.leftSeconds > 0)
    {
        self.leftSecondsLabel.text = [NSString stringWithFormat:@"%d", self.leftSeconds];
    }
    else
    {
        [self stopTimerAndEnableButton];
    }
}

- (void) stopTimer
{
    self.leftSeconds = 60;
    self.leftSecondsLabel.text = @"";
    [self.timer invalidate];
    self.timer = nil;
}

- (void) stopTimerAndEnableButton
{
    self.sendButton.enabled = YES;
    [self stopTimer];
}

- (void) stopRotateIcon
{
    [self.sendingImageView stopRoatate];
    self.sendingImageView.hidden = YES;
}


- (UITextField *) entryForTag:(NSString *)title placeHolder:(NSString *)placeHolder offsetY:(CGFloat)offsetY
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, kEntryHeight)];
    
    view.backgroundColor = [UIColor whiteColor];
    CGRect rect = view.bounds;
    
    rect.origin.x = kMarginLeft;
    UILabel* mobileNoLabel = [[UILabel alloc] initWithFrame:rect];
    mobileNoLabel.textColor = RGBCOLOR(96, 99, 102);
    mobileNoLabel.font = [UIFont systemFontOfSize:15];
    mobileNoLabel.text = title;
    mobileNoLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:mobileNoLabel];
    [mobileNoLabel sizeToFit];
    CGRect labelFrame = mobileNoLabel.frame;
    labelFrame.origin.y = (kEntryHeight - labelFrame.size.height) / 2;
    mobileNoLabel.frame = labelFrame;
    
    CGFloat offsetX = mobileNoLabel.frame.size.width + kMarginLeft;
    CGFloat width = rect.size.width - kMarginLeft - offsetX;
    UITextField* field = [[UITextField alloc] initWithFrame:CGRectMake(offsetX, (kEntryHeight - 38) / 2, width, 38)];
    field.font = [UIFont systemFontOfSize:15];
    field.textColor = [UIColor blackColor];
    field.placeholder = placeHolder;
    field.delegate = self;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.borderStyle = UITextBorderStyleNone;
    field.backgroundColor = [UIColor clearColor];
    field.textAlignment = NSTextAlignmentRight;
    [view addSubview:field];
    
    UIImageView* line = [[UIImageView alloc] initWithFrame:CGRectMake(0, kEntryHeight - 1, rect.size.width, 1)];
//    line.image = [UIImage imageNamed:@"reg_line.png"];
    line.backgroundColor = RGBCOLOR(233, 233, 233);
    [view addSubview:line];
    
    [self.scrollView addSubview:view];
    
    return field;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
