//
//  DFTeacherItem.h
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
// 老师模型对象

#import <Foundation/Foundation.h>

#import "DFUserProfile.h"

@interface DFTeacherItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSInteger userId;
@property(nonatomic, readonly) NSString* nickname;
@property(nonatomic, readonly) NSInteger rate;
//@property(nonatomic, readonly) DFVerifyType verify;
@property(nonatomic, readonly) NSString* teacherDescription;
@property(nonatomic, readonly) NSInteger studentsCount;
@property(nonatomic, readonly) NSString* avatarUrl;
@property(nonatomic, readonly) DFMemberType member;

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
