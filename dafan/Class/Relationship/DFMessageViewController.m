//
//  MYMessageViewController.m
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFUserProfile.h"
#import "DFPreference.h"
#import "SYPrompt.h"
#import "RTMPClient.h"
#import "DFGroupMessageItem.h"
#import "VoiceConverter.h"
#import "DFAppDelegate.h"
#import "DFNotificationDefines.h"
#import "SYConstDefine.h"
#import "UIView+SYShape.h"
#import "CoreTextView.h"
#import "SYPopoverMenu.h"
#import "SYFacesPanel.h"
#import "NSString+HTMLCoreText.h"
#import "SYStandardNavigationBar.h"
#import "SYHttpRequest.h"
#import "NSString+SYFace.h"
#import "DFUrlDefine.h"
#import "SYFilePath.h"
#import "DFMessageViewController.h"
#import "SYDeviceDescription.h"
#import "UIBubbleTableView.h"
#import "SYVoiceFaceTextInputPanel.h"
#import "UIAlertView+SYExtension.h"
#import "SYRecordController.h"
#import "SYEnum.h"
#import "SYVoicePlayer.h"
#import "SYBaseNavigationController.h"
#import "SYBaseContentViewController+Keyboard.h"
#import "DFClassCirclePreferenceViewController.h"
#import "SYBaseContentViewController+EGORefresh.h"


@interface DFMessageViewController () < UIActionSheetDelegate,
                                        UITextViewDelegate,
                                        IRTMPClientDelegate,
                                        UIBubbleTableViewDataSource,
                                        SYFaceTextInputPanelDelegate,
                                        MYBubbleTableViewDelegate,
                                        SYRecordControllerDelegate,
                                        SYVoicePlayerDelegate,
                                        SYPopoverMenuDelegate>

@property(nonatomic) NSInteger userId;
@property(nonatomic) NSInteger classCircleId;
@property(nonatomic, strong) DFGroupMessageItem* classInfo;

@property(nonatomic, strong) RTMPClient* rtmpClient;
@property(nonatomic) BOOL needReConnectRTMP; //连接失败是否重新连接
@property(nonatomic) NSInteger continueFailedCount;

@property(nonatomic, strong) UIBubbleTableView* bubbleTableView;
@property(nonatomic, strong) NSMutableArray* bubbleData;
@property(nonatomic) NSInteger offsetMessageId;

@property(nonatomic, strong) SYVoiceFaceTextInputPanel* inputPanel;
@property(nonatomic, strong) NSString* voiceUrl;
@property(nonatomic) NSInteger voiceDuration;
@property(nonatomic) BOOL voiceHasModified; //是否需要重新上传获取voiceUrl

@property(nonatomic, strong) SYRecordController* recordController;

@property(nonatomic, strong) SYVoicePlayer* voicePlayer;

@property(nonatomic, strong) NSMutableDictionary* voices; //timeinterval : voiceUrl
@property(nonatomic, strong) NSMutableArray* otherVoiceAnimatingImages;
@property(nonatomic, strong) NSMutableArray* myVoiceAnimatingImages;
@property(nonatomic, strong) UIButton* animatingButton;

@property(nonatomic, strong) NSString* myNewestMessageForClosedBlock;
@property(nonatomic) NSInteger myNewestMessageTimeintervalForClosedBlock;

@end

@implementation DFMessageViewController

