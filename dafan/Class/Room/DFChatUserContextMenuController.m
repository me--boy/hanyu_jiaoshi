//
//  DFChatUserContextMenuController.m
//  dafan
//
//  Created by iMac on 14-9-2.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChatUserContextMenuController.h"
#import "SYContextMenu.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "SYPrompt.h"
#import "DFAppDelegate.h"
#import "DFMessageViewController.h"
#import "UIAlertView+SYExtension.h"

@interface DFChatUserContextMenuController ()<SYContextMenuDelegate>

@property(nonatomic, strong) SYContextMenu* contextMenu;
@property(nonatomic, strong) DFUserMemberItem* memberItem;
@property(nonatomic) DFChatsUserStyle userStyle;

//@property(nonatomic, strong) NSMutableArray* requests;


@end

@implementation DFChatUserContextMenuController

- (id) initWithChatUserStyle:(DFChatsUserStyle)userStyle member:(DFUserMemberItem *)memberItem
{
    self = [super init];
    if (self)
    {
        self.userStyle = userStyle;
        self.memberItem = memberItem;
        [self initContextMenu];
    }
    return self;
}

- (void) initContextMenu
{
    NSMutableArray* items = [NSMutableArray array];
    SYContextMenuItem* messageItem = nil;
    SYContextMenuItem* disableTextChatItem = nil;
    SYContextMenuItem* disableVoiceItem = nil;
    
    switch (self.userStyle) {
        case DFChatsUserStyleClassroomVisitor:
        case DFChatsUserStyleClassroomStudent:
        case DFChatsUserStyleRoomVisitor:
            messageItem = [SYContextMenuItem contextMenuItemWithID:0 title:@"与TA私聊"];
            break;
        case DFChatsUserStyleClassroomTeacher:
        case DFChatsUserStyleRoomAdministrator:
            messageItem = [SYContextMenuItem contextMenuItemWithID:0 title:@"与TA私聊"];
            disableTextChatItem = [SYContextMenuItem contextMenuItemWithID:1 title:(self.memberItem.disableTextChat ? @"允许文聊" : @"禁止文聊")];
            disableVoiceItem = [SYContextMenuItem contextMenuItemWithID:2 title:(self.memberItem.disableVoiceChat ? @"允许语音": @"禁止语音")];
            break;
            
        default:
            break;
    }
    
    if (messageItem != nil)
    {
        [items addObject:messageItem];
    }
    if (disableTextChatItem)
    {
        [items addObject:disableTextChatItem];
    }
    if (disableVoiceItem)
    {
        [items addObject:disableVoiceItem];
    }
    SYContextMenuItem* reportItem = [SYContextMenuItem contextMenuItemWithID:3 title:@"举报TA"];
    [items addObject:reportItem];
    
    self.contextMenu = [[SYContextMenu alloc] initWithTitle:@"" menuItems:items];
    self.contextMenu.delegate = self;
}

- (void) popupInView:(UIView *)canvasView
{
    [self.contextMenu showInView:canvasView];
}

- (void) contextMenu:(SYContextMenu *)menu selectItem:(SYContextMenuItem *)item
{
    switch (item.menuId) {
        case 0:
            [self gotoMessageViewController];
            break;
            
        case 1:
            [self inverseTextChatEnabled];
            break;
        case 2:
            [self inverseVoiceChatEnabled];
            break;
            
        case 3:
            [self reportSomeone];
            break;
            
        default:
            break;
    }
}

- (void) reportSomeone
{
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforReport] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [SYPrompt showWithText:@"您已举报成功，一经核实会进行处理!"];
        }
        else
        {
            [UIAlertView showWithTitle:@"举报" message:errorMsg];
        }
    }];
    [self.urlRequests addObject:request];
}

- (void) contextMenuDidDismiss:(SYContextMenu *)contextMenu
{
    [self.delegate chatUserContextMenuControllerDidDismiss:self];
}

- (void) inverseVoiceChatEnabled
{
    typeof(self) __weak bself = self;
    if ([self.delegate respondsToSelector:@selector(menuActionDidStartForChatUserContextMenuController:)])
    {
        [self.delegate menuActionDidStartForChatUserContextMenuController:self];
    }
    
    NSString* url = nil;
    NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.memberItem.userId] forKey:@"banuid"];
    if (self.courseId > 0)
    {
        [info setObject:[NSNumber numberWithInt:self.courseId] forKey:@"course_id"];
        url = [DFUrlDefine urlForInverseClassroomVoiceChatEnabled];
        
//        [url appendFormat:@"%@&course_id=%d", [DFUrlDefine urlForInverseClassroomVoiceChatEnabled], self.courseId];
    }
    if (self.channeldId)
    {
        [info setObject:[NSNumber numberWithInt:self.channeldId] forKey:@"channel_id"];
        url = [DFUrlDefine urlForInverseChatroomVoiceChatEnabled];
        
//        [url appendFormat:@"%@&channel_id=%d", [DFUrlDefine urlForInverseChatroomVoiceChatEnabled], self.channeldId];
    }
    [info setObject:(self.memberItem.disableVoiceChat ? @"1" : @"0") forKey:@"type"];
