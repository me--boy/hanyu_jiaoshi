//
//  DFRepeatController.h
//  dafan
//
//  Created by iMac on 14-10-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFRepeatPanel.h"
#import "DFSentenceItem.h"

@interface DFRepeatController : NSObject

@property(nonatomic, strong) DFRepeatPanel* repeatPanel;
@property(nonatomic, strong) DFSentenceItem* sentence;

- (void) done;

@end
