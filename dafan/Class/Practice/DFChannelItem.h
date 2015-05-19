//
//  DFChannelItem.h
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFChannelItem : NSObject

@property(nonatomic, readonly) NSInteger adminUserId;
@property(nonatomic, readonly) NSInteger persistendId;
@property(nonatomic, strong) NSString* imageUrl;
@property(nonatomic, strong) NSString* title;
@property(nonatomic, readonly) NSInteger livingUserCount;
@property(nonatomic, readonly) NSInteger limitUserCount;
@property(nonatomic, readonly) NSString* typeText;
@property(nonatomic, strong) NSString* password;

@property(nonatomic, strong) NSString* topic; //话题
@property(nonatomic, readonly) NSString* textChatUrl;
@property(nonatomic, readonly) NSString* voiceChannelId;

- (id) initWithListItemDictionary:(NSDictionary *)dict;
- (id) initWithDetailDictionary:(NSDictionary *)dict;

+ (DFChannelItem *) testChannelItem;

@end
