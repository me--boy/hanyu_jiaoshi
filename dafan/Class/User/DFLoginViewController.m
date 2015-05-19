//
//  MYLoginViewController.m
//  MY
//
//  Created by iMac on 14-4-14.
//  Copyright (c) 2014年 halley. All rights reserved.
//

//#import <ShareSDK/ShareSDK.h>
#import <CoreText/CoreText.h>
#import "DFLoginViewController.h"
#import "SYHttpRequest.h"
#import "UIAlertView+SYExtension.h"
#import "UIView+SYShape.h"
#import "SYConstDefine.h"
#import "DFPreference.h"
#import "UMSocialAccountManager.h"
#import "DFUrlDefine.h"
#import "UMSocialSnsPlatformManager.h"
//#import "MYUserRegisterViewController.h"
#import "SYDeviceDescription.h"
#import "UMSocial.h"
#import "DFUserRegisterViewController.h"
#import "DFPasswordViewController.h"
#import "SYBaseContentViewController+Keyboard.h"

#import "DFColorDefine.h"

@interface DFLoginViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIScrollView* scrollContentView;
@property(nonatomic, strong) UITextField* mobileNoField;
@property(nonatomic, strong) UITextField* passwordField;

@property(nonatomic, strong) UIButton* remeberPasswordButton;

@property(nonatomic, strong) UITapGestureRecognizer* tapForView;

@end

@implementation DFLoginViewController

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
    
    [self registerKeyboardObservers];
    [self configCustomNavigationBars];
    [self initSubviews];
    [self configSubviews];
}

- (void) ensureTapGestureOnView
{
    if (self.tapForView == nil)
    {
        self.tapForView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
        self.tapForView.delegate = self;
        [self.view addGestureRecognizer:self.tapForView];
    }
}

- (void) hideKeyboard
{
    [self.mobileNoField resignFirstResponder];
    [self.passwordField resignFirstResponder];
}

