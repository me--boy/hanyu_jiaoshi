//
//  DFChatViewController.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//


#import "DFChatViewController.h"
#import "SYConstDefine.h"
#import "DFChatItem.h"
#import "DFCommonImages.h"
#import "UIImageView+WebCache.h"
#import "DFChatTableViewCell.h"
#import "DFTypeEnum.h"
#import "SYBaseContentViewController+DFLogInOut.h"
#import "DFUserMemberItem.h"
#import "DFRatingTeacherPanel.h"
#import "VoiChannelAPI.h"
#import "GotyeTypeDefine.h"
#import "SYFaceTextInputPanel.h"
#import "DFPreference.h"
#import "UIView+SYShape.h"
#import "SYPrompt.h"
#import "DFMikeButton.h"
#import "RTMPClient.h"
#import "DFColorDefine.h"
#import "NSString+HTMLCoreText.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFChatUserContextMenuController.h"
#import "UIAlertView+SYExtension.h"
#import "DFNotificationDefines.h"
#import "DFVoiceAnimationView.h"

typedef NS_ENUM(NSInteger, DFConnectState) {
    DFConnectStateUnconnected,
    DFConnectStateConnecting,
    DFConnectStateUnconnecting,
    DFConnectStateConnected,
};

@interface DFChatViewController ()<UIAlertViewDelegate, VoiChannelAPIDelegate, IRTMPClientDelegate, SYFaceTextInputPanelDelegate, DFChatUserContextMenuControllerDelegate, DFMikeButtonDelegate>

@property(nonatomic, strong) NSMutableArray* chats;
@property(nonatomic, strong) UIView* footerView;

@property(nonatomic, strong) DFUserMemberItem* me;

@property(nonatomic, strong) UIView* tipsContainerView;
@property(nonatomic, strong) UILabel* tableHeaderLabel;
@property(nonatomic, strong) DFMikeButton* mikeButton;

@property(nonatomic, strong) DFVoiceAnimationView* voiceAnimatingView;
//@property(nonatomic, strong) UIButton* voiceAnimatingButton;
//@property(nonatomic, strong) UIImageView* voiceAnimatingImageView;

@property(nonatomic) DFChatsUserStyle userStyle;

@property(nonatomic, strong) VoiChannelAPI* apiInstance;

@property(nonatomic) DFConnectState channelConnectState;
//带有表情的键盘
@property(nonatomic, strong) SYFaceTextInputPanel* faceTextInputPanel;

//text chat
@property(nonatomic, strong) RTMPClient* rtmpClient;

@property(nonatomic) BOOL needReConnectRTMP; //连接失败是否重新连接

@property(nonatomic) BOOL firstConnectRTMP; //用于确定链接rtmpclient时，是否设置isreconnect为1
@property(nonatomic) NSInteger continueFailedCount;

@property(nonatomic) BOOL startTalk;

@property(nonatomic) NSInteger currentTalkingUserId;

@property(nonatomic) BOOL voiceChatEnabled;

@property(nonatomic) BOOL textChatEnabled;

@property(nonatomic, strong) NSString* disableVoiceChatTips;

@property(nonatomic, strong) NSString* disableTextChatTips;

@property(nonatomic, strong) DFChatUserContextMenuController* contextMenuController;

@property(nonatomic, strong) UIView* floatingVoicePanel;

@property(nonatomic, strong) UIImageView* floatingVoicePanelVolumnImageView;

@property(nonatomic) NSInteger voiceChannelJoinFailedCount;

@property(nonatomic, strong) NSTimer* speakTimer;

@end

@implementation DFChatViewController

- (void) dealloc
{
    [self.voiceAnimatingView removeFromSuperview];
    
    NSLog(@"DFChatViewController dealloc");
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithChatUserStyle:(DFChatsUserStyle)chatUserStyle
{
    self = [super init];
    if (self)
    {
        self.userStyle = chatUserStyle;
        self.classroomStatus = -1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self listenCall];
    
    self.firstConnectRTMP = YES;
    self.chats = [NSMutableArray array];
    
    [self addObservers];
    [self configTableView];
    [self initFooterView];
    [self initFaceTextInputPanel];
    [self initVoiceChannelAPI];
}

- (void) initVoiceChannelAPI
{
    self.apiInstance = [VoiChannelAPI defaultAPI];
    [self.apiInstance addListener:self];
}

- (void) setMembers:(NSMutableArray *)members
{
//    if (_members != members)
    {
        _members = members;
        
        for (DFUserMemberItem* member in members)
        {
            if (member.userId == [DFPreference sharedPreference].currentUser.persistentId)
            {
                self.me = member;
            }
        }
    }
}

- (void) joinChannel
{
//    if (self.channelConnectState == DFConnectStateUnconnected && self.voiceChannelId.length > 0)
    if (self.voiceChannelId.length > 0)
    {
        NSLog(@"%s", __FUNCTION__);
        [self loginVoiceChannel];
        
        [self.apiInstance stopTalking];
        
        [self showProgresWithText:@"实时语音连接中..." inView:self.view];
        self.channelConnectState = DFConnectStateConnecting;
//        [self.apiInstance joinChannel:self.voiceChannelId];
        
        GotyeChannelInfo *channel = [[GotyeChannelInfo alloc] init];
        channel.name = self.voiceChannelId;
        
        [self.apiInstance joinChannel:channel];
        
        NSLog(@"%s, end", __FUNCTION__);
    }
}

- (void) exitChannel
{
//    if (self.channelConnectState == DFConnectStateConnected)
    {
        NSLog(@"%s", __FUNCTION__);
        self.channelConnectState = DFConnectStateUnconnecting;
        [self.apiInstance exitChannel];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
            [[VoiChannelAPI defaultAPI] exit];
        
        });
    }
}

- (void) exit
{
    [self.apiInstance removeListener:self];
    
    [self exitChannel];
    
    [self stopTextChat];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - background foreground

- (void) applicationBecomeActive:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    [self connectRTMPClient];
    
    [self joinChannel];
    
}

- (void) applicationResignActive:(NSNotification *)notification
{
    [self disconnectRTMPClient];
    
    [self exitChannel];
}

- (void) applicationdidEnterForegound:(NSNotification *)notification
{
    self.needReConnectRTMP = YES;
}

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    self.needReConnectRTMP = NO;
}

