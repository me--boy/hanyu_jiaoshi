//
//  DFAppDelegate.m
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
//#import <UIKit/UIUserNotificationSettings.h>

#import "SYPrompt.h"
#import "MobClick.h"
#import "SYDeviceDescription.h"
#import "UIAlertView+SYExtension.h"
#import "DFMyCoursesViewController.h"
#import "DFMyIncomingViewController.h"
#import "DFChannelZoneViewController.h"
#import "DFClassroomViewController.h"
#import "DFTeacherCoursesViewController.h"
#import "DataVerifier.h"
#import "PartnerConfig.h"
#import "AlixPayResult.h"
//#import "UMSocialSinaHandler.h"
#import "DFPreference.h"
#import "DFAppDelegate.h"
#import "DFThirdPartyDefines.h"
#import "DFHomeTabController.h"
#import "UMSocial.h"
#import "DFVersionRelease.h"
#import "SYFilePath.h"
#import "DFPayManager.h"
#import "DFNotificationDefines.h"
#import "DFMessagesViewController.h"
#import "VoiChannelAPI.h"
#import "DFMessageViewController.h"
#import "SYBaseNavigationController.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFFilePath.h"
#import "SYHttpRequest.h"
#import "UMSocialWechatHandler.h"
#import "UMSocialQQHandler.h"

typedef NS_ENUM(NSInteger, DFRemoteNotification)
{
    DFRemoteNotificationNone = 0,
    DFRemoteNotificationMessage = 1,
    DFRemoteNotificationClassroom = 2,
    DFRemoteNotificationChatroom = 3,
    DFRemoteNotificationTeacher = 4,
    DFRemoteNotificationFilmClips = 5,
    DFRemoteNotificationMyCourse = 6,
    DFRemoteNotificationMyIncoming = 7,
    DFRemoteNotificationClasscircleMessage = 8,
    DFRemoteNotificationCount
};

@interface DFAppDelegate ()

@property(nonatomic, strong) NSMutableArray* requests;


@end

@implementation DFAppDelegate

- (void) skipBackupDirectoryToCloud
{
    NSString* voiceDirectoryPath = [SYFilePath voiceDirectoryPath];
    [SYFilePath ensureDirectory:voiceDirectoryPath];
    [SYFilePath addSkipBackupAttributeToItemAtPath:voiceDirectoryPath];
    
    NSString* dailyDirectoryPath = [DFFilePath dailiesDirectory];
    [SYFilePath ensureDirectory:dailyDirectoryPath];
    [SYFilePath addSkipBackupAttributeToItemAtPath:dailyDirectoryPath];
    
    NSString* audioDirectoryPath = [DFFilePath audiosDirectory];
    [SYFilePath ensureDirectory:audioDirectoryPath];
    [SYFilePath addSkipBackupAttributeToItemAtPath:audioDirectoryPath];
    
    NSString* homeCacheDirectoryPath = [DFFilePath homeCachesDirectory];
    [SYFilePath ensureDirectory:homeCacheDirectoryPath];
    [SYFilePath addSkipBackupAttributeToItemAtPath:homeCacheDirectoryPath];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.requests = [NSMutableArray array];
    
    [self registerUM];
    [self enableRemoteNotification];
    [self registerVoiceChannel];
    
    [self skipBackupDirectoryToCloud];
    
#ifdef AlphaVersion
    
//    [self redirectNSlogToDocumentFolder];
    
#endif
    
    [self requestUserInfo];
    
    UIWindow* window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window = window;
    
    DFHomeTabController* homeController = [[DFHomeTabController alloc] init];
    SYBaseNavigationController* rootViewController = [[SYBaseNavigationController alloc] initWithRootViewController:homeController];
    
    self.window.rootViewController = rootViewController;
    [self.window makeKeyAndVisible];
    //处理远程通知
    NSDictionary* remoteMessage = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    NSLog(@"%s, remoteMessage, %@", __FUNCTION__, remoteMessage);
    [self performActionForPushInfo:remoteMessage lanuching:YES];
    //检查版本更新
    [self performSelector:@selector(performActionsDelayable) withObject:nil afterDelay:3];
    
    return YES;
}

- (void) performActionsDelayable
{
    [[DFPreference sharedPreference] checkUpdate:NO completion:^(BOOL success) {
        
    }];
}

- (void)redirectNSlogToDocumentFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSString *fileName = [NSString stringWithFormat:@"dafan.log"];// 注意不是NSData!
    NSString *logFilePath = [documentDirectory stringByAppendingPathComponent:fileName];
    // 先删除已经存在的文件
    NSFileManager *defaultManager = [NSFileManager defaultManager];
    [defaultManager removeItemAtPath:logFilePath error:nil];
    [defaultManager createFileAtPath:logFilePath contents:nil attributes:nil];
    
    // 将log输入到文件
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stdout);
    freopen([logFilePath cStringUsingEncoding:NSASCIIStringEncoding], "a+", stderr);
}

- (void) registerUM
{
    [MobClick startWithAppkey:kUMengAppKey reportPolicy:SENDDAILY channelId:nil];
    [MobClick updateOnlineConfig];
    
    [UMSocialData setAppKey:kUMengAppKey];
    
//    [UMSocialWechatHandler setWXAppId:@"wx71aa44f231cfa080" appSecret:@"b0609767fd5755191da449f633367b1f" url:nil];
//    [UMSocialQQHandler setQQWithAppId:@"1102930163" appKey:@"4UZxiCR1O35lnW9B" url:@"http://www.umeng.com/social"];
    
    [UMSocialWechatHandler setWXAppId:@"wx12edeceea7099610" appSecret:@"19e4c80150c3aa8eb3230dd91d1861e5" url:@"http://www.umeng.com/social"];
    
    [UMSocialQQHandler setQQWithAppId:@"1104529176" appKey:@"045HGshwjNZUZEJv" url:@"http://www.umeng.com/social"];
    
//    [UMSocialQQHandler setSupportQzoneSSO:YES];
//    [UMSocialQQHandler setSupportWebView:YES];
//    [UMSocialSinaHandler openSSOWithRedirectURL:@"http://sns.whalecloud.com/sina2/callback"];
    
//    [UMSocialConfig setSupportSinaSSO:YES appRedirectUrl:@"http://sns.whalecloud.com/sina2/callback"];
}

- (void) requestUserInfo
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUserInfo] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            if (success)
            {
                [[DFPreference sharedPreference].currentUser updateWithDictionary:[resultInfo objectForKey:@"info"]];
            }
        }];
        [self.requests addObject:request];
    }
}

- (void) sendStartupRequest:(NSString *)deviceToken
{
//    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForStartup] postValues:@{@"device_token" : deviceToken} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            DFPreference* preference = [DFPreference sharedPreference];
            
            NSInteger inviteCodeWorth = [[info objectForKey:@"invitecode_money"] integerValue];
            NSInteger agentReward = [[info objectForKey:@"proxyprice"] integerValue];
            
            [preference setInviteCodeworth:inviteCodeWorth agentReward:agentReward];
            
            preference.privateMessageChatUrl = [info objectForKey:@"singlechat_url"];
        }
        
    }];
    [self.requests addObject:request];
}

- (void) registerVoiceChannel
{
    VoiChannelAPI* api = [VoiChannelAPI defaultAPI];
    [api setAppKey:@"967c3754-d921-4ae8-a518-9ca9b969de00"];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    application.applicationIconBadgeNumber = 0;
    
    [UMSocialSnsService applicationDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
//下面的两个方法功能类似
- (BOOL) application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    if (url != nil && [[url host] compare:@"safepay"] == 0)
    {
        [[DFPayManager sharedPreference] processAliPayWithURL:url];
    }
    else
    {
        //友盟的回调
        [UMSocialSnsService handleOpenURL:url];
    }
    return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if (url != nil && [url host] != nil && [[url host] compare:@"safepay"] == 0)
    {
        [[DFPayManager sharedPreference] processAliPayWithURL:url];
    }
    else
    {
        //友盟的回调
        [UMSocialSnsService handleOpenURL:url];
    }
    return YES;
}
//开启推送通知
- (void) enableRemoteNotification
{
#if !TARGET_IPHONE_SIMULATOR
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 7)
    {
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeAlert | UIUserNotificationTypeSound) categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    else
    {
        [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        UIRemoteNotificationType apnsType = UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeSound | UIRemoteNotificationTypeBadge;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:apnsType];
    }
    
#endif
}

- (void) disableRemoteNotificaton
{
    [[UIApplication sharedApplication] unregisterForRemoteNotifications];
}
//
//- (void) application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
//{
//    [application registerForRemoteNotifications];
//}

