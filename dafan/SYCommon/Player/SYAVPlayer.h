//
//  SYAVPlayer.h
//  MY
//
//  Created by iMac on 14-6-4.
//  Copyright (c) 2014年 halley. All rights reserved.
//  视频播放

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SYAVPlayerStatus)
{
    SYAVPlayerStatusStopped,
    SYAVPlayerStatusCompleted,
    SYAVPlayerStatusSetup,
    SYAVPlayerStatusPreparing,
    SYAVPlayerStatusPrepared,
    SYAVPlayerStatusPlaying,
    SYAVPlayerStatusPause,
    SYAVPlayerStatusBufferBegin,
    SYAVPlayerStatusBufferEnd,
    SYAVPlayerStatusSeekCompleted,
    SYAVPlayerStatusError
};

@class SYAVPlayer;
@protocol SYAVPlayerDelegate <NSObject>

- (void) avPlayer:(SYAVPlayer *)player statusChanged:(SYAVPlayerStatus)status;

@end

@interface SYAVPlayer : NSObject

@property(nonatomic, weak) id<SYAVPlayerDelegate> delegate;

+ (SYAVPlayer *) sharedAVPlayer;
/**
 *  设置显示的视图
 *
 *  @param carrier  需要显示视图
 *  @param delegate 代理
 */
- (BOOL)setupPlayerWithCarrierView:(UIView *)carrier withDelegate:(id<SYAVPlayerDelegate>)delegate;
/**
 *  播放指定URL的文件
 */
- (void) playWithUrl:(NSString *)url;
/**
 *  暂停播放
 */
- (void) pause;
/**
 *  重新播放
 */
- (void) resume;
/**
 *  停止播放
 */
- (void) stop;
/**
 *  跳转到指定的时间
 *
 *  @param seconds 指定时间
 */
- (void) seekTo:(NSInteger)seconds;

//seconds
- (NSInteger) currentPlayTime;
- (NSInteger) duration;

- (void) startReachabilityNotifier;
- (void) stopReachabilityNotifier;

@end
