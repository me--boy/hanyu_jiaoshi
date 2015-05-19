//
//  FriendsViewController.h
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//  学习圈子

#import "SYScrollPageViewController.h"


@interface DFRelationshipsViewController : SYScrollPageViewController

@property(nonatomic) NSInteger userId;
@property(nonatomic, strong) NSString* nickname;

- (id) initWithUserId:(NSInteger)userId;

@end