- (id) initWithUserId:(NSInteger)userId
{
    self = [super init];
    if (self)
    {
        self.userId = userId;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithClassCircleId:(NSInteger)classCircleId
{
    self = [super init];
    if (self)
    {
        self.classCircleId = classCircleId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.bubbleData = [NSMutableArray array];
    
    [self initFaceTextInputPanel];
    [self initBubbleTableView];
    [self configCustomNavigationBar];
    [self registerObservers];
    
    if (self.classCircleId > 0)
    {
        [self requestClassCircleInfo];
    }
    else{
        self.title = self.nickname;
        [self connectRTMPClient];
    }
    
    [self requestLatestMessage];
}

- (void) configCustomNavigationBar
{
    if (self.classCircleId > 0)
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
    if (self.classCircleId > 0)
    {
        SYPopoverMenuItem* preferenceItem = [[SYPopoverMenuItem alloc] init];
        preferenceItem.title = @"班级设置";
        
        SYPopoverMenuItem* reportItem = [[SYPopoverMenuItem alloc] init];
        reportItem.title = @"举报";
        
        SYPopoverMenu* menu = [[SYPopoverMenu alloc] initWithMenuItems:@[preferenceItem, reportItem]];
        menu.delegate = self;
        [menu showFromView:self.customNavigationBar.rightButton];
    }
    else
    {
        [self requestReport];
    }
}

- (void) presentPreferenceViewController
{
    DFClassCirclePreferenceViewController* controller = [[DFClassCirclePreferenceViewController alloc] init];
    controller.preference = self.classInfo;
    
    SYBaseNavigationController* navigationController = [[SYBaseNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{
        
    }];
}

- (void) popoverMenu:(SYPopoverMenu *)menu select:(NSInteger)menuId
{
    if (self.classCircleId > 0)
    {
        switch (menuId) {
            case 0:
                [self presentPreferenceViewController];
                break;
            case 1:
                [self requestReport];
                break;
            default:
                break;
        }
    }
    else
    {
        switch (menuId) {
            case 0:
                [self showClearMessageActionSheet];
                break;
            case 1:
                [self requestReport];
                break;
            default:
                break;
        }
    }
}

- (void) requestClassCircleInfo
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForClassCircleInfo] postValues:@{@"class_id" : [NSNumber numberWithInt:self.classCircleId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            bself.classInfo = [[DFGroupMessageItem alloc] initWithClassCircleInfo:[resultInfo objectForKey:@"info"]];
            bself.title = bself.classInfo.title;
            [bself connectRTMPClient];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) reloadDataWithClassCircleInfo:(NSDictionary *)info
{
    
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.inputPanel registerKeyboardObservers];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.inputPanel unregisterKeyboardObservers];
}

- (void) initBubbleTableView
{
    CGFloat offsetY = 0;
    CGRect navigationBarFrame = self.customNavigationBar.frame;
    offsetY += navigationBarFrame.origin.y + navigationBarFrame.size.height;
    
    CGFloat height = self.view.frame.size.height - offsetY - self.inputPanel.inputBarView.frame.size.height;
    
    self.bubbleTableView=[[UIBubbleTableView alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, height)];
    self.bubbleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.bubbleTableView.backgroundColor = self.view.backgroundColor;
    [self.view addSubview:self.bubbleTableView];
    self.bubbleTableView.bubbleDataSource = self;
    self.bubbleTableView.snapInterval = 300;
    self.bubbleTableView.showAvatars = YES;
    self.bubbleTableView.bubbleDelegate = self;
    self.bubbleTableView.showsVerticalScrollIndicator = YES;
    [self.bubbleTableView reloadData];
    
    [self enableRefreshAtHeaderForScrollView:self.bubbleTableView];
    [_refreshHeaderView setTitle:@"下拉获取更早私信" forState:EGOOPullRefreshNormal];
    [_refreshHeaderView setTitle:@"松开后开始获取" forState:EGOOPullRefreshPulling];
    [_refreshHeaderView setTitle:@"获取中..." forState:EGOOPullRefreshLoading];
    
}

- (void) reloadDataForRefresh
{
    if (self.offsetMessageId > 0)
    {
        [self requestLatestMessage];
    }
    else
    {
        [SYPrompt showWithText:@"没有更早私信" topOffset:80];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) leftButtonClicked:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_rtmpClient disconnect];
    if ([_rtmpClient isDelegate:self])
    {
        [_rtmpClient removeDelegate:self];
    }
    
    if (self.closedBlock && self.myNewestMessageForClosedBlock.length > 0)
    {
        self.closedBlock(self.myNewestMessageForClosedBlock, self.myNewestMessageTimeintervalForClosedBlock);
    }
    
    [super leftButtonClicked:sender];
}

#pragma mark - background foreground

- (void) applicationBecomeActive:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    [self connectRTMPClient];
}

