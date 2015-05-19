//
//  AFSoundManager.m
//  AFSoundManager-Demo
//
//  Created by Alvaro Franco on 4/16/14.
//  Copyright (c) 2014 AlvaroFranco. All rights reserved.
//

#import "AFSoundManager.h"

@interface AFSoundManager ()<AVAudioPlayerDelegate>

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) int type;

@property(nonatomic, copy) progressBlock block;

@property(nonatomic) BOOL playLocal;
@property(nonatomic, strong) NSString* playingUrl;

@end

@implementation AFSoundManager

+(instancetype)sharedManager {
    
    static AFSoundManager *soundManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        soundManager = [[self alloc]init];
    });
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    return soundManager;
}

-(void)startPlayingLocalFilePath:(NSString *)filePath andBlock:(progressBlock)block {
//-(void)startPlayingLocalFileWithName:(NSString *)name andBlock:(progressBlock)block {
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [self stopTimer];
    self.playLocal = YES;
    self.block = block;
    self.playingUrl = filePath;
    
//    NSString *filePath = [NSString stringWithFormat:@"%@/%@", [[NSBundle mainBundle]resourcePath], name];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSError *error = nil;
    
    _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:&error];
    _audioPlayer.delegate = self;
    if ([_audioPlayer play])
    {
        _status = AFSoundManagerStatusPlaying;
        [_delegate currentPlayingStatusChanged:AFSoundManagerStatusPlaying];
        
        [self startAudioPlayerTimer];
    }
    else
    {
        if (block) {
            block(0, 0, 0, error, YES);
        }
        [_audioPlayer stop];
        
        _status = AFSoundManagerStatusFinished;
        [_delegate currentPlayingStatusChanged:AFSoundManagerStatusFinished];
    }
}

- (void) stopTimer
{
//    _audioPlayer.delegate = nil;
    [self.timer invalidate];
    self.timer = nil;
}

- (void) startAudioPlayerTimer
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(audioPlayerTimerScheduled:) userInfo:nil repeats:YES];
}

- (void) audioPlayerTimerScheduled:(NSTimer *)timer
{
    NSError *error = nil;
    if ((self.audioPlayer.duration - self.audioPlayer.currentTime) >= 1) {
        
        int percentage = (int)((self.audioPlayer.currentTime * 100)/self.audioPlayer.duration);
        int timeRemaining = self.audioPlayer.duration - self.audioPlayer.currentTime;
        
        if (self.block) {
            self.block(percentage, self.audioPlayer.currentTime, timeRemaining, error, NO);
        }
    }
    else
    {
//        int timeRemaining = self.audioPlayer.duration - self.audioPlayer.currentTime;
//        
//        if (self.block) {
//            self.block(100, self.audioPlayer.currentTime, timeRemaining, error, YES);
//        }
//        [self stopTimer];
//        self.status = AFSoundManagerStatusFinished;
//        [self.delegate currentPlayingStatusChanged:AFSoundManagerStatusFinished];
    }
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error
{
    NSLog(@"%s %@", __FUNCTION__, error);
}

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    [self stopTimer];
    
    if (self.block) {
        self.block(100, self.audioPlayer.currentTime, self.audioPlayer.duration - self.audioPlayer.currentTime, nil, YES);
    }
    
    self.status = AFSoundManagerStatusFinished;
    [self.delegate currentPlayingStatusChanged:AFSoundManagerStatusFinished];
}

#pragma mark - avplayer

- (void) startAVPlayerTimer
{
    [self stopTimer];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(avPlayerTimerScheduled:) userInfo:nil repeats:YES];
}

