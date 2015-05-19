//
//  DFChatViewController.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYTableViewController.h"
#import "DFTypeEnum.h"
#import "DFChannelItem.h"
#import "SYFaceTextInputPanel.h"
#import "DFUserMemberItem.h"


@class DFChatViewController;
@protocol DFChatViewControllerDelegate <NSObject>

- (void) facePanel:(SYFaceTextInputPanel *)facePanel beginEditingForChatViewController:(DFChatViewController *)viewController;
- (void) facePanel:(SYFaceTextInputPanel *)facePanel endEditingForChatViewController:(DFChatViewController *)viewController;

@optional
- (void) roomMemberStatusChanged;

- (void) classroomStatusChanged:(DFClassroomStatus)classStatus;
- (void) classroomDidKickedByTeacher;
- (void) classroomDidSetChapter:(NSInteger)chapterId section:(NSInteger)sectionId;

- (void) chatroomTopicChanged;
- (void) chatroomSettingsChanged;

- (void) voiceChannelExit;

@end

@interface DFChatViewController : SYTableViewController

@property(nonatomic) NSInteger rateId;

- (id) initWithChatUserStyle:(DFChatsUserStyle)chatUserStyle;


@property(nonatomic) NSInteger courseId;
@property(nonatomic) DFClassroomStatus classroomStatus;
@property(nonatomic) NSInteger courseHourRateId;
@property(nonatomic) NSInteger courseHourRate;

@property(nonatomic, strong) NSMutableArray* members;
@property(nonatomic, strong) DFChannelItem* channelInfo;

@property(nonatomic, readonly) SYFaceTextInputPanel* faceTextInputPanel;
@property(nonatomic, weak) id<DFChatViewControllerDelegate> controllerDelegate;

@property(nonatomic, strong) NSString* voiceChannelId;
@property(nonatomic, strong) NSString* textChatUrl;

- (void) joinChannel;
- (void) exitChannel;
- (void) stopChatroomSpeakTimer;

- (void) startTextChat;
- (void) stopTextChat;

- (void) exit;

@end
