//
//  DFMyCourseItem.h
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//课程的模型对象

#import <Foundation/Foundation.h>
#import "DFTypeEnum.h"

@interface DFCourseItem : NSObject <NSCoding>

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSInteger teacherId;
@property(nonatomic, readonly) NSString* courseName;
@property(nonatomic, readonly) NSString* coursePeriod;
@property(nonatomic, readonly) NSString* statusDescription;
@property(nonatomic, readonly) NSString* currentHoursTitle;

@property(nonatomic, readonly) NSString* teacherAvatarUrl;
@property(nonatomic, readonly) DFClassroomStatus classroomStatus;

@property(nonatomic, readonly) NSInteger tuition;
@property(nonatomic, readonly) NSInteger hoursCount;
@property(nonatomic, readonly) NSInteger registersCount;
@property(nonatomic, readonly) NSInteger maxRegisterCount;

@property(nonatomic, readonly) BOOL hasFinished;

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
