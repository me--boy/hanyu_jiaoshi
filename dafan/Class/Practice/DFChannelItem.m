//
//  DFChannelItem.m
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChannelItem.h"

@interface DFChannelItem ()

@property(nonatomic) NSInteger persistendId;
@property(nonatomic) NSInteger livingUserCount;
@property(nonatomic) NSInteger limitUserCount;
@property(nonatomic, strong) NSString* typeText;

@property(nonatomic) NSInteger adminUserId;

@property(nonatomic, strong) NSString* textChatUrl;
@property(nonatomic, strong) NSString* voiceChannelId;

@end

static int stPersistentId = 0;

#define kTestAvatarUrl @"http://static.maiqinqin.com/www/img/defaultavatar/avatar491.jpg"

@implementation DFChannelItem

- (id) initWithListItemDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        if ([dict objectForKey:@"channel_id"])
        {
            self.persistendId = [[dict objectForKey:@"channel_id"] integerValue];
        }
        else
        {
            self.persistendId = [[dict objectForKey:@"id"] integerValue];
        }
        
        self.adminUserId = [[dict objectForKey:@"userid"] integerValue];
        self.imageUrl = [dict objectForKey:@"img"];
        self.title = [dict objectForKey:@"name"];
        self.limitUserCount = [[dict objectForKey:@"max_count"] integerValue];
        self.livingUserCount = [[dict objectForKey:@"user_count"] integerValue];
        self.typeText = [dict objectForKey:@"tag_name"];
        
        self.password = [dict objectForKey:@"password"];
        
    }
    return self;
}

- (id) initWithDetailDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        if ([dict objectForKey:@"channel_id"])
        {
            self.persistendId = [[dict objectForKey:@"channel_id"] integerValue];
        }
        else
        {
            self.persistendId = [[dict objectForKey:@"id"] integerValue];
        }
        
        self.adminUserId = [[dict objectForKey:@"userid"] integerValue];
        self.imageUrl = [dict objectForKey:@"img"];
        self.title = [dict objectForKey:@"name"];
        self.limitUserCount = [[dict objectForKey:@"max_count"] integerValue];
        self.livingUserCount = [[dict objectForKey:@"user_count"] integerValue];
        self.typeText = [dict objectForKey:@"tag_name"];
        self.password = [dict objectForKey:@"password"];
        
        self.textChatUrl = [dict objectForKey:@"chat_url"];
        self.voiceChannelId = [dict objectForKey:@"room_id"];
        self.topic = [dict objectForKey:@"notice"];
        
        
    }
    return self;
}

+ (DFChannelItem *) testChannelItem
{
    ++stPersistentId;
    
    DFChannelItem* item = [[DFChannelItem alloc] init];
    
    item.persistendId = stPersistentId;
    item.imageUrl = kTestAvatarUrl;
    item.title = [NSString stringWithFormat:@"title%d", stPersistentId];
    item.livingUserCount = stPersistentId + 19;
    item.limitUserCount = 100;
    item.typeText = @"上海话";
    
    return item;
}

@end
