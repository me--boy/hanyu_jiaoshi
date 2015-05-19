//
//  NSDate+Extension.h
//  MY
//
//  Created by iMac on 14-5-7.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SYExtension)

// yyyy-MM-dd
+ (NSDate *) dateWithDateFormattedString:(NSString *)string;
- (NSString *) dateString;

- (NSInteger) yearsFromDate:(NSDate *)date;

- (BOOL) earierOrSameDay:(NSDate *)date;

@end
