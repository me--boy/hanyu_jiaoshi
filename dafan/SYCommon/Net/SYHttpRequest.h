//
//  MYHttpRequest.h
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>

extern const NSInteger kRequestCodeSucceed;
extern const NSInteger kRequestCodeHavenotEnoughtMoney;
extern const NSInteger kRequestCodeBeKicked;
extern const NSInteger kRequestCodeLoginOtherDevice;

@interface SYHttpRequestUploadFileParameter : NSObject

@property(nonatomic, strong) NSData* data;
@property(nonatomic, strong) NSString* contentType;
@property(nonatomic, strong) NSString* filename;

@property(nonatomic, strong) NSDictionary* userInfo;

@end

typedef void(^SYHttpRequestFinishedCallback)(BOOL success, NSDictionary * resultInfo, NSString* errorMsg);
typedef void(^SYHttpRequestProgressCallback)(CGFloat progress);

@interface SYHttpRequest : NSObject

+ (SYHttpRequest *) startAsynchronousRequestWithUrl:(NSString *)url postValues:(NSDictionary *)postValues finished:(SYHttpRequestFinishedCallback)finshed;

+ (SYHttpRequest *) uploadFile:(NSString *)url parameter:(SYHttpRequestUploadFileParameter *)param finished:(SYHttpRequestFinishedCallback)finshed;

+ (SYHttpRequest *) startDownloadFromUrl:(NSString *)url toFilePath:(NSString *)filePath progress:(SYHttpRequestProgressCallback)progress finished:(SYHttpRequestFinishedCallback)finshed;


- (void) cancel;

@end
