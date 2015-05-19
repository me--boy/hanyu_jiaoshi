//
//  DFGroupMessageItem.m
//  dafan
//
//  Created by iMac on 14-10-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFGroupMessageItem.h"
#import "NSString+SYCoreText.h"
#import "DFUserBasic.h"

@interface DFGroupMessageItem ()

@property(nonatomic) NSInteger persistentId;

@property(nonatomic, strong) NSString* adminAvatarUrl;
@property(nonatomic) NSInteger adminUserId;

//@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSString* chatUrl;
@property(nonatomic) NSInteger courseId;

@property(nonatomic, strong) NSAttributedString* lastMessage;

@property(nonatomic, strong) NSArray* userMembers;

@end

@implementation DFGroupMessageItem

- (id) initWithClassCircleItemInfo:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[info objectForKey:@"class_id"] integerValue];
        self.timeintervalSince1970 = [[info objectForKey:@"time"] integerValue];
        self.unreadCount = [[info objectForKey:@"unreads"] integerValue];

        self.adminUserId = [[info objectForKey:@"userid"] integerValue];
        self.adminAvatarUrl = [info objectForKey:@"avatar"];
        self.title = [info objectForKey:@"classname"];
        
        self.ignoreNewMessage = [[info objectForKey:@"is_ban"] integerValue] == 1;
        
        NSString* nickname = [info objectForKey:@"nickname"];
        NSString* originMsg = [info objectForKey:@"content"];
        if (originMsg.length > 0)
        {
            [self setLastMessageWithString:[NSString stringWithFormat:@"%@：%@", (nickname.length > 0 ? nickname : @""), originMsg]];
        }
        else if ([[info objectForKey:@"voice"] length] > 0)
        {
            [self setLastMessageWithString:[NSString stringWithFormat:@"%@：[语音]", (nickname.length > 0 ? nickname : @"")]];
        }
    }
    return self;
}

- (void) updateContentWithText:(NSString *)text
{
    [self setLastMessageWithString:text];
}

- (void) setLastMessageWithString:(NSString *)originMessage
{
    self.lastMessage = [originMessage privateMessageAttributedString];
}

- (id) initWithClassCircleInfo:(NSDictionary *)info
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[info objectForKey:@"id"] integerValue];
        self.adminUserId = [[info objectForKey:@"userid"] integerValue];
        self.title = [info objectForKey:@"classname"];
        self.chatUrl = [info objectForKey:@"chat_url"];
        self.courseId = [[info objectForKey:@"course_id"] integerValue];
        
        self.ignoreNewMessage = [[info objectForKey:@"is_ban"] integerValue] == 1;
        
        NSMutableArray* array = [NSMutableArray array];
        NSArray* members = [info objectForKey:@"members"];
        for (NSDictionary* info in members)
        {
            DFUserBasic* user = [[DFUserBasic alloc] initWithClassCircleMember:info];
            [array addObject:user];
        }
        self.userMembers = [NSArray arrayWithArray:array];
    }
    return self;
}

- (BOOL) isEqual:(id)object
{
    return [object isKindOfClass:[DFGroupMessageItem class]] && ((DFGroupMessageItem *)object).persistentId == self.persistentId;
}

@end
