//
//  DFChatMemberViewController.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYTableViewController.h"
#import "DFTypeEnum.h"
#import "DFUserMemberItem.h"

@class DFChatMemberViewController;
@protocol DFChatMemberViewControllerDelegate <NSObject>

@optional
- (void) refreshMemberForChatMemberViewController:(DFChatMemberViewController *)viewController;

@end

@interface DFChatMemberViewController : SYTableViewController

@property(nonatomic, weak) id<DFChatMemberViewControllerDelegate> delegate;

- (id) initWithChatUserStyle:(DFChatsUserStyle)userStyle;

@property(nonatomic) NSInteger classroomVisitorCount;

@property(nonatomic) NSInteger courseId;
@property(nonatomic) NSInteger channelId;

@property(nonatomic) NSArray* members;

@end
