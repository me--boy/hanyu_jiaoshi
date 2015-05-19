//
//  FriendsViewController.m
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFRelationshipsViewController.h"
#import "DFMessagesViewController.h"
#import "DFMessageViewController.h"
#import "SYStandardNavigationBar.h"
#import "DFNotificationDefines.h"
#import "SYHttpRequest.h"
#import "MobClick.h"
#import "DFPreference.h"
#import "SYBaseContentViewController+DFLogInOut.h"
#import "DFUserProfile.h"
#import "SYConstDefine.h"

@interface DFRelationshipsViewController ()

/**
 *  班级圈
 */
@property(nonatomic, strong) DFMessagesViewController* classCircleViewController;
/**
 *  最近联系人
 */
@property(nonatomic, strong) DFMessagesViewController* recentContactsViewController;

@end

@implementation DFRelationshipsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithUserId:(NSInteger)userId
{
    self = [super init];
    if (self)
    {
        self.userId = userId;
    }
    return self;
}
/**
 *  重写userId的set方法
 */
- (void) setUserId:(NSInteger)userId
{
    if (_userId != userId)
    {
        _userId = userId;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kNotificationNewsCountChanged object:nil];
        if ([DFPreference sharedPreference].currentUser.persistentId == userId)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newsCountChanged:) name:kNotificationNewsCountChanged object:nil];
        }
        
        self.recentContactsViewController.userId = userId;
        self.classCircleViewController.userId = userId;
    }
}

- (void) addObservers
{
    if (self.userId == [DFPreference sharedPreference].currentUser.persistentId)
    {
        [self registerLogInOutObservers];
    }
}

- (void) userDidLogin
{
    self.userId = [DFPreference sharedPreference].currentUser.persistentId;
}

- (void) userDidLogout
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configCustomNavigationBar];
    [self addObservers];
    [self resetBadgeCount];
    //友盟MobClick是统计的核心类
    [MobClick event:@"Friends"];
}

- (void) configCustomNavigationBar
{
    self.title = @"学习圈子";
    
    if (self.customTabBarController != nil)
    {
        self.customNavigationBar.leftButton.hidden = YES;
    }
}

- (void) newsCountChanged:(NSNotification *)notification
{
    [self resetBadgeCount];
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (self.currentTabIdx == 1)
    {
        if (user.newContactMessageCount > 0)
        {
            [self.currentTabBarViewController loadData];
        }
        user.newContactMessageCount = 0;
    }
    else if (self.currentTabIdx == 0)
    {
        if (user.newGroupMessageCount > 0)
        {
            [self.currentTabBarViewController loadData];
        }
        user.newGroupMessageCount = 0;
    }
}

- (void) resetBadgeCount
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (self.currentTabIdx != 0)
    {
        [self setBadgeCount:user.newGroupMessageCount forTabIdx:0];
    }
    if (self.currentTabIdx != 1)
    {
        [self setBadgeCount:user.newContactMessageCount forTabIdx:1];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *) tabBarViewControllers
{
    [self ensureSubTabBarViewController];
    
    return [NSArray arrayWithObjects:self.classCircleViewController, self.recentContactsViewController, nil];
}

- (void) ensureSubTabBarViewController
{
    if (self.classCircleViewController == nil)
    {
        self.classCircleViewController = [[DFMessagesViewController alloc] initWithStyle:DFMessageStyleGroup];
        self.classCircleViewController.userId = self.userId;
    }
    
    if (self.recentContactsViewController == nil)
    {
        self.recentContactsViewController = [[DFMessagesViewController alloc] initWithStyle:DFMessageStyleContact];
        self.recentContactsViewController.userId = self.userId;
    }
}

@end
