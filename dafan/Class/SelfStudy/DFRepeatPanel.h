//
//  DFRepeatPanel.h
//  dafan
//
//  Created by iMac on 14-10-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFRepeatPanel : UIView
@property (weak, nonatomic) IBOutlet UIButton *originVoicePlayButton;
@property (weak, nonatomic) IBOutlet UIButton *mikeButton;
@property (weak, nonatomic) IBOutlet UIButton *myVoicePlayButton;
@property (weak, nonatomic) IBOutlet UIButton *voicesComparedButton;

@property(nonatomic) BOOL originVoiceAnimating;

- (void) resetOriginVoice;
- (void) startOriginVoice;

- (void) startMyVoice;
- (void) resetMyVoice;

@end
