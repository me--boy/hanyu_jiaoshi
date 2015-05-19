//
//  MYRecordPanel.h
//  MY
//
//  Created by 胡少华 on 14-8-4.
//  Copyright (c) 2014年 halley. All rights reserved.
//  音频按钮点击后的展示的音频录制视图

#import <UIKit/UIKit.h>

@interface SYRecordPanel : UIView

/**
 *  点击播放按钮
 */
@property(nonatomic, readonly) UIButton* playVoiceButton;
/**
 *  开始录音按钮
 */
@property(nonatomic, readonly) UIButton* recordButton;

@property(nonatomic, readonly) UIImageView* leftVolumeImageView;

@property(nonatomic, readonly) UIImageView* rightVolumeImageView;

@property(nonatomic, readonly) UIButton* voiceDurationButton;
/**
 *  录音提示标签
 */
@property(nonatomic, readonly) UILabel* recordTipsLabel;
/**
 *  重新录制按钮
 */
@property(nonatomic, readonly) UIButton* resetRecordButton;

- (void) reset;

@end
