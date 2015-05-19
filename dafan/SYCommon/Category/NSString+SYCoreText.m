//
//  NSString+SYCoreText.m
//  dafan
//
//  Created by iMac on 14-8-21.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import <CoreText/CoreText.h>
#import "NSString+SYCoreText.h"

@implementation NSString (SYCoreText)

#pragma mark - core text
void RunDelegateDeallocCallback(void* refCon)
{
    
}

CGFloat RunDelegateGetAscentCallback(void* refCon)
{
    return 14;// [UIImage imageNamed:(__bridge NSString *)refCon].size.height;
}

CGFloat RunDelegateGetDescentCallback(void* refCon)
{
    return 0;
}

CGFloat RunDelegateGetWidthCallback(void *refCon)
{
    return 14;// [UIImage imageNamed:(__bridge NSString *)refCon].size.width;
}

- (NSAttributedString *) privateMessageAttributedString
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"@.+@"
                                                                           options:0
                                                                             error:&error];
    
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
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
            NSString* subString = [self substringWithRange:NSMakeRange(lastIdx, range.location - lastIdx)];
            [attributedString appendAttributedString:[subString faceAttributeString]];
            
            //            NSInteger userId = [[resultJSON objectForKey:@"userid"] integerValue];
            NSString* nickname = [resultJSON objectForKey:@"nickname"];
            
            NSMutableAttributedString* nicknameAttributedString = [[NSMutableAttributedString alloc] initWithString:nickname];
            [nicknameAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[UIColor redColor].CGColor range:NSMakeRange(0, nickname.length)];
            [attributedString appendAttributedString:nicknameAttributedString];
        }
        else
        {
            NSString* subString = [self substringWithRange:NSMakeRange(lastIdx, range.location + range.length - lastIdx)];
            [attributedString appendAttributedString:[subString faceAttributeString]];
        }
        lastIdx = range.location + range.length;
        
    }];
    
    NSString* subString = [self substringFromIndex:lastIdx];
    [attributedString appendAttributedString:[subString faceAttributeString]];
    
    //font
    CTFontRef font = CTFontCreateUIFontForLanguage(kCTFontUIFontSystem, 12, nil);
    [attributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:NSMakeRange(0, [attributedString length])];
    CFRelease(font);
    
    //txt color
    [attributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor grayColor].CGColor range:NSMakeRange(0, [attributedString length])];
    
    //pragrahp
    CTParagraphStyleSetting lineBreakMode;
    CTLineBreakMode lineBreak = kCTLineBreakByTruncatingTail;
    lineBreakMode.spec = kCTParagraphStyleSpecifierLineBreakMode;
    lineBreakMode.value = &lineBreak;
    lineBreakMode.valueSize = sizeof(CTLineBreakMode);
    //
    CTParagraphStyleSetting settings[] = {lineBreakMode};
    //
    CTParagraphStyleRef style = CTParagraphStyleCreate(settings, 1);
    //
    NSMutableDictionary* attributes = [NSMutableDictionary dictionaryWithObject:(__bridge id)style forKey:(id)kCTParagraphStyleAttributeName];
    [attributedString addAttributes:attributes range:NSMakeRange(0, [attributedString length])];
    
    return attributedString;
}

- (NSAttributedString *) faceAttributeString
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\[face\\d{1,2}\\]"
                                                                           options:0
                                                                             error:&error];
    NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc] initWithString:@""];
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
        
        if (idx > 0)
        {
            NSString* subString = [NSString stringWithFormat:@"%@ ", [self substringWithRange:NSMakeRange(lastIdx, range.location - lastIdx)]];
            NSMutableAttributedString* subAttributedString = [[NSMutableAttributedString alloc] initWithString:subString];
            
            CTRunDelegateCallbacks imageCallbacks;
            imageCallbacks.version = kCTRunDelegateVersion1;
            imageCallbacks.dealloc = RunDelegateDeallocCallback;
            imageCallbacks.getAscent = RunDelegateGetAscentCallback;
            imageCallbacks.getDescent = RunDelegateGetDescentCallback;
            imageCallbacks.getWidth = RunDelegateGetWidthCallback;
            
            NSString* imgName = [NSString stringWithFormat:@"face%d.png", idx];
            CTRunDelegateRef runDelegate = CTRunDelegateCreate(&imageCallbacks, (__bridge void *)(imgName));
            //    NSMutableAttributedString* imgAttributeString = [[NSMutableAttributedString alloc] initWithString:@" "];
            [subAttributedString addAttribute:(NSString *)kCTRunDelegateAttributeName value:(__bridge id)runDelegate range:NSMakeRange(subString.length - 1, 1)];
            CFRelease(runDelegate);
            
            [subAttributedString addAttribute:@"imageName" value:imgName range:NSMakeRange(subString.length - 1, 1)];
            
            [attributedString appendAttributedString:subAttributedString];
        }
        else
        {
            NSString* subString = [self substringWithRange:NSMakeRange(lastIdx, range.location + range.length - lastIdx)];
            NSMutableAttributedString* subAttributedString = [[NSMutableAttributedString alloc] initWithString:subString];
            
            [attributedString appendAttributedString:subAttributedString];
            
        }
        lastIdx = range.location + range.length;
    }];
    
    NSString* subString = [self substringFromIndex:lastIdx];
    NSAttributedString* subAttributedString = [[NSAttributedString alloc] initWithString:subString];
    [attributedString appendAttributedString:subAttributedString];
    
    return attributedString;
}

@end
