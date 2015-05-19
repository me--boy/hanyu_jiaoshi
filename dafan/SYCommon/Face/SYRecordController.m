//
//  MYRecordController.m
//  MY
//
//  Created by iMac on 14-8-5.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYRecordController.h"
#import "SYFilePath.h"
#import "SYPrompt.h"

typedef NS_ENUM(NSInteger, SYRecordPlayStatus)
{
    SYRecordPlayStatusPreRecord,
    SYRecordPlayStatusRecording,
    SYRecordPlayStatusPrePlay,
    SYRecordPlayStatusPlaying,
};

@interface SYRecordController ()<AVAudioPlayerDelegate, AVAudioRecorderDelegate>

@property(nonatomic, strong) AVAudioRecorder* record;
@property(nonatomic, strong) AVAudioPlayer* player;
@property(nonatomic, strong) NSTimer* voiceTimer;
@property(nonatomic) NSInteger voiceDuration;

@property(nonatomic) SYRecordPlayStatus status;

@end

@implementation SYRecordController

- (void) setStatus:(SYRecordPlayStatus)status
{
    if (_status != status)
    {
        _status = status;
        
        switch (status) {
            case SYRecordPlayStatusPreRecord:
            {
                self.recordPanel.playVoiceButton.hidden = YES;
                self.recordPanel.playVoiceButton.selected = NO;
                self.recordPanel.recordButton.hidden = NO;
                self.recordPanel.recordButton.selected = NO;
                self.recordPanel.leftVolumeImageView.hidden = NO;
                self.recordPanel.rightVolumeImageView.hidden = NO;
                self.recordPanel.voiceDurationButton.hidden = YES;
                self.recordPanel.resetRecordButton.hidden = YES;
                self.recordPanel.recordTipsLabel.hidden = NO;
                self.recordPanel.recordTipsLabel.text = @"长按开始录音，最多20秒～";
            }
                break;
            case SYRecordPlayStatusRecording:
            {
                self.recordPanel.playVoiceButton.hidden = YES;
                self.recordPanel.playVoiceButton.selected = NO;
                self.recordPanel.recordButton.hidden = NO;
                self.recordPanel.recordButton.selected = YES;
                self.recordPanel.leftVolumeImageView.hidden = NO;
                [self.recordPanel.leftVolumeImageView startAnimating];
                self.recordPanel.rightVolumeImageView.hidden = NO;
                [self.recordPanel.rightVolumeImageView startAnimating];
                self.recordPanel.voiceDurationButton.hidden = NO;
                self.recordPanel.resetRecordButton.hidden = YES;
                self.recordPanel.recordTipsLabel.hidden = YES;
            }
                break;
            case SYRecordPlayStatusPrePlay:
            {
                self.recordPanel.playVoiceButton.hidden = NO;
                self.recordPanel.playVoiceButton.selected = NO;
                self.recordPanel.recordButton.hidden = YES;
                self.recordPanel.recordButton.selected = NO;
                self.recordPanel.leftVolumeImageView.hidden = YES;
                self.recordPanel.rightVolumeImageView.hidden = YES;
                self.recordPanel.voiceDurationButton.hidden = NO;
                self.recordPanel.resetRecordButton.hidden = NO;
                self.recordPanel.recordTipsLabel.hidden = NO;
                self.recordPanel.recordTipsLabel.text = @"点击播放";
            }
                break;
            case SYRecordPlayStatusPlaying:
            {
                self.recordPanel.playVoiceButton.hidden = NO;
                self.recordPanel.playVoiceButton.selected = YES;
                self.recordPanel.recordButton.hidden = YES;
                self.recordPanel.recordButton.selected = NO;
                self.recordPanel.leftVolumeImageView.hidden = NO;
                [self.recordPanel.leftVolumeImageView startAnimating];
                self.recordPanel.rightVolumeImageView.hidden = NO;
                [self.recordPanel.rightVolumeImageView startAnimating];
                self.recordPanel.voiceDurationButton.hidden = NO;
                self.recordPanel.resetRecordButton.hidden = YES;
                self.recordPanel.recordTipsLabel.hidden = YES;
                
            }
                break;
            default:
                break;
        }
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
        NSError* error;
        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    }
    return self;
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
    if (self.record.currentTime > 60)
    {
        [SYPrompt showWithText:@"超过60秒了～" bottomOffset:64];
        [self stopTimer];
        [self stopRecord];
        return;
    }
    
    [self resetVoiceDurationButton];
}

