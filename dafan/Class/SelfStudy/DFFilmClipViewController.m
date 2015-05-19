//
//  DFTVViewController.m
//  dafan
//
//  Created by iMac on 14-9-9.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFColorDefine.h"
#import "DFChatTableViewCell.h"
#import "DFChatItem.h"
#import "DFUrlDefine.h"
#import "DFCommonImages.h"
#import "UIAlertView+SYExtension.h"
#import "SYHttpRequest.h"
#import "SYFaceTextInputPanel.h"
#import "NSString+HTMLCoreText.h"
#import "NSString+SYCoreText.h"
#import "UIView+SYShape.h"
#import "SYAVPlayer.h"
#import "SYPrompt.h"
#import "UMSocialData.h"
#import "UMSocialSnsPlatformManager.h"
#import "SYContextMenu.h"
#import "DFChatTableViewCell.h"
#import "DFFilmClipComment.h"
#import "DFFilmClipViewController.h"
#import "UIImageView+WebCache.h"
#import "UIImage+SYExtension.h"
#import "SYFullShareActionSheet.h"
#import "DFPreference.h"
#import "UMSocialScreenShoter.h"
#import "DFUserProfile.h"
#import "SYBaseContentViewController+EGORefresh.h"

@interface DFFilmClipViewController ()<UIGestureRecognizerDelegate, SYAVPlayerDelegate, SYFaceTextInputPanelDelegate, SYContextMenuDelegate>

@property(nonatomic, strong) DFFilmClipItem* clipItem;

@property(nonatomic, strong) UIView* tvContainerView;
@property(nonatomic, strong) UIImageView* tvPreviewImageView;

@property(nonatomic, strong) UITableView* commentTableView;

@property(nonatomic, strong) UIView* tvControlBar;
@property(nonatomic, strong) UISlider* tvSlider;
@property(nonatomic, strong) UILabel* tvCurrentTimeLabel;
@property(nonatomic, strong) UILabel* tvDurationLabel;
@property(nonatomic, strong) UIButton* playpauseButton;

@property(nonatomic, strong) UIButton* bottomCommentButton;
@property(nonatomic, strong) UIButton* bottomCollectButton;
@property(nonatomic, strong) UIButton* bottomShareButton;

@property(nonatomic, strong) NSTimer* progressTimer;
@property (nonatomic) NSInteger currentDuration;

@property(nonatomic, strong) SYFaceTextInputPanel* faceTextInputPanel;
@property(nonatomic, strong) NSMutableArray* commentItems;
@property(nonatomic) NSInteger offsetId;

@property(nonatomic, strong) NSString* sharedUrl;

@end

@implementation DFFilmClipViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithFilmClip:(DFFilmClipItem *)clipItem
{
    self = [super init];
    if (self)
    {
        self.clipItem = clipItem;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[SYAVPlayer sharedAVPlayer] startReachabilityNotifier];
    [self configCustomNavigationBar];
    [self initSubviews];
    [self initFaceTextInputPanel];

    [self requestFilmClipInfo];
    [self requestComments:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.clipItem.sourceUrl.length > 0)
    {
        [[SYAVPlayer sharedAVPlayer] startReachabilityNotifier];
        if ([SYAVPlayer sharedAVPlayer].delegate == self)
        {
            [[SYAVPlayer sharedAVPlayer] resume];
        }
        else
        {
            [[SYAVPlayer sharedAVPlayer] setupPlayerWithCarrierView:self.tvContainerView withDelegate:self];
            [[SYAVPlayer sharedAVPlayer] playWithUrl:self.clipItem.sourceUrl];
        }
    }
    [self.faceTextInputPanel registerKeyboardObservers];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[SYAVPlayer sharedAVPlayer] pause];
    
    [self.faceTextInputPanel unregisterKeyboardObservers];
}

