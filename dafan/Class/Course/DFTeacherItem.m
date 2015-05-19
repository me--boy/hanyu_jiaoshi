//
//  DFTeacherItem.m
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFTeacherItem.h"

@interface DFTeacherItem()

@property(nonatomic) NSInteger persistentId;
@property(nonatomic) NSInteger userId;
@property(nonatomic, strong) NSString* nickname;
@property(nonatomic) NSInteger rate;
//@property(nonatomic) DFVerifyType verify;
@property(nonatomic, strong) NSString* teacherDescription;
@property(nonatomic) NSInteger studentsCount;
@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic) DFMemberType member;

@end

@implementation DFTeacherItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        if ([dictionary objectForKey:@"teacher_id"])
        {
            self.persistentId = [[dictionary objectForKey:@"teacher_id"] integerValue];
        }
        else
        {
            self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        }
        if ([dictionary objectForKey:@"teacher_userid"] != nil)
        {
            self.userId = [[dictionary objectForKey:@"teacher_userid"] integerValue];
        }
        else
        {
            self.userId = [[dictionary objectForKey:@"userid"] integerValue];;
        }
        
        self.nickname = [dictionary objectForKey:@"nickname"];
        self.rate = [[dictionary objectForKey:@"rate"] integerValue];
        self.teacherDescription = [dictionary objectForKey:@"description"];
        self.studentsCount = [[dictionary objectForKey:@"student_count"] integerValue];
        self.avatarUrl = [dictionary objectForKey:@"avatar"];
        
        self.member = [[dictionary objectForKey:@"vip_type"] integerValue];
    }
    return self;
}

@end
