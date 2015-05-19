//
//  DFChatRoomViewController.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChannelZoneViewController.h"
#import "SYScrolledTabBar.h"
#import "SYConstDefine.h"
#import "SYBaseNavigationController.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "UIAlertView+SYExtension.h"
#import "DFPreference.h"
#import "SYPrompt.h"
#import "DFNotificationDefines.h"
#import "DFColorDefine.h"
#import "DFChatMemberViewController.h"
#import "DFChatViewController.h"
#import "SYPopoverMenu.h"
#import "DFImportChatSubjectViewController.h"
#import "DFChannelSettingsViewController.h"
#import "SYFaceTextInputPanel.h"


@interface DFChannelZoneViewController ()<SYScrolledTabBarDelegate, SYPopoverMenuDelegate, DFChatViewControllerDelegate, DFChatMemberViewControllerDelegate>

@property(nonatomic, strong) UIView* higherContainerView;
@property(nonatomic, strong) UILabel* channelIDLabel;
@property(nonatomic, strong) UILabel* memberCountLabel;
@property(nonatomic, strong) UITextView* topicTextView;
@property(nonatomic, strong) UILabel* noTopicTipsLabel;

@property(nonatomic, strong) UIView* lowerContainerView;
@property(nonatomic, strong) SYScrolledTabBar* lowerTabBar;

@property(nonatomic, strong) DFChannelItem* originChannel;
@property(nonatomic, strong) DFChannelItem* detailChannel;
@property(nonatomic) NSInteger channelId;

@property(nonatomic, strong) NSMutableArray* members;
/**
 *  成员视图控制器
 */
@property(nonatomic, strong) DFChatMemberViewController* memberViewController;
/**
 *  聊天视图控制器
 */
@property(nonatomic, strong) DFChatViewController* chatViewController;

@property(nonatomic, strong) DFUserMemberItem* me;

@end

@implementation DFChannelZoneViewController