- (void) startRecord
{
    self.record = nil;
    
    self.status = SYRecordPlayStatusPreRecord;
    
    [SYFilePath clearCurrentVoiceFilePath];
    [self enableAudioSession];
    
    NSError* error;
    
    NSMutableDictionary* recordConfiguration = [NSMutableDictionary dictionary];
    [recordConfiguration setObject:[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    [recordConfiguration setObject:[NSNumber numberWithFloat:8000] forKey:AVSampleRateKey];
    [recordConfiguration setObject:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    [recordConfiguration setObject:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    [recordConfiguration setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    [recordConfiguration setObject:[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    NSURL* url = [NSURL fileURLWithPath:[SYFilePath currentVoiceWAVFilePath] isDirectory:NO];
    self.record = [[AVAudioRecorder alloc] initWithURL:url settings:recordConfiguration error:&error];
    self.record.delegate = self;
    self.record.meteringEnabled = YES;
    if ([self.record prepareToRecord])
    {
        if ([self.record record])
        {
            self.status = SYRecordPlayStatusRecording;
            [self startRecordTimer];
        }
        else
        {
            NSLog(@"%s record failed!", __FUNCTION__);
            [SYPrompt showWithText:@"不可录制，请检查设备情况～" bottomOffset:180];
        }
    }
    else
    {
        [SYPrompt showWithText:@"不可录制，请检查设备情况～" bottomOffset:180];
        NSLog(@"%s prepare record failed!", __FUNCTION__);
    }
}

- (void) stopRecord
{
    self.status = SYRecordPlayStatusPrePlay;
    
    self.voiceDuration = self.record.currentTime + 1;
    [self.recordPanel.voiceDurationButton setTitle:[NSString stringWithFormat:@"%d''", self.voiceDuration] forState:UIControlStateNormal];
    
    [self.record stop];
}

- (void) resetVoiceDurationButton
{
    if (self.record.currentTime > 0)
    {
        [self.recordPanel.voiceDurationButton setTitle:[NSString stringWithFormat:@"%ld''", (long)self.record.currentTime] forState:UIControlStateNormal];
    }
}

#pragma mark - audio record delegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    self.status = SYRecordPlayStatusPrePlay;
    
//    [self resetVoiceDurationButton];
    
    [self stopTimer];
    self.record = nil;
    [self disableAudioSession];
    
    [self.delegate recordControllerVoiceRecord:self duration:self.voiceDuration];
    
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

#pragma mark - play

- (void) playVoice
{
    self.player = nil;
    self.status = SYRecordPlayStatusPrePlay;
    [self enableAudioSession];
    
    NSError* error = nil;
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[SYFilePath currentVoiceWAVFilePath] isDirectory:NO] error:&error];
    self.player.delegate = self;
    if ([self.player prepareToPlay])
    {
        [self.player play];
        self.status = SYRecordPlayStatusPlaying;
    }
    else
    {
        [SYPrompt showWithText:@"不能播放，可重新录制～" bottomOffset:180];
    }
}

- (void) pausePlayVoice
{
    self.status = SYRecordPlayStatusPrePlay;
    [self.player pause];
}

#pragma mark - audio play

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self.player stop];
    self.player = nil;
    
    self.status = SYRecordPlayStatusPrePlay;
    
    [self disableAudioSession];
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    [self.player stop];
    self.player = nil;
    
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withOptions:(NSUInteger)flags
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player withFlags:(NSUInteger)flags
{
    NSLog(@"%s", __FUNCTION__);
}

- (void)audioPlayerEndInterruption:(AVAudioPlayer *)player
{
    NSLog(@"%s", __FUNCTION__);
}

#pragma mark - action

- (void) setRecordPanel:(SYRecordPanel *)recordPanel
{
    if (_recordPanel != recordPanel)
    {
        _recordPanel = recordPanel;
        
        [_recordPanel.recordButton addTarget:self action:@selector(panelRecordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
        [_recordPanel.recordButton addTarget:self action:@selector(panelRecordButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_recordPanel.recordButton addTarget:self action:@selector(panelRecordButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        
        [_recordPanel.playVoiceButton addTarget:self action:@selector(panelPlayVoiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_recordPanel.resetRecordButton addTarget:self action:@selector(panelResetRecordButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
}

#pragma mark - actions

- (void) panelPlayVoiceButtonClicked:(id)sender
{
    self.recordPanel.playVoiceButton.selected = !self.recordPanel.playVoiceButton.selected;
    
    if (self.recordPanel.playVoiceButton.selected)
    {
        [self playVoice];
    }
    else
    {
        [self pausePlayVoice];
    }
}

- (void) stopPlay
{
    if (self.status == SYRecordPlayStatusPlaying)
    {
        self.status = SYRecordPlayStatusPrePlay;
    }
}

- (void) panelRecordButtonTouchDown:(id)sender
{
    [self startRecord];
}

- (void) panelRecordButtonTouchUpInside:(id)sender
{
    [self stopRecord];
}

- (void) panelRecordButtonTouchUpOutside:(id)sender
{
    [self stopRecord];
}

- (void) panelResetRecordButtonClicked:(id)sender
{
    [SYFilePath clearCurrentVoiceFilePath];
    [self.recordPanel reset];
    
    [self.delegate recordControllerVoiceClear:self];
}


@end
