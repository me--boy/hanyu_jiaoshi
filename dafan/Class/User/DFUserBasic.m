//
//  DFUserBasic.m
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUserBasic.h"

@interface DFUserBasic ()



@end

@implementation DFUserBasic

- (id) initWithContentFilePath:(NSString *)filePath
{
    self = [super init];
    if (self)
    {
        NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
        self.persistentId = [[dict objectForKey:@"userid"] integerValue];
        self.nickname = [dict objectForKey:@"nickname"];
        self.avatarUrl = [dict objectForKey:@"avatar"];
        self.role = [[dict objectForKey:@"user_type"] integerValue];
    }
    return self;
}

- (id) initWithClassCircleMember:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[info objectForKey:@"user_id"] integerValue];
        self.nickname = [info objectForKey:@"nickname"];
        self.avatarUrl = [info objectForKey:@"avatar"];
    }
    return self;
}

@end