- (void) configCustomNavigationBar
{
    [self.customNavigationBar setRightButtonWithStandardTitle:@"举报"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initSubviews
{
    [self initTVSubviews];
    [self initBottomBar];
    [self configTableView];
    [self reloadCommonSubViews];
    [self reloadVideoViews];
}

#pragma mark - 

- (void) startProgressTimer
{
    [self stopProgressTimer];
    
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(progressTimerScheduled:) userInfo:nil repeats:YES];
}

- (void) progressTimerScheduled:(NSTimer *)timer
{
    [self refreshPlayTimeLabel];
    
    if (self.currentDuration <= 0)
    {
        [self refreshDurationLabel];
    }
    
    if (self.currentDuration > 0)
    {
        CGFloat progress = (CGFloat)[[SYAVPlayer sharedAVPlayer] currentPlayTime] / self.currentDuration;
        self.tvSlider.value = progress;
    }
}

- (void) stopProgressTimer
{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}

- (void)resetTimeLabels
{
    self.tvDurationLabel.text = @"/00:00";
    self.tvCurrentTimeLabel.text = @"00:00";
}

- (void) refreshDurationLabel
{
    self.currentDuration = [[SYAVPlayer sharedAVPlayer] duration];
    if (self.currentDuration > 0)
    {
        self.tvDurationLabel.text = [NSString stringWithFormat:@"/%02d:%02d", self.currentDuration / 60, self.currentDuration % 60];
    }
    else
    {
        self.tvDurationLabel.text = @"/00:00";
    }
}

- (void) refreshPlayTimeLabel
{
    NSInteger currentTime = [[SYAVPlayer sharedAVPlayer] currentPlayTime];
    if (currentTime <= self.currentDuration)
    {
        self.tvCurrentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", currentTime / 60, currentTime % 60];
    }
}

#pragma mark - load & refresh

- (void) requestFilmClipInfo
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForFilmClipDetail] postValues:@{@"id": [NSNumber numberWithInt:self.clipItem.persistentId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            bself.sharedUrl = [info objectForKey:@"share_url"];
            bself.clipItem = [[DFFilmClipItem alloc] initWithItemDictionary:info];
            [bself reloadCommonSubViews];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) requestComments:(BOOL) reload
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    if (self.commentItems == nil)
    {
        self.commentItems = [NSMutableArray array];
    }
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.clipItem.persistentId] forKey:@"video_id"];
    if (!reload)
    {
        [dict setObject:[NSNumber numberWithInt:self.offsetId] forKey:@"offsetid"];
    }
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForFilmpClipComments] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        
        if (success)
        {
            bself.offsetId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];
            if (reload)
            {
                [bself.commentItems removeAllObjects];
            }
            [bself reloadCommentsTableView:[resultInfo objectForKey:@"info"]];
            [bself setTableFooterStauts:bself.offsetId > 0 empty:bself.commentItems.count > 0];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
            [bself setTableFooterStauts:YES empty:NO];
        }
    }];
    [self.requests addObject:request];
}

- (void) reloadDataForRefresh
{
    [self requestComments:YES];
}

- (void) requestMoreDataForTableFooterClicked
{
    [self requestComments:NO];
}