- (void) avPlayerTimerScheduled:(NSTimer *)timer
{
    NSError *error = nil;
    
    int timeRemaining = CMTimeGetSeconds(self.player.currentItem.duration) - CMTimeGetSeconds(self.player.currentItem.currentTime);
    
    if (timeRemaining != 0) {
        
        int percentage = (int)((CMTimeGetSeconds(self.player.currentItem.currentTime) * 100)/CMTimeGetSeconds(self.player.currentItem.duration));
        
        if (self.block) {
            self.block(percentage, CMTimeGetSeconds(self.player.currentItem.currentTime), timeRemaining, error, NO);
        }
    } else {
        
        
        
        if (self.block) {
            self.block(100, CMTimeGetSeconds(self.player.currentItem.currentTime), timeRemaining, error, YES);
        }
        
        [self stopTimer];
        self.status = AFSoundManagerStatusFinished;
        [self.delegate currentPlayingStatusChanged:AFSoundManagerStatusFinished];
}
}

- (void) startStreamingRemoteAudioFromURL:(NSString *)url andBlock:(progressBlock)block {
    
    [self stopTimer];
    self.playLocal = NO;
    self.block = block;
    self.playingUrl = url;
    
    NSURL *streamingURL = [NSURL URLWithString:url];
    
    _player = [[AVPlayer alloc]initWithURL:streamingURL];
    [_player play];
    
    _status = AFSoundManagerStatusPlaying;
    [_delegate currentPlayingStatusChanged:AFSoundManagerStatusPlaying];
    
    [self startAVPlayerTimer];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == (id)self && [keyPath isEqualToString:@"status"]) {
        [self currentPlayingStatusChanged:_status];
        NSLog(@":roto2:");
    }
    NSLog(@":roto2:");
    
}

-(NSDictionary *)retrieveInfoForCurrentPlaying {
    
    if (_audioPlayer.url) {
        
        NSArray *parts = [_audioPlayer.url.absoluteString componentsSeparatedByString:@"/"];
        NSString *filename = [parts objectAtIndex:[parts count]-1];
        
        NSDictionary *info = @{@"name": filename, @"duration": [NSNumber numberWithInt:_audioPlayer.duration], @"elapsed time": [NSNumber numberWithInt:_audioPlayer.currentTime], @"remaining time": [NSNumber numberWithInt:(_audioPlayer.duration - _audioPlayer.currentTime)], @"volume": [NSNumber numberWithFloat:_audioPlayer.volume]};
        
        return info;
    } else {
        return nil;
    }
}

-(void)pause {
    [_audioPlayer pause];
    [_player pause];
    
    [self stopTimer];
    
    _status = AFSoundManagerStatusPaused;
    [_delegate currentPlayingStatusChanged:AFSoundManagerStatusPaused];
}

-(void)resume {
    [_audioPlayer play];
    [_player play];
    
    if (self.playLocal)
    {
        [self startAudioPlayerTimer];
    }
    else
    {
        [self startAVPlayerTimer];
    }
    
    _status = AFSoundManagerStatusPlaying;
    [_delegate currentPlayingStatusChanged:AFSoundManagerStatusPlaying];
}

-(void)stop {
    [_audioPlayer stop];
    _player = nil;

    [self stopTimer];
    
    self.block = NULL;
    
    _status = AFSoundManagerStatusStopped;
    [_delegate currentPlayingStatusChanged:AFSoundManagerStatusStopped];
}

-(void)restart {
    [_audioPlayer setCurrentTime:0];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    [_player seekToTime:CMTimeMake(0.000000, timeScale)];
    _status = AFSoundManagerStatusRestarted;
    [_delegate currentPlayingStatusChanged:AFSoundManagerStatusRestarted];
}

