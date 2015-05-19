//
//  DFPaymentItem.h
//  dafan
//
//  Created by iMac on 14-9-17.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFPaymentItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSInteger value;
@property(nonatomic, readonly) NSString* comment;
@property(nonatomic, readonly) NSDate* date;

@property(nonatomic, strong) NSString* dateText; //date yyyy-MM-dd

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