- (void) reloadCommonSubViews
{
    self.title = self.clipItem.title;
    [self.bottomCommentButton setTitle:[NSString stringWithFormat:@"%d", self.clipItem.commentCount] forState:UIControlStateNormal];
    [self.bottomCollectButton setTitle:[NSString stringWithFormat:@"%d", self.clipItem.collectionCount] forState:UIControlStateNormal];
    self.bottomCollectButton.selected = self.clipItem.isCollected;
    [self.bottomShareButton setTitle:[NSString stringWithFormat:@"%d", self.clipItem.shareCount] forState:UIControlStateNormal];
    [self.tvPreviewImageView setImageWithURL:[NSURL URLWithString:self.clipItem.previewImageUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
}

- (void) reloadVideoViews
{
    [[SYAVPlayer sharedAVPlayer] setupPlayerWithCarrierView:self.tvContainerView withDelegate:self];
    [[SYAVPlayer sharedAVPlayer] playWithUrl:self.clipItem.sourceUrl];
    [self hidePlayControlBarDelayedFromNow];
}

#define kCellMarginLeftRight 6.f
#define kCellMarginTop 2.f
#define kCellAvatarTextSpace 6.f
#define kCellMarginBottom 9.f //
#define kCellTextMarginTop 7.f

- (void) reloadCommentsTableView:(NSArray *)infos
{
    for (NSDictionary* info in infos)
    {
        DFFilmClipComment* comment = [[DFFilmClipComment alloc] initWithDictionary:info];
        [self.commentItems addObject:comment];
    }
    
    for (DFFilmClipComment* item in self.commentItems)
    {
        [item.chatItem resetTextContentSizeWithConstraintSize:CGSizeMake(self.view.frame.size.width - kCellMarginLeftRight - kCellAvatarTextSpace - kChatTableViewCellAvatarSize, 200)];
        
        item.chatItem.chatTableCellHeight = kCellMarginTop + kCellMarginBottom + (item.chatItem.textContentSize.height > kChatTableViewCellAvatarSize ? item.chatItem.textContentSize.height : kChatTableViewCellAvatarSize);
    }
    [self.tableView reloadData];
}


#pragma mark - avplayer

- (void) avPlayer:(SYAVPlayer *)player statusChanged:(SYAVPlayerStatus)status
{
    NSLog(@"studio avPlayer status changed: %d", status);
    switch (status) {
        case SYAVPlayerStatusStopped:
            [self stopProgressTimer];
            self.playpauseButton.selected = NO;
            [self resetTimeLabels];
            break;
        case SYAVPlayerStatusCompleted:
            [self stopProgressTimer];
            self.playpauseButton.selected = NO;
            [self.tvContainerView insertSubview:self.tvPreviewImageView belowSubview:self.tvControlBar];
            [self showControlBarAnimatedPeroidly:NO];
            break;
        case SYAVPlayerStatusSetup:
        case SYAVPlayerStatusPreparing:
        case SYAVPlayerStatusPause:
        case SYAVPlayerStatusError:
            [self stopProgressTimer];
            self.playpauseButton.selected = NO;
            break;
            
        case SYAVPlayerStatusBufferBegin:
            [self stopProgressTimer];
            [self showProgresWithText:@"缓冲中.." inView:self.tvContainerView];
            break;
            
        case SYAVPlayerStatusBufferEnd:
            [self hideProgress];
            [self startProgressTimer];
            break;
            
        case SYAVPlayerStatusPrepared:
            [self refreshDurationLabel];
            self.playpauseButton.selected = NO;
            [self.tvPreviewImageView removeFromSuperview];
            break;
        case SYAVPlayerStatusPlaying:
            [self startProgressTimer];
            self.playpauseButton.selected = YES;
            self.tvSlider.value = 0;
            break;
            
        case SYAVPlayerStatusSeekCompleted:
            [self hideProgress];
            [self refreshPlayTimeLabel];
            self.playpauseButton.selected = NO;
            break;
            
        default:
            break;
    }
}

#define kTVContentHeight 200.f
#define kTVControlBarHeight 31.f
#define kTVSliderWidth 156.f

- (void) initTVSubviews
{
    CGRect navigationFrame = self.customNavigationBar.frame;
    self.tvContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationFrame.size.height, navigationFrame.size.width, kTVContentHeight)];
    self.tvContainerView.backgroundColor = [UIColor blackColor];
    self.tvContainerView.clipsToBounds = YES;
    [self.view addSubview:self.tvContainerView];
    //视频播放视图
    self.tvPreviewImageView = [[UIImageView alloc] initWithFrame:self.tvContainerView.bounds];
    [self.tvContainerView addSubview:self.tvPreviewImageView];
    //控制条
    self.tvControlBar = [[UIView alloc] initWithFrame:CGRectMake(0, kTVContentHeight - kTVControlBarHeight, navigationFrame.size.width, kTVControlBarHeight)];
    self.tvControlBar.clipsToBounds = YES;
    self.tvControlBar.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.8];
    [self.tvContainerView addSubview:self.tvControlBar];
    //控制时间的滑竿
    self.tvSlider = [[UISlider alloc] initWithFrame:CGRectMake(32.f, 0, kTVSliderWidth, kTVControlBarHeight)];
    [self.tvSlider setMaximumTrackImage:[UIImage imageWithColor:[UIColor grayColor] size:CGSizeMake(kTVSliderWidth, 4.f)] forState:UIControlStateNormal];
    [self.tvSlider setMinimumTrackImage:[UIImage imageWithColor:kMainDarkColor size:CGSizeMake(kTVSliderWidth, 4.f)] forState:UIControlStateNormal];
    [self.tvSlider setThumbImage:[UIImage imageNamed:@"playbar_progress_thumb.png"] forState:UIControlStateNormal];
    self.tvSlider.continuous = NO;
    [self.tvSlider addTarget:self action:@selector(tvSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.tvControlBar addSubview:self.tvSlider];
    //当前时间
    self.tvCurrentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(202.f, 0, 40.f, kTVControlBarHeight)];
    self.tvCurrentTimeLabel.backgroundColor = [UIColor clearColor];
    self.tvCurrentTimeLabel.textColor = [UIColor whiteColor];
    self.tvCurrentTimeLabel.textAlignment = NSTextAlignmentRight;
    self.tvCurrentTimeLabel.font = [UIFont systemFontOfSize:13];
    self.tvCurrentTimeLabel.text = @"00:00";
    [self.tvControlBar addSubview:self.tvCurrentTimeLabel];
    //持续时间
    self.tvDurationLabel = [[UILabel alloc] initWithFrame:CGRectMake(242.f, 0, 40.f, kTVControlBarHeight)];
    self.tvDurationLabel.backgroundColor = [UIColor clearColor];
    self.tvDurationLabel.textColor = [UIColor grayColor];
    self.tvDurationLabel.text = @"/10:01";
    self.tvDurationLabel.font = [UIFont systemFontOfSize:13];
    [self.tvControlBar addSubview:self.tvDurationLabel];
    //播放/暂停按钮
    self.playpauseButton = [[UIButton alloc] initWithFrame:CGRectMake(288.f, 0, kTVControlBarHeight, kTVControlBarHeight)];
    self.playpauseButton.backgroundColor = [UIColor clearColor];
    [self.playpauseButton setImage:[UIImage imageNamed:@"playbar_pause.png"] forState:UIControlStateSelected];
    [self.playpauseButton setImage:[UIImage imageNamed:@"playbar_play.png"] forState:UIControlStateNormal];
    [self.playpauseButton addTarget:self action:@selector(playpauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.tvControlBar addSubview:self.playpauseButton];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnTVView:)];
    tap.delegate = self;
    [self.tvContainerView addGestureRecognizer:tap];
}
//展示/退出视频控制栏
- (void) tapOnTVView:(UIGestureRecognizer *)gesture
{
    if (self.tvControlBar.hidden)
    {
        [self showControlBarAnimatedPeroidly:YES];
    }
    else
    {
        [self hideControlBarAnimated];
    }
}

