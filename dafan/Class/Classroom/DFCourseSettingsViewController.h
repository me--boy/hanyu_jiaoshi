//
//  DFCourseSettingsViewController.h
//  dafan
//
//  Created by iMac on 14-8-26.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"

@interface DFCourseConfiguration : NSObject

@property(nonatomic) BOOL textChatEnabled;
@property(nonatomic) NSInteger timeInterval;
@property(nonatomic) NSInteger delayedTimeInterval;

@end

@interface DFCourseSettingsViewController : SYBaseContentViewController

@property(nonatomic, strong) DFCourseConfiguration* configuration;;

@end
