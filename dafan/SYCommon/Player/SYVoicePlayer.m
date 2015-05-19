//
//  MYVoicePlayer.m
//  MY
//
//  Created by iMac on 14-8-6.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYVoicePlayer.h"
#import "NSString+SYExtension.h"
#import "SYFilePath.h"
#import "SYHttpRequest.h"
#import "VoiceConverter.h"
#import "SYPrompt.h"
#import <AVFoundation/AVFoundation.h>

@interface SYVoicePlayer ()<AVAudioPlayerDelegate>

@property(nonatomic, strong) AVAudioPlayer* audioPlayer;
@property(nonatomic, strong) NSMutableArray* requests;

@end

@implementation SYVoicePlayer

- (id) init
{
    self = [super init];
    if (self)
    {
        self.requests = [NSMutableArray array];
    }
    return self;
}

- (void) playWithUrl:(NSString *)url tag:(NSInteger)tag
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    typeof(self) __weak bself = self;
    NSString* fileName = [url encryptionWithMD5];
    
    NSString* wavFilename = [fileName stringByAppendingPathExtension:@"wav"];
    NSString* wavFilepath = [[SYFilePath voiceDirectoryPath] stringByAppendingPathComponent:wavFilename];
    
    if ([SYFilePath fileExists:wavFilepath])
    {
        [self playVoiceWithWavFile:wavFilepath tag:tag];
    }
    else
    {
        NSString* amrFilename = [fileName stringByAppendingPathExtension:@"amr"];
        NSString* amrFilepath = [[SYFilePath voiceDirectoryPath] stringByAppendingPathComponent:amrFilename];
        
        if ([SYFilePath fileExists:amrFilepath])
        {
            [self playWAVFile:wavFilepath fromAMRFile:amrFilepath tag:tag];
        }
        else
        {
            SYHttpRequest* request = [SYHttpRequest startDownloadFromUrl:url toFilePath:amrFilepath progress:^(CGFloat progress) {
                
            } finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
                if (success)
                {
                    [bself playWAVFile:wavFilepath fromAMRFile:amrFilepath tag:tag];
                }
                else
                {
                    [bself.delegate voiceStopped:self];
                    [SYPrompt showWithText:@"不能播放"];
                }
            }];
            [bself.requests addObject:request];
        }
    }
}

- (void) playWAVFile:(NSString *)wavFilepath fromAMRFile:(NSString *)amrFilePath tag:(NSInteger)tag
{
    if ([VoiceConverter convertAMR:amrFilePath toWAV:wavFilepath] > 0)
    {
        [self playVoiceWithWavFile:wavFilepath tag:tag];
    }
    else
    {
        [self.delegate voiceStopped:self];
        [SYPrompt showWithText:@"不能播放"];
    }
}

- (void) playVoiceWithWavFile:(NSString *)wavFilepath tag:(NSInteger)tag
{
    NSError* error = nil;
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL URLWithString:wavFilepath] error:&error];
    self.audioPlayer.delegate = self;
    if ([self.audioPlayer prepareToPlay])
    {
        [self.audioPlayer play];
        
        [self.delegate voicePlayed:self tag:tag];
    }
    else
    {
        [self.delegate voiceStopped:self];
    }
}

#pragma mark - audio play

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    [self.delegate voiceStopped:self];
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self.audioPlayer stop];
    self.audioPlayer = nil;
    
    [self.delegate voiceStopped:self];
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    //    [self.audioPlayer pause];
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    //    [self.audioPlayer play];
    
    NSLog(@"%s", __FUNCTION__);
}

@end
