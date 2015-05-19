//
//  SYDownloadQueue.h
//  dafan
//
//  Created by iMac on 14-10-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^SYDownloadUrlCallback)(BOOL success, NSString* url);

@interface SYDownloadQueue : NSObject

+ (SYDownloadQueue *) startDownloadQueueWithUrls:(NSArray *)urls cacheDirectory:(NSString *)directory elementCallback:(SYDownloadUrlCallback)callback;

@end