- (void) applicationResignActive:(NSNotification *)notification
{
    [self disconnectRTMPClient];
}

- (void) applicationdidEnterForegound:(NSNotification *)notification
{
    self.needReConnectRTMP = YES;
}

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    self.needReConnectRTMP = NO;
}

- (void) registerObservers
{
    NSNotificationCenter* notifiy = [NSNotificationCenter defaultCenter];
    [notifiy addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationResignActive:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationdidEnterForegound:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    if (self.classCircleId > 0)
    {
        [notifiy addObserver:self selector:@selector(preferenceUpdated:) name:kNotificationClasscircleNameUpdated object:nil];
        [notifiy addObserver:self selector:@selector(preferenceUpdated:) name:kNotificationClasscircleIgnoreUpdated object:nil];
    }
}

- (void) preferenceUpdated:(NSNotification *)notification
{
    self.title = self.classInfo.title;
}

#pragma mark - rtmpclient

- (void) disconnectRTMPClient
{
    NSLog(@"%s, disconnect, begin", __FUNCTION__);
    if ([_rtmpClient isDelegate:self])
    {
        [_rtmpClient removeDelegate:self];
    }
    
    if ([_rtmpClient connected])
    {
        [_rtmpClient disconnect];
    }
    NSLog(@"%s, disconnect, end", __FUNCTION__);
}

- (void) connectRTMPClient
{
    NSString* url = nil;
    if (self.userId > 0)
    {
        url = [DFPreference sharedPreference].privateMessageChatUrl;
        if (url.length == 0)
        {
            //默认的端口号1935
            url = @"rtmp://chat.maiqinqin.com:1935/chat";
        }
    }
    else
    {
        url = self.classInfo.chatUrl;
    }
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:user.nickname forKey:@"nickname"];
    [dict setObject:[NSString stringWithFormat:@"%d", user.persistentId] forKey:@"userid"];
    NSArray* array = [NSArray arrayWithObject:dict];
    
    self.rtmpClient = [[RTMPClient alloc] init:url andParams:array];
    self.rtmpClient.delegate = self;
    [self.rtmpClient connect];
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
        NSLog(@"%s, connect", __FUNCTION__);
        [self connectRTMPClient];
    }
}
#pragma mark    RTMP IRTMPClientDelegate
- (void) connectedEvent
{
    self.needReConnectRTMP = NO;
    self.continueFailedCount = 0;
}

- (void) disconnectedEvent
{
    NSLog(@"%s", __FUNCTION__);
    _rtmpClient = nil;
}