- (void) dealloc
{
    NSLog(@"ChannelZone, dealloc %@", self);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithChannelId:(NSInteger)channelId
{
    self = [super init];
    if (self)
    {
        self.channelId = channelId;
    }
    return self;
}

- (id) initWithChannelItem:(DFChannelItem *)channel
{
    self = [super init];
    if (self)
    {
        NSLog(@"ChannelZone, init %@", self);
        self.originChannel = channel;
        self.channelId = self.originChannel.persistendId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configCustomNavigationBar];
    [self initHigherViews];
    [self initLowerViews];
    
    [self initMe];
    
    [self requestChannelInfo];
    [self requestMembers:YES];
}

- (void) initMe
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    self.me = [[DFUserMemberItem alloc] init];
    self.me.userId = user.persistentId;
    self.me.nickname = user.nickname;
    
    self.me.avatarUrl = user.avatarUrl;
    self.me.provinceCity = user.city;
    self.me.member = user.member;
    self.me.userRole = user.role;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //使屏幕不锁屏
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
//    [self.chatViewController joinChannel];
    [self.chatViewController.faceTextInputPanel registerKeyboardObservers];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
//    [self.chatViewController exitChannel];
    [self.chatViewController.faceTextInputPanel unregisterKeyboardObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) leftButtonClicked:(id)sender
{
    [self stopTextVoiceChat];
    [super leftButtonClicked:nil];
}

- (void) stopTextVoiceChat
{
    [self.chatViewController stopChatroomSpeakTimer];
    [self.chatViewController exit];
}

#pragma mark - items

- (void) configMe:(NSDictionary *)info
{
    
    self.me.disableTextChat = [[info objectForKey:@"ban_chat"] integerValue] > 0;
    self.me.disableVoiceChat = [[info objectForKey:@"ban_voice"] integerValue] > 0;
}

- (void) requestChannelInfo
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForChannelInfo] postValues:@{@"id": [NSNumber numberWithInt:self.channelId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            bself.detailChannel = [[DFChannelItem alloc] initWithDetailDictionary:info];
            
            [bself reloadSubviews];
            
            [bself configMe:info];
            
            [self initPutChatsViewControllerOn];
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
    [self configCustomNavigationBar];
    
    self.topicTextView.text = self.detailChannel.topic;
    self.memberCountLabel.text = [NSString stringWithFormat:@"当前在线:%d", self.detailChannel.livingUserCount];
    self.channelIDLabel.text = [NSString stringWithFormat:@"频道ID:%d", self.detailChannel.persistendId];
}

- (void) initPutChatsViewControllerOn
{
    [self putChatViewControllerOn];
    [self.chatViewController joinChannel];
    [self.chatViewController startTextChat];
}

- (void) requestMembers:(BOOL)reload
{
    if (self.members == nil)
    {
        self.members = [NSMutableArray array];
    }
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForChannelMembers] postValues:@{@"channel_id": [NSNumber numberWithInt:self.channelId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            if (reload)
            {
                [bself.members removeAllObjects];
            }
            [bself reloadMembersWithDictionaries:[resultInfo objectForKey:@"info"]];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) reloadMembersWithDictionaries:(NSArray *)infos
{
    for (NSDictionary* info in infos)
    {
        DFUserMemberItem* member = [[DFUserMemberItem alloc] initWithDictionary:info];
        if (member.userId == self.me.userId)
        {
            self.me = member;
//            self.chatViewController.me = member;
        }
        [self.members addObject:member];
    }
    
    [self.members removeObject:self.me];
    [self.members insertObject:self.me atIndex:0];
    
    self.chatViewController.members = self.members;
    [self.memberViewController.tableView reloadData];
    self.memberCountLabel.text = [NSString stringWithFormat:@"当前在线人数:%d", self.members.count];
}

#pragma mark - custom navigation bar

- (void) configCustomNavigationBar
{
    self.title = self.detailChannel.title;
    
    if ([DFPreference sharedPreference].currentUser.persistentId == self.detailChannel.adminUserId)
    {
        [self.customNavigationBar setRightButtonWithStandardImage:[UIImage imageNamed:@"menu_more.png"]];
    }
    else
    {
        [self.customNavigationBar setRightButtonWithStandardTitle:@"举报"];
    }
}

- (void) rightButtonClicked:(id)sender
{
    if ([DFPreference sharedPreference].currentUser.persistentId == self.detailChannel.adminUserId)
    {
        SYPopoverMenuItem* importSubjectItem = [[SYPopoverMenuItem alloc] init];
        importSubjectItem.title = @"导入话题";
        importSubjectItem.image = [UIImage imageNamed:@"menu_import.png"];
        
        SYPopoverMenuItem* subjectConfigurationItem = [[SYPopoverMenuItem alloc] init];
        subjectConfigurationItem.title = @"频道设置";
        subjectConfigurationItem.image = [UIImage imageNamed:@"menu_settings.png"];
        
        SYPopoverMenu* menu = [[SYPopoverMenu alloc] initWithMenuItems:@[importSubjectItem, subjectConfigurationItem]];
        menu.delegate = self;
        [menu showFromView:self.customNavigationBar.rightButton];
    }
    else
    {
        [self reportSomeone];
    }
}

- (void) reportSomeone
{
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforReport] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [SYPrompt showWithText:@"您已举报成功，一经核实会进行处理!"];
        }
        else
        {
            [UIAlertView showWithTitle:@"举报" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) popoverMenu:(SYPopoverMenu *)menu select:(NSInteger)menuId
{
    switch (menuId) {
        case 0:
        {
            DFImportChatSubjectViewController* controller = [[DFImportChatSubjectViewController alloc] init];
            controller.channelId = self.detailChannel.persistendId;
            controller.defaultText = self.detailChannel.topic;
            [self presentViewController:controller animated:YES completion:^{}];
        }
            break;
            
        case 1:
        {
            DFChannelSettingsViewController* controller = [[DFChannelSettingsViewController alloc] initWithNibName:@"DFChannelSettingsViewController" bundle:[NSBundle mainBundle]];
            controller.channelInfo = self.detailChannel;
            SYBaseNavigationController* navigationController = [[SYBaseNavigationController alloc] initWithRootViewController:controller];
            [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - higher part

#define kHigherPartHeight 204.f
#define kHighBarHeight 32.f
#define kHighBarLabelWidth 90.f
#define kHighBarLabelMargin 10.f

- (void) initHigherViews
{
    CGSize navigationSize = self.customNavigationBar.frame.size;
    
    self.higherContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationSize.height, navigationSize.width, kHigherPartHeight)];
    [self.view addSubview:self.higherContainerView];
    //黑板
    UIImageView* bkgImageView = [[UIImageView alloc] initWithFrame:self.higherContainerView.bounds];
    bkgImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_blackboard.png"]];
//    bkgImageView.image = [UIImage imageNamed:@"bkg_blackboard.png"];
    [self.higherContainerView addSubview:bkgImageView];
    
    self.topicTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, navigationSize.width, kHigherPartHeight - kHighBarHeight)];
    self.topicTextView.backgroundColor = [UIColor clearColor];
    self.topicTextView.editable = NO;
    self.topicTextView.textColor = [UIColor whiteColor];
    self.topicTextView.font = [UIFont systemFontOfSize:13];
    [self.higherContainerView addSubview:self.topicTextView];
    
    self.noTopicTipsLabel = [[UILabel alloc] initWithFrame:self.topicTextView.frame];
    self.noTopicTipsLabel.textColor = [UIColor whiteColor];
    self.noTopicTipsLabel.backgroundColor = [UIColor clearColor];
    self.noTopicTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.noTopicTipsLabel.font = [UIFont systemFontOfSize:20];
    self.noTopicTipsLabel.text = @"～话题～";
    [self.higherContainerView addSubview:self.noTopicTipsLabel];
    if (self.topicTextView.text.length == 0)
    {
        self.noTopicTipsLabel.hidden = YES;
    }
    
    UIView* barView = [[UIView alloc] initWithFrame:CGRectMake(0, kHigherPartHeight - kHighBarHeight, navigationSize.width, kHighBarHeight)];
    barView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.higherContainerView addSubview:barView];
    
    self.channelIDLabel = [[UILabel alloc] initWithFrame:CGRectMake(kHighBarLabelMargin, 0, kHighBarLabelWidth, kHighBarHeight)];
    self.channelIDLabel.backgroundColor = [UIColor clearColor];
    self.channelIDLabel.textColor = [UIColor whiteColor];
    self.channelIDLabel.font = [UIFont systemFontOfSize:13];
    
    [barView addSubview:self.channelIDLabel];
    
    self.memberCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(navigationSize.width - kHighBarLabelMargin - kHighBarLabelWidth, 0, kHighBarLabelWidth, kHighBarHeight)];
    self.memberCountLabel.backgroundColor = [UIColor clearColor];
    self.memberCountLabel.textColor = [UIColor whiteColor];
    self.memberCountLabel.font = [UIFont systemFontOfSize:13];
    self.memberCountLabel.textAlignment = NSTextAlignmentRight;
    [barView addSubview:self.memberCountLabel];
}

