//
//  DFCalendarView.h
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, DFCalendarMode)
{
    DFCalendarModeNew,
    DFCalendarModeEdit,
    DFCalendarModeRead//只读
};
@interface DFCalendarView : UIScrollView

- (id)initWithFrame:(CGRect)frame mode:(DFCalendarMode)mode;

@property(nonatomic) NSInteger eventCountForNew;

@property(nonatomic, strong) NSDate* firstWeekDate;
@property(nonatomic, strong) NSArray* events;//DFCalendarEvent{id, date, event}

@property(nonatomic, readonly) NSArray* newDates; //DFCalendarModeNew时
@property(nonatomic, readonly) NSArray* editEvents;

//在之前调用beginEventDate, events
//return: end origin y
- (CGFloat) drawDaysFromOriginY:(CGFloat)pointY;

- (void) setItemDisabledForEditMode;

@end