- (void) resultReceived:(id<IServiceCall>)call
{
    NSString *method = [call getServiceMethodName];
    NSArray *args = [call getArguments];
    int status = [call getStatus];
    
    NSLog(@" $$$$$$ <IRTMPClientDelegate>> resultReceived <---- status=%d, method='%@', arguments=%d\n", status, method, args.count);

    if ([method isEqualToString:@"ServerSendSingleChat"] || [method isEqualToString:@"getMessage"]) {
        
        NSDictionary* info = [args objectAtIndex:0];

        NSBubbleData* data = [self bubbleDataWIthInfo:info];
        if (data != nil)
        {
            [self.bubbleData addObject:data];
            [self.bubbleTableView reloadData];
            [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
        }
    }
}

- (NSBubbleData *) bubbleDataWIthInfo:(NSDictionary *)info
{
    NSInteger fromUserId = 0;
    NSInteger toUserId = 0;
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    NSString* textMessage = nil;
    NSString* avatarUrl = nil;
    NSInteger interval = 0;
    NSInteger voiceDuration = [[info objectForKey:@"duration"] integerValue];
    
    if (self.classCircleId > 0)
    {
        fromUserId = [[info objectForKey:@"userid"] integerValue];
        textMessage = [info objectForKey:@"content"];
        avatarUrl = [info objectForKey:@"avatar"];
        interval = [[info objectForKey:@"add_time"] integerValue];
    }
    else
    {
        fromUserId = [[info objectForKey:@"fromid"] integerValue];
        toUserId = [[info objectForKey:@"toid"] integerValue];
        
        if (!((fromUserId == user.persistentId && toUserId == self.userId) || (toUserId == user.persistentId && fromUserId == self.userId)))
        {
            return nil;
        }
        textMessage = [info objectForKey:@"msg"];
        avatarUrl = self.avatarUrl;
        interval = [[info objectForKey:@"ts"] integerValue];
    }
    
    NSString* voiceUrl = [info objectForKey:@"voice"];
    if (voiceUrl.length > 0)
    {
        if (self.voices == nil)
        {
            self.voices = [NSMutableDictionary dictionary];
        }
        [self.voices setObject:voiceUrl forKey:[NSString stringWithFormat:@"%d", interval]];
    }
    
    UIView* messageView = nil;
    UILabel* voiceDurationLabel = nil;
    
    BOOL isMe = (fromUserId == user.persistentId);
    if (textMessage.length > 0)
    {
        CoreTextView *chatScrollView = [[CoreTextView alloc] initWithFrame:CGRectMake(0,0,0,0)];
        chatScrollView.backgroundColor = [UIColor clearColor];
        NSString* message = [textMessage replaceUserIdNicknameJsonWithHrefAtDoubleAt];
        if (isMe)
        {
            message = [NSString stringWithFormat:@"<span color=\"#ffffff\">%@</span>", message];
        }
        chatScrollView.attributedString = [NSAttributedString attributedStringWithHTML:[message replaceFacesWithHtmlFormat] renderer:nil];
        
        CGSize r = [chatScrollView sizeThatFits:CGSizeMake(self.view.frame.size.width - 60 * 2, 50)];
        [chatScrollView setFrame:CGRectMake(0, 0, r.width,r.height)];
        
        messageView = chatScrollView;
        
        self.myNewestMessageForClosedBlock = isMe ? [NSString stringWithFormat:@"%@：%@", user.nickname, textMessage] : @"";
    }
    else
    {
        voiceDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 14, 15)];
        voiceDurationLabel.backgroundColor = [UIColor clearColor];
        voiceDurationLabel.textColor = RGBCOLOR(159, 159, 159);
        voiceDurationLabel.font = [UIFont systemFontOfSize:14];
        voiceDurationLabel.text = [NSString stringWithFormat:@"%d'", voiceDuration];
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 52, 23)];
        button.backgroundColor = [UIColor clearColor];
        button.tag = interval;
        if (isMe)
        {
            voiceDurationLabel.textAlignment = NSTextAlignmentRight;
            [self ensureMyVoiceAnimatingImages];
            [button setImage:[UIImage imageNamed:@"msg_me_voice_normal.png"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"msg_me_voice_normal.png"] forState:UIControlStateHighlighted];
            button.imageView.animationImages = self.myVoiceAnimatingImages;
            button.imageView.animationDuration = 0.9;
            button.imageView.animationRepeatCount = INT16_MAX;
        }
        else
        {
            voiceDurationLabel.textAlignment = NSTextAlignmentLeft;
            [self ensureOtherVoiceAnimatingImages];
            [button setImage:[UIImage imageNamed:@"msg_other_voice_normal.png"] forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"msg_other_voice_normal.png"] forState:UIControlStateHighlighted];
            button.imageView.animationImages = self.otherVoiceAnimatingImages;
            button.imageView.animationDuration = 0.9;
            button.imageView.animationRepeatCount = INT16_MAX;
        }
        
        [button addTarget:self action:@selector(bubbleVoiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        messageView = button;
        
        self.myNewestMessageForClosedBlock = isMe ? [NSString stringWithFormat:@"%@：[语音]", user.nickname] : @"";
    }
    self.myNewestMessageTimeintervalForClosedBlock = interval;
    
    NSDate* date = nil;
    if (interval > 0)
    {
        date =  [NSDate dateWithTimeIntervalSince1970:interval];
    }
    else
    {
        date = [NSDate date];
    }
    
    UIEdgeInsets insets = UIEdgeInsetsMake(9, 0, 9, 0);
    
    if (isMe)
    {
        insets.left = 9;
        insets.right = 15;
        avatarUrl = user.avatarUrl;
    }
    else
    {
        insets.left = 15;
        insets.right = 9;
        avatarUrl = avatarUrl;
    }
    
    NSBubbleData *sayBubble = [NSBubbleData dataWithView:messageView date:date type:(!isMe ? BubbleTypeSomeoneElse : BubbleTypeMine) insets:insets];
    sayBubble.trailView = voiceDurationLabel;
    sayBubble.avatar=[NSURL URLWithString:avatarUrl];
    return sayBubble;
}

