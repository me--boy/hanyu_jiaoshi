//
//  DFCalendarEvent.h
//  dafan
//
//  Created by iMac on 14-9-3.
//  Copyright (c) 2014年 com. All rights reserved.
//  模型对象

#import <Foundation/Foundation.h>

@interface DFCalendarEvent : NSObject

@property(nonatomic) NSInteger persistentId;
@property(nonatomic, strong) NSDate* date;
//@property(nonatomic, strong) NSDate* dateText;
@property(nonatomic, strong) NSString* event;

@end