- (void) addObservers
{
    NSNotificationCenter* notifiy = [NSNotificationCenter defaultCenter];

    [notifiy addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationResignActive:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationdidEnterForegound:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    
    [self registerLogInOutObservers];
}

- (void) userDidLogin
{
    //TODO:user login welcome
    NSLog(@"%s", __FUNCTION__);
    [_rtmpClient disconnect];
//    _rtmpClient = nil;
    [self connectRTMPClient];
}

#pragma mark - text chat

- (void) startTextChat
{
    if (self.textChatUrl.length > 0)
    {
        [self connectRTMPClient];
    }
}

- (void) stopTextChat
{
    if (self.textChatUrl.length > 0)
    {
        [self disconnectRTMPClient];
    }
}

-(void)connectRTMPClient
{
    if (_rtmpClient.connected)
    {
        return;
    }
    NSLog(@"%s, begin", __FUNCTION__);
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    DFPreference* preference = [DFPreference sharedPreference];
    DFUserProfile* user = preference.currentUser;
    if ([preference hasLogin])
    {
        [dict setObject:[NSNumber numberWithInteger:user.persistentId] forKey:@"userid"];
        
        [dict setObject:user.nickname forKey:@"nickname"];
        [dict setObject:[NSNumber numberWithInt:user.role] forKey:@"user_type"];
    }
    else
    {
        [dict setObject:@"0" forKey:@"userid"];
    }
    
    if (self.userStyle == DFChatsUserStyleRoomAdministrator || self.userStyle == DFChatsUserStyleRoomVisitor)
    {
        [dict setObject:[NSNumber numberWithInt:self.voiceChatEnabled ? 1 : 0] forKey:@"voice_chat_enabled"];
        [dict setObject:[NSNumber numberWithInt:self.textChatEnabled ? 1 : 0] forKey:@"text_chat_enabled"];
        [dict setObject:user.avatarUrl forKey:@"avatar"];
        [dict setObject:[NSNumber numberWithInt:user.member] forKey:@"vip_type"];
        if (user.city.length > 0)
        {
            [dict setObject:user.city forKey:@"city"];
        }
    }
    
    if (!self.firstConnectRTMP)
    {
        [dict setObject:[NSNumber numberWithInt:1] forKey:@"isreconnect"];
    }

    NSArray* param = [NSArray arrayWithObject:dict];
    if (_rtmpClient != nil)
    {
        NSLog(@"%s, connect nonnil", __FUNCTION__);
        
        [_rtmpClient connect:self.textChatUrl andParams:param];
        if (![_rtmpClient isDelegate:self])
        {
            _rtmpClient.delegate = self;
        }
    }
    else
    {
        NSLog(@"%s, connect nil", __FUNCTION__);
        _rtmpClient = [[RTMPClient alloc] init:self.textChatUrl andParams:param];
        _rtmpClient.delegate = self;
        [_rtmpClient connect];
    }
    NSLog(@"%s, end", __FUNCTION__);
}

- (void) disconnectRTMPClient
{
    NSLog(@"%s, disconnect, begin", __FUNCTION__);
    if ([_rtmpClient isDelegate:self])
    {
        NSLog(@"%s, disconnect, remove delegate", __FUNCTION__);
        [_rtmpClient removeDelegate:self];
    }
    
    if ([_rtmpClient connected])
    {
        NSLog(@"%s, disconnect, disconnect", __FUNCTION__);
        [_rtmpClient disconnect];
    }
//    _rtmpClient = nil;
    NSLog(@"%s, disconnect, end", __FUNCTION__);
}

- (void) connectedEvent
{
    NSLog(@"%s", __FUNCTION__);
    if (self.firstConnectRTMP)
    {
        self.firstConnectRTMP = NO;
    }
    self.continueFailedCount = 0;
    self.needReConnectRTMP = NO;
}

- (void) disconnectedEvent
{
    NSLog(@"%s", __FUNCTION__);
//    _rtmpClient = nil;
}

- (void) connectFailedEvent:(int)code description:(NSString *)description
{
    ++self.continueFailedCount;
    NSLog(@"%s, %d (%@) %@ ", __FUNCTION__, code, (self.needReConnectRTMP ? @"need" : @"noneed"), description);
    if (self.continueFailedCount <= 5 && code == -7)
    {
        self.needReConnectRTMP = YES;
        [self performSelector:@selector(reConnectRTMPClient) withObject:nil afterDelay:0.15];
    }
    else
    {
        [SYPrompt showWithText:@"请检查网络情况后重新进入！"];
        self.needReConnectRTMP = NO;
    }
}

- (void) reConnectRTMPClient
{
    NSLog(@"%s, (%@)", __FUNCTION__, (self.needReConnectRTMP ? @"need" : @"noneed"));
//    [self disconnectRTMPClient];
    if (self.needReConnectRTMP)
    {
        NSLog(@"%s, reconnect", __FUNCTION__);
        [self connectRTMPClient];
        self.needReConnectRTMP = NO;
    }
}

#pragma mark - voice

- (void) loginVoiceChannel
{
    NSLog(@"%s", __FUNCTION__);
    
    DFPreference* preference = [DFPreference sharedPreference];
    if ([preference hasLogin])
    {
        NSString *userId = [NSString stringWithFormat:@"%i", preference.currentUser.persistentId];
//        NSString *passWord = preference.currentUser
        NSString *nickName = preference.currentUser.nickname;
        
        GotyeLoginInfo *loginInfo = [[GotyeLoginInfo alloc] initWithUserId:userId password:nil nickname:nickName];
        
//        GotyeLoginInfo* loginInfo = [[GotyeLoginInfo alloc] initWithUserId:[NSString stringWithFormat:@"%i", preference.currentUser.persistentId] nickname:preference.currentUser.nickname];
        
        [self.apiInstance setLoginInfo:loginInfo];    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table

#define kFooterHeight 44.f
#define kMikeButtonSize 73.f
#define kMikeButtonMarginRight 17.f

#pragma mark - chat items

#define kCellMarginLeftRight 6.f
#define kCellMarginTop 2.f
#define kCellAvatarTextSpace 6.f
#define kCellMarginBottom 9.f //
#define kCellTextMarginTop 7.f

#define kTableHeaderHeight 44.f

#define kChatTableCellReuseId @"ChatTableCell"

#define kVoiceAnimatingButtonSize 96

- (void) startVoiceAnimating
{
    if (self.voiceAnimatingView == nil)
    {
        self.voiceAnimatingView = [DFVoiceAnimationView showVoiceAnimationViewFromBottom:80];
    }
    else
    {
        [self.voiceAnimatingView showAnimating];
    }
}

- (void) stopVoiceAnimating
{
    [self.voiceAnimatingView hideAnimating];
}

- (void) configTableView
{
    [self setTableHeaderView];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[DFChatTableViewCell class] forCellReuseIdentifier:kChatTableCellReuseId];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height;
    self.tableView.frame = tableFrame;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, kFooterHeight, 0);
}

- (void) setTableHeaderView
{
    self.tipsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTableHeaderHeight)];
    
    UIImage* image = [[UIImage imageNamed:@"chats_item_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:CGRectMake(4, 0, self.view.frame.size.width - 8, 36)];
    bkgView.image = image;
    [self.tipsContainerView addSubview:bkgView];
    
    self.tableHeaderLabel = [[UILabel alloc] initWithFrame:bkgView.frame];
    self.tableHeaderLabel.backgroundColor = [UIColor clearColor];
    self.tableHeaderLabel.font = [UIFont systemFontOfSize:15];
    self.tableHeaderLabel.textAlignment = NSTextAlignmentCenter;
    [self.tipsContainerView addSubview:self.tableHeaderLabel];
    
    self.tipsContainerView.alpha = 0;
    [self.view addSubview:self.tipsContainerView];
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[self.chats objectAtIndex:indexPath.row] chatTableCellHeight];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.chats.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFChatTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kChatTableCellReuseId forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    
    DFChatItem* item = [self.chats objectAtIndex:indexPath.row];
    
    [cell.avatarView setImageWithUrl:item.avatarUrl placeHolder:[DFCommonImages defaultAvatarImage]];
    cell.coreTextView.attributedString = item.textContent;
    
    cell.contentInsets = UIEdgeInsetsMake(kCellMarginTop, kCellMarginLeftRight, kCellMarginBottom, kCellMarginLeftRight);
    cell.avatarTextSpace = kCellAvatarTextSpace;
    
    cell.coreTextOriginY = kCellTextMarginTop;
    cell.coreTextSize = item.textContentSize;
    
    return cell;
}