- (void) showControlBarAnimatedPeroidly:(BOOL)periodly
{
    typeof(self) __weak bself = self;
    CGSize barSize = self.tvControlBar.frame.size;
    
    self.tvControlBar.hidden = NO;
    [UIView animateWithDuration:0.2 animations:^{
        bself.tvControlBar.frame = CGRectMake(0, bself.tvContainerView.frame.size.height - barSize.height, barSize.width, barSize.height);
    } completion:^(BOOL finished){
        
        if (periodly)
        {
            [bself hidePlayControlBarDelayedFromNow];
        }
    }];
}

- (void) hideControlBarAnimated
{
    typeof(self) __weak bself = self;
    CGSize barSize = self.tvControlBar.frame.size;
    
    [UIView animateWithDuration:0.2 animations:^{
        bself.tvControlBar.frame = CGRectMake(0, bself.tvContainerView.frame.size.height, barSize.width, barSize.height);
    } completion:^(BOOL finished){
        bself.tvControlBar.hidden = YES;
    }];
}

- (void) tvSliderValueChanged:(id)sender
{
    NSInteger time = self.currentDuration * self.tvSlider.value;
    [[SYAVPlayer sharedAVPlayer] seekTo:time];
//    [self showProgress];
}

- (void) playpauseButtonClicked:(id)sender
{
//    [self hidePlayControlBarDelayedFromNow];
    
    if (self.playpauseButton.selected)
    {
        self.playpauseButton.selected = NO;
        [[SYAVPlayer sharedAVPlayer] pause];
    }
    else
    {
        self.playpauseButton.selected = YES;
        [[SYAVPlayer sharedAVPlayer] resume];
    }
}

