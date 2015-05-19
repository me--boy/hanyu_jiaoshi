//
//  DFCourseHoursItem.h
//  dafan
//
//  Created by iMac on 14-9-3.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DFCourseHoursItem : NSObject

//@property(nonatomic) BOOL onlyLocal;

@property(nonatomic) NSInteger teacherUserId;

@property(nonatomic, strong) NSString* teacherName;
/**
 *  课程开始的时间
 */
@property(nonatomic, strong) NSString* classBeginTimeTextInDay;

@property(nonatomic) NSInteger bookId;

@property(nonatomic) NSInteger courseId;
/**
 *  课程的名字
 */
@property(nonatomic, strong) NSString* courseName;
/**
 *  总共上课的节数
 */
@property(nonatomic) NSInteger hoursCount;
/**
 *  学费
 */
@property(nonatomic) CGFloat tuition;
/**
 *  课程的开始时间 20:00-21:00
 */
@property(nonatomic) NSString* classPeriodText;

@property(nonatomic, strong) NSDate* beginDate;

@property(nonatomic) BOOL registered;

@property(nonatomic) BOOL fullStrength; //已经报满

@property(nonatomic, strong) NSArray* hoursEvents; //DFCalendarEvents.....

- (id) initWithCourseDetailInfo:(NSDictionary *)dictionary;

- (id) initWithAvailableCourseInfo:(NSDictionary *)dictionary;


@end
