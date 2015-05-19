//
//  MYRecordController.h
//  MY
//
//  Created by iMac on 14-8-5.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "SYRecordPanel.h"

@class SYRecordController;
@protocol SYRecordControllerDelegate <NSObject>

- (void) recordControllerVoiceRecord:(SYRecordController *)controller duration:(NSInteger)duration;
- (void) recordControllerVoiceClear:(SYRecordController *)controller;

@end

@interface SYRecordController : NSObject

@property(nonatomic, strong) SYRecordPanel* recordPanel;
@property(nonatomic,weak) id<SYRecordControllerDelegate> delegate;

- (void) stopPlay;


@end