- (void) tapOnView:(UIGestureRecognizer *)gesture
{
    [self hideKeyboard];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configCustomNavigationBars
{
    self.title = @"登录";
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    [self ensureTapGestureOnView];
    self.tapForView.enabled = YES;
    
    [UIView animateWithDuration:duration animations:^{
        
        CGRect scrollFrame = self.scrollContentView.frame;
        
        scrollFrame.origin.y = -50;
        self.scrollContentView.frame = scrollFrame;
        
    }];
}

- (void) keyboardWillChangeFrame:(CGRect)frame inDuration:(NSTimeInterval)duration
{
    [UIView animateWithDuration:duration animations:^{
        
        CGRect scrollFrame = self.scrollContentView.frame;
        
        scrollFrame.origin.y = -50;
        self.scrollContentView.frame = scrollFrame;
        
    }];
}

- (void) keyboardWithFrame:(CGRect)frame willHideInDuration:(NSTimeInterval)duration
{
    self.tapForView.enabled = NO;
    [UIView animateWithDuration:duration animations:^{
        
        self.scrollContentView.frame = self.view.bounds;
    }];
}

- (void) configSubviews
{
    DFPreference* prefer = [DFPreference sharedPreference];
    self.mobileNoField.text = prefer.lastPhoneNo;
    self.passwordField.text = prefer.lastPassword;
    
    if (prefer.lastPassword != nil)
    {
        self.remeberPasswordButton.selected = (prefer.lastPassword.length > 0);
    }
    else
    {
        self.remeberPasswordButton.selected = YES;
    }
}

#define kMarginLeft 25.f

- (void) initSubviews
{
    CGSize size = self.view.frame.size;
    
    //scrollview
    self.scrollContentView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollContentView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollContentView];
    
    //top image
    CGFloat offsetY = 174;
    SYDeviceDescription* device = [SYDeviceDescription sharedDeviceDescription];
    if (!device.isLongScreen)
    {
        offsetY = 134;
    }
    if (device.mainSystemVersion < 7)
    {
        offsetY -= 20;
    }
    
    UIView* frameView = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, offsetY, size.width - 2 * kMarginLeft, 110)];
    [self.scrollContentView addSubview:frameView];
    
    UIImageView* frameBkgView = [[UIImageView alloc] initWithFrame:frameView.bounds];
    frameBkgView.image = [UIImage imageNamed:@"login_input_frame.png"];
    [frameView addSubview:frameBkgView];
    
    UILabel* usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 46, 55)];
    usernameLabel.backgroundColor = [UIColor clearColor];
    usernameLabel.font = [UIFont systemFontOfSize:14];
    usernameLabel.textColor = [UIColor blackColor];
    usernameLabel.text = @"用户名";
    usernameLabel.textAlignment = NSTextAlignmentRight;
    [frameView addSubview:usernameLabel];
    
    self.mobileNoField = [[UITextField alloc] initWithFrame:CGRectMake(96, 2, 200, 55)];
    self.mobileNoField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.mobileNoField.keyboardType = UIKeyboardTypeNumberPad;
    self.mobileNoField.textColor = [UIColor blackColor];
    self.mobileNoField.font = [UIFont systemFontOfSize:14];
    self.mobileNoField.placeholder = @"请输入手机号码";
    [frameView addSubview:self.mobileNoField];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(6, 55, frameView.frame.size.width - 12, 1)];
    lineView.backgroundColor = RGBCOLOR(199, 199, 205);
    lineView.alpha = 0.8; 
    [frameView addSubview:lineView];
    
    UILabel* passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 55, 46, 55)];
    passwordLabel.backgroundColor = [UIColor clearColor];
    passwordLabel.font = [UIFont systemFontOfSize:14];
    passwordLabel.textColor = [UIColor blackColor];
    passwordLabel.text = @"密码";
    passwordLabel.textAlignment = NSTextAlignmentRight;
    [frameView addSubview:passwordLabel];
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(96, 55, 200, 55)];
    self.passwordField.keyboardType = UIKeyboardTypeNumberPad;
    self.passwordField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.passwordField.textColor = [UIColor blackColor];
    self.passwordField.font = [UIFont systemFontOfSize:14];
    self.passwordField.placeholder = @"请输入密码";
    self.passwordField.keyboardType = UIKeyboardTypeDefault;
    self.passwordField.secureTextEntry = YES;
    [frameView addSubview:self.passwordField];

    
    //loginbutton
    offsetY += frameView.frame.size.height + 47;
    UIButton* loginButton = [[UIButton alloc] initWithFrame:CGRectMake(kMarginLeft, offsetY, size.width - kMarginLeft * 2, 44)];
    loginButton.backgroundColor = kMainDarPinkColor;
    [loginButton makeViewASCircle:loginButton.layer withRaduis:3 color:kMainDarPinkColor.CGColor strokeWidth:1];
    [loginButton setTitle:@"登录" forState:UIControlStateNormal];
    [loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollContentView addSubview:loginButton];
    
    //---remember password button, find password button, register button
    offsetY += loginButton.frame.size.height + (device.isLongScreen ? 35 : 18);
    CGFloat offsetX = 0;
    CGFloat buttonWidth = size.width / 3;
    self.remeberPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, buttonWidth, 16)];
    self.remeberPasswordButton.backgroundColor = [UIColor clearColor];
    [self.remeberPasswordButton setTitle:@"记住密码" forState:UIControlStateNormal];
    self.remeberPasswordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.remeberPasswordButton setTitleColor:RGBCOLOR(119, 119, 119) forState:UIControlStateNormal];
    [self.remeberPasswordButton setImage:[UIImage imageNamed:@"login_save_password_normal.png"] forState:UIControlStateNormal];
    [self.remeberPasswordButton setImage:[UIImage imageNamed:@"login_save_password_selected.png"] forState:UIControlStateSelected];
    [self.remeberPasswordButton addTarget:self action:@selector(remeberPasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollContentView addSubview:self.remeberPasswordButton];
    
    offsetX += buttonWidth + 1;
    
    UIButton* findPasswordButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, buttonWidth, 16)];
    findPasswordButton.backgroundColor = [UIColor clearColor];
    [findPasswordButton setAttributedTitle:[self underlineString:@"忘记密码？"] forState:UIControlStateNormal];
    [findPasswordButton addTarget:self action:@selector(findPasswordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollContentView addSubview:findPasswordButton];
    
    offsetX += buttonWidth + 1;
    UIButton* registerButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, buttonWidth, 16)];
    registerButton.backgroundColor = [UIColor clearColor];
    [registerButton setAttributedTitle:[self underlineString:@"注册账户"] forState:UIControlStateNormal];
    [registerButton addTarget:self action:@selector(registerButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollContentView addSubview:registerButton];
    
    //weibo button
    offsetY = size.height - 48;
    
    UIView* borderView = [[UIView alloc] initWithFrame:CGRectMake(0, offsetY, size.width, 48)];
    [self.scrollContentView addSubview:borderView];
    
//    UIButton* weiboButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width / 3, 48)];
//    weiboButton.backgroundColor = [UIColor clearColor];
//    [weiboButton setImage:[UIImage imageNamed:@"login_weibo.png"] forState:UIControlStateNormal];
//    [weiboButton setTitle:@"微博登录" forState:UIControlStateNormal];
//    weiboButton.titleLabel.font = [UIFont systemFontOfSize:15];
//    [weiboButton  setTitleColor:RGBCOLOR(119, 119, 119) forState:UIControlStateNormal];
//    weiboButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    weiboButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    [weiboButton addTarget:self action:@selector(weiboLogin:) forControlEvents:UIControlEventTouchUpInside];
//    [borderView addSubview:weiboButton];
    
    CGRect qqFrame = CGRectZero;
    NSURL* weixinUrl = [NSURL URLWithString:@"weixin://"];
    if ([[UIApplication sharedApplication] canOpenURL:weixinUrl])
    {
        UIButton* wechatButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size.width / 2, 48)];
        wechatButton.backgroundColor = [UIColor clearColor];
        [wechatButton setImage:[UIImage imageNamed:@"login_wechat.png"] forState:UIControlStateNormal];
        [wechatButton setTitle:@"微信登录" forState:UIControlStateNormal];
        wechatButton.titleLabel.font = [UIFont systemFontOfSize:15];
        [wechatButton  setTitleColor:RGBCOLOR(119, 119, 119) forState:UIControlStateNormal];
        wechatButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        wechatButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        [wechatButton addTarget:self action:@selector(wechatLogin:) forControlEvents:UIControlEventTouchUpInside];
        [borderView addSubview:wechatButton];
        
        qqFrame = CGRectMake(size.width / 2, 0, size.width / 2, 48);
    }
    else
    {
        qqFrame = borderView.bounds;
    }
    

    //qq button
    UIButton* qqButton = [[UIButton alloc] initWithFrame:qqFrame];
    qqButton.backgroundColor = [UIColor clearColor];
    qqButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [qqButton  setTitleColor:RGBCOLOR(119, 119, 119) forState:UIControlStateNormal];
    [qqButton setImage:[UIImage imageNamed:@"login_qq.png"] forState:UIControlStateNormal];
    [qqButton setTitle:@"QQ登录" forState:UIControlStateNormal];
    qqButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    qqButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [qqButton addTarget:self action:@selector(qqLogin:) forControlEvents:UIControlEventTouchUpInside];
    [borderView addSubview:qqButton];
    
    self.scrollContentView.contentSize = CGSizeMake(size.width, offsetY + 48 + 16);
