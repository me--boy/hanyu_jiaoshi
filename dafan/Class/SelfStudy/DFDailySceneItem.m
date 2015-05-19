//
//  DFDailySceneItem.m
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFDailySceneItem.h"

@interface DFDailySceneItem()

@property(nonatomic) NSInteger persistentId;
@property(nonatomic, strong) NSString* subject;
@property(nonatomic) NSInteger sectionCount;

@end

@implementation DFDailySceneItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        self.subject = [dictionary objectForKey:@"content"];
        self.sectionCount = [[dictionary objectForKey:@"section_count"] integerValue];
    }
    return self;
}

@end