- (void) hidePlayControlBarDelayedFromNow
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlBarAnimated) object:nil];
    [self performSelector:@selector(hideControlBarAnimated) withObject:nil afterDelay:2];
}

#define kBottomBarHeight 54.f


- (void) initBottomBar
{
    UIView* bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - kBottomBarHeight, self.view.frame.size.width, kBottomBarHeight)];
    bottomBar.backgroundColor = [UIColor colorWithWhite:0.92 alpha:1];
    [bottomBar setBorderInteraction:MYBorderInteractionTop withColor:RGBCOLOR(171, 187, 200)];
    [self.view addSubview:bottomBar];
    
    CGFloat bottomButtonWidth = self.view.frame.size.width / 3;
    
    self.bottomCommentButton = [self bottomButtonWithImage:@"tv_comment.png" frame:CGRectMake(0, 0, bottomButtonWidth, kBottomBarHeight) action:@selector(bottomCommentButtonClicked:)];
    self.bottomCollectButton = [self bottomButtonWithImage:@"tv_uncollected.png" frame:CGRectMake(bottomButtonWidth, 0, bottomButtonWidth, kBottomBarHeight) action:@selector(bottomCollectButtonClicked:)];
    [self.bottomCollectButton setImage:[UIImage imageNamed:@"tv_collected.png"] forState:UIControlStateSelected];
    self.bottomShareButton = [self bottomButtonWithImage:@"tv_share.png" frame:CGRectMake(bottomButtonWidth * 2, 0, bottomButtonWidth, kBottomBarHeight) action:@selector(bottomShareButtonClicked:)];
    
    [bottomBar addSubview:self.bottomCommentButton];
    [bottomBar addSubview:self.bottomCollectButton];
    [bottomBar addSubview:self.bottomShareButton];
}

- (UIButton *) bottomButtonWithImage:(NSString *)imageName frame:(CGRect)frame action:(SEL)action
{
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13];
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 4);
    button.titleEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 0);
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (void) bottomCommentButtonClicked:(id)sender
{
    [self.faceTextInputPanel.textView becomeFirstResponder];
    [self.faceTextInputPanel beginEditing];
}

- (void) bottomCollectButtonClicked:(id)sender
{
    if (![[DFPreference sharedPreference] validateLogin:^{
        return NO;
    }])
    {
        return;
    }
    
    typeof(self) __weak bself = self;
    [self showProgress];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:(self.clipItem.isCollected ? [DFUrlDefine urlForUncollectFilmClip] : [DFUrlDefine urlForCollectFilmClip]) postValues:@{@"video_id": [NSNumber numberWithInt:self.clipItem.persistentId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            bself.clipItem.isCollected = !bself.clipItem.isCollected;
            bself.clipItem.collectionCount = [[[resultInfo objectForKey:@"info"] objectForKey:@"fav_count"] integerValue];
            bself.bottomCollectButton.selected = bself.clipItem.isCollected;
            [bself.bottomCollectButton setTitle:[NSString stringWithFormat:@"%d", bself.clipItem.collectionCount] forState:UIControlStateNormal];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
        
    }];
    [self.requests addObject:request];
}

- (void) bottomShareButtonClicked:(id)sender
{
    SYFullShareActionSheet* shareActionSheet = [[SYFullShareActionSheet alloc] initWithTitle:@"分享"];
    shareActionSheet.messageButton.hidden = YES;
    [shareActionSheet.qqFriendButton addTarget:self action:@selector(actionSheetQQFriendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareActionSheet.wechatFriendButton addTarget:self action:@selector(actionSheetWechatFriendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [shareActionSheet.wechatFriendsCircleButton addTarget:self action:@selector(actionSheetWechatFriendsCircleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareActionSheet.weiboButton addTarget:self action:@selector(actionSheetWeiboButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [shareActionSheet.qZoneButton addTarget:self action:@selector(actionSheetQZoneButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
   
    [shareActionSheet showInView:self.view];
}

- (void) actionSheetQQFriendButtonClicked:(id)sender
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self requestMyShareWithType:@"4"];
    }
    
    [self shareToQQFriend];
}

- (void) actionSheetWechatFriendButtonClicked:(id)sender
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self requestMyShareWithType:@"0"];
    }
    [self shareToWechatFriend];
}

- (void) actionSheetWechatFriendsCircleButtonClicked:(id)sender
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self requestMyShareWithType:@"0"];
    }
    [self shareToWechatFriendsCircle];
}

