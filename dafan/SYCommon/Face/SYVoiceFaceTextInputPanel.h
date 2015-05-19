//
//  MYVoiceFaceTextInputPanel.h
//  MY
//
//  Created by iMac on 14-8-6.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYFaceTextInputPanel.h"
#import "SYRecordPanel.h"

@interface SYVoiceFaceTextInputPanel : SYFaceTextInputPanel

@property(nonatomic, readonly) SYRecordPanel* recordPanel;
@property(nonatomic, readonly) UIImageView* voiceMarkedImageView;

@end