- (void) application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    
}
#pragma mark    远程推送通知

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *deviceTokenStr = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    deviceTokenStr = [deviceTokenStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    [self sendStartupRequest:deviceTokenStr];
    [DFPreference sharedPreference].deviceToken = deviceTokenStr;
}

- (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [self sendStartupRequest:@""];
    UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                   message:@"您将无法接收到推送通知"
                                                  delegate:self
                                         cancelButtonTitle:@"我知道了"
                                         otherButtonTitles:nil];
    [alert show];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    
    if (application.applicationIconBadgeNumber > 0)
    {
        [self performActionForPushInfo:userInfo lanuching:NO];
    }
    else
    {
        [self performTipsForPushInfo:userInfo];
    }
}

#pragma mark - alipay


#pragma mark - push

- (void) vibratePhone
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive)
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
    }
}
/**
 *  处理推送信息
 *
 *  @param info
 *  @param launch 
 */
- (void) performActionForPushInfo:(NSDictionary *)info lanuching:(BOOL)launch
{
    DFPreference* preference = [DFPreference sharedPreference];
    NSInteger type = [[info objectForKey:@"type"] integerValue];
    if (info == nil || type < 0 || ![preference hasLogin])
    {
        return;
    }
    if (type == 0)
    {
        NSString* prompt = [[info objectForKey:@"aps"] objectForKey:@"alert"];
        [SYPrompt showWithText:prompt];
        return;
    }
    
    DFPreference* prefer = [DFPreference sharedPreference];
    
    NSInteger optionId = [[info objectForKey:@"id"] integerValue];
    SYBaseNavigationController* rootViewController = (SYBaseNavigationController *)self.window.rootViewController;
    //取出跟控制器
    DFHomeTabController* homeController = rootViewController.viewControllers.firstObject;
    if (!launch)
    {
        [self vibratePhone];
        UIViewController* viewController = rootViewController.presentedViewController;
        [viewController dismissViewControllerAnimated:NO completion:^{}];
        
        for (NSInteger idx = rootViewController.viewControllers.count - 1; idx > 0; --idx)
        {
            SYBaseContentViewController* controller = [rootViewController.viewControllers objectAtIndex:idx];
            [controller closeMeAnimated:NO];
        }
    }
    switch (type) {
        
        case DFRemoteNotificationMessage:
        {
            if (prefer.hasLogin)
            {
                homeController.selectedIndex = DFTabBarIDRelationship;
                [homeController.relationshipsViewController selectTabAtIdx:1];
                if (!launch)
                {
                    [[homeController.relationshipsViewController tabBarViewControllerAtIndex:1] loadData];
                }
            }
        }
            break;
            
        case DFRemoteNotificationClasscircleMessage:
        {
            if (prefer.hasLogin)
            {
                homeController.selectedIndex = DFTabBarIDRelationship;
                [homeController.relationshipsViewController selectTabAtIdx:0];
                if (!launch)
                {
                    [[homeController.relationshipsViewController tabBarViewControllerAtIndex:0] loadData];
                }
            }
        }
            break;
            
        case DFRemoteNotificationChatroom:
        {
            DFChannelZoneViewController* controller = [[DFChannelZoneViewController alloc] initWithChannelId:optionId];
            [rootViewController pushViewController:controller animated:NO];
        }
            break;
            
        case DFRemoteNotificationClassroom:
        {
            DFClassroomViewController* controller = [[DFClassroomViewController alloc] initWithCourseId:optionId];
            [rootViewController pushViewController:controller animated:NO];
        }
            break;
            
        case DFRemoteNotificationTeacher:
        {
            DFTeacherCoursesViewController* controller = [[DFTeacherCoursesViewController alloc] initWithTeacherId:optionId];
            [rootViewController pushViewController:controller animated:NO];
        }
            break;
            
        case DFRemoteNotificationFilmClips:
        {
            homeController.selectedIndex = 1;
            [homeController.selfStudyViewController selectRight];
        }
            break;
            
        case DFRemoteNotificationMyCourse:
        {
            if (prefer.hasLogin)
            {
                DFMyCoursesViewController* controller = [[DFMyCoursesViewController alloc] init];
                [rootViewController pushViewController:controller animated:YES];
            }
        }
            break;
            
        case DFRemoteNotificationMyIncoming:
        {
            if (prefer.hasLogin)
            {
                DFMyIncomingViewController* controller = [[DFMyIncomingViewController alloc] init];
                [rootViewController pushViewController:controller animated:YES];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void) performTipsForPushInfo:(NSDictionary *)info
{
    DFPreference* preference = [DFPreference sharedPreference];
    NSInteger type = [[info objectForKey:@"type"] integerValue];
    if (type < 0 || ![preference hasLogin])
    {
        return;
    }
    
    NSString* prompt = [[info objectForKey:@"aps"] objectForKey:@"alert"];
    
    SYBaseNavigationController* rootViewController = (SYBaseNavigationController *)self.window.rootViewController;
    switch (type) {
        case DFRemoteNotificationMessage:
        {
            NSInteger userId = [[info objectForKey:@"id"] integerValue];

            DFHomeTabController* homeTabController = (DFHomeTabController *)rootViewController.viewControllers.firstObject; //首页
            DFRelationshipsViewController* relationshipViewController = homeTabController.relationshipsViewController;  //师友信息
            
            if (rootViewController.viewControllers.count > 1) //大于一层页面
            {
                DFMessagesViewController* contactsViewController = (DFMessagesViewController *)[relationshipViewController tabBarViewControllerAtIndex:1]; //最近联系人
                DFMessageViewController* privateMsgViewController = (DFMessageViewController *)[rootViewController.viewControllers objectAtIndex:1];;       //第二层页面
                if ([privateMsgViewController isKindOfClass:[DFMessageViewController class]] && privateMsgViewController.userId == userId)              //若是和这个人的聊天页面
                {
                    [contactsViewController updateNewMessage:prompt userId:userId unread:NO];
                }
                else
                {
                    [preference.currentUser increaseContactMessageCount];
                    preference.currentUser.needRequestContactMessages = YES;
                    [SYPrompt showWithText:prompt];
                }
                return;
            }
            
            if (homeTabController.selectedIndex != DFTabBarIDRelationship)
            {
                [preference.currentUser increaseContactMessageCount];
                preference.currentUser.needRequestContactMessages = YES;
                [SYPrompt showWithText:prompt];
                return;
            }
            
            if (relationshipViewController.currentTabIdx == 0)
            {
                [preference.currentUser increaseContactMessageCount];
                preference.currentUser.needRequestContactMessages = YES;
                [SYPrompt showWithText:prompt];
                return;
            }
            DFMessagesViewController* messageViewController = (DFMessagesViewController *)relationshipViewController.currentTabBarViewController;
            [messageViewController updateNewMessage:prompt userId:userId unread:YES];
            
        }
            break;
            
        case DFRemoteNotificationClasscircleMessage:
        {
            NSInteger classcircleId = [[info objectForKey:@"id"] integerValue];
            
            DFHomeTabController* homeTabController = (DFHomeTabController *)rootViewController.viewControllers.firstObject; //首页
            DFRelationshipsViewController* relationshipViewController = homeTabController.relationshipsViewController;  //师友信息
            
            if (rootViewController.viewControllers.count > 1) //大于一层页面
            {
                DFMessagesViewController* contactsViewController = (DFMessagesViewController *)[relationshipViewController tabBarViewControllerAtIndex:0]; //最近联系人
                DFMessageViewController* msgViewController = (DFMessageViewController *)[rootViewController.viewControllers objectAtIndex:1];;       //第二层页面
                if ([msgViewController isKindOfClass:[DFMessageViewController class]] && msgViewController.classCircleId == classcircleId)              //若是和这个人的聊天页面
                {
                    [contactsViewController updateNewMessage:prompt classcircleId:classcircleId unread:NO];
                }
                else
                {
                    [preference.currentUser increaseGroupMessageCount];
                    preference.currentUser.needRequestGroupMessages = YES;
                    [SYPrompt showWithText:prompt];
                }
                return;
            }
            
            if (homeTabController.selectedIndex != DFTabBarIDRelationship)
            {
                [preference.currentUser increaseGroupMessageCount];
                preference.currentUser.needRequestGroupMessages = YES;
                [SYPrompt showWithText:prompt];
                return;
            }
            
            if (relationshipViewController.currentTabIdx == 1)
            {
                [preference.currentUser increaseGroupMessageCount];
                preference.currentUser.needRequestGroupMessages = YES;
                [SYPrompt showWithText:prompt];
                return;
            }
            DFMessagesViewController* messageViewController = (DFMessagesViewController *)relationshipViewController.currentTabBarViewController;
            [messageViewController updateNewMessage:prompt classcircleId:classcircleId unread:NO];
        }
            
        default:
            break;
    }
}

@end
