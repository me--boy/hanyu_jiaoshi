//
//  VoiceConverter.h
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceConverter : NSObject

+ (int)convertAMR:(NSString *)amrPath toWAV:(NSString *)wavPath;

+ (int)convertWAV:(NSString *)wavPath toAMR:(NSString *)amrPath;

@end
