//
//  DFCreateCourseViewController.h
//  dafan
//
//  Created by iMac on 14-8-19.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"
#import "DFCourseItem.h"
#import "DFCourseHoursItem.h"
#import "DFCalendarView.h"

@interface DFCourseViewController : SYBaseContentViewController

- (id) initWithMode:(DFCalendarMode)mode;

@property(nonatomic) NSInteger courseId;
/**
 *  数据源
 */
@property(nonatomic, strong) DFCourseHoursItem* currentCourseHoursItem; //mode == new

@property(nonatomic, strong) NSDate* hoursViewBeginDate; //课时面板时第一周的某个日期，精确到周即可

@end