- (void) actionSheetWeiboButtonClicked:(id)sender
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self requestMyShareWithType:@"2"];
    }
    [self shareToSinaweibo];
}

- (void) actionSheetQZoneButtonClicked:(id)sender
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self requestMyShareWithType:@"3"];
    }
    [self shareToQQZone];
}

- (void) requestMyShareWithType:(NSString *)type
{
    typeof(self) __weak bself = self;
    [self showProgress];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForShareFilmClip] postValues:@{@"video_id": [NSNumber numberWithInt:self.clipItem.persistentId], @"share_type" : type} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            bself.clipItem.shareCount = [[[resultInfo objectForKey:@"info"] objectForKey:@"share_count"] integerValue];
            [bself.bottomShareButton setTitle:[NSString stringWithFormat:@"%d", bself.clipItem.shareCount] forState:UIControlStateNormal];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
        
    }];
    [self.requests addObject:request];
}

#pragma mark - face text input

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
    return YES;
}

- (void) sendText:(NSString *)text forFacePanel:(SYFaceTextInputPanel *)panel
{
    typeof(self) __weak bself = self;
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForSendFilmClipComment] postValues:@{@"video_id": [NSNumber numberWithInt:self.clipItem.persistentId], @"content" : text} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            [bself addCommentWithId:[[info objectForKey:@"id"] integerValue] content:text];
            bself.clipItem.commentCount = [[info objectForKey:@"comment_count"] integerValue];;
            [bself reloadCommonSubViews];
            
            [SYPrompt showWithText:@"评论成功～"];
            [panel endEditing];
        }
        else
        {
            [UIAlertView showWithTitle:@"发评论" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) addCommentWithId:(NSInteger)commentId content:(NSString *)text
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    DFFilmClipComment* item = [[DFFilmClipComment alloc] init];
    DFChatItem* chatItem = [[DFChatItem alloc] init];
    chatItem.userId = user.persistentId;
    chatItem.avatarUrl = user.avatarUrl;
    NSString* htmlString = [NSString stringWithFormat:@"<span color=\"#df0494\">%@</span>&nbsp;：<span color=\"#27373f\">%@</span>", user.nickname, [text replaceFacesWithHtmlFormat]];
    chatItem.textContent = [NSAttributedString attributedStringWithHTML:htmlString renderer:nil];
    [chatItem resetTextContentSizeWithConstraintSize:CGSizeMake(self.view.frame.size.width - kCellMarginLeftRight - kCellAvatarTextSpace - kChatTableViewCellAvatarSize, 200)];
    
    chatItem.chatTableCellHeight = kCellMarginTop + kCellMarginBottom + (chatItem.textContentSize.height > kChatTableViewCellAvatarSize ? chatItem.textContentSize.height : kChatTableViewCellAvatarSize);
    
    item.chatItem = chatItem;
    item.persistentId = commentId;
    
    [self.commentItems insertObject:item atIndex:0];
    [self.tableView reloadData];
}

- (void) facePanelBeginEditing:(SYFaceTextInputPanel *)facePanel
{
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.origin.y = facePanel.inputBarView.frame.origin.y - tableFrame.size.height + facePanel.inputBarView.frame.size.height;
//    self.tableView.frame = tableFrame;
}

- (void) facePanelEndEditing:(SYFaceTextInputPanel *)facePanel
{
//    CGRect tableFrame = self.tableView.frame;
//    tableFrame.origin.y = facePanel.inputBarView.frame.origin.y - tableFrame.size.height;
//    self.tableView.frame = tableFrame;
}


#pragma mark - tableview