- (void) ensureMyVoiceAnimatingImages
{
    if (self.myVoiceAnimatingImages == nil)
    {
        self.myVoiceAnimatingImages = [NSMutableArray array];
        [self.myVoiceAnimatingImages addObject:[UIImage imageNamed:@"msg_me_voice_play_1.png"]];
        [self.myVoiceAnimatingImages addObject:[UIImage imageNamed:@"msg_me_voice_play_2.png"]];
        [self.myVoiceAnimatingImages addObject:[UIImage imageNamed:@"msg_me_voice_play_3.png"]];
    }
}

- (void) ensureOtherVoiceAnimatingImages
{
    if (self.otherVoiceAnimatingImages == nil)
    {
        self.otherVoiceAnimatingImages = [NSMutableArray array];
        [self.otherVoiceAnimatingImages addObject:[UIImage imageNamed:@"msg_other_voice_play_1.png"]];
        [self.otherVoiceAnimatingImages addObject:[UIImage imageNamed:@"msg_other_voice_play_2.png"]];
        [self.otherVoiceAnimatingImages addObject:[UIImage imageNamed:@"msg_other_voice_play_3.png"]];
    }
}

- (void) bubbleVoiceButtonClicked:(UIButton *)sender
{
    if (self.voicePlayer == nil)
    {
        self.voicePlayer = [[SYVoicePlayer alloc] init];
        self.voicePlayer.delegate = self;
    }
    
    [self.animatingButton.imageView stopAnimating];
    self.animatingButton.highlighted = NO;
    
    self.animatingButton = sender;
    [self.animatingButton.imageView startAnimating];
    
    NSString* voiceUrl = [self.voices objectForKey:[NSString stringWithFormat:@"%d", sender.tag]];
    [self.voicePlayer playWithUrl:voiceUrl tag:sender.tag];
}

- (void) voicePlayed:(SYVoicePlayer *)player tag:(NSInteger)tag
{
    NSLog(@"%s, %d", __FUNCTION__, tag);
}

- (void) voiceStopped:(SYVoicePlayer *)player
{
    NSLog(@"%s", __FUNCTION__);
    
    [self.animatingButton.imageView stopAnimating];
    self.animatingButton.highlighted = NO;
    self.animatingButton = nil;
}

- (NSBubbleData *)bubbleTableView:(UIBubbleTableView *)tableView dataForRow:(NSInteger)row
{
    return [self.bubbleData objectAtIndex:row];
}

- (NSInteger)rowsForBubbleTable:(UIBubbleTableView *)tableView
{
    return [self.bubbleData count];
}

#define kBottomButtonFrameHeight 63.0f

- (void) initFaceTextInputPanel
{
    self.inputPanel = [[SYVoiceFaceTextInputPanel alloc] initWithCanvasView:self.view];
    self.inputPanel.inputBarView.backgroundColor = RGBCOLOR(246, 246, 246);
    self.inputPanel.delegate = self;
    
    self.recordController = [[SYRecordController alloc] init];
    self.recordController.delegate = self;
    self.recordController.recordPanel = self.inputPanel.recordPanel;
    
    [self.inputPanel putInBack];
}