-(void)moveToSecond:(int)second {
    [_audioPlayer setCurrentTime:second];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    [_player seekToTime:CMTimeMakeWithSeconds((Float64)second, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)moveToSection:(CGFloat)section {
    int audioPlayerSection = _audioPlayer.duration * section;
    [_audioPlayer setCurrentTime:audioPlayerSection];
    
    int32_t timeScale = _player.currentItem.asset.duration.timescale;
    Float64 playerSection = CMTimeGetSeconds(_player.currentItem.duration) * section;
    [_player seekToTime:CMTimeMakeWithSeconds(playerSection, timeScale) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

-(void)changeSpeedToRate:(CGFloat)rate {
    _audioPlayer.rate = rate;
    _player.rate = rate;
}

-(void)changeVolumeToValue:(CGFloat)volume {
    _audioPlayer.volume = volume;
    _player.volume = volume;
}

-(void)startRecordingAudioWithFileName:(NSString *)name andExtension:(NSString *)extension shouldStopAtSecond:(NSTimeInterval)second {
    
    _recorder = [[AVAudioRecorder alloc]initWithURL:[NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@.%@", [NSHomeDirectory() stringByAppendingString:@"/Documents"], name, extension]] settings:nil error:nil];
    
    if (second == 0 && !second) {
        [_recorder record];
    } else {
        [_recorder recordForDuration:second];
    }
}

-(void)pauseRecording {
    
    if ([_recorder isRecording]) {
        [_recorder pause];
    }
}

-(void)resumeRecording {
    
    if (![_recorder isRecording]) {
        [_recorder record];
    }
}

-(void)stopAndSaveRecording {
    [_recorder stop];
}

-(void)deleteRecording {
    [_recorder deleteRecording];
}

-(NSInteger)timeRecorded {
    return [_recorder currentTime];
}

-(void)currentPlayingStatusChanged:(AFSoundManagerStatus)status {
    status = (AFSoundManagerStatus)_status;
    NSLog(@"wut");
}

-(BOOL)status:(AFSoundManagerStatus)status {
    
    if (status == _status) {
        return YES;
    } else {
        return NO;
    }
}

-(BOOL)areHeadphonesConnected {
    
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance]currentRoute];
        
    BOOL headphonesLocated = NO;
    
    for (AVAudioSessionPortDescription *portDescription in route.outputs) {
        
        headphonesLocated |= ([portDescription.portType isEqualToString:AVAudioSessionPortHeadphones]);
    }
    
    return headphonesLocated;
}

-(void)forceOutputToDefaultDevice {
    
    [AFAudioRouter initAudioSessionRouting];
    [AFAudioRouter switchToDefaultHardware];
}

-(void)forceOutputToBuiltInSpeakers {
    
    [AFAudioRouter initAudioSessionRouting];
    [AFAudioRouter forceOutputToBuiltInSpeakers];
}

@end

//@implementation NSTimer (Blocks)
//
//+(id)scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
//    
//    void (^block)() = [inBlock copy];
//    id ret = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
//    
//    return ret;
//}
//
//+(id)timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)())inBlock repeats:(BOOL)inRepeats {
//    
//    void (^block)() = [inBlock copy];
//    id ret = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(executeSimpleBlock:) userInfo:block repeats:inRepeats];
//    
//    return ret;
//}
//
//+(void)executeSimpleBlock:(NSTimer *)inTimer {
//    
//    if ([inTimer userInfo]) {
//        void (^block)() = (void (^)())[inTimer userInfo];
//        block();
//    }
//}
//
//@end
//
//@implementation NSTimer (Control)
//
//static NSString *const NSTimerPauseDate = @"NSTimerPauseDate";
//static NSString *const NSTimerPreviousFireDate = @"NSTimerPreviousFireDate";
//
//-(void)pauseTimer {
//    
//    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPauseDate), [NSDate date], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    objc_setAssociatedObject(self, (__bridge const void *)(NSTimerPreviousFireDate), self.fireDate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//    
//    self.fireDate = [NSDate distantFuture];
//}
//
//-(void)resumeTimer {
//    
//    NSDate *pauseDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPauseDate);
//    NSDate *previousFireDate = objc_getAssociatedObject(self, (__bridge const void *)NSTimerPreviousFireDate);
//    
//    const NSTimeInterval pauseTime = -[pauseDate timeIntervalSinceNow];
//    self.fireDate = [NSDate dateWithTimeInterval:pauseTime sinceDate:previousFireDate];
//}
//
//@end
