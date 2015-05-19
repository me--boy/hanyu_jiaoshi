//
//  DFUserMemberItem.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUserMemberItem.h"

@interface DFUserMemberItem ()

@property(nonatomic) SYGenderType gender;

@end

@implementation DFUserMemberItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.userId = [[dictionary objectForKey:@"userid"] integerValue];
        self.nickname = [dictionary objectForKey:@"nickname"];
        self.avatarUrl = [dictionary objectForKey:@"avatar"];
        self.provinceCity = [dictionary objectForKey:@"city"];
        if (self.provinceCity.length == 0)
        {
            self.provinceCity = @"上海";
        }
        self.gender = [[dictionary objectForKey:@"gender"] integerValue];
        
        self.member = [[dictionary objectForKey:@"vip_type"] integerValue];
        self.userRole = [[dictionary objectForKey:@"user_type"] integerValue];
        self.focused = [[dictionary objectForKey:@"fav_type"] integerValue];
        
        self.inClassroom = [[dictionary objectForKey:@"online"] integerValue] > 0;
        self.disableTextChat = [[dictionary objectForKey:@"ban_chat"] integerValue] > 0;
        self.disableVoiceChat = [[dictionary objectForKey:@"ban_voice"] integerValue] > 0;
    }
    return self;
}

static NSString* prefix[] = {@"大" , @"二", @"三", @"四", @"五", @"六", @"七", @"八", @"九"};

- (void) setStudentPositionTextWithCount:(NSInteger)userCount
{
    NSMutableString* text = [[NSMutableString alloc] initWithString:@""];
    
    if (self.positionId == 0)
    {
        [text appendString:@"大"];
    }
    else if (self.positionId == userCount - 1)
    {
        [text appendString:@"小"];
    }
    else
    {
        [text appendString:prefix[self.positionId]];
    }
    [text appendString:@"弟子"];
    
    self.positionText = text;
}

- (void) setPositionTextBaseMyPosition:(NSInteger)myPosition count:(NSInteger)userCount
{
    if (myPosition == self.positionId)
    {
        if (myPosition == 0 || myPosition < userCount - 1)
        {
            self.positionText = [NSString stringWithFormat:@"老%@", prefix[myPosition]];
        }
        else
        {
            self.positionText = @"老小";
        }
        return;
    }
    
    NSMutableString* text = [[NSMutableString alloc] initWithString:@""];
    
    if (self.positionId == 0)
    {
        [text appendString:@"大"];
    }
    else if (self.positionId == userCount - 1)
    {
        [text appendString:@"小"];
    }
    else if (self.positionId >= 100)
    {
        [text appendString:@"X"];
    }
    else if (self.positionId > 0)
    {
        NSInteger ten = self.positionId / 10;
        NSInteger bit = self.positionId % 10;
        if (ten > 1)
        {
            [text appendString:prefix[ten - 1]];
        }
        if (ten > 0)
        {
            [text appendString:@"十"];
        }
        if (bit >= 0)
        {
            if (bit == 0 && ten > 0)
            {
                [text appendString:@"一"];
            }
            else
            {
                [text appendString:prefix[bit]];
            }
        }
    }
    
    
    if (self.gender == SYGenderTypeMale)
    {
        [text appendString:self.positionId > myPosition ? @"师弟" : @"师兄"];
    }
    else
    {
        [text appendString:self.positionId > myPosition ? @"师妹" : @"师姐"];
    }
    self.positionText = text;
}

- (BOOL) isEqual:(id)object
{
    DFUserMemberItem* member = (DFUserMemberItem *)object;
    return [member isKindOfClass:[DFUserMemberItem class]] && member.userId == self.userId;
}

@end