#pragma mark - lower part

#define kTabBarHeight 26.f

- (void) initLowerViews
{
    CGRect higherFrame = self.higherContainerView.frame;
    
    self.lowerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, higherFrame.origin.y + higherFrame.size.height, higherFrame.size.width, self.view.frame.size.height - higherFrame.origin.y - higherFrame.size.height)];
    [self.view addSubview:self.lowerContainerView];
    
    [self initScrolledTabBar];
}

- (void) initScrolledTabBar
{
    self.lowerTabBar = [[SYScrolledTabBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTabBarHeight)];
    self.lowerTabBar.backgroundImageView.image = [UIImage imageNamed:@"scroll_bar_bg.png"];
    self.lowerTabBar.normalTitleColor = RGBCOLOR(51, 51, 51);
    self.lowerTabBar.selectedTitleColor = RGBCOLOR(51, 51, 51);
    self.lowerTabBar.indicatorColor = kMainDarkColor;
    self.lowerTabBar.delegate = self;
    [self.lowerContainerView addSubview:self.lowerTabBar];
    
    SYTabBarButtonItem* chatTabItem = [[SYTabBarButtonItem alloc] init];
    chatTabItem.title = @"公屏";
    
    SYTabBarButtonItem* memberTabItem = [[SYTabBarButtonItem alloc] init];
    memberTabItem.title = @"成员";
    
    self.lowerTabBar.selectedIndex = 0;
    
    self.lowerTabBar.tabButtonItems = [NSArray arrayWithObjects:chatTabItem, memberTabItem, nil];
    
    [self.lowerTabBar reloadData];
}