#pragma mark - face input panel

- (void) recordControllerVoiceClear:(SYRecordController *)controller
{
    self.inputPanel.voiceMarkedImageView.hidden = YES;
    self.voiceUrl = @"";
    self.voiceDuration = 0;
}

- (void) recordControllerVoiceRecord:(SYRecordController *)controller duration:(NSInteger)duration
{
    self.inputPanel.voiceMarkedImageView.hidden = NO;
    self.voiceHasModified = YES;
    self.voiceDuration = duration;
}

- (BOOL) uploadVoice:(NSString *)text
{
    typeof(self) __weak bself = self;
    NSString* wavFilePath = [SYFilePath currentVoiceWAVFilePath];
    if (self.voiceHasModified && [SYFilePath fileExists:wavFilePath])
    {
        NSString* amrFilePath = [SYFilePath currentVoiceAMRFilePath];
        
        if (![SYFilePath fileExists:amrFilePath])
        {
            [VoiceConverter convertWAV:wavFilePath toAMR:amrFilePath];
        }
        
        if ([SYFilePath fileExists:amrFilePath])
        {
            SYHttpRequestUploadFileParameter* param = [[SYHttpRequestUploadFileParameter alloc] init];
            param.data = [NSData dataWithContentsOfFile:amrFilePath];
            param.filename = @"my_post.amr";
            param.contentType = @"audio/*";
            SYHttpRequest* request = [SYHttpRequest uploadFile:[DFUrlDefine urlForUploadVoice] parameter:param finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
                if (success)
                {
                    bself.voiceUrl = [[resultInfo objectForKey:@"info"] objectForKey:@"url"];
                    bself.voiceHasModified = NO;
                    
                    //-------------------upload
                    [bself sendText:text forFacePanel:bself.inputPanel];
                }
                else
                {
                    [bself hideProgress];
                    [UIAlertView showWithTitle:@"上传语音" message:errorMsg];
                }
            }];
            [self.requests addObject:request];
            return YES;
        }
    }
    return NO;
}

- (BOOL) facePanelShouldEditing
{
//    return [[MYUser currentActiveUser] validateLogin:^{
//        return NO;
//    }];
    return YES;
}

- (void) facePanelBeginEditing:(SYFaceTextInputPanel *)panel
{
    CGRect tableViewFrame = self.bubbleTableView.frame;
    tableViewFrame.size.height = self.inputPanel.inputBarView.frame.origin.y - tableViewFrame.origin.y;
    self.bubbleTableView.frame = tableViewFrame;
    
    [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
}

-(void) facePanelEndEditing:(SYFaceTextInputPanel *)panel
{
    CGRect tableViewFrame = self.bubbleTableView.frame;
    tableViewFrame.size.height = self.inputPanel.inputBarView.frame.origin.y - tableViewFrame.origin.y;
    self.bubbleTableView.frame = tableViewFrame;
    
    [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
    
    [self.bubbleTableView reloadData];
}

- (void) resetVoice
{
    [self hideProgress];
    self.voiceUrl = @"";
    self.voiceHasModified = NO;
    self.inputPanel.voiceMarkedImageView.hidden = YES;
}

- (void) sendText:(NSString *)text forFacePanel:(SYFaceTextInputPanel *)panel
{
    BOOL needUploadVoice = [self uploadVoice:text];
    [self showProgress]; //
    if (needUploadVoice)
    {
        return;
    }
    
    if (text.length == 0 && self.voiceUrl.length == 0)
    {
        [SYPrompt showWithText:@"说点什么吧"];
        return;
    }
    
    if (self.classCircleId > 0)
    {
        [self sendGroupMessage:text];
    }
    else
    {
        [self sendContactMessage:text];
    }
}

- (void) sendContactMessage:(NSString *)text
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.userId] forKey:@"userid"];
    NSMutableDictionary* secondDict = nil;
    if (self.voiceUrl.length > 0)
    {
        [dict setObject:self.voiceUrl forKey:@"voice"];
        [dict setObject:[NSNumber numberWithInt:self.voiceDuration] forKey:@"duration"];
        
        if (text.length > 0)
        {
            secondDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.userId] forKey:@"userid"];
            [secondDict setObject:text forKey:@"msg"];
        }
    }
    else
    {
        [dict setObject:text forKey:@"msg"];
    }
    [self sendContactRequest:dict other:secondDict];
}

