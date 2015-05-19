//
//  MYVoicePlayer.h
//  MY
//
//  Created by iMac on 14-8-6.
//  Copyright (c) 2014年 halley. All rights reserved.
//  音频播放

#import <Foundation/Foundation.h>

@class SYVoicePlayer;
@protocol SYVoicePlayerDelegate <NSObject>

- (void) voicePlayed:(SYVoicePlayer *)player tag:(NSInteger)tag;

- (void) voiceStopped:(SYVoicePlayer *)player;

@end

@interface SYVoicePlayer : NSObject

@property(nonatomic, weak) id<SYVoicePlayerDelegate> delegate;

- (void) playWithUrl:(NSString *)url tag:(NSInteger)tag;

@end
