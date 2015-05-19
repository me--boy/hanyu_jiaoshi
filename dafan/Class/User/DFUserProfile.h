//
//  DFUserProfile.h
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUserBasic.h"
#import "SYEnum.h"



typedef NS_ENUM(NSInteger, DFMemberType)
{
    DFMemberTypeNormal = 0,
    DFMemberTypeVip = 1,
    DFMemberTypeCount
};


@interface DFUserProfile : DFUserBasic


@property(nonatomic, strong) NSString* accessToken;
@property(nonatomic, strong) NSString* accountName;
//@property(nonatomic, strong) NSString* password;
@property(nonatomic, strong) NSString* city;
@property(nonatomic) NSInteger provinceId;
@property(nonatomic) NSInteger cityId;
@property(nonatomic) SYGenderType gender;
@property(nonatomic) DFMemberType member;
@property(nonatomic) NSDate* memberEndDate;

@property(nonatomic) NSInteger freeTrialCount; //免费试听的次数

@property(nonatomic, strong) NSString* birthday;

@property(nonatomic) BOOL needRequestContactMessages;
@property(nonatomic) BOOL needRequestGroupMessages;
@property(nonatomic) NSInteger newContactMessageCount;
@property(nonatomic) NSInteger newGroupMessageCount;

- (void) increaseContactMessageCount;
- (void) increaseGroupMessageCount;

@property(nonatomic, strong) NSString* inviteCode;

- (id) initWithDictionary:(NSDictionary *)dictionary; //from server

- (void) updateWithDictionary:(NSDictionary *)dictionary;

- (void) writeToFile:(NSString *)filePath;

- (BOOL) hasListenCourse:(NSInteger)courseId;
- (void) listenCourse:(NSInteger)courseId;

- (void) punishForNoPreviewCourse:(NSInteger)courseId;
- (BOOL) hasPunishForNoPreviewCourse:(NSInteger)courseId;



@end