//    self.scrollContentView.contentOffset = CGPointMake(0, self.scrollContentView.contentSize.height - self.scrollContentView.frame.size.height);
}

- (NSAttributedString *)underlineString:(NSString *)string
{
    NSDictionary* attr = @{NSFontAttributeName:[UIFont systemFontOfSize:14], NSForegroundColorAttributeName:RGBCOLOR(51, 153, 255), NSUnderlineStyleAttributeName:[NSNumber numberWithInt:NSUnderlineStyleSingle]};
    return [[NSAttributedString alloc] initWithString:string attributes:attr];
}

- (void) wechatLogin:(id)sender
{
    [self hideKeyboard];
    
    typeof(self) __weak bself = self;
    [self showProgress];
    UMSocialSnsPlatform* platform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToWechatSession];
    platform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity* response){
        
        UMSocialAccountEntity* account = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToWechatSession];
        if (response.responseCode == UMSResponseCodeSuccess && account != nil)
        {
            //登陆成功
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"loginbysns"];
            [userDefaults synchronize];
            
            [bself loginByAccount:account type:7];
        }
        else
        {
            [bself hideProgress];
        }
        
    });
}

- (void) weiboLogin:(id)sender
{
    [self hideKeyboard];
    
    typeof(self) __weak bself = self;
    [self showProgress];
    UMSocialSnsPlatform* platform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    platform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity* response){
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            UMSocialAccountEntity* account = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
            
            //登陆成功
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setBool:YES forKey:@"loginbysns"];
            [userDefaults synchronize];
            
            [bself loginByAccount:account type:1];
        }
        else
        {
            [bself hideProgress];
        }
        
    });
}

