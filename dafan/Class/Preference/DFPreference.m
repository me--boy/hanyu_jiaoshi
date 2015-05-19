//
//  DFPreference.m
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUrlDefine.h"
#import "SYHttpRequest.h"
#import "DFFilePath.h"
#import "DFNotificationDefines.h"
#import "UIAlertView+SYExtension.h"
#import "DFPreference.h"
#import "SYBaseNavigationController.h"
#import "DFAppDelegate.h"
#import "DFLoginViewController.h"

#define kAlertViewCheckLogin 1024
#define kAlertViewCheckupdate 1025

#define kKeyInviteCodeWorth @"inviteCodeWorth"
#define kKeyAgentReward @"agentReward"

static DFPreference* sSharedPreference = nil;

@interface DFPreference ()


@property(nonatomic, strong) NSMutableArray* requests;
@property(nonatomic, strong) DFUserProfile* currentUser;
@property(nonatomic, copy) processWhenHasLogout loginBlock;
@property(nonatomic) BOOL isThirdPartyLogin;
@property(nonatomic, strong) NSString* updatedUrl;

@property(nonatomic) NSInteger inviteCodeWorth;
@property(nonatomic) NSInteger agentReward;


@end

@implementation DFPreference


+ (DFPreference *) sharedPreference
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedPreference = [[DFPreference alloc] init];
    });
    return sSharedPreference;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id) allocWithZone:(NSZone *)zone
{
    //    return [[self class] sharedDeviceDescription];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedPreference = [super allocWithZone:zone];
    });
    return sSharedPreference;
}

#define kKeyCurrentUserId @"currentUserid"
#define kKeyLastPhoneNo @"lastPhoneNo"
#define kKeyLastPassword @"lastPassword"
#define kKeyThirdParty @"thirdParty"

- (id) init
{
    self = [super init];
    if (self)
    {
        //加载用户信息
        [self initFromUserDefaults];
        self.requests = [NSMutableArray array];
    }
    return self;
}

#pragma mark - user

- (void) initFromUserDefaults
{
    //确保这个路径的
    [SYFilePath ensureDirectory:[SYFilePath userDirectory]];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* userIdText = [userDefaults objectForKey:kKeyCurrentUserId];
    if (userIdText.length > 0)
    {
        NSString* userFilePath = [DFFilePath userProfilePathWithId:userIdText];
        self.currentUser = [[DFUserProfile alloc] initWithContentFilePath:userFilePath];
    }
    self.isThirdPartyLogin = ([userDefaults objectForKey:kKeyThirdParty] != nil);
    
    self.inviteCodeWorth = [[userDefaults objectForKey:kKeyInviteCodeWorth] integerValue];
    self.agentReward = [[userDefaults objectForKey:kKeyAgentReward] integerValue];
    if (self.inviteCodeWorth == 0)
    {
        self.inviteCodeWorth = 30;
    }
    if (self.agentReward == 0)
    {
        self.agentReward = 50;
    }
    
    self.lastPhoneNo = [userDefaults objectForKey:kKeyLastPhoneNo];
    self.lastPassword = [userDefaults objectForKey:kKeyLastPassword];
}

- (void) loginWithDictionary:(NSDictionary *)dict password:(NSString *)password
{
    self.currentUser = [[DFUserProfile alloc] initWithDictionary:dict];
    NSString* userIdText = [NSString stringWithFormat:@"%i", self.currentUser.persistentId];
    [self.currentUser writeToFile:[DFFilePath userProfilePathWithId:userIdText]];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userIdText forKey:kKeyCurrentUserId];
    [userDefaults setObject:password forKey:kKeyLastPassword];
    [userDefaults removeObjectForKey:kKeyThirdParty];
    [userDefaults setObject:self.currentUser.accountName forKey:kKeyLastPhoneNo];
    [userDefaults synchronize];
    
    self.isThirdPartyLogin = NO;
    self.lastPassword = password;
    self.lastPhoneNo = self.currentUser.accountName;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLogin object:nil];
    
    [self bindDeviceToken];
}

- (void) thirdPartyLogin:(NSDictionary *)dict
{
    self.isThirdPartyLogin = YES;
    
    self.currentUser = [[DFUserProfile alloc] initWithDictionary:dict];
    NSString* userIdText = [NSString stringWithFormat:@"%i", self.currentUser.persistentId];
    [self.currentUser writeToFile:[DFFilePath userProfilePathWithId:userIdText]];
    
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:userIdText forKey:kKeyCurrentUserId];
    [userDefaults setObject:@"1" forKey:kKeyThirdParty];
    [userDefaults synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLogin object:nil];
    
    [self bindDeviceToken];
}

