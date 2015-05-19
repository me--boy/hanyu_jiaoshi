
//
//  DFPreference.h
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFUserProfile.h"

typedef BOOL(^processWhenHasLogout)();

@interface DFPreference : NSObject

+ (DFPreference *) sharedPreference;

@property(nonatomic, readonly) NSInteger inviteCodeWorth;
@property(nonatomic, readonly) NSInteger agentReward;

@property(nonatomic, strong) NSString* privateMessageChatUrl;

@property(nonatomic, strong) NSString* deviceToken;

@property(nonatomic, strong) NSString* lastPhoneNo;
@property(nonatomic, strong) NSString* lastPassword;

//user
@property(nonatomic, readonly) DFUserProfile* currentUser;
@property(nonatomic, readonly) BOOL isThirdPartyLogin;

- (void) loginWithDictionary:(NSDictionary *)dict password:(NSString *)password;
- (void) thirdPartyLogin:(NSDictionary *)dict;

- (void) logout;

- (BOOL) validateLogin:(processWhenHasLogout)block;

- (BOOL) hasLogin;

//agreement

- (BOOL) userAgreeAgreement;
- (void) agreeAgreement;

- (void) requestNewsCount;


- (void) checkUpdate:(BOOL)alertWhenNewest completion:(void(^)(BOOL success))completion;

- (void) setInviteCodeworth:(NSInteger)worthValue agentReward:(NSInteger)agentReward;


@end
