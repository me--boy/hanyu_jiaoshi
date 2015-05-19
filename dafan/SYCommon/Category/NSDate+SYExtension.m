//
//  NSDate+Extension.m
//  MY
//
//  Created by iMac on 14-5-7.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "NSDate+SYExtension.h"

@implementation NSDate (SYExtension)

+ (NSDate *) dateWithDateFormattedString:(NSString *)string
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy-MM-dd";
    NSDate* date = [formater dateFromString:string];
    return date;
}

- (NSString *) dateString
{
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    formater.dateFormat = @"yyyy-MM-dd";
    
    return [formater stringFromDate:self];
}


- (NSInteger) yearsFromDate:(NSDate *)date
{
    NSTimeInterval interval = [self timeIntervalSinceDate:date];
    return ABS(interval / (60 * 60 * 24 * 365));
}

- (BOOL) earierOrSameDay:(NSDate *)date
{
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:self];
    NSDateComponents* dateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    
    return (components.year < dateComponents.year
            || (components.year == dateComponents.year || components.month < dateComponents.month)
            || (components.year == dateComponents.year || components.month == dateComponents.month || components.day <= dateComponents.day));
    
}

@end