//    [url appendString:(self.memberItem.disableVoiceChat ? @"&type=1" : @"type=0")];
//    [url appendFormat:@"&banuid=%d", self.memberItem.userId];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:url postValues:info finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage)
                              {
                                  if (succeed)
                                  {
//                                      bself.memberItem.disableVoiceChat = !bself.memberItem.disableVoiceChat;
//                                      if ([bself.delegate respondsToSelector:@selector(menuActionDidSucceedForChatUserContextMenuController:)])
//                                      {
//                                          [bself.delegate menuActionDidSucceedForChatUserContextMenuController:self];
//                                      }
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                                  if ([bself.delegate respondsToSelector:@selector(menuActionDidFinishForChatUserContextMenuController:)])
                                  {
                                      [bself.delegate menuActionDidFinishForChatUserContextMenuController:self];
                                  }
                              }];
    [self.urlRequests addObject:request];
}

- (void) inverseTextChatEnabled
{
    typeof(self) __weak bself = self;
    if ([self.delegate respondsToSelector:@selector(menuActionDidStartForChatUserContextMenuController:)])
    {
        [self.delegate menuActionDidStartForChatUserContextMenuController:self];
    }
    
    NSString* url = nil;
    NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.memberItem.userId] forKey:@"banuid"];
    if (self.courseId > 0)
    {
        [info setObject:[NSNumber numberWithInt:self.courseId] forKey:@"course_id"];
        url = [DFUrlDefine urlForInverseClassroomTextChatEnabled];
    }
    if (self.channeldId > 0)
    {
        [info setObject:[NSNumber numberWithInt:self.channeldId] forKey:@"channel_id"];
        url = [DFUrlDefine urlForInverseChatroomTextChatEnabled];
    }
    [info setObject:(self.memberItem.disableTextChat ? @"1" : @"0") forKey:@"type"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:url postValues:info finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage)
                              {
                                  if (succeed)
                                  {
//                                      bself.memberItem.disableTextChat = !bself.memberItem.disableTextChat;
//                                      if ([bself.delegate respondsToSelector:@selector(menuActionDidSucceedForChatUserContextMenuController:)])
//                                      {
//                                          [bself.delegate menuActionDidSucceedForChatUserContextMenuController:self];
//                                      }
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                                  if ([bself.delegate respondsToSelector:@selector(menuActionDidFinishForChatUserContextMenuController:)])
                                  {
                                      [bself.delegate menuActionDidFinishForChatUserContextMenuController:self];
                                  }
                              }];
    [self.urlRequests addObject:request];
}

- (void) gotoMessageViewController
{
    DFMessageViewController* controller = [[DFMessageViewController alloc] initWithUserId:self.memberItem.userId];
    controller.nickname = self.memberItem.nickname;
    controller.avatarUrl = self.memberItem.avatarUrl;
    UINavigationController* navigationController = (UINavigationController *)((DFAppDelegate *)[UIApplication sharedApplication].delegate).window.rootViewController;
    [navigationController pushViewController:controller animated:YES];
}

- (void) inverseFocuse
{
    typeof(self) __weak bself = self;
    if ([self.delegate respondsToSelector:@selector(menuActionDidStartForChatUserContextMenuController:)])
    {
        [self.delegate menuActionDidStartForChatUserContextMenuController:self];
    }
    NSDictionary* info = [NSDictionary dictionaryWithObject:[NSNumber numberWithInteger:self.memberItem.userId] forKey:@"userid"];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForInverseFocused] postValues:info finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage)
                              {
                                  if (succeed)
                                  {
                                      NSInteger focused = [[[resultInfo objectForKey:@"info"] objectForKey:@"fav_type"] integerValue];
                                      self.memberItem.focused = focused;
//                                      //与页面无关
//                                      if ([bself.delegate respondsToSelector:@selector(menuActionDidSucceedForChatUserContextMenuController:)])
//                                      {
//                                          [bself.delegate menuActionDidSucceedForChatUserContextMenuController:self];
//                                      }
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                                  if ([bself.delegate respondsToSelector:@selector(menuActionDidFinishForChatUserContextMenuController:)])
                                  {
                                      [bself.delegate menuActionDidFinishForChatUserContextMenuController:self];
                                  }
                              }];
    [self.urlRequests addObject:request];
}

@end
