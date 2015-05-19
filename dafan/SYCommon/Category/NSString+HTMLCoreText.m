//
//  NSString+HTMLCoreText.m
//  dafan
//
//  Created by iMac on 14-8-21.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "NSString+HTMLCoreText.h"

@implementation NSString (HTMLCoreText)

- (NSString *) replaceFacesWithHtmlFormat
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\[face\\d{1,2}\\]"
                                                                           options:0
                                                                             error:&error];
    NSMutableString* string = [NSMutableString stringWithString:@""];
    __block NSInteger lastIdx = 0;
    
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
        NSRange range = result.range;
        NSLog(@"%d,%d", range.location, range.length);
        
        
        
        NSInteger idx = -1;
        NSString* intString = [self substringWithRange:NSMakeRange(range.location+5, range.length - 6)];
        if (intString.length == 1)
        {
            idx = [intString integerValue];
            
        }
        else if (intString.length == 2)
        {
            NSInteger tempIdx = [intString integerValue];
            if (tempIdx >= 10)
            {
                idx = tempIdx;
            }
        }
        
        if (idx >= 0)
        {
            [string appendString:[self substringWithRange:NSMakeRange(lastIdx, range.location - lastIdx)]];
            
            [string appendFormat:@"<img height='20' width='20' src='face%d.png'>",idx];
        }
        else
        {
            [string appendString:[self substringWithRange:NSMakeRange(lastIdx, range.location + range.length - lastIdx)]];
            
        }
        lastIdx = range.location + range.length;
        
        
    }];
    
    [string appendString:[self substringFromIndex:lastIdx]];
    
    return string;
}

- (NSString *) replaceUserIdNicknameJsonWithHrefAtDoubleAt
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"@.+@"
                                                                           options:0
                                                                             error:&error];
    NSMutableString* string = [NSMutableString stringWithString:@""];
    __block NSInteger lastIdx = 0;
    
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
        NSRange range = result.range;
        NSLog(@"%d,%d", range.location, range.length);
        
        
        
        NSString* json = [self substringWithRange:NSMakeRange(range.location + 1, range.length - 2)];
        NSData* data = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error;
        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
        if (resultJSON != nil)
        {
            NSInteger userId = [[resultJSON objectForKey:@"userid"] integerValue];
            NSString* nickname = [resultJSON objectForKey:@"nickname"];
            [string appendString:[self substringWithRange:NSMakeRange(lastIdx, range.location - lastIdx)]];
            [string appendString:[NSString stringWithFormat:@"<span color=\"#df0494\"><a href=\"mychat://%d\">%@</a></span>", userId, nickname]];
        }
        else
        {
            [string appendString:[self substringWithRange:NSMakeRange(lastIdx, range.location + range.length - lastIdx)]];
        }
        lastIdx = range.location + range.length;
        
    }];
    
    [string appendString:[self substringFromIndex:lastIdx]];
    
    return string;
}


@end
