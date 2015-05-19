//
//  DFRepeatController.m
//  dafan
//
//  Created by iMac on 14-10-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFRepeatController.h"
#import "DFFilePath.h"
#import "SYPrompt.h"
#import "DFVoiceAnimationView.h"
#import <AVFoundation/AVFoundation.h>

@interface DFRepeatController ()<AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property(nonatomic, strong) AVAudioRecorder* record;
@property(nonatomic, strong) NSTimer* voiceTimer;
@property(nonatomic, strong) DFVoiceAnimationView* voiceAnimatingView;
@property(nonatomic, strong) NSMutableDictionary* voiceDurations;

@end

@implementation DFRepeatController

- (NSString *)voiceDurationFilePath
{
    return [[DFFilePath sentenceVoicesDirectory] stringByAppendingPathComponent:@"durations"];
}

- (void) dealloc
{
//    [self saveDurations];
}

- (void) done
{
    [self stopTimer];
    [self.voiceDurations writeToFile:[self voiceDurationFilePath] atomically:YES];
}

- (id) init
{
    self = [super init];
    if (self)
    {
        NSError* error;
//        AVAudioSession* session = [AVAudioSession sharedInstance];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
        
        [self initVoiceDurations];
    }
    return self;
}

- (void) initVoiceDurations
{
    [DFFilePath ensureDirectory:[DFFilePath sentenceVoicesDirectory]];
    
    NSString* filePath = [self voiceDurationFilePath];
    if ([DFFilePath fileExists:filePath])
    {
        self.voiceDurations = [NSMutableDictionary dictionaryWithContentsOfFile:filePath];
    }
    
    if (self.voiceDurations == nil)
    {
        self.voiceDurations = [NSMutableDictionary dictionary];
    }
    
}

- (void) enableAudioSession
{
    NSError* error;
    [[AVAudioSession sharedInstance] setActive:YES error:&error];
}

- (void) disableAudioSession
{
    NSError* error = nil;
    [[AVAudioSession sharedInstance] setActive:NO error:&error];
}

- (void) setSentence:(DFSentenceItem *)sentence
{
    if (_sentence != sentence)
    {
        _sentence = sentence;
        
        [self refreshRepeatPanel];
    }
}

- (void) setRepeatPanel:(DFRepeatPanel *)repeatPanel
{
    if (_repeatPanel != repeatPanel)
    {
        _repeatPanel = repeatPanel;
        
        [self refreshRepeatPanel];
        
        [_repeatPanel.mikeButton addTarget:self action:@selector(panelMikeButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_repeatPanel.mikeButton addTarget:self action:@selector(panelMikeButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_repeatPanel.mikeButton addTarget:self action:@selector(panelMikeButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    }
}

- (void) panelMikeButtonTouchDown:(UIButton *)sender
{
    [self startRecord];
    [self startVoiceAnimating];
}

- (void) panelMikeButtonTouchUpInside:(UIButton *)sender
{
    [self stopRecord];
    [self stopVoiceAnimating];
}

- (void) panelMikeButtonTouchUpOutside:(UIButton *)sender
{
    [self stopRecord];
    [self stopVoiceAnimating];
}

- (void) refreshRepeatPanel
{
    if (self.sentence != nil)
    {
        NSString* filePath = [DFFilePath sentenceVoicesWithId:self.sentence.persistentId];
        self.repeatPanel.voicesComparedButton.hidden = self.repeatPanel.myVoicePlayButton.hidden = ![DFFilePath fileExists:filePath];
        NSString* duration = [self.voiceDurations objectForKey:[NSString stringWithFormat:@"%d", self.sentence.persistentId]];
        if (duration.length > 0)
        {
            [self.repeatPanel.myVoicePlayButton setTitle:[NSString stringWithFormat:@"%@''", duration] forState:UIControlStateNormal];
        }
    }
}

- (void) startRecord
{
    self.record = nil;
    
    NSError* error;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    [self enableAudioSession];
    
    NSString* filePath = [DFFilePath sentenceVoicesWithId:self.sentence.persistentId];
    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
    
    NSMutableDictionary* recordConfiguration = [NSMutableDictionary dictionary];
    [recordConfiguration setObject:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordConfiguration setObject:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    [recordConfiguration setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordConfiguration setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordConfiguration setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordConfiguration setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSURL* url = [NSURL fileURLWithPath:filePath isDirectory:NO];
    self.record = [[AVAudioRecorder alloc] initWithURL:url settings:recordConfiguration error:&error];
    self.record.delegate = self;
    self.record.meteringEnabled = YES;
    if ([self.record prepareToRecord])
    {
        if ([self.record record])
        {
            [self startRecordTimer];
        }
        else
        {
            [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
            NSLog(@"%s record failed!", __FUNCTION__);
            [SYPrompt showWithText:@"不可录制，请检查设备情况～" bottomOffset:180];
        }
    }
    else
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
        
        [SYPrompt showWithText:@"不可录制，请检查设备情况～" bottomOffset:180];
        NSLog(@"%s prepare record failed!", __FUNCTION__);
    }
}

- (void) startRecordTimer
{
    [self stopTimer];
    
    self.voiceTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(recordTimeScheduled:) userInfo:nil repeats:YES];
}

- (void) stopTimer
{
    [self.voiceTimer invalidate];
    self.voiceTimer = nil;
}

- (void) recordTimeScheduled:(id)timer
{
    if (self.record.currentTime > 20)
    {
        [SYPrompt showWithText:@"超过20秒了～" bottomOffset:64];
        [self stopTimer];
        [self stopRecord];
        return;
    }
    
    [self resetVoiceDurationButton];
}

- (void) stopRecord
{
    [self resetVoiceDurationButton];
    [self.voiceDurations setObject:[NSString stringWithFormat:@"%ld", (long)self.record.currentTime] forKey:[NSString stringWithFormat:@"%d", self.sentence.persistentId]];
    
    [self.record stop];
}

- (void) resetVoiceDurationButton
{
    if (self.record.currentTime > 0)
    {
        [self.repeatPanel.myVoicePlayButton setTitle:[NSString stringWithFormat:@"%ld''", (long)self.record.currentTime] forState:UIControlStateNormal];
    }
}

#pragma mark - audio record delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    self.repeatPanel.voicesComparedButton.hidden = NO;
    self.repeatPanel.myVoicePlayButton.hidden = NO;
//    [self resetVoiceDurationButton];
    
    [self stopTimer];
    self.record = nil;
    [self disableAudioSession];
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error
{
    [self.record stop];
    self.record = nil;
    [self stopTimer];
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioRecorderBeginInterruption:(AVAudioRecorder *)recorder
{
    [self stopTimer];
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withOptions:(NSUInteger)flags
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder withFlags:(NSUInteger)flags
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioRecorderEndInterruption:(AVAudioRecorder *)recorder
{
    [self startRecordTimer];
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - voice animating

- (void) startVoiceAnimating
{
    if (self.voiceAnimatingView == nil)
    {
        self.voiceAnimatingView = [DFVoiceAnimationView showVoiceAnimationView];
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


@end
