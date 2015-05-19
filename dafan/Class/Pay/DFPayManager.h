//
//  DFPayManager.h
//  dafan
//
//  Created by iMac on 14-9-24.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFPayManager : NSObject

+ (DFPayManager *) sharedPreference;

- (void) payWithTradeNo:(NSString *)tradeNo params:(NSString *)params forCourse:(NSInteger)courseId;

- (void) processAliPayWithURL:(NSURL *)url;

@end
