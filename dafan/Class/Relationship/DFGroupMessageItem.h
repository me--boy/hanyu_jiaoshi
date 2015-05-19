//
//  DFGroupMessageItem.h
//  dafan
//
//  Created by iMac on 14-10-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFGroupMessageItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;

@property(nonatomic, readonly) NSString* adminAvatarUrl;
@property(nonatomic, readonly) NSInteger adminUserId;

@property(nonatomic, strong) NSString* title;
@property(nonatomic, readonly) NSString* chatUrl;
@property(nonatomic, readonly) NSInteger courseId;

@property(nonatomic, readonly) NSAttributedString* lastMessage;

@property(nonatomic) NSInteger timeintervalSince1970;
@property(nonatomic, strong) NSString* dateText;

@property(nonatomic) NSInteger unreadCount;
@property(nonatomic) BOOL ignoreNewMessage;

@property(nonatomic, readonly) NSArray* userMembers;

- (id) initWithClassCircleItemInfo:(NSDictionary *)info;

- (id) initWithClassCircleInfo:(NSDictionary *)info;

- (void) updateContentWithText:(NSString *)text;

@end
