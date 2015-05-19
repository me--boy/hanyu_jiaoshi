//
//  MYFriendsTableViewController.h
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTableViewController.h"
#import "SYEnum.h"

@interface DFMessagesViewController : SYTableViewController

@property(nonatomic) NSInteger userId;

- (id) initWithStyle:(DFMessageStyle)style;

- (void) updateNewMessage:(NSString *)message userId:(NSInteger)userId unread:(BOOL)unread;
- (void) updateNewMessage:(NSString *)textContent classcircleId:(NSInteger)classcircleId unread:(BOOL)unread;

@end
