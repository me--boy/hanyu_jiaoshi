
//
//  DFRepeatPanel.m
//  dafan
//
//  Created by iMac on 14-10-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFRepeatPanel.h"

@implementation DFRepeatPanel

- (void) resetOriginVoice
{
    self.originVoiceAnimating = NO;
    
    [self.originVoicePlayButton.imageView stopAnimating];
    [self.originVoicePlayButton setImage:[UIImage imageNamed:@"repeat_icon_play.png"] forState:UIControlStateNormal];
    self.originVoicePlayButton.highlighted = NO;
}

- (void) startOriginVoice
{
    self.originVoiceAnimating = YES;
    
    if (self.originVoicePlayButton.imageView.isAnimating)
    {
        return;
    }
    if (self.originVoicePlayButton.imageView.animationImages.count == 0)
    {
        NSMutableArray* images = [NSMutableArray arrayWithCapacity:3];
        for (NSInteger idx = 0; idx < 3; ++idx)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"voice_origin_play_%d.png", idx]]];
        }
        self.originVoicePlayButton.imageView.animationImages = images;
        self.originVoicePlayButton.imageView.animationDuration = 0.9;
        self.originVoicePlayButton.imageView.animationRepeatCount = INT16_MAX;
    }

    [self.originVoicePlayButton.imageView startAnimating];
}

- (void) resetMyVoice
{
    self.myVoicePlayButton.highlighted = NO;
    [self.myVoicePlayButton.imageView stopAnimating];
    [self.myVoicePlayButton setImage:[UIImage imageNamed:@"voice_play_3.png"] forState:UIControlStateNormal];
}

- (void) startMyVoice
{
    if (self.myVoicePlayButton.imageView.animationImages.count == 0)
    {
        NSMutableArray* images = [NSMutableArray arrayWithCapacity:4];
        for (NSInteger idx = 0; idx < 4; ++idx)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"voice_play_%d.png", idx]]];
        }
        self.myVoicePlayButton.imageView.animationImages = images;
        self.myVoicePlayButton.imageView.animationDuration = 1.2;
        self.myVoicePlayButton.imageView.animationRepeatCount = INT16_MAX;
    }
    
    [self.myVoicePlayButton.imageView startAnimating];
}

@end
