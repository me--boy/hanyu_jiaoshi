//
//  DFPaymentItem.m
//  dafan
//
//  Created by iMac on 14-9-17.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPaymentItem.h"

@interface DFPaymentItem ()

@property(nonatomic) NSInteger persistentId;
@property(nonatomic) NSInteger value;
@property(nonatomic, strong) NSString* comment;
@property(nonatomic, strong) NSDate* date;

@end

@implementation DFPaymentItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        self.value = [[dictionary objectForKey:@"balance"] integerValue];
        self.comment = [dictionary objectForKey:@"description"];
        self.date = [NSDate dateWithTimeIntervalSince1970:[[dictionary objectForKey:@"add_time"] integerValue]];
    }
    return self;
}
@end