- (void) qqLogin:(id)sender
{
    [self hideKeyboard];
    
    typeof(self) __weak bself = self;
    
    [self showProgress];
    UMSocialSnsPlatform* platform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
    
    platform.loginClickHandler(self, [UMSocialControllerService defaultControllerService], YES, ^(UMSocialResponseEntity* response){
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            UMSocialAccountEntity* account = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
            
            [bself loginByAccount:account type:6];
        }
        else
        {
            [bself hideProgress];
        }
        
    });
    
}

- (void) loginByAccount:(UMSocialAccountEntity *)account type:(NSInteger)type
{
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setObject:[account usid] forKey:@"snsid"];
    [info setObject:[NSNumber numberWithInt:type] forKey:@"snstype"]; //qq:6; sina:1 wechat:7
    //[request addPostValue:birthday forKey:@"birthday"];
    [info setObject:[account iconURL] forKey:@"avatar"];
    [info setObject:[account userName] forKey:@"nickname"];
    
    typeof(self) __weak bself = self;
    
//    [info setObject:[NSNumber numberWithInt:[userInfo gender]] forKey:@"gender"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForLoginBySns] postValues:info finished:^(BOOL success, NSDictionary* resultInfo, NSString* errorMessage)
                              {
                                  [bself dismissMe];
                                  if (success)
                                  {
                                      [[DFPreference sharedPreference] thirdPartyLogin:[resultInfo objectForKey:@"info"]];
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                              } 
                              ];
    
    [bself.requests addObject:request];
}



- (void) loginButtonClicked:(id)sender
{
    [self hideKeyboard];
    
    NSString* mobleNoText = [self validMobileNoText];
    if (mobleNoText.length == 0)
    {
        return;
    }
    
    NSString *password_txt=[self.passwordField text];
    
    if (password_txt.length < 6) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"请至少输入6位密码"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    [self showProgresWithText:@"正在登录" inView:self.view];
    
    
    NSMutableDictionary* info = [NSMutableDictionary dictionary];
    [info setObject:mobleNoText forKey:@"mobileno"];
    [info setObject:password_txt forKey:@"password"];
    
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForLogin] postValues:info finished:^(BOOL success, NSDictionary* resultInfo, NSString* errorMessage)
    {
       if (success)
       {
           [[DFPreference sharedPreference] loginWithDictionary:[resultInfo objectForKey:@"info"] password:(bself.remeberPasswordButton.selected ? password_txt : @"")];
           
           [bself dismissMe];
       }
       else
       {
           [UIAlertView showNOPWithText:errorMessage];
       }
        [bself hideProgress];
    }
     ];
    
    [self.requests addObject:request];
}

- (void) dismissMe
{
    [self leftButtonClicked:nil];
}

- (void) remeberPasswordButtonClicked:(id)sender
{
    self.remeberPasswordButton.selected = !self.remeberPasswordButton.selected;
    [self hideKeyboard];
}

- (void) findPasswordButtonClicked:(id)sender
{
    [self hideKeyboard];
    
    DFPasswordViewController* passwordController = [[DFPasswordViewController alloc] init];
    passwordController.passwordSetType = PasswordSetTypeFind;
    [self.navigationController pushViewController:passwordController animated:YES];
}

- (void) registerButtonClicked:(id)sender
{
    [self hideKeyboard];
    
    DFUserRegisterViewController* controller = [[DFUserRegisterViewController alloc] initWithNibName:@"DFUserRegisterViewController" bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
    
}

#pragma mark - check

- (NSString *) validMobileNoText
{
    NSString *mobileno_txt=[self.mobileNoField text];
    if (mobileno_txt.length != 11 || ![mobileno_txt hasPrefix:@"1"]) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"电话号码格式不对，请重新输入"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        return nil;
    }
    return mobileno_txt;
}

@end