- (void) configTableView
{
    CGRect tableviewFrame = self.tableView.frame;
    tableviewFrame.origin.y = self.tvContainerView.frame.size.height + self.tvContainerView.frame.origin.y;
    tableviewFrame.size.height = self.view.frame.size.height - kBottomBarHeight - tableviewFrame.origin.y;
    self.tableView.frame = tableviewFrame;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    [self setClickToFetchMoreTableFooterView];
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFFilmClipComment* item = [self.commentItems objectAtIndex:indexPath.row];
    return item.chatItem.chatTableCellHeight;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.commentItems.count;
}

#define kCommentTableViewCellReuseId @"CommentTableViewCell"
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFChatTableViewCell* cell = (DFChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCommentTableViewCellReuseId];
    if (cell == nil)
    {
        cell = [[DFChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCommentTableViewCellReuseId];
        cell.backgroundColor = [UIColor clearColor];
    }
    
    
    DFFilmClipComment* item = [self.commentItems objectAtIndex:indexPath.row];
    
    [cell.avatarView setImageWithUrl:item.chatItem.avatarUrl placeHolder:[DFCommonImages defaultAvatarImage]];
    cell.coreTextView.attributedString = item.chatItem.textContent;
    
    cell.contentInsets = UIEdgeInsetsMake(kCellMarginTop, kCellMarginLeftRight, kCellMarginBottom, kCellMarginLeftRight);
    cell.avatarTextSpace = kCellAvatarTextSpace;
    
    cell.coreTextOriginY = kCellTextMarginTop;
    cell.coreTextSize = item.chatItem.textContentSize;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFPreference* preference = [DFPreference sharedPreference];
    
    if ([preference hasLogin])
    {
        DFFilmClipComment* item = [self.commentItems objectAtIndex:indexPath.row];
        
        SYContextMenuItem* menuItem = [[SYContextMenuItem alloc] init];
        menuItem.menutitle = preference.currentUser.persistentId == item.chatItem.userId ?  @"删除" : @"举报";
        menuItem.menuId = indexPath.row;
        
        SYContextMenu* contextMenu = [[SYContextMenu alloc] initWithTitle:@"" menuItems:[NSArray arrayWithObject:menuItem]];
        contextMenu.delegate = self;
        [contextMenu showInView:self.view];
    }
}

- (void) contextMenu:(SYContextMenu *)menu selectItem:(SYContextMenuItem *)menuItem
{
    DFFilmClipComment* item = [self.commentItems objectAtIndex:menuItem.menuId];
    
    if ([DFPreference sharedPreference].currentUser.persistentId == item.chatItem.userId)
    {
        [self deleteCommentItem:item];
    }
    else
    {
        [self reportCommentItem:item];
    }
}

- (void) contextMenuDidDismiss:(SYContextMenu *)contextMenu
{
    
}

