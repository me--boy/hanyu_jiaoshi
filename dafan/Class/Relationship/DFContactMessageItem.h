//
//  MYFriendItem.h
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFUserProfile.h"
#import "SYEnum.h"

@interface DFContactMessageItem : NSObject

@property(nonatomic, readonly) NSInteger userId;
@property(nonatomic, readonly) NSString* avatarUrl;

@property(nonatomic, readonly) NSString* nickname;
@property(nonatomic, readonly) SYGenderType gender;

@property(nonatomic, readonly) DFUserRole userRole;
@property(nonatomic, readonly) DFMemberType member;
@property(nonatomic, readonly) NSString* city;

@property(nonatomic, readonly) NSAttributedString* lastMessage;

@property(nonatomic) NSInteger unreadCount;

@property(nonatomic) NSInteger timeintervalSince1970;
@property(nonatomic, strong) NSString* dateText;

- (id) initWithDictionary:(NSDictionary *)info;

- (void) updateContentWithText:(NSString *)text;

+ (DFContactMessageItem *)testItem;


@end
