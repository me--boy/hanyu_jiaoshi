//
//  MYRecordPanel.m
//  MY
//
//  Created by 胡少华 on 14-8-4.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYRecordPanel.h"
#import "DFColorDefine.h"
//#import "ConstDefine.h"

#define kRecordButtonMarginTop 50.0f
#define kRecordButtonSize 112.0f

#define kRecordVolumnSpace 14.0f

#define kVolumeMarginTop 72.0f
#define kVolumeSize CGSizeMake(38.0f, 68.0f)

#define kVoiceDurationMarginTop 19.0f
#define kVoiceDurationSize CGSizeMake(52.0f, 27.0f)

#define kRecordTipsHeight 21.0f
#define kRecordTipsMarginBottom 15.0f

#define kResetRecordSize 50.0f
#define kResetRecordSpace -10.0f


@interface SYRecordPanel ()

@property(nonatomic, strong) UIButton* playVoiceButton;

@property(nonatomic, strong) UIButton* recordButton;

@property(nonatomic, strong) UIImageView* leftVolumeImageView;

@property(nonatomic, strong) UIImageView* rightVolumeImageView;

@property(nonatomic, strong) UIButton* voiceDurationButton;

@property(nonatomic, strong) UILabel* recordTipsLabel;

@property(nonatomic, strong) UIButton* resetRecordButton;

@end

@implementation SYRecordPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    CGSize size = self.frame.size;
    //点击播放按钮
    CGFloat offsetX = (size.width - kRecordButtonSize) / 2;
    self.playVoiceButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, kRecordButtonMarginTop, kRecordButtonSize, kRecordButtonSize)];
    self.playVoiceButton.backgroundColor = [UIColor clearColor];
    self.playVoiceButton.hidden = YES;
    [self.playVoiceButton setImage:[UIImage imageNamed:@"post_record_play.png"] forState:UIControlStateNormal];
    [self.playVoiceButton setImage:[UIImage imageNamed:@"post_record_stop.png"] forState:UIControlStateSelected];
    [self addSubview:self.playVoiceButton];
    //开始录音按钮
    CGRect playVoiceFrame = self.playVoiceButton.frame;
    self.recordButton = [[UIButton alloc] initWithFrame:playVoiceFrame];
    self.recordButton.backgroundColor = [UIColor clearColor];
    [self.recordButton setImage:[UIImage imageNamed:@"post_record_normal.png"] forState:UIControlStateNormal];
    [self.recordButton setImage:[UIImage imageNamed:@"post_record_selected.png"] forState:UIControlStateSelected];
    [self addSubview:self.recordButton];
    //开始录音的声波左图片
    offsetX = playVoiceFrame.origin.x - kVolumeSize.width - kRecordVolumnSpace;
    self.leftVolumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, kVolumeMarginTop, kVolumeSize.width, kVolumeSize.height)];
    self.leftVolumeImageView.image = [UIImage imageNamed:@"post_record_left_volumn_0.png"];
    [self addSubview:self.leftVolumeImageView];
    [self setleftVolumeAnimationImages];
    //开始录音的声波右图片
    offsetX = playVoiceFrame.origin.x + playVoiceFrame.size.width + kRecordVolumnSpace;
    self.rightVolumeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, kVolumeMarginTop, kVolumeSize.width, kVolumeSize.height)];
    self.rightVolumeImageView.image = [UIImage imageNamed:@"post_record_right_volumn_0.png"];
    [self addSubview:self.rightVolumeImageView];
    [self setRightVolumeAnimationImages];
    //显示录音时长的按钮
    offsetX = (size.width - kVoiceDurationSize.width) / 2;
    self.voiceDurationButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, kVoiceDurationMarginTop, kVoiceDurationSize.width, kVoiceDurationSize.height)];
    self.voiceDurationButton.contentEdgeInsets = UIEdgeInsetsMake(0, 12, 6, 0);
    [self.voiceDurationButton setTitle:@"0''" forState:UIControlStateNormal];
    [self.voiceDurationButton setBackgroundImage:[UIImage imageNamed:@"post_record_duration.png"] forState:UIControlStateNormal];
    self.voiceDurationButton.hidden = YES;
    self.voiceDurationButton.backgroundColor = [UIColor clearColor];
    [self addSubview:self.voiceDurationButton];
    //重新录制按钮
    offsetX = playVoiceFrame.origin.x + playVoiceFrame.size.width + kResetRecordSpace;
    CGFloat offsetY = playVoiceFrame.size.height + playVoiceFrame.origin.y - kResetRecordSize;
    self.resetRecordButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, kResetRecordSize, kResetRecordSize)];
    self.resetRecordButton.backgroundColor = [UIColor clearColor];
    [self.resetRecordButton setBackgroundImage:[UIImage imageNamed:@"post_record_reset.png"] forState:UIControlStateNormal];
    [self.resetRecordButton setTitle:@"重录" forState:UIControlStateNormal];
    [self.resetRecordButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    self.resetRecordButton.titleLabel.font = [UIFont systemFontOfSize:15];
    self.resetRecordButton.hidden = YES;
    [self addSubview:self.resetRecordButton];
    //录音提示标签
    self.recordTipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, offsetY + kResetRecordSize + 12, size.width, kRecordTipsHeight)];
    self.recordTipsLabel.text = @"长按开始录音";
    self.recordTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.recordTipsLabel.font = [UIFont systemFontOfSize:15];
    self.recordTipsLabel.backgroundColor = [UIColor clearColor];
    self.recordTipsLabel.textColor = RGBCOLOR(170, 170, 170);
    [self addSubview:self.recordTipsLabel];
}

- (void) reset
{
    self.playVoiceButton.hidden = YES;
    self.playVoiceButton.selected = NO;
    self.recordButton.hidden = NO;
    self.recordButton.selected = NO;
    self.voiceDurationButton.hidden = YES;
    self.resetRecordButton.hidden = YES;
    self.recordTipsLabel.text = @"长按开始录音";
}
/**
 *  设置录音时录音左边的动画
 */
#define kVolumeAnimationCount 4
- (void) setleftVolumeAnimationImages
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSInteger idx = 0; idx < kVolumeAnimationCount; ++idx)
    {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"post_record_left_volumn_%d.png", idx]]];
    }
    self.leftVolumeImageView.animationImages = array;
    self.leftVolumeImageView.animationRepeatCount = INT16_MAX;
    self.leftVolumeImageView.animationDuration = 1.4;
}
/**
 *  设置录音时录音右边的动画
 */
- (void) setRightVolumeAnimationImages
{
    NSMutableArray* array = [NSMutableArray array];
    for (NSInteger idx = 0; idx < kVolumeAnimationCount; ++idx)
    {
        [array addObject:[UIImage imageNamed:[NSString stringWithFormat:@"post_record_right_volumn_%d.png", idx]]];
    }
    self.rightVolumeImageView.animationImages = array;
    self.rightVolumeImageView.animationRepeatCount = INT16_MAX;
    self.rightVolumeImageView.animationDuration = 1.4;
}


@end