- (void) deleteCommentItem:(DFFilmClipComment *)comment
{
    typeof(self) __weak bself = self;
    
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForDeleteFilmClipComment] postValues:@{@"id": [NSNumber numberWithInt:comment.persistentId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        [bself hideProgress];
        if (success)
        {
            [bself.commentItems removeObject:comment];
            [bself.tableView reloadData];
            
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            bself.clipItem.commentCount = [[info objectForKey:@"comment_count"] integerValue];;
            [bself reloadCommonSubViews];
        }
        else
        {
            [UIAlertView showWithTitle:@"删除评论" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) reportCommentItem:(DFFilmClipComment *)comment
{
    [self showProgress];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:@"10" forKey:@"type"];
    
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

#pragma mark -

- (void) leftButtonClicked:(id)sender
{
    NSLog(@"%s 1", __FUNCTION__);
    [self stopProgressTimer];
    
    NSLog(@"%s 2", __FUNCTION__);
    [[SYAVPlayer sharedAVPlayer] stopReachabilityNotifier];
    
    NSLog(@"%s 3", __FUNCTION__);
    if ([SYAVPlayer sharedAVPlayer].delegate == self)
    {
        [[SYAVPlayer sharedAVPlayer] stop];
    }
    
    NSLog(@"%s 4", __FUNCTION__);
    [super leftButtonClicked:sender];
}

- (void) rightButtonClicked:(id)sender
{
    [self showProgress];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if (self.clipItem.sourceUrl.length > 0)
    {
        [dict setObject:self.clipItem.sourceUrl forKey:@"content"];
    }
    [dict setObject:@"9" forKey:@"type"];
    
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

#pragma mark -

- (void) registerApplicationObservers
{
    NSNotificationCenter* notifiy = [NSNotificationCenter defaultCenter];
    [notifiy addObserver:self selector:@selector(applicationBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationResignActive:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationdidEnterForegound:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [notifiy addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
}

- (void) unregisterApplicationObservers
{
    NSNotificationCenter* notifiy = [NSNotificationCenter defaultCenter];
    [notifiy removeObserver:self name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [notifiy removeObserver:self name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
    [notifiy removeObserver:self name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
    [notifiy removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:[UIApplication sharedApplication]];
    //    [[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (BOOL) isFrontViewController
{
    return self.navigationController.viewControllers.lastObject == self;
}

- (void) applicationBecomeActive:(NSNotification *)notification
{
    NSLog(@"%s", __FUNCTION__);
    
    //    if ([self isFrontViewController])
    //    {
    //        [self requestLive];
    //    }
}

- (void) applicationResignActive:(NSNotification *)notification
{
}

- (void) applicationdidEnterForegound:(NSNotification *)notification
{
    if ([self isFrontViewController])
    {
        [[SYAVPlayer sharedAVPlayer] resume];
    }
    
    [self hideProgress];
}

- (void) applicationDidEnterBackground:(NSNotification *)notification
{
    if ([self isFrontViewController])
    {
        [[SYAVPlayer sharedAVPlayer] pause];
    }
}

#pragma mark - share

#define kDefaultSharedText @"韩语外教纯正发音~"//@"经典电影高潮片段上海话配音，真是醉了~"

- (void) shareToTypes:(NSArray *)shareTypes videoResourced:(BOOL)resourced
{
    [self showProgress];
    typeof(self) __weak bself = self;
    
    UIImage* image = nil;
    NSString* content = nil;
    UMSocialUrlResource* res = nil;
    
    if (self.sharedUrl.length > 0)
    {
        if (resourced)
        {
            res = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeVideo url:self.sharedUrl];
            content = kDefaultSharedText;
        }
        else
        {
            content = [NSString stringWithFormat:@"%@ %@", kDefaultSharedText, self.sharedUrl];
        }
        
    }
    else
    {
        content = kDefaultSharedText;
    }
    
    
    image = self.tvPreviewImageView.image;
    if (image == nil)
    {
        image = [[UMSocialScreenShoterDefault screenShoter] getScreenShot];
    }
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:shareTypes content:content image:image location:nil urlResource:res presentedController:self completion:^(UMSocialResponseEntity* response){
        
        [bself hideProgress];
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            [SYPrompt showWithText:@"分享成功～"];
        }
        else
        {
            [SYPrompt showWithText:@"分享失败～"];
        }
    }];
}

- (void) shareToSinaweibo
{
    [self shareToTypes:@[UMShareToSina] videoResourced:NO];
    
    //    [[UMSocialControllerService defaultControllerService] setShareText:kDefaultSharedText shareImage:image socialUIDelegate:self];
    //    [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina].snsClickHandler(self, [UMSocialControllerService defaultControllerService], YES);
}

- (void) shareToQQFriend
{
    [UMSocialData defaultData].extConfig.qqData.qqMessageType = UMSocialQQMessageTypeDefault;
    [UMSocialData defaultData].extConfig.qqData.title = @"韩语教室";
    [UMSocialData defaultData].extConfig.qqData.url = @"http://www.dafanpx.com";
    
    [self shareToTypes:@[UMShareToQQ] videoResourced:YES];
}

- (void) shareToWechatFriend
{
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"韩语教室";
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeVideo;
    
    [self shareToTypes:@[UMShareToWechatSession] videoResourced:YES];
}

- (void) shareToQQZone
{
    [UMSocialData defaultData].extConfig.qzoneData.title = @"韩语教室";
    [UMSocialData defaultData].extConfig.qzoneData.url = @"http://www.dafanpx.com";
    
    [self shareToTypes:@[UMShareToQzone] videoResourced:YES];
}

- (void) shareToWechatFriendsCircle
{
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeVideo;
    [self shareToTypes:@[UMShareToWechatTimeline] videoResourced:YES];
}


@end
