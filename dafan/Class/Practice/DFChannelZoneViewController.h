//
//  DFChatRoomViewController.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"
#import "DFTypeEnum.h"
#import "DFChannelItem.h"

@interface DFChannelZoneViewController : SYBaseContentViewController

- (id) initWithChannelItem:(DFChannelItem *)channel;

- (id) initWithChannelId:(NSInteger)channelId;

@end
