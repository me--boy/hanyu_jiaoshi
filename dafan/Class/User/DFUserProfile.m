//
//  DFUserProfile.m
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUserProfile.h"
#import "DFNotificationDefines.h"

@interface DFUserProfile ()

@property(nonatomic, strong) NSMutableArray* listenedCourseIds;
@property(nonatomic, strong) NSMutableArray* punishedNoPreviewCourseIds;

@end

@implementation DFUserProfile

- (id) initWithContentFilePath:(NSString *)filePath
{
    NSDictionary* dict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    return [self initWithDictionary:dict];
}

- (id) initWithDictionary:(NSDictionary *)dict //from server
{
    self = [super init];
    if (self)
    {
        [self updateWithDictionary:dict];
    }
    return self;
}

- (void) updateWithDictionary:(NSDictionary *)dict
{
    self.persistentId = [[dict objectForKey:@"userid"] integerValue];
    self.nickname = [dict objectForKey:@"nickname"];
    self.avatarUrl = [dict objectForKey:@"avatar"];
    self.role = [[dict objectForKey:@"user_type"] integerValue];
    self.member = [[dict objectForKey:@"vip_type"] integerValue];
//    self.verify = [[dict objectForKey:@"cert_type"] integerValue];
    self.city = [dict objectForKey:@"city_name"];
    self.cityId = [[dict objectForKey:@"city_id"] integerValue];
    self.provinceId = [[dict objectForKey:@"prov_id"] integerValue];
    self.freeTrialCount = [[dict objectForKey:@"lasttrycount"] integerValue];
    self.inviteCode = [dict objectForKey:@"invitecode"];
    self.gender = [[dict objectForKey:@"gender"] integerValue];
//    self.memberEndDate = [NSDate dateWithTimeIntervalSince1970:[[dict objectForKey:@"vip_endtime"] integerValue]];
    
    if ([dict objectForKey:@"SY_token"] != nil)
    {
        self.accessToken = [dict objectForKey:@"SY_token"];
    }
    self.accountName = [dict objectForKey:@"mobileno"];
}

- (void) writeToFile:(NSString *)filePath
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[NSString stringWithFormat:@"%i", self.persistentId] forKey:@"userid"];
    [dict setObject:self.nickname forKey:@"nickname"];
    [dict setObject:self.avatarUrl forKey:@"avatar"];
    [dict setObject:[NSNumber numberWithInteger:self.role] forKey:@"user_type"];
    [dict setObject:[NSNumber numberWithInteger:self.member] forKey:@"vip_type"];
//    [dict setObject:[NSNumber numberWithInteger:self.verify] forKey:@"cert_type"];
    [dict setObject:[NSNumber numberWithInteger:self.cityId] forKey:@"city_id"];
    [dict setObject:[NSNumber numberWithInteger:self.provinceId] forKey:@"prov_id"];
    [dict setObject:self.city forKey:@"city_name"];
    [dict setObject:self.inviteCode forKey:@"invitecode"];
    [dict setObject:self.accessToken forKey:@"SY_token"];
    [dict setObject:self.accountName forKey:@"mobileno"];
    [dict setObject:[NSNumber numberWithInt:self.freeTrialCount] forKey:@"lasttrycount"];
//    [dict setObject:self.memberEndDate forKey:@"vip_endtime"];
    
    [dict writeToFile:filePath atomically:YES];
}

- (BOOL) hasListenCourse:(NSInteger)courseId
{
    NSString* courseIdText = [NSString stringWithFormat:@"%d", courseId];
    return [self.listenedCourseIds containsObject:courseIdText];
}

- (void) listenCourse:(NSInteger)courseId
{
    if (self.listenedCourseIds == nil)
    {
        self.listenedCourseIds = [NSMutableArray array];
    }
    NSString* courseIdText = [NSString stringWithFormat:@"%d", courseId];
    if (![self.listenedCourseIds containsObject:courseIdText])
    {
        [self.listenedCourseIds addObject:courseIdText];
    }
}

- (void) punishForNoPreviewCourse:(NSInteger)courseId
{
    if (self.punishedNoPreviewCourseIds == nil)
    {
        self.punishedNoPreviewCourseIds = [NSMutableArray array];
    }
    NSString* courseIdText = [NSString stringWithFormat:@"%d", courseId];
    if (![self.punishedNoPreviewCourseIds containsObject:courseIdText])
    {
        [self.punishedNoPreviewCourseIds addObject:courseIdText];
    }
}

- (BOOL) hasPunishForNoPreviewCourse:(NSInteger)courseId
{
    NSString* courseIdText = [NSString stringWithFormat:@"%d", courseId];
    return [self.punishedNoPreviewCourseIds containsObject:courseIdText];
}

- (void) increaseContactMessageCount
{
    ++self.newContactMessageCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsCountChanged object:nil];
}

- (void) increaseGroupMessageCount
{
    ++self.newGroupMessageCount;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationNewsCountChanged object:nil];
}

@end
