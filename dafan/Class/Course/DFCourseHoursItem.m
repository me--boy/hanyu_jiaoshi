//
//  DFCourseHoursItem.m
//  dafan
//
//  Created by iMac on 14-9-3.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCourseHoursItem.h"
#import "DFCalendarEvent.h"

@implementation DFCourseHoursItem

- (id) initWithCourseDetailInfo:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.teacherUserId = [[dictionary objectForKey:@"teacher_userid"] integerValue];
        self.teacherName = [dictionary objectForKey:@"teacher_nickname"];
        
        self.courseName = [dictionary objectForKey:@"title"];
        self.courseId = [[dictionary objectForKey:@"id"] integerValue];
        self.bookId = [[dictionary objectForKey:@"textbook_id"] integerValue];
        self.classPeriodText = [dictionary objectForKey:@"course_starttime"];
        
        self.tuition = [[dictionary objectForKey:@"price"] floatValue];
//        self.hoursCount = [[dictionary objectForKey:@"coursehours"] integerValue];
        self.registered = [[dictionary objectForKey:@"sign_id"] integerValue] > 0;
        
        NSInteger hasRegisteredCount = [[dictionary objectForKey:@"sign_count"] integerValue];
        NSInteger maxRegisteredCount = [[dictionary objectForKey:@"max_sign_count"] integerValue];
        self.fullStrength = hasRegisteredCount >= maxRegisteredCount;
        
        NSArray* infos = [dictionary objectForKey:@"coursehours"];
        NSMutableArray* hours = [NSMutableArray arrayWithCapacity:infos.count];
        for (NSDictionary* info in infos)
        {
            DFCalendarEvent* hour = [[DFCalendarEvent alloc] init];
            hour.persistentId = [[info objectForKey:@"id"] integerValue];
            hour.date = [NSDate dateWithTimeIntervalSince1970:[[info objectForKey:@"course_day"] floatValue]];
            hour.event = [info objectForKey:@"title"];
            [hours addObject:hour];
        }
        self.hoursEvents = hours;
        self.hoursCount = self.hoursEvents.count;
    }
    return self;
}

- (id) initWithAvailableCourseInfo:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.courseName = [dictionary objectForKey:@"name"];
        self.bookId = [[dictionary objectForKey:@"textbook_id"] integerValue];
//        self.hoursCount = [[dictionary objectForKey:@"coursehours"] integerValue];
        self.tuition = [[dictionary objectForKey:@"price"] integerValue];
        
        NSArray* infos = [dictionary objectForKey:@"chapters"];
        NSMutableArray* hours = [NSMutableArray arrayWithCapacity:infos.count];
        for (NSDictionary* info in infos)
        {
            DFCalendarEvent* hour = [[DFCalendarEvent alloc] init];
//            hour.persistentId = [[info objectForKey:@"id"] integerValue];
//            hour.date = [NSDate dateWithTimeIntervalSince1970:[[info objectForKey:@"course_day"] floatValue]];
            hour.event = [info objectForKey:@"content"];
            [hours addObject:hour];
        }
        self.hoursEvents = hours;
        self.hoursCount = self.hoursEvents.count;
        
    }
    return self;
}

@end
