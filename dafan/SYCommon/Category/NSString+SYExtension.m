//
//  NSString+Extension.m
//  MY
//
//  Created by 胡少华 on 14-3-24.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+SYExtension.h"




@implementation NSString (SYExtension)



- (NSString *) encryptionWithMD5
{
    if (self.length == 0)
    {
        return @"";
    }
    
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	const char *cstr = [self UTF8String];
    if (cstr)
    {
        CC_MD5(cstr, strlen(cstr), result);
        return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
    }
    else
    {
        return @"";
    }
    
}




#pragma mark -



@end