- (void) sendContactRequest:(NSDictionary *)dict other:(NSDictionary *)secondDict
{
    typeof(self)  __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSendContactMessage] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        if (succeed)
        {
            [bself reloadDataWithMyContactInfo:[resultInfo objectForKey:@"info"]];
            
            if (secondDict == nil)
            {
                [bself resetVoice];
                [bself.inputPanel endEditing];
            }
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
        
        if (secondDict == nil)
        {
            [bself hideProgress];
        }
        else
        {
            [bself sendContactRequest:secondDict other:nil];
        }
        
    }];
    
    [self.requests addObject:request];
}

- (void) sendGroupMessage:(NSString *)text
{
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.classCircleId] forKey:@"class_id"];
    NSMutableDictionary* secondDict = nil;
    if (self.voiceUrl.length > 0)
    {
        [dict setObject:self.voiceUrl forKey:@"voice"];
        [dict setObject:[NSNumber numberWithInt:self.voiceDuration] forKey:@"duration"];
        
        if (text.length > 0)
        {
            secondDict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.classCircleId] forKey:@"class_id"];
            [secondDict setObject:[text replaceFacesIDWithFaceDescriptions] forKey:@"content"];
        }
    }
    else
    {
        [dict setObject:[text replaceFacesIDWithFaceDescriptions] forKey:@"content"];
    }
    
    [self sendGroupRequest:dict other:secondDict];
}

- (void) sendGroupRequest:(NSDictionary *)dict other:(NSDictionary *)secondDict
{
    typeof(self)  __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSendClassCircleMessage] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        if (succeed)
        {
            if (secondDict == nil)
            {
                [bself resetVoice];
                [bself.inputPanel endEditing];
            }
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
        
        if (secondDict == nil)
        {
            [bself hideProgress];
        }
        else
        {
            [bself sendGroupRequest:secondDict other:nil];
        }
    }];
    
    [self.requests addObject:request];
}

- (void) requestReport
{
    [self showProgress];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:self.userId] forKey:@"content"];
    [dict setObject:@"5" forKey:@"type"];
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforReport] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        [bself hideProgress];
        
        if (succeed)
        {
            [SYPrompt showWithText:@"您已举报成功，一经核实会进行处理!"];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
    }];
    
    [self.requests addObject:request];
}

- (void) showClearMessageActionSheet
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"确定清空聊天记录" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil];
    [actionSheet showInView:self.view];
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self clearMessage];
    }
}

- (void) clearMessage
{
    typeof(self) __weak bself = self;
    
    [self showProgress];
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.userId] forKey:@"userid"];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForClearMessage] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        if (succeed)
        {
            [bself.bubbleData removeAllObjects];
            [bself.bubbleTableView reloadData];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
        
        [bself hideProgress];
        
    }];
    
    [self.requests addObject:request];
}

#define kFaceKeyboardHeight 216