- (DFUserMemberItem *) memberWithUserId:(NSInteger)userId
{
    for (DFUserMemberItem* member in self.members)
    {
        if (member.userId == userId)
        {
            return member;
        }
    }
    return nil;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFChatItem* item = [self.chats objectAtIndex:indexPath.row];
    DFUserMemberItem* memberItem = [self memberWithUserId:item.userId];
    if (memberItem != nil && item.userId != [DFPreference sharedPreference].currentUser.persistentId)
    {
        self.contextMenuController = [[DFChatUserContextMenuController alloc] initWithChatUserStyle:self.userStyle member:memberItem];
        self.contextMenuController.urlRequests = self.requests;
        self.contextMenuController.courseId = self.courseId;
        self.contextMenuController.channeldId = self.channelInfo.persistendId;
        self.contextMenuController.delegate = self;
        [self.contextMenuController popupInView:self.parentViewController.view];
    }
}

#pragma mark - context menu

- (void) chatUserContextMenuControllerDidDismiss:(DFChatUserContextMenuController *)controller
{
    self.contextMenuController = nil;
}

#pragma mark - footerview

- (void) keyboardButtonClicked:(id)sender
{
    [self.faceTextInputPanel.textView becomeFirstResponder];
    [self.faceTextInputPanel beginEditing];
//    [self.faceTextInputPanel showPanelContainer];
}

- (void) setTeacherVoiceDisabledTips
{
    self.disableVoiceChatTips = @"还未开始上课，请您点击‘开始上课’";
}

- (void) setStudentsVoiceDisabledTips
{
    if (self.me.disableVoiceChat)
    {
        self.disableVoiceChatTips = @"您已暂时被老师禁止语音发言，请稍候重试或联系老师申诉";
    }
    else if (self.currentTalkingUserId != 0)
    {
        self.disableVoiceChatTips = @"其他人正在发言，请稍候";
    }
    else if (self.classroomStatus != DFClassroomStatusDoing)
    {
        self.disableVoiceChatTips = @"还未开始上课，请稍候";
    }
}

- (void) setClassroomVistorVoiceDisableTips
{
    self.disableVoiceChatTips = @"矮油，偷师弟子不能说话哦~";
}

- (void) setChatroomVoiceDisableTips
{
    if (self.me.disableVoiceChat)
    {
        self.disableVoiceChatTips = @"您已被管理员禁言，请稍后再发言或联系管理员申诉";
    }
    else if (self.currentTalkingUserId != 0)
    {
        self.disableVoiceChatTips = @"其他人正在发言，请稍候";
    }
}

- (void) setTeacherTextDisabledTips
{
    self.disableTextChatTips = @"还未开始上课，请您点击‘开始上课’";
}

- (void) setStudentsTextDisabledTips
{
    if (self.me.disableTextChat)
    {
        self.disableTextChatTips = @"您已暂时被老师禁止文字发言，请稍候重试或联系老师申诉";
    }
    else if (self.classroomStatus != DFClassroomStatusDoing)
    {
        self.disableTextChatTips = @"还未开始上课，请稍候";
    }
}

- (void) setClassroomVistorTextDisableTips
{
    self.disableTextChatTips = @"矮油，偷师弟子不能说话哦~";
}

- (void) setChatroomTextDisableTips
{
    if (self.me.disableTextChat)
    {
        self.disableTextChatTips = @"您已被管理员禁言，请稍后再发言或联系管理员申诉";
    }
}

- (void) resetVoiceChatEnabled
{
    switch (self.userStyle) {
        case DFChatsUserStyleClassroomStudent:
            self.voiceChatEnabled = !self.me.disableVoiceChat && self.currentTalkingUserId == 0 && self.classroomStatus != DFClassroomStatusDone;
            [self setStudentsVoiceDisabledTips];
            break;
        case DFChatsUserStyleClassroomTeacher:
            self.voiceChatEnabled = YES;
//            [self setTeacherVoiceDisabledTips];
            break;
        case DFChatsUserStyleClassroomVisitor:
            self.voiceChatEnabled = NO;
            [self setClassroomVistorVoiceDisableTips];
            break;
        case DFChatsUserStyleRoomAdministrator:
            self.voiceChatEnabled = YES;
            break;
        case DFChatsUserStyleRoomVisitor:
            self.voiceChatEnabled = !self.me.disableVoiceChat && self.currentTalkingUserId == 0;
            [self setChatroomVoiceDisableTips];
            break;
            
        default:
            break;
    }
}

- (void) setVoiceChatEnabled:(BOOL)voiceChatEnabled
{
    _voiceChatEnabled = voiceChatEnabled;
    [self resetsetMikeButtonBackgroundNormalImage];
}

- (void) setMe:(DFUserMemberItem *)me
{
//    if (_me != me)
    {
        _me = me;
    }
    
    [self resetTextChatEnabled];
    [self resetVoiceChatEnabled];
}

- (void) resetTextChatEnabled
{
    switch (self.userStyle) {
        case DFChatsUserStyleClassroomStudent:
            self.textChatEnabled = !self.me.disableTextChat && self.classroomStatus != DFClassroomStatusDone;
            [self setStudentsTextDisabledTips];
            break;
        case DFChatsUserStyleClassroomTeacher:
            self.textChatEnabled = YES;
//            [self setTeacherTextDisabledTips];
            break;
        case DFChatsUserStyleClassroomVisitor:
            self.textChatEnabled = NO;
            [self setClassroomVistorTextDisableTips];
            break;
        case DFChatsUserStyleRoomAdministrator:
            self.textChatEnabled = YES;
            break;
        case DFChatsUserStyleRoomVisitor:
            self.textChatEnabled = !self.me.disableTextChat;
            [self setChatroomTextDisableTips];
            break;
            
        default:
            break;
    }
}

- (void) setClassroomStatus:(DFClassroomStatus)classroomStatus
{
    _classroomStatus = classroomStatus;
    
    [self resetVoiceChatEnabled];
    [self resetTextChatEnabled];
}

- (void) setCurrentTalkingUserId:(NSInteger)currentTalkingUserId
{
    _currentTalkingUserId = currentTalkingUserId;
    
    [self resetVoiceChatEnabled];
}

#define kChatroomSpeakTimeDuration 20.f

- (void) startChatroomSpeakTimer
{
    [self stopChatroomSpeakTimer];
    if (self.userStyle == DFChatsUserStyleRoomVisitor)
    {
        self.speakTimer = [NSTimer scheduledTimerWithTimeInterval:kChatroomSpeakTimeDuration target:self selector:@selector(speakTimerScheduled:) userInfo:nil repeats:NO];
    }
}

- (void) speakTimerScheduled:(NSTimer *)timer
{
    [self stopVoiceTalking];
    [SYPrompt showWithText:@"时间到!(每次最长可以讲20秒)" bottomOffset:80.f];
}

- (void) stopChatroomSpeakTimer
{
    [self.speakTimer invalidate];
    self.speakTimer = nil;
}

- (void) resetsetMikeButtonBackgroundNormalImage
{
    if (self.voiceChatEnabled)
    {
        [self.mikeButton setBackgroundImage:[UIImage imageNamed:@"chats_voice_normal.png"] forState:UIControlStateNormal];
    }
    else
    {
        [self.mikeButton setBackgroundImage:[UIImage imageNamed:@"chats_voice_disable.png"] forState:UIControlStateNormal];
    }
}

