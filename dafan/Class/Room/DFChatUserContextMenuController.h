//
//  DFChatUserContextMenuController.h
//  dafan
//
//  Created by iMac on 14-9-2.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFUserMemberItem.h"
#import "DFTypeEnum.h"

@class DFChatUserContextMenuController;
@protocol DFChatUserContextMenuControllerDelegate <NSObject>

- (void) chatUserContextMenuControllerDidDismiss:(DFChatUserContextMenuController *)controller; //set controller nil

@optional
- (void) menuActionDidStartForChatUserContextMenuController:(DFChatUserContextMenuController *)controller; // show doing view
- (void) menuActionDidFinishForChatUserContextMenuController:(DFChatUserContextMenuController *)controller; //hide doing view
//- (void) menuActionDidSucceedForChatUserContextMenuController:(DFChatUserContextMenuController *)controller; // reload subviews

@end

@interface DFChatUserContextMenuController : NSObject

@property(nonatomic, weak) id<DFChatUserContextMenuControllerDelegate> delegate;

- (id) initWithChatUserStyle:(DFChatsUserStyle)userStyle member:(DFUserMemberItem *)memberItem;
@property(nonatomic) NSInteger courseId;
@property(nonatomic) NSInteger channeldId;

- (void) popupInView:(UIView *)canvasView;

@property(nonatomic, strong) NSMutableArray* urlRequests;

@end
