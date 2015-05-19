//
//  MYAVPlayer.m
//  MY
//
//  Created by iMac on 14-6-4.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYAVPlayer.h"
#import "Reachability.h"
#import "SYPrompt.h"
#import "Vitamio.h"
#import "UIAlertView+SYExtension.h"


@interface SYAVPlayer ()<VMediaPlayerDelegate>

@property(nonatomic) BOOL reachableNotifierStarted;

@property(nonatomic, strong) NSString* currentAVUrl;
//Vitamio 播放类
@property(nonatomic, weak) VMediaPlayer* player;
//播放器的状态
@property(nonatomic) SYAVPlayerStatus status;
//检测网络状况
@property(nonatomic, strong) Reachability* reachability;

@property(nonatomic) BOOL canStart;
@property(nonatomic) BOOL canPrepare;

@end

static SYAVPlayer* stAVPlayer = nil;

@implementation SYAVPlayer

+ (SYAVPlayer *) sharedAVPlayer
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stAVPlayer = [[SYAVPlayer alloc] init];
    });
    return stAVPlayer;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.player = [VMediaPlayer sharedInstance];
        [self registerNetObserver];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id) allocWithZone:(NSZone *)zone
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        stAVPlayer = [super allocWithZone:zone];
    });
    return stAVPlayer;
}


- (void) startReachabilityNotifier
{
    if (self.reachability == nil)
    {
        self.reachability = [Reachability reachabilityForInternetConnection];
    }
    
    if (!self.reachableNotifierStarted)
    {
        [self.reachability startNotifier];
        self.reachableNotifierStarted = YES;
    }
}
/**
 *  注册网络状况改变的通知时间
 */
- (void) registerNetObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
}

- (void) stopReachabilityNotifier
{
    if (self.reachableNotifierStarted)
    {
        [self.reachability stopNotifier];
    }
    self.reachableNotifierStarted = NO;
}
/**
 *  网络状况改变的时间处理
 */
- (void) reachabilityChanged:(NSNotification *)notification
{
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
       if (self.status <= SYAVPlayerStatusSetup)
       {
           [self preparePlayerWithUrl:self.currentAVUrl];
       }
    }
    else
    {
        if (self.status >= SYAVPlayerStatusPreparing)
        {
            [self.player reset];
            self.status = SYAVPlayerStatusStopped;
            [UIAlertView showNOPWithText:@"当前网络不为Wi-Fi, 不能观看直播"];
        }
    }
}

- (BOOL)setupPlayerWithCarrierView:(UIView *)carrier withDelegate:(id<SYAVPlayerDelegate>)delegate
{
    if (self.delegate != nil)
    {
        [self.player reset];
        [self.player unSetupPlayer];
    }
    
    self.canStart = YES;
    self.delegate = delegate;
    self.status = SYAVPlayerStatusSetup;
    return [self.player setupPlayerWithCarrierView:carrier withDelegate:self];
}

- (void) preparePlayerWithUrl:(NSString *)url
{
    if (self.currentAVUrl.length > 0)
    {
        [self.player setDataSource:[NSURL URLWithString:url]];
        [self.player prepareAsync];
        [SYPrompt showWithText:@"正在连接..."];
        self.status = SYAVPlayerStatusPreparing;
    }
}

- (void) playWithUrl:(NSString *)url
{
    self.currentAVUrl = url;
    self.canStart = YES;
    
    if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
    {
        [self preparePlayerWithUrl:url];
    }
    else
    {
        [UIAlertView showNOPWithText:@"非Wi-Fi网络最好不要看视频，省点流量哦~"];
    }
}

- (void) resume
{
    //NSLog(@"%s, %@", __FUNCTION__, self.currentAVUrl);
    
    self.canStart = YES;
    
    if (self.status <= SYAVPlayerStatusSetup)
    {
        if ([self.reachability currentReachabilityStatus] == ReachableViaWiFi)
        {
            [self preparePlayerWithUrl:self.currentAVUrl];
        }
    }
    else if (self.status >= SYAVPlayerStatusPrepared && ![self.player isPlaying])
    {
        [self.player start];
        self.status = SYAVPlayerStatusPlaying;
    }
}

- (void) pause
{
    //NSLog(@"%s, %@", __FUNCTION__, self.currentAVUrl);
    
    self.canStart = NO;
    
    if (self.status >= SYAVPlayerStatusPrepared && [self.player isPlaying])
    {
        [self.player pause];
        self.status = SYAVPlayerStatusPause;
    }
}

- (void) stop
{
    NSLog(@"%s, 1", __FUNCTION__);
    
    if (self.status >= SYAVPlayerStatusPrepared) //若还未执行到mediaPlayer:didPrepared:就运行reset则可能会崩溃
    {
        [self.player reset];
    }
    self.status = SYAVPlayerStatusStopped;
    
    NSLog(@"%s, 2", __FUNCTION__);
    
    //    if (self.status >= SYAVPlayerStatusSetup)
    {
        [self.player unSetupPlayer];
    }
    
    self.delegate = nil;
}

- (void) setStatus:(SYAVPlayerStatus)status
{
    if (_status != status)
    {
        _status = status;
        [self.delegate avPlayer:self statusChanged:status];
    }
}

#pragma mark - VMediaPlayerDelegate
//
- (void) mediaPlayer:(VMediaPlayer *)player didPrepared:(id)arg
{
    NSLog(@"%s, %@", __FUNCTION__, self.currentAVUrl);
    
    self.status = SYAVPlayerStatusPrepared;
    if (self.canStart)
    {
        [self.player start];
        self.status = SYAVPlayerStatusPlaying;
    }
}

- (void) mediaPlayer:(VMediaPlayer *)player playbackComplete:(id)arg
{
    NSLog(@"%s, %@", __FUNCTION__, self.currentAVUrl);
    
    self.status = SYAVPlayerStatusCompleted;
    
    [self.player reset];
}

- (void) mediaPlayer:(VMediaPlayer *)player error:(id)arg
{
    NSLog(@"%s, %@", __FUNCTION__, self.currentAVUrl);
    
    self.status = SYAVPlayerStatusError;
    
    [self.player reset];
}

- (void) mediaPlayer:(VMediaPlayer *)player setupManagerPreference:(id)arg
{
    
    [player setBufferSize:512*1024];
    [player setVideoQuality:VMVideoQualityMedium];
    player.useCache = YES;
}

- (void) mediaPlayer:(VMediaPlayer *)player bufferingStart:(id)arg
{
//    [SYPrompt showWithText:@"缓冲中....."];
    self.status = SYAVPlayerStatusBufferBegin;
}

- (void) mediaPlayer:(VMediaPlayer *)player bufferingEnd:(id)arg
{
    self.status = SYAVPlayerStatusBufferEnd;
}

- (void)mediaPlayer:(VMediaPlayer *)player seekComplete:(id)arg
{
    self.status = SYAVPlayerStatusSeekCompleted;
}

- (void) mediaPlayer:(VMediaPlayer *)player notSeekable:(id)arg
{
    self.status = SYAVPlayerStatusSeekCompleted;
}

#pragma mark - time

- (NSInteger) currentPlayTime
{
    return [self.player getCurrentPosition] / 1000;
}

- (NSInteger) duration
{
    return [self.player getDuration] / 1000;
}

- (void) seekTo:(NSInteger)seconds
{
    [self.player seekTo:seconds * 1000];
}

@end
