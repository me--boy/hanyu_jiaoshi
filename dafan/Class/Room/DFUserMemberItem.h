//
//  DFUserMemberItem.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFUserProfile.h"

@interface DFUserMemberItem : NSObject

@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic) NSInteger userId;

@property(nonatomic, strong) NSString* nickname;
@property(nonatomic, strong) NSString* provinceCity;

//课堂
@property(nonatomic, strong) NSString* positionText; //大师兄
@property(nonatomic) BOOL inClassroom; //在课堂时有效

@property(nonatomic) NSInteger positionId;

@property(nonatomic) DFMemberType member;
@property(nonatomic) DFUserRole userRole;
@property(nonatomic) SYFocusState focused;

@property(nonatomic) BOOL disableTextChat;
@property(nonatomic) BOOL disableVoiceChat;

@property(nonatomic) BOOL admin;


- (id) initWithDictionary:(NSDictionary *)dictionary;

- (void) setStudentPositionTextWithCount:(NSInteger)userCount;
- (void) setPositionTextBaseMyPosition:(NSInteger)myPosition count:(NSInteger)userCount;

@end