- (void) putChatViewControllerOn
{
    if (self.chatViewController == nil)
    {
        DFUserProfile* user = [DFPreference sharedPreference].currentUser;
        self.chatViewController = [[DFChatViewController alloc] initWithChatUserStyle:user.persistentId == self.detailChannel.adminUserId ? DFChatsUserStyleRoomAdministrator : DFChatsUserStyleRoomVisitor];
        self.chatViewController.navigationBarStyle = SYNavigationBarStyleNone;
        self.chatViewController.members = self.members;
//        self.chatViewController.me = self.me;
        self.chatViewController.channelInfo = self.detailChannel;
        self.chatViewController.controllerDelegate = self;
        self.chatViewController.textChatUrl = self.detailChannel.textChatUrl;
        self.chatViewController.voiceChannelId = self.detailChannel.voiceChannelId;
        [self addChildViewController:self.chatViewController];
    }
    if ([self.memberViewController isViewLoaded] && self.memberViewController.view.superview != nil)
    {
        [self.memberViewController.view removeFromSuperview];
    }
    
    self.chatViewController.view.frame = CGRectMake(0, self.lowerTabBar.frame.size.height, self.lowerTabBar.frame.size.width, self.lowerContainerView.frame.size.height - self.lowerTabBar.frame.size.height);
    [self.lowerContainerView addSubview:self.chatViewController.view];
    
    [self.chatViewController.faceTextInputPanel registerKeyboardObservers];
}

- (void) putMemberViewControllerOn
{
    [self.chatViewController.view removeFromSuperview];
    
    if (self.memberViewController == nil)
    {
        DFUserProfile* user = [DFPreference sharedPreference].currentUser;
        self.memberViewController = [[DFChatMemberViewController alloc] initWithChatUserStyle:user.persistentId == self.detailChannel.adminUserId ? DFChatsUserStyleRoomAdministrator : DFChatsUserStyleRoomVisitor];
        self.memberViewController.navigationBarStyle = SYNavigationBarStyleNone;
        self.memberViewController.members = self.members;
        self.memberViewController.channelId = self.detailChannel.persistendId;
        [self addChildViewController:self.memberViewController];
    }
    self.memberViewController.view.frame = CGRectMake(0, self.lowerTabBar.frame.size.height, self.lowerTabBar.frame.size.width, self.lowerContainerView.frame.size.height - self.lowerTabBar.frame.size.height);
    [self.lowerContainerView addSubview:self.memberViewController.view];
}

#pragma mark - scroll tabbar

- (void) scrolledTabBar:(SYScrolledTabBar *)tabbar selectIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            //显示聊天界面
            [self putChatViewControllerOn];
            break;
            
        case 1:
            //显示成员界面
            [self requestMembers:YES];
            [self putMemberViewControllerOn];
            break;
            
        default:
            break;
    }
    
    [self.lowerTabBar setIndicatorPositionFactor:index selectTab:YES];
}

#pragma mark - face input panel

- (void) roomMemberStatusChanged
{
    [self.memberViewController.tableView reloadData];
    self.memberCountLabel.text = [NSString stringWithFormat:@"当前在线人数:%d", self.members.count];
}

- (void) chatroomTopicChanged
{
    self.topicTextView.text = self.detailChannel.topic;
}

- (void) chatroomSettingsChanged
{
    self.title = self.detailChannel.title;
    
    self.originChannel.title = self.detailChannel.title;
    self.originChannel.imageUrl = self.detailChannel.imageUrl;
    self.originChannel.password = self.detailChannel.password;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationChannelSettingsUpdated object:nil userInfo:nil];
}

- (void) facePanel:(SYFaceTextInputPanel *)facePanel beginEditingForChatViewController:(DFChatViewController *)viewController
{
    CGRect lowerFrame = self.lowerContainerView.frame;
    lowerFrame.origin.y = facePanel.inputBarView.frame.origin.y - lowerFrame.size.height + facePanel.inputBarView.frame.size.height;
    self.lowerContainerView.frame = lowerFrame;
}

-(void) facePanel:(SYFaceTextInputPanel *)facePanel endEditingForChatViewController:(DFChatViewController *)viewController
{
    CGRect lowerFrame = self.lowerContainerView.frame;
    lowerFrame.origin.y = facePanel.inputBarView.frame.origin.y - lowerFrame.size.height;
    self.lowerContainerView.frame = lowerFrame;
}

- (void) leftRoomForError
{
    
}

#pragma mark - DFChatMemberViewControllerDelegate

- (void) refreshMemberForChatMemberViewController:(DFChatMemberViewController *)viewController
{
    [self requestMembers:YES];
}

@end
