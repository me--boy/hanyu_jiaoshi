//
//  DFUserBasic.h
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, DFUserRole)
{
    DFUserRoleNormal = 0,
    DFUserRoleStudent = 2,
    DFUserRoleTeacher = 1,
    DFUserRoleCount
};


@interface DFUserBasic : NSObject

@property(nonatomic) NSInteger persistentId;
@property(nonatomic, strong) NSString* nickname;
@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic) DFUserRole role;

- (id) initWithContentFilePath:(NSString *)filePath;

- (id) initWithClassCircleMember:(NSDictionary *)info;

@end