- (void) initFooterView
{
    self.footerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kFooterHeight, self.view.frame.size.width, kFooterHeight)];
    self.footerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.footerView];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:self.footerView.bounds];
    bkgView.image = [UIImage imageNamed:@"chats_bar_bkg.png"];;
    [self.footerView addSubview:bkgView];
    
    UIButton* keyboardButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kFooterHeight, kFooterHeight)];
    [keyboardButton setImage:[UIImage imageNamed:@"chats_keyboard.png"] forState:UIControlStateNormal];
    keyboardButton.backgroundColor = [UIColor clearColor];
    [keyboardButton addTarget:self action:@selector(keyboardButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:keyboardButton];
    
    self.mikeButton = [[DFMikeButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - kMikeButtonSize) / 2, self.view.frame.size.height - 6 - kMikeButtonSize, kMikeButtonSize, kMikeButtonSize)];
    self.mikeButton.delegate = self;
    self.mikeButton.backgroundColor = [UIColor clearColor];
//    [self.mikeButton addTarget:self action:@selector(mikeButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
//    [self.mikeButton addTarget:self action:@selector(mikeButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
//    [self.mikeButton addTarget:self action:@selector(mikeButtonTouchUp:) forControlEvents:UIControlEventTouchUpOutside];
    self.mikeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.mikeButton setBackgroundImage:[UIImage imageNamed:@"chats_voice_pressed.png"] forState:UIControlStateHighlighted];
    [self.view addSubview:self.mikeButton];
    [self resetsetMikeButtonBackgroundNormalImage];
    
    switch (self.userStyle) {
        case DFChatsUserStyleClassroomTeacher:
            [self addTeacherFooterSubviews];
            break;
            
        case DFChatsUserStyleClassroomStudent:
            [self addStudentFooterSubviews];
            break;
            
        case DFChatsUserStyleRoomAdministrator:
//            [self addRoomAdministratorFooterSubviews];
            break;
            
        case DFChatsUserStyleRoomVisitor:
//            [self addRoomVistorFooterSubviews];
            break;
            
        default:
            break;
    }
}


- (UIButton *) roundCornerButtonWithTitle:(NSString *)title frame:(CGRect)frame
{
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor clearColor];
    UIImage* image = [[UIImage imageNamed:@"chat_operation_button.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(26, 30, 26, 30) resizingMode:UIImageResizingModeStretch];
    [button setBackgroundImage:image forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    [button setTitleColor:RGBCOLOR(39, 55, 53) forState:UIControlStateNormal];
    return button;
}

#pragma mark - teacher

- (void) addTeacherFooterSubviews
{
    if (self.classroomStatus != DFClassroomStatusDoing)
    {
        UIButton* button = [self roundCornerButtonWithTitle:@"上课" frame:CGRectMake(50, 8, 50, 31)];
        [button addTarget:self action:@selector(startClassButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.footerView addSubview:button];
    }
}

- (void) startClassButtonClicked:(UIButton *)sender
{
    if (self.classroomStatus == DFClassroomStatusReady)
    {
        self.classroomStatus = DFClassroomStatusDoing;
        
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForStartClass] postValues:@{@"course_id": [NSNumber numberWithInt:self.courseId], @"isclass" : @"1"} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            if (success)
            {
                sender.hidden = YES;
            }
            else
            {
                [UIAlertView showWithTitle:@"开始上课" message:errorMsg];
            }
        }];
        [self.requests addObject:request];
    }
    else
    {
        [SYPrompt showWithText:@"当前还不是上课时间" bottomOffset:80];
    }
}

#pragma mark - student

