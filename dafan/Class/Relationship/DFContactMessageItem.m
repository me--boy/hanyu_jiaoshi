//
//  MYFriendItem.m
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFContactMessageItem.h"
#import "NSString+SYCoretext.h"

@interface DFContactMessageItem ()

@property(nonatomic) NSInteger userId;
@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic, strong) NSString* nickname;
@property(nonatomic) SYGenderType gender;

@property(nonatomic) DFUserRole userRole;
@property(nonatomic) DFMemberType member;

@property(nonatomic, strong) NSString* city;
@property(nonatomic, strong) NSAttributedString* lastMessage;


@end

@implementation DFContactMessageItem

- (id) initWithDictionary:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        self.userId = [[info objectForKey:@"userid"] integerValue];
        self.nickname = [[info objectForKey:@"nickname"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.avatarUrl = [info objectForKey:@"avatar"];

        self.gender = [[info objectForKey:@"gender"] integerValue];
        self.member = [[info objectForKey:@"vip_type"] integerValue];
        self.userRole = [[info objectForKey:@"user_type"] integerValue];
        
        self.unreadCount = [[info objectForKey:@"unreaded"] integerValue];
        self.timeintervalSince1970 = [[info objectForKey:@"ts"] integerValue];
        
        NSString* originMsg = [info objectForKey:@"msg"];
        if (originMsg.length > 0)
        {
            [self setLastMessageWithString:originMsg];
        }
        else if ([info objectForKey:@"voice"])
        {
            [self setLastMessageWithString:@"[语音]"];
        }

        self.city = [info objectForKey:@"city"];
        if (self.city.length == 0)
        {
            self.city = @"上海";
        }
    }
    return self;
}

static int stTestItemId = 0;
#define kTestAvatarUrl @"http://static.maiqinqin.com/www/img/defaultavatar/avatar491.jpg"

+ (DFContactMessageItem *)testItem
{
    DFContactMessageItem* item = [[DFContactMessageItem alloc] init];
    
    item.nickname = [NSString stringWithFormat:@"nick%d", ++stTestItemId];
    item.avatarUrl = kTestAvatarUrl;
    item.userRole = stTestItemId % DFUserRoleCount;
    item.member = stTestItemId % DFMemberTypeCount;
    item.unreadCount = stTestItemId % 4;
    item.gender = stTestItemId % SYGenderTypeCount;
    [item setLastMessageWithString:[NSString stringWithFormat:@"%@ say jhh", item.nickname]];
    
    return item;
}

- (void) setLastMessageWithString:(NSString *)originMessage
{
    self.lastMessage = [originMessage privateMessageAttributedString];
}

- (void) updateContentWithText:(NSString *)text
{
    [self setLastMessageWithString:text];
}

@end