- (void) logout
{
    NSInteger userId = self.currentUser.persistentId;
    self.currentUser = nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserLogout object:nil];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kKeyCurrentUserId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self unbindDeviceToken:userId];
}

- (BOOL) hasLogin
{
    return self.currentUser != nil && self.currentUser.persistentId > 0;
}

- (BOOL) validateLogin:(processWhenHasLogout)block
{
    if ([self hasLogin])
    {
        return YES;
    }
    
    self.loginBlock = block;
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"登录" message:@"登录后可继续，是否登录？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"登录", nil];
    alertView.delegate = self;
    alertView.tag = kAlertViewCheckLogin;
    [alertView show];
    
    return NO;
}
/**
 *  弹出登陆试图控制器
 */
- (void) presentLoginViewController
{
    UIViewController* controller = ((DFAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController;
    
    DFLoginViewController* loginController = [[DFLoginViewController alloc] init];
    SYBaseNavigationController* loginNavi = [[SYBaseNavigationController alloc] initWithRootViewController:loginController];
    
    [controller presentViewController:loginNavi animated:YES completion:^{}];
}

#pragma user aggreement

#define kKeyUserAgreement @"my_agreement_ok"

- (BOOL) userAgreeAgreement
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kKeyUserAgreement] length] > 0;
}

- (void) agreeAgreement
{
    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:kKeyUserAgreement];
}

#pragma mark - 

- (void) requestNewsCount
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForNewsCount] postValues:nil finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        if (succeed)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            bself.currentUser.newGroupMessageCount = [[info objectForKey:@"newclassmsg"] integerValue];
            bself.currentUser.newContactMessageCount = [[info objectForKey:@"newmsg"] integerValue];
            
            if (bself.currentUser.newGroupMessageCount + bself.currentUser.newContactMessageCount > 0)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsCountChanged object:nil];
            }
        }
        
    }];
    [self.requests addObject:request];
}

#pragma mark - 

- (void) setDeviceToken:(NSString *)deviceToken
{
    _deviceToken = deviceToken;
    [self bindDeviceToken];
}

- (void) bindDeviceToken
{
    if ([self hasLogin] && self.deviceToken.length > 0)
    {
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSetUserDeviceToken] postValues:@{@"igetcid": @"", @"device_token" : self.deviceToken} finished:^(BOOL success, NSDictionary* resultInfo, NSString* errorMessage){
            
            NSLog(@"MYUser bindDefaultGetuiClientId:%@", errorMessage);
            
        }];
        [self.requests addObject:request];
    }
}

- (void) unbindDeviceToken:(NSInteger)userId
{
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSetUserDeviceToken] postValues:@{@"userid": [NSNumber numberWithInt:userId], @"device_token" : @""} finished:^(BOOL success, NSDictionary* resultInfo, NSString* errorMessage){
        
        NSLog(@"MYUser unbindGetuiClientId, %@", errorMessage);
        
    }];
    [self.requests addObject:request];
}

//- (void) increaseNewFansCount
//{
//    self.newFansCount++;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsCountChanged object:nil];
//}
//
//- (void) increaseNewMessagesCount
//{
//    self.newMessageCount++;
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsCountChanged object:nil];
//}

//update

- (void) checkUpdate:(BOOL)alertWhenNewest completion:(void(^)(BOOL success))completion
{
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCheckUpdate] postValues:nil finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        if (succeed)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            
            self.updatedUrl = [info objectForKey:@"url"];
            if ([[info objectForKey:@"isupdate"] integerValue] != 0 && self.updatedUrl.length > 0)
            {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"版本更新" message:[resultInfo objectForKey:@"updatecontent"] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"前往更新", nil];
                alert.delegate = self;
                alert.tag = kAlertViewCheckupdate;
                [alert show];
            }
            else if (alertWhenNewest)
            {
                [UIAlertView showNOPWithText:@"已是最新版本"];
            }
        }
        else if (alertWhenNewest)
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
        completion(succeed);
    }];
    [self.requests addObject:request];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        switch (alertView.tag) {
            case kAlertViewCheckLogin:
                if (!self.loginBlock())
                {
                    [self presentLoginViewController];
                }
                break;
            case kAlertViewCheckupdate:
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.updatedUrl]];
                break;
                
            default:
                break;
        }
        
    }
}



- (void) setInviteCodeworth:(NSInteger)worthValue agentReward:(NSInteger)agentReward
{
    self.inviteCodeWorth = worthValue;
    self.agentReward = agentReward;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithInteger:worthValue] forKey:kKeyInviteCodeWorth];
    [defaults setObject:[NSNumber numberWithInteger:agentReward] forKey:kKeyAgentReward];
    [defaults synchronize];
}


@end