- (void) addStudentFooterSubviews
{
    UIButton* ratingButton = [[UIButton alloc] initWithFrame:CGRectMake(62, 4, 36, 36)];
    ratingButton.backgroundColor = [UIColor clearColor];
    [ratingButton setBackgroundImage:[UIImage imageNamed:@"chats_rating.png"] forState:UIControlStateNormal];
    [ratingButton addTarget:self action:@selector(ratingButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.footerView addSubview:ratingButton];
}

#pragma mark - rating

- (void) ratingButtonClicked:(id)sender
{
    if (self.classroomStatus != DFClassroomStatusDone)
    {
        NSArray* subviews = [[NSBundle mainBundle] loadNibNamed:@"DFRatingTeacherPanel" owner:self options:nil];
        DFRatingTeacherPanel* panel = subviews.firstObject;
        
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPanel:)];
        [panel addGestureRecognizer:tap];
        
        [panel.poorButton addTarget:self action:@selector(panelPoorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        panel.poorButton.selected = self.courseHourRate == 1;
        
        [panel.ordinaryButton addTarget:self action:@selector(panelOrdinaryButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        panel.ordinaryButton.selected = self.courseHourRate == 3;
        
        [panel.goodButton addTarget:self action:@selector(panelGoodButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        panel.goodButton.selected = self.courseHourRate == 5;
        
        __block CGRect panelFrame = panel.frame;
        panelFrame.origin.y = 80;
        panel.frame = panelFrame;
        
        [self.view addSubview:panel];
        
        [UIView animateWithDuration:0.2 animations:^{
            panelFrame.origin.y = self.view.frame.size.height - panelFrame.size.height;
            panel.frame = panelFrame;
        }];
    }
    else
    {
        [SYPrompt showWithText:@"还未开始上课，不能评价老师" inView:self.view];
    }
    
}

- (void) tapPanel:(UIGestureRecognizer *)gesture
{
    [self dismissRatingPanel:gesture.view];
}

- (void) panelPoorButtonClicked:(UIButton *)sender
{
    [self rating:1];
    //TODO:
    [self dismissRatingPanel:sender.superview.superview];
}

- (void) panelOrdinaryButtonClicked:(UIButton *)sender
{
    [self rating:3];
    //TODO
    [self dismissRatingPanel:sender.superview.superview];
}

- (void) panelGoodButtonClicked:(UIButton *)sender
{
    [self rating:5];
    //TODO
    [self dismissRatingPanel:sender.superview.superview];
}

- (void) dismissRatingPanel:(UIView *)view
{
    __block CGRect panelFrame = view.frame;
    panelFrame.origin.y = 80;
    
    [UIView animateWithDuration:0.2 animations:^{
    
        view.frame = panelFrame;
        
    } completion:^(BOOL finished){
    
        [view removeFromSuperview];
        
    }];
}

- (void) rating:(NSInteger)grade
{
    if (self.courseHourRateId > 0)
    {
        typeof(self) __weak bself = self;
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForRatingTeacherCourse] postValues:@{@"course_hour_id": [NSNumber numberWithInt:self.courseHourRateId], @"rate" : [NSNumber numberWithInt:grade]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            if (success)
            {
                bself.courseHourRate = grade;
                [SYPrompt showWithText:@"评价成功，结果将会体现在老师的星级中"];
            }
            else
            {
                [UIAlertView showWithTitle:@"评价" message:errorMsg];
            }
        }];
        [self.requests addObject:request];
    }
    else
    {
        [SYPrompt showWithText:@"评价成功，结果将会体现在老师的星级中"];
    }
}

#pragma mark - face text inputpanel

#define kBottomButtonFrameHeight 63.0f

- (void) initFaceTextInputPanel
{
    self.faceTextInputPanel = [[SYFaceTextInputPanel alloc] initWithCanvasView:self.parentViewController.view];
    self.faceTextInputPanel.inputBarView.backgroundColor = RGBCOLOR(246, 246, 246);
    self.faceTextInputPanel.delegate = self;
    self.faceTextInputPanel.inputBarHidden = YES;
    
    [self.faceTextInputPanel putInBack];
}

- (BOOL) facePanelShouldEditing
{
    if (![[DFPreference sharedPreference] validateLogin:^{
        return NO;
    }])
    {
        return NO;
    }
    else if (!self.textChatEnabled)
    {
        [SYPrompt showWithText:self.disableTextChatTips inView:self.view];
        return NO;
    }
    return YES;
}

- (void) sendText:(NSString *)text forFacePanel:(SYFaceTextInputPanel *)panel
{
    [panel endEditing];
    [self sendTextMsg:text];
}

- (void) facePanelBeginEditing:(SYFaceTextInputPanel *)panel
{
    [self.controllerDelegate facePanel:panel beginEditingForChatViewController:self];
}

- (void) facePanelEndEditing:(SYFaceTextInputPanel *)panel
{
    [self.controllerDelegate facePanel:panel endEditingForChatViewController:self];
}

#pragma mark - error alertview

#define kAlertViewTagLeft 1028

- (void) showLeftAlertViewForError:(NSString *)errorMessage
{
    UIAlertView* alertview = [[UIAlertView alloc] initWithTitle:@"语音" message:errorMessage delegate:self cancelButtonTitle:nil otherButtonTitles:@"好", nil];
    alertview.tag = kAlertViewTagLeft;
    [alertview show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTagLeft)
    {
        [((SYBaseContentViewController *)self.parentViewController) leftButtonClicked:nil];
    }
}

#pragma mark - channel delegate

- (void) reconnect
{
    if (self.voiceChannelJoinFailedCount < 3)
    {
        self.channelConnectState = DFConnectStateUnconnected;
        [self joinChannel];
        ++self.voiceChannelJoinFailedCount;
    }
    else
    {
        [self showLeftAlertViewForError:@"网络异常，请退出后再重新进入"];
    }
    
}

/**
 *  错误异常
 *
 *  @param errorType  错误消息类型
 */
- (void)onError:(GotyeErrorType)errorType
{
    NSLog(@"%s:%@:%d", __FUNCTION__, self.voiceChannelId, errorType);
    
//    switch (errorType) {
//        case ErrorNetworkInvalid:
//            [self reconnect];
//            break;
//            
//        default:
//            [self showLeftAlertViewForError:@"网络异常，请退出后再重新进入"];
//            break;
//    }
}

/**
 *  退出登录
 *
 *  @param success  YES 成功 NO 失败
 */
- (void)onExit:(BOOL)success
{
    NSLog(@"%s:%@", __FUNCTION__, self.voiceChannelId);
    self.channelConnectState = DFConnectStateUnconnected;
}

/**
 *  加入频道
 *
 * @param success  YES 成功 NO 失败
 */
- (void)onJoinChannel:(BOOL)success
{
    NSLog(@"%s:%@", __FUNCTION__, (success ? @"success" : @"no"));
    
    [self hideProgress];
    
    self.channelConnectState = DFConnectStateConnected;
//    if (!success)
//    {
//        [self reconnect];
//    }
//    else
//    {
//        self.voiceChannelJoinFailedCount = 0;
//        self.channelConnectState = DFConnectStateConnected;
//    }
}

/**
 *  退出频道
 *
 *  @param success  YES 成功 NO 失败
 */
- (void)onExitChannel:(BOOL)success
{
    NSLog(@"%s:%@", __FUNCTION__, self.voiceChannelId);
    self.channelConnectState = DFConnectStateUnconnected;
}

/**
 *  获取到用户昵称的回调
 *
 *  @param userMap   用户昵称的key-value对，key值为用户id，value值为用户昵称
 */
- (void)onGetUserNickname:(NSDictionary *)userMap
{

}

/**
 *  获取到频道其他成员
 *
 *  @param userId  进入频道的用户id
 */
- (void)onGetChannelMember:(NSString *)userId
{
    NSLog(@"%s:%@", __FUNCTION__, userId);
}

/**
 *  其他成员退出频道通知
 *
 *  @param userId  退出频道用户id
 */
- (void)onRemoveChannelMember:(NSString *)userId
{
    NSLog(@"%s:%@", __FUNCTION__, userId);
}

/**
 *  频道中有人开始说话(包含自己)
 *
 *  @param userId  开始说话用户id
 */
- (void)onStartTalking:(NSString *)userId
{

    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    NSInteger originTalkingUserId = self.currentTalkingUserId;
    if (originTalkingUserId > 0)
    {
        return;
    }

    self.currentTalkingUserId = [userId integerValue];
    
    NSLog(@"%s:%d, %d, %d", __FUNCTION__, originTalkingUserId, self.currentTalkingUserId, user.persistentId);
    
    if (self.currentTalkingUserId != user.persistentId) //别人正在说
    {
//        if (user.persistentId == originTalkingUserId) //原来是我说
//        {
//            NSLog(@"%s-stop:%d, %d, %d", __FUNCTION__, originTalkingUserId, self.currentTalkingUserId, user.persistentId);
//            [self.apiInstance stopTalking];
//            [self sendStopVoiceMessage];
//            
//            [self stopChatroomSpeakTimer];
//            [self stopVoiceAnimating];
//        }
    }
    else
    {
        [self startChatroomSpeakTimer];
        
        [self sendStartVoiceMessage];
        
        [self startVoiceAnimating];
    }
}

/**
 *  频道中有人停止说话(包含自己)
 *
 *  @param userId  停止说话用户id
 */
- (void)onStopTalking:(NSString *)userId
{
    NSLog(@"%s:%@, %d", __FUNCTION__, userId, self.currentTalkingUserId);
    if (self.currentTalkingUserId == [userId integerValue])
    {
        [self stopChatroomSpeakTimer];
        
        [self stopVoiceAnimating];
        
        self.currentTalkingUserId = 0;
    }
}

- (void) touchDownForMikeButton:(DFMikeButton *)button
{
    NSLog(@"%s:%d, try", __FUNCTION__, self.currentTalkingUserId);
    if (self.voiceChatEnabled)
    {
        NSLog(@"%s:%d", __FUNCTION__, self.currentTalkingUserId);
        
        self.startTalk = YES;
        
        [self.apiInstance startTalking];
    }
    else
    {
        [SYPrompt showWithText:self.disableVoiceChatTips inView:self.view];
    }
}

- (void) touchUpForMikeButton:(DFMikeButton *)button
{
    NSLog(@"%s:%d, try", __FUNCTION__, self.currentTalkingUserId);
    if (self.startTalk
        || self.currentTalkingUserId == [DFPreference sharedPreference].currentUser.persistentId)
    {
        [self stopVoiceTalking];
    }
    
    self.startTalk = NO;
}

- (void) stopVoiceTalking
{

    NSLog(@"%s:%d", __FUNCTION__, self.currentTalkingUserId);
    
    [self.apiInstance stopTalking];
    
    [self sendStopVoiceMessage];
    
    [self stopChatroomSpeakTimer];
    [self stopVoiceAnimating];
    
    
}

/**
 *  自己禁言|静音状态发生改变
 *
 *  @param muted  YES 自己禁言｜静音  NO 自己取消禁言｜静音
 */
- (void)onMuteStateChanged:(BOOL)muted
{
}

/**
 *  频道中有人被管理员 禁言/取消禁言(包括自己)
 *
 *  @param silenced YES 用户被禁言/静音  NO 用户禁言/静音被取消
 *  @param userId   被禁言/取消禁言用户id
 */
- (void)onSilencedStateChanged:(BOOL)silenced with:(NSString *)userId
{
}

/**
 *  通知：获取到频道发言模式
 *
 *  @param TalkMode  频道发言模式枚举值
 */
- (void)notifyChannelTalkMode:(TalkMode)talkMode
{
}


/**
 *  通知：获取到频道成员类型表
 *
 *  @param typeList  频道成员列表。key为成员userId，value为封装了MemberType的NSNumber类型; 字典中包含发生身份发生变化的成员，不在此字典中的成员身份不变.
 */
- (void)notifyChannelMemberTypes:(NSDictionary *)typeList
{
}

#pragma mark - rtmp

#define kMainGrayColor RGBCOLOR(39, 55, 63)

#define STATUS_SUCCESS_RESULT 0x02

- (void) resultReceived:(id<IServiceCall>)call
{
    //ServerLastMessage
    
    NSString *method = [call getServiceMethodName];
    NSArray *args = [call getArguments];
    int status = [call getStatus];
    
//    NSLog(@"%s, %@, %@", __FUNCTION__, method, args);
    
    if (status != STATUS_SUCCESS_RESULT) // this call is not a server invoke
        return;
    
    NSDictionary* info = args.firstObject;
    if ([method isEqualToString:@"welcome"])
    {
        [self welcomeMessageReceived:info];
    }
    else if ([method isEqualToString:@"getMessage"])
    {
        [self textMessageReceived:info];
    }
    else if ([method isEqualToString:@"ServerLastMessage"])
    {
        [self last5MessagesReceived:(NSArray *)info];
    }
//    else if ([method isEqualToString:@"serverSendKickUser"])
//    {
//        [self kickMessageReceived:info];
//    }
    else if ([method isEqualToString:@"ServerBanMessage"])
    {
        [self banMessageReceived:info];
    }
    else if ([method isEqualToString:@"ServerSetCourseSection"])
    {
        [self setCurrentSectionMessageReceived:info];
    }
    else if ([method isEqualToString:@"ServerChangeClass"])
    {
        [self classStatusChangedReceived:info];
    }
    else if ([method isEqualToString:@"ServerStartVoice"])
    {
        [self startVoiceMessageReceived:info];
    }
    else if ([method isEqualToString:@"ServerEndVoice"])
    {
        [self stopVoiceMessageReceived:info];
    }
    else if ([method isEqualToString:@"ServerSetChannel"])
    {
        [self chatroomSettingsUpdatedMessageReceived:info];
    }
    else if ([method isEqualToString:@"ServerSetChannelNotice"])
    {
        [self chatroomTopicChangedMessageReceived:info];
    }
}

- (void) chatroomSettingsUpdatedMessageReceived:(NSDictionary *)info
{
    if ([info objectForKey:@"name"])
    {
        self.channelInfo.title = [info objectForKey:@"name"];
    }
    if ([info objectForKey:@"img"])
    {
        self.channelInfo.imageUrl = [info objectForKey:@"img"];
    }
    if ([info objectForKey:@"password"])
    {
        self.channelInfo.password = [info objectForKey:@"password"];
    }
    if ([self.controllerDelegate respondsToSelector:@selector(chatroomSettingsChanged)])
    {
        [self.controllerDelegate chatroomSettingsChanged];
    }
}

- (void) chatroomTopicChangedMessageReceived:(NSDictionary *)info
{
    NSString* text = [info objectForKey:@"notice"];
    self.channelInfo.topic = text;
    if ([self.controllerDelegate respondsToSelector:@selector(chatroomTopicChanged)])
    {
        [self.controllerDelegate chatroomTopicChanged];
    }
}

- (NSString *) positionTextFor:(NSInteger)userId
{
    for (DFUserMemberItem* item in self.members)
    {
        if (item.userId == userId)
        {
            return item.positionText;
        }
    }
    return @"";
}

- (void) startVoiceMessageReceived:(NSDictionary *)info
{
    NSLog(@"%s,%@", __FUNCTION__, info);
    
    NSInteger userId = [[info objectForKey:@"userid"] integerValue];
    NSString* nickname = [info objectForKey:@"nickname"];
    
    NSAttributedString* prefixText = nil;
    NSAttributedString* nicknameText = [[NSAttributedString alloc] initWithString:nickname attributes:@{UITextAttributeTextColor: kMainDarkColor}];
    NSAttributedString* suffixText = nil;
    NSString* position = [self positionTextFor:userId];
    if (position.length > 0)
    {
        prefixText = [[NSAttributedString alloc] initWithString:position attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    else
    {
        prefixText = [[NSAttributedString alloc] initWithString:@" " attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    suffixText = [[NSAttributedString alloc] initWithString:@"正在发言" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithAttributedString:prefixText];
    [text appendAttributedString:nicknameText];
    [text appendAttributedString:suffixText];
//    self.tableHeaderLabel.attributedText = text;
    [self setTipsWithAttributedText:text];
    
//    self.currentTalkingUserId = userId;
//    
//    if (self.talking && userId != [DFPreference sharedPreference].currentUser.persistentId)
//    {
//        [self stopChatroomSpeakTimer];
//        [self.apiInstance stopTalking];
//        [self stopVoiceAnimating];
//        self.talking = NO;
//    }
}

- (void) stopVoiceMessageReceived:(NSDictionary *)info
{
    NSLog(@"%s,%@", __FUNCTION__, info);
    NSInteger userId = [[info objectForKey:@"userid"] integerValue];
    NSString* nickname = [info objectForKey:@"nickname"];
    
    NSAttributedString* prefixText = nil;
    NSAttributedString* nicknameText = [[NSAttributedString alloc] initWithString:nickname attributes:@{UITextAttributeTextColor: kMainDarkColor}];
    NSAttributedString* suffixText = nil;
    NSString* position = [self positionTextFor:userId];
    if (position.length > 0)
    {
        prefixText = [[NSAttributedString alloc] initWithString:position attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    else
    {
        prefixText = [[NSAttributedString alloc] initWithString:@" " attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    suffixText = [[NSAttributedString alloc] initWithString:@"发言结束" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithAttributedString:prefixText];
    [text appendAttributedString:nicknameText];
    [text appendAttributedString:suffixText];
//    self.tableHeaderLabel.attributedText = text;
    [self setTipsWithAttributedText:text];
    
//    self.currentTalkingUserId = 0;
}

- (void) classStatusChangedReceived:(NSDictionary *)info
{
    NSInteger classStatus = [[info objectForKey:@"isclass"] integerValue];
    if (classStatus == 1)
    {
        self.classroomStatus = DFClassroomStatusDoing;
        [self setTipsText:@"上课喽~~"];
    }
    else
    {
        self.classroomStatus = DFClassroomStatusDone;
        [self setTipsText:@"下课喽~~"];
    }
    if ([self.controllerDelegate respondsToSelector:@selector(classroomStatusChanged:)])
    {
        [self.controllerDelegate classroomStatusChanged:self.classroomStatus];
    }
}

- (void) setCurrentSectionMessageReceived:(NSDictionary *)info
{
    NSInteger sectionId = [[info objectForKey:@"section_id"] integerValue];
    NSInteger chapterId = [[info objectForKey:@"chapter_id"] integerValue];
    if ([self.controllerDelegate respondsToSelector:@selector(classroomDidSetChapter:section:)])
    {
        [self.controllerDelegate classroomDidSetChapter:chapterId section:sectionId];
    }
}

- (void) banMessageReceived:(NSDictionary *)info
{
    NSInteger userId = [[info objectForKey:@"userid"] integerValue];
    NSString* nickname = [info objectForKey:@"nickname"];
    NSInteger banType = [[info objectForKey:@"ban_type"] integerValue];
    BOOL enabled = [[info objectForKey:@"type"] integerValue] == 1;
    
    NSMutableString* descText = [[NSMutableString alloc] init];
    [descText appendString:(enabled ? @"已恢复" : @"被禁止")];
    [descText appendString:(banType == 0 ? @"文字发言" : @"语音发言")];
    
    NSAttributedString* prefixText = nil;
    NSAttributedString* nicknameText = [[NSAttributedString alloc] initWithString:nickname attributes:@{UITextAttributeTextColor: kMainDarkColor}];
    NSAttributedString* suffixText = nil;
    if ( self.members.count > 0 && self.channelInfo == nil)
    {
        NSString* position = [self positionTextFor:userId];
        prefixText = [[NSAttributedString alloc] initWithString:position attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        suffixText = [[NSAttributedString alloc] initWithString:descText attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    else
    {
        prefixText = [[NSAttributedString alloc] initWithString:@" " attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        suffixText = [[NSAttributedString alloc] initWithString:descText attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithAttributedString:prefixText];
    [text appendAttributedString:nicknameText];
    [text appendAttributedString:suffixText];
    [self setTipsWithAttributedText:text];
    
    DFUserMemberItem* member = [self memberWithUserId:userId];
    if (banType == 0)
    {
        member.disableTextChat = !enabled;
        if (userId == [DFPreference sharedPreference].currentUser.persistentId)
        {
            self.me.disableTextChat = !enabled;
            [self resetTextChatEnabled];
        }
    }
    else if (banType == 1)
    {
        member.disableVoiceChat = !enabled;
        if (userId == [DFPreference sharedPreference].currentUser.persistentId)
        {
            self.me.disableVoiceChat = !enabled;
            [self resetVoiceChatEnabled];
        }
    }
    if ([self.controllerDelegate respondsToSelector:@selector(roomMemberStatusChanged)])
    {
        [self.controllerDelegate roomMemberStatusChanged];
    }
}

- (void) kickMessageReceived:(NSDictionary *)info
{
    NSInteger userId = [[info objectForKey:@"userid"] integerValue];
    NSString* nickname = [info objectForKey:@"nickname"];
    
    if (userId == [DFPreference sharedPreference].currentUser.persistentId)
    {
        if ([self.controllerDelegate respondsToSelector:@selector(classroomDidKickedByTeacher)])
        {
            [self.controllerDelegate classroomDidKickedByTeacher];
        }
        return;
    }
    
    NSAttributedString* prefixText = nil;
    NSAttributedString* nicknameText = [[NSAttributedString alloc] initWithString:nickname attributes:@{UITextAttributeTextColor: kMainDarkColor}];
    NSAttributedString* suffixText = nil;
    
    if (self.members.count > 0)
    {
        NSString* position = [self positionTextFor:userId];
        if (position.length > 0)
        {
            prefixText = [[NSAttributedString alloc] initWithString:position attributes:@{UITextAttributeTextColor: kMainGrayColor}];
            suffixText = [[NSAttributedString alloc] initWithString:@"被逐出课堂" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        }
    }
    else
    {
        prefixText = [[NSAttributedString alloc] initWithString:@" " attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        suffixText = [[NSAttributedString alloc] initWithString:@"被逐出课堂" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithAttributedString:prefixText];
    [text appendAttributedString:nicknameText];
    [text appendAttributedString:suffixText];
//    self.tableHeaderLabel.attributedText = text;
    [self setTipsWithAttributedText:text];
}

- (NSAttributedString *) classroomWelocomTextForUserId:(NSInteger)userId nickname:(NSString *)nickname
{
    NSAttributedString* prefixText = nil;
    NSAttributedString* nicknameText = [[NSAttributedString alloc] initWithString:nickname attributes:@{UITextAttributeTextColor: kMainDarkColor}];
    NSAttributedString* suffixText = nil;
    
    if (self.members.count > 0)
    {
        NSString* position = [self positionTextFor:userId];
        if (position.length > 0)
        {
            prefixText = [[NSAttributedString alloc] initWithString:position attributes:@{UITextAttributeTextColor: kMainGrayColor}];
            suffixText = [[NSAttributedString alloc] initWithString:([(DFUserMemberItem *)self.members.firstObject userId] == userId ? @"驾到" : @"报到") attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        }
        else
        {
            prefixText = [[NSAttributedString alloc] initWithString:@"偷师弟子" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
            suffixText = [[NSAttributedString alloc] initWithString:@"潜入" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        }
    }
    else
    {
        prefixText = [[NSAttributedString alloc] initWithString:@" " attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        suffixText = [[NSAttributedString alloc] initWithString:@"进入" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithAttributedString:prefixText];
    [text appendAttributedString:nicknameText];
    [text appendAttributedString:suffixText];
    
    return text;
}

- (NSAttributedString *) channelZoneWelocomTextForUserId:(NSInteger)userId nickname:(NSString *)nickname
{
    NSAttributedString* prefixText = nil;
    NSAttributedString* nicknameText = [[NSAttributedString alloc] initWithString:nickname attributes:@{UITextAttributeTextColor: kMainDarkColor}];
    NSAttributedString* suffixText = nil;
    if (userId == self.channelInfo.adminUserId)
    {
        prefixText = [[NSAttributedString alloc] initWithString:@"房主[" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
        suffixText = [[NSAttributedString alloc] initWithString:@"]驾到" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    else
    {
        prefixText = [[NSAttributedString alloc] initWithString:@"欢迎" attributes:@{UITextAttributeTextColor: kMainGrayColor}];
    }
    
    NSMutableAttributedString* text = [[NSMutableAttributedString alloc] initWithAttributedString:prefixText];
    [text appendAttributedString:nicknameText];
    if (suffixText.length > 0)
    {
        [text appendAttributedString:suffixText];
    }
    
    return text;
}

- (DFChatItem *)chatItemWithWelcomClassroomForUserId:(NSInteger)userId name:(NSString *)nickname
{
    DFChatItem* item = [[DFChatItem alloc] init];
    item.userId =  userId;
    item.avatarUrl = [self avatarWithUserId:userId];
    
    NSString* htmlString = nil;
    NSString* position = [self positionTextFor:userId];
    if (position.length > 0)
    {
        htmlString = [NSString stringWithFormat:@"<span color=\"#67777f\">[%@]</span><span color=\"#f8444f\">%@</span>&nbsp;<span color=\"#27373f\">进入课堂</span>", position, nickname];
    }
    else
    {
        htmlString = [NSString stringWithFormat:@"<span color=\"#f8444f\">%@</span>&nbsp;<span color=\"#27373f\">进入课堂</span>", nickname];
    }
    
    item.textContent = [NSAttributedString attributedStringWithHTML:htmlString renderer:nil];
    [item resetTextContentSizeWithConstraintSize:CGSizeMake(self.view.frame.size.width - kCellMarginLeftRight - kCellAvatarTextSpace - kChatTableViewCellAvatarSize, 200)];
    
    item.chatTableCellHeight = kCellMarginTop + kCellMarginBottom + (item.textContentSize.height > kChatTableViewCellAvatarSize ? item.textContentSize.height : kChatTableViewCellAvatarSize);
    
    return item;
}

- (DFChatItem *)chatItemWithWelcomChatroomForUserId:(NSInteger)userId name:(NSString *)nickname
{
    DFChatItem* item = [[DFChatItem alloc] init];
    item.userId =  userId;
    item.avatarUrl = [self avatarWithUserId:userId];
    
    NSString* htmlString = [NSString stringWithFormat:@"<span color=\"#fc7caf\">%@</span>&nbsp;<span color=\"#27373f\">进入房间</span>", nickname];
    
    item.textContent = [NSAttributedString attributedStringWithHTML:htmlString renderer:nil];
    [item resetTextContentSizeWithConstraintSize:CGSizeMake(self.view.frame.size.width - kCellMarginLeftRight - kCellAvatarTextSpace - kChatTableViewCellAvatarSize, 200)];
    
    item.chatTableCellHeight = kCellMarginTop + kCellMarginBottom + (item.textContentSize.height > kChatTableViewCellAvatarSize ? item.textContentSize.height : kChatTableViewCellAvatarSize);
    
    return item;
}

- (void) welcomeMessageReceived:(NSDictionary *)info
{
    NSString* nickname = [[info objectForKey:@"nickname"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSInteger userId = [[info objectForKey:@"userid"] integerValue];
    DFUserRole userType = [[info objectForKey:@"user_type"] integerValue];
    
    switch (self.userStyle) {
        case DFChatsUserStyleRoomAdministrator:
        case DFChatsUserStyleRoomVisitor:
            [self setTipsWithAttributedText:[self channelZoneWelocomTextForUserId:userId nickname:nickname]];
            [self.chats addObject:[self chatItemWithWelcomChatroomForUserId:userId name:nickname]];
            [self.tableView reloadData];
            break;
        case DFChatsUserStyleClassroomStudent:
        case DFChatsUserStyleClassroomTeacher:
        case DFChatsUserStyleClassroomVisitor:
            [self setTipsWithAttributedText:[self classroomWelocomTextForUserId:userId nickname:nickname]];
            [self.chats addObject:[self chatItemWithWelcomClassroomForUserId:userId name:nickname]];
            [self.tableView reloadData];
            break;
            
        default:
            break;
    }
    
    if ([DFPreference sharedPreference].currentUser.persistentId == userId)
    {
        self.currentTalkingUserId = [[info objectForKey:@"voiceuserid"] integerValue];
    }
    
    [self scrollTableViewToNew:self.tableView];
    
    DFUserMemberItem* member = [self memberWithUserId:userId];
    if (member != nil)
    {
        member.inClassroom = YES;
        if ([self.controllerDelegate respondsToSelector:@selector(roomMemberStatusChanged)])
        {
            [self.controllerDelegate roomMemberStatusChanged];
        }
    }
    else if (self.userStyle == DFChatsUserStyleRoomAdministrator || self.userStyle == DFChatsUserStyleRoomVisitor)
    {
        DFUserMemberItem* member = [[DFUserMemberItem alloc] init];
        member.userId = userId;
        member.nickname = nickname;
        member.userRole = userType;
        member.avatarUrl = [info objectForKey:@"avatar"];
        member.member = [[info objectForKey:@"vip_type"] integerValue];
        member.disableTextChat = [[info objectForKey:@"text_chat_enabled"] integerValue] == 0;
        member.disableVoiceChat = [[info objectForKey:@"voice_chat_enabled"] integerValue] == 0;
        member.provinceCity = [info objectForKey:@"city"];
        [self.members addObject:member];
        
        if ([self.controllerDelegate respondsToSelector:@selector(roomMemberStatusChanged)])
        {
            [self.controllerDelegate roomMemberStatusChanged];
        }
    }
}


- (void) scrollTableViewToNew:(UITableView *)tableView
{
    if ([self.tableView numberOfRowsInSection:0] > 0)
    {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.tableView numberOfRowsInSection:0] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void) textMessageReceived:(NSDictionary *)info
{
    [self.chats addObject:[self chatItemWithDictionary:info]];
    
    [self.tableView reloadData];
    [self scrollTableViewToNew:self.tableView];
}

- (NSString *) avatarWithUserId:(NSInteger)userId
{
    for (DFUserMemberItem* member in self.members)
    {
        if (member.userId == userId)
        {
            return member.avatarUrl;
        }
    }
    return @"";
}

- (DFChatItem *) chatItemWithDictionary:(NSDictionary *)info
{
    NSInteger userId = [[info objectForKey:@"userid"] integerValue];
    NSString* nickname = [info objectForKey:@"nickname"];
    NSString* content = [info objectForKey:@"content"];
    
    DFChatItem* item = [[DFChatItem alloc] init];
    item.userId =  userId;
    item.avatarUrl = [self avatarWithUserId:userId];
    
    NSString* htmlString = nil;
    NSString* position = [self positionTextFor:userId];
    if (position.length > 0)
    {
        htmlString = [NSString stringWithFormat:@"<span color=\"#67777f\">[%@]</span><span color=\"#f8444f\">%@</span>&nbsp;：<span color=\"#27373f\">%@</span>", position, nickname, [content replaceFacesWithHtmlFormat]];
    }
    else
    {
        htmlString = [NSString stringWithFormat:@"<span color=\"#f8444f\">%@</span>&nbsp;：<span color=\"#27373f\">%@</span>", nickname, [content replaceFacesWithHtmlFormat]];
    }
    
    item.textContent = [NSAttributedString attributedStringWithHTML:htmlString renderer:nil];
    [item resetTextContentSizeWithConstraintSize:CGSizeMake(self.view.frame.size.width - kCellMarginLeftRight - kCellAvatarTextSpace - kChatTableViewCellAvatarSize, 200)];
    
    item.chatTableCellHeight = kCellMarginTop + kCellMarginBottom + (item.textContentSize.height > kChatTableViewCellAvatarSize ? item.textContentSize.height : kChatTableViewCellAvatarSize);
    
    return item;
}

- (void) last5MessagesReceived:(NSArray *)infos
{
    for (NSDictionary* info in infos)
    {
        [self.chats addObject:[self chatItemWithDictionary:info]];
    }
    [self.tableView reloadData];
    [self scrollTableViewToNew:self.tableView];
}

-(void)sendTextMsg:(NSString *) msg
{
	NSMutableArray *args = [[NSMutableArray alloc] init];
	// set call parameters
	NSString *method = @"sendMessage";
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:msg forKey:@"content"];
    [dict setObject:user.nickname forKey:@"nickname"];
//    [dict setObject:user.avatarUrl forKey:@"avatar"];
    [dict setObject:[NSNumber numberWithInteger:user.persistentId] forKey:@"userid"];
    
    [args addObject:dict];
    
	[_rtmpClient invoke:method withArgs:args responder:nil];
}

#pragma mark -

- (void) sendStartVoiceMessage
{
    NSMutableArray *args = [[NSMutableArray alloc] init];
	// set call parameters
	NSString *method = @"startvoice";
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:user.nickname forKey:@"nickname"];
    [dict setObject:[NSNumber numberWithInteger:user.persistentId] forKey:@"userid"];
    
    [args addObject:dict];
    
	[_rtmpClient invoke:method withArgs:args responder:nil];
}

- (void) sendStopVoiceMessage
{
    NSMutableArray *args = [[NSMutableArray alloc] init];
	// set call parameters
	NSString *method = @"endvoice";
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:user.nickname forKey:@"nickname"];
    [dict setObject:[NSNumber numberWithInteger:user.persistentId] forKey:@"userid"];
    
    [args addObject:dict];
    
	[_rtmpClient invoke:method withArgs:args responder:nil];
}

- (void) setTipsText:(NSString *)text
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutTipsContainerView) object:nil];
    self.tipsContainerView.alpha = 1;
    self.tableHeaderLabel.text = text;
    [self performSelector:@selector(fadeOutTipsContainerView) withObject:nil afterDelay:3];
}

- (void) setTipsWithAttributedText:(NSAttributedString *)text
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(fadeOutTipsContainerView) object:nil];
    self.tipsContainerView.alpha = 1;
    self.tableHeaderLabel.attributedText = text;
    [self performSelector:@selector(fadeOutTipsContainerView) withObject:nil afterDelay:3];
}

- (void) fadeOutTipsContainerView
{
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.2 animations:^{
        bself.tipsContainerView.alpha = 0;
    }];
}

@end