- (void) reloadDataWithMyContactInfo:(NSDictionary *)dict
{
//    NSString* msg = [NSString stringWithFormat:@"<span color=\"#ffffff\">%@</span>", [dict objectForKey:@"msg"]];
//    CoreTextView *chatScrollView=[[CoreTextView alloc] initWithFrame:CGRectMake(0,0,0,0)];
//    chatScrollView.backgroundColor=[UIColor clearColor];
//    chatScrollView.attributedString=[NSAttributedString attributedStringWithHTML:[msg replaceFacesWithHtmlFormat] renderer:nil];
//    CGSize r=[chatScrollView sizeThatFits:CGSizeMake(200, 300)];
//    [chatScrollView setFrame:CGRectMake(0 , 0, r.width,r.height)];
//    
//    chatScrollView.tag=[[dict objectForKey:@"id"] intValue]+100;
//    
//    NSBubbleData *sayBubble = [NSBubbleData dataWithView:chatScrollView date: [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"ts"] intValue]] type:BubbleTypeMine insets:UIEdgeInsetsMake(9, 9, 9, 15)];
//    sayBubble.avatar=[NSURL URLWithString:[DFPreference sharedPreference].currentUser.avatarUrl];
    
    NSBubbleData* data = [self bubbleDataWIthInfo:dict];
    [self.bubbleData addObject:data];
    [self.bubbleTableView reloadData];
    [self.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
}

#pragma mark -

- (void) requestLatestMessage
{
    typeof(self) __weak bself = self;
    
    [self showProgress];
    
    NSString* url = nil;
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if (self.classCircleId > 0)
    {
        [dict setObject:[NSNumber numberWithInt:self.classCircleId] forKey:@"class_id"];
        url = [DFUrlDefine urlForLatestClassCircleMessages];
    }
    else
    {
        [dict setObject:[NSNumber numberWithInt:self.userId] forKey:@"userid"];
        url = [DFUrlDefine urlForLatestContactMessages];
    }
    [dict setObject:[NSNumber numberWithInt:self.offsetMessageId] forKey:@"offsetid"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:url postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        if (succeed)
        {
            if (bself.offsetMessageId <= 0)
            {
                [bself.bubbleData removeAllObjects];
            }
            
            for (NSDictionary *info in [resultInfo objectForKey:@"info"]) {
                NSBubbleData* data = [self bubbleDataWIthInfo:info];
                if (data != nil)
                {
                    [bself.bubbleData addObject:data];
                }
            }
            
            [bself.bubbleTableView reloadData];
            if (bself.offsetMessageId == 0)
            {
                [bself.bubbleTableView scrollBubbleViewToBottomAnimated:YES];
            }
            
            bself.offsetMessageId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
        
        [bself hideProgress];
        
    }];
    
    [self.requests addObject:request];
}

//-(BOOL)coreTextView:(CoreTextView*)view openURL:(NSURL*)url rect:(CGRect)rect
//{
//    if ([url.scheme isEqualToString:@"mychat"])
//    {
//        NSString* host = url.host;
//        NSLog(@"host:%@", host);
//        
//        NSInteger userId = [host integerValue];
//        
//        if ([MYUser validteUserId:userId])
//        {
//            MYProfileViewController* controller = [[MYProfileViewController alloc] initWithUserId:userId];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//    }
//    return YES;
//}

#pragma mark - bubble delegate

- (void) avatarView:(NSBubbleType)type tappedForBubbleTableView:(UIBubbleTableView *)bubbleTableView
{
//    switch (type) {
//        case BubbleTypeMine:
//        {
//            MYProfileViewController* controller = [[MYProfileViewController alloc] initWithUserId:[MYUser currentActiveUser].userId];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//            break;
//        case BubbleTypeSomeoneElse:
//        {
//            MYProfileViewController* controller = [[MYProfileViewController alloc] initWithUserId:self.userId];
//            [self.navigationController pushViewController:controller animated:YES];
//        }
//            break;
//        default:
//            break;
//    }
}

- (void) bubbleTableViewDidScroll:(UIBubbleTableView *)tableView
{
    [self scrollViewDidScroll:tableView];
}

- (void) bubbleTableViewDidEndDragging:(UIBubbleTableView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
}

- (void) bubbleViewDidEndDecelerating:(UIBubbleTableView *)scrollView
{
    [self scrollViewDidEndDecelerating:scrollView];
}

@end
