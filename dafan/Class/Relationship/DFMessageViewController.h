//
//  DFMessageViewController.h
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//  

#import "SYBaseContentViewController.h"

typedef void(^messageViewControllerClosed)(NSString* text, NSInteger timeinterval);

@interface DFMessageViewController : SYBaseContentViewController

- (id) initWithUserId:(NSInteger)userId;

@property(nonatomic, readonly) NSInteger userId;
@property(nonatomic, strong) NSString* nickname;
@property(nonatomic, strong) NSString* avatarUrl;

- (id) initWithClassCircleId:(NSInteger)classCircleId;

@property(nonatomic, readonly) NSInteger classCircleId;

@property(nonatomic, copy) messageViewControllerClosed closedBlock;

@end
