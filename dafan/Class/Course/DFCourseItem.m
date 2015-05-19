
//
//  DFMyCourseItem.m
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCourseItem.h"

@interface DFCourseItem()

@property(nonatomic) NSInteger persistentId;
@property(nonatomic) NSInteger teacherId;
@property(nonatomic, strong) NSString* courseName;
@property(nonatomic, strong) NSString* coursePeriod;
@property(nonatomic, strong) NSString* statusDescription;
@property(nonatomic, strong) NSString* currentHoursTitle;

@property(nonatomic, strong) NSString* teacherAvatarUrl;
@property(nonatomic) DFClassroomStatus classroomStatus;

@property(nonatomic) NSInteger tuition;
@property(nonatomic) NSInteger hoursCount;
@property(nonatomic) NSInteger registersCount;
@property(nonatomic) NSInteger maxRegisterCount;

@property(nonatomic) BOOL hasFinished;

@end

#define kCoderKeyId @"id"
#define kCoderKeyName @"title"
#define kCoderKeyTeacherId @"teacher_id"
#define kCoderKeyCoursePeriod @"course_starttime"
#define kCoderKeyStatus @"status_name"
#define kCoderKeyHourTitle @"hour_title"

#define kCoderKeyTuition @"price"
#define kCoderKeyHoursCount @"course_hours"
#define kCoderKeyRegisterCount @"sign_count"
#define kCoderKeyMaxRegisterCount @"max_sign_count"
#define kCoderKeyTeacherAvatar @"avatar"
#define kCoderKeyClassStatus @"isclass"
#define kCoderKeyFinished @"isover"

@implementation DFCourseItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if ([dictionary objectForKey:@"course_id"] != nil)
        {
            self.persistentId = [[dictionary objectForKey:@"course_id"] integerValue];
        }
        else
        {
            self.persistentId = [[dictionary objectForKey:kCoderKeyId] integerValue];
        }
        
        self.courseName = [dictionary objectForKey:kCoderKeyName];
        self.teacherId = [[dictionary objectForKey:kCoderKeyTeacherId] integerValue];
        self.coursePeriod = [dictionary objectForKey:kCoderKeyCoursePeriod];
        self.statusDescription = [dictionary objectForKey:kCoderKeyStatus];
        self.currentHoursTitle = [dictionary objectForKey:kCoderKeyHourTitle];
        
        self.tuition = [[dictionary objectForKey:kCoderKeyTuition] integerValue];
        self.hoursCount = [[dictionary objectForKey:kCoderKeyHoursCount] integerValue];
        self.registersCount = [[dictionary objectForKey:kCoderKeyRegisterCount] integerValue];
        self.maxRegisterCount = [[dictionary objectForKey:kCoderKeyMaxRegisterCount] integerValue];
        if (self.maxRegisterCount < self.registersCount)
        {
            self.maxRegisterCount = self.registersCount;
        }
        
        self.teacherAvatarUrl = [dictionary objectForKey:kCoderKeyTeacherAvatar];
        self.classroomStatus = [[dictionary objectForKey:kCoderKeyClassStatus] integerValue];
        self.hasFinished = [[dictionary objectForKey:kCoderKeyFinished] integerValue] == 1;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    
}

@end
