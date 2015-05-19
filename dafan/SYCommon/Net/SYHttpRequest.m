//
//  SYHttpRequest.m
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYHttpRequest.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SYDeviceDescription.h"
#import "DFVersionRelease.h"
#import "DFUserProfile.h"
#import "DFPreference.h"

const NSInteger kRequestCodeSucceed = 200;
const NSInteger kRequestCodeHavenotEnoughtMoney = 100;
const NSInteger kRequestCodeBeKicked = 11;
const NSInteger kRequestCodeLoginOtherDevice = 10;


@implementation SYHttpRequestUploadFileParameter


@end

@interface SYHttpRequest()<ASIHTTPRequestDelegate>

@property(nonatomic, strong) ASIFormDataRequest* asiRequest;
@property(nonatomic, copy) SYHttpRequestFinishedCallback finishedBlock;
@property(nonatomic, copy) SYHttpRequestProgressCallback progressBlock;
@property(nonatomic) long long downloadedSize;

@end

@implementation SYHttpRequest


+ (SYHttpRequest *) startDownloadFromUrl:(NSString *)url toFilePath:(NSString *)filePath progress:(SYHttpRequestProgressCallback)progress finished:(SYHttpRequestFinishedCallback)finshed
{
    SYHttpRequest* request = [[SYHttpRequest alloc] initWithUrl:url];
    request.finishedBlock = finshed;
    request.progressBlock = progress;
    
    request.asiRequest.downloadDestinationPath = filePath;
    
    request.asiRequest.timeOutSeconds = 10;
    
    [request.asiRequest startAsynchronous];
    
    return request;
}

+ (SYHttpRequest *) uploadFile:(NSString *)url parameter:(SYHttpRequestUploadFileParameter *)param finished:(SYHttpRequestFinishedCallback)finished
{
    SYHttpRequest* request = [[SYHttpRequest alloc] initWithUrl:url];
    request.finishedBlock = finished;
    
    [request.asiRequest addData:param.data withFileName:param.filename andContentType:param.contentType forKey:@"Filedata"];
    
    [param.userInfo enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL* stop){
        [request.asiRequest addPostValue:object forKey:key];
    }];
    
    [request.asiRequest addPostValue:kAppVersion forKey:@"SY_version"];
    [request.asiRequest addPostValue:kSource forKey:@"source"];
    [request.asiRequest addPostValue:[SYDeviceDescription sharedDeviceDescription].vendorID forKey:@"vendorID"];
    [request.asiRequest addPostValue:[DFPreference sharedPreference].currentUser.accessToken forKey:@"SY_token"];
    
    [request.asiRequest startAsynchronous];
    
    return request;
}

+ (SYHttpRequest *) startAsynchronousRequestWithUrl:(NSString *)url postValues:(NSDictionary *)dict finished:(SYHttpRequestFinishedCallback)finished
{
    SYHttpRequest* request = [[SYHttpRequest alloc] initWithUrl:url];
    request.finishedBlock = finished;
    
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id object, BOOL* stop){
        [request.asiRequest addPostValue:object forKey:key];
    }];
    
    [request.asiRequest addPostValue:kAppVersion forKey:@"SY_version"];
//    [request.asiRequest addPostValue:@"0.9" forKey:@"SY_version"];
    [request.asiRequest addPostValue:kSource forKey:@"source"];
    [request.asiRequest addPostValue:[SYDeviceDescription sharedDeviceDescription].vendorID forKey:@"vendorID"];
    if ([DFPreference sharedPreference].currentUser.accessToken.length > 0)
    {
        [request.asiRequest addPostValue:[DFPreference sharedPreference].currentUser.accessToken forKey:@"SY_token"];
    }
    else
    {
        [request.asiRequest addPostValue:@"1" forKey:@"SY_token"];
    }
    
    [request.asiRequest startAsynchronous];
    
    return request;
}

- (id) initWithUrl:(NSString *)url
{
    self = [super init];
    if (self)
    {
        self.asiRequest = [[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        self.asiRequest.delegate = self;
        typeof(self) __weak bself = self;
        [self.asiRequest setBytesReceivedBlock:^(unsigned long long size, unsigned long long total) {
            if (bself.progressBlock)
            {
                NSLog(@"%s, download: %llu:%llu", __FUNCTION__, size, total);
                bself.downloadedSize += size;
                bself.progressBlock((float)bself.downloadedSize / total);
                
            }
        }];
    }
    return self;
}

- (void) requestStarted:(ASIHTTPRequest *)request
{
    self.downloadedSize = 0;
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    if (request.downloadDestinationPath.length > 0)
    {
        self.downloadedSize = 0;
        self.finishedBlock(YES, nil, @"download succeed!");
    }
    else
    {
        NSError *error;
        
//        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[request responseData] options:NSJSONReadingAllowFragments error:&error];
        NSDictionary *resultJSON = [NSJSONSerialization JSONObjectWithData:[[request responseString] dataUsingEncoding:NSUTF8StringEncoding]options:NSJSONReadingAllowFragments error:&error];
        
        NSInteger code = [[resultJSON objectForKey:@"code"] integerValue];
        if (code == 200)
        {
            self.finishedBlock(YES, resultJSON, [resultJSON objectForKey:@"errormsg"]);
        }
        else
        {
            NSLog(@"request-code-!200 %@-%@", request.url, request.responseString);
            
            NSString* message = [resultJSON objectForKey:@"errormsg"];
            self.finishedBlock(NO, resultJSON, (message.length == 0 ? @"网络不给力" : [resultJSON objectForKey:@"errormsg"]));
        }
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    self.downloadedSize = 0;
    self.finishedBlock(NO, nil, @"网络不给力");
}

- (void) cancel
{
    [self.asiRequest clearDelegatesAndCancel];
}

@end
