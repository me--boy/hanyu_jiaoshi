//
//  SYDownloadQueue.m
//  dafan
//
//  Created by iMac on 14-10-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "ASIHttpRequest.h"
#import "ASINetworkQueue.h"
#import "SYDownloadQueue.h"
#import "NSString+SYExtension.h"

@interface SYDownloadQueue () <ASIHTTPRequestDelegate>

@property(nonatomic, weak) SYDownloadUrlCallback callback;

@property(nonatomic, strong) ASINetworkQueue* asiQueue;

@end

@implementation SYDownloadQueue

+ (SYDownloadQueue *) startDownloadQueueWithUrls:(NSArray *)urls cacheDirectory:(NSString *)directory elementCallback:(SYDownloadUrlCallback)callback
{
    SYDownloadQueue* queue = [[SYDownloadQueue alloc] init];
    queue.callback = callback;
    
    for (NSString* url in urls)
    {
        ASIHTTPRequest* request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:url]];
        request.delegate = self;
        
        [queue.asiQueue addOperation:request];
    }
    
    [queue.asiQueue go];
    
    return queue;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.asiQueue = [[ASINetworkQueue alloc] init];
        
        self.asiQueue.requestDidStartSelector = @selector(requestStarted:);
        self.asiQueue.requestDidFinishSelector = @selector(requestFinished:);
        self.asiQueue.requestDidFailSelector = @selector(requestFailed:);
    }
    return self;
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    self.callback(YES, request.url.absoluteString);
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    self.callback(NO, request.url.absoluteString);
}

- (void) requestStarted:(ASIHTTPRequest *)request
{
    
}

@end
