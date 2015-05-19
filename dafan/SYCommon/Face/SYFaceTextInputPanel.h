//
//  MYFaceTextInputPanel.h
//  MY
//
//  Created by 胡少华 on 14-6-19.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYFacesPanel.h"

#define kDefaultFooterViewHeight 44.0f
#define kFaceButtonSize 34.0f
#define kContentHeight kFaceButtonSize
//发送按钮
#define kSendButtonWidth 54.f
#define kSendButtonMarginRight 10.f

@class SYFaceTextInputPanel;

@protocol SYFaceTextInputPanelDelegate <NSObject>

- (BOOL) facePanelShouldEditing;

- (void) facePanelBeginEditing:(SYFaceTextInputPanel *)panel;
- (void) facePanelEndEditing:(SYFaceTextInputPanel *)panel;
- (void) sendText:(NSString *)text forFacePanel:(SYFaceTextInputPanel *)panel;


@end

@interface SYFaceTextInputPanel : UIView<UITextViewDelegate, SYFacesPanelDelegate>
{
    UIView* _panelContainerView;
    BOOL _isEditing;
}

- (id) initWithCanvasView:(UIView *)canvasView;

@property(nonatomic, weak) id<SYFaceTextInputPanelDelegate> delegate;

@property(nonatomic, readonly) UIView* inputBarView;

@property(nonatomic, readonly) UIButton* faceButton;
@property(nonatomic, readonly) UIView* textContainerView;
@property(nonatomic, readonly) UITextView* textView;
@property(nonatomic, readonly) UIButton* sendButton;

@property(nonatomic) BOOL inputBarHidden;

@property(nonatomic, readonly) SYFacesPanel* facesPanel;

- (void) putInBack;
- (void) putInBelowView:(UIView *)view;
- (void) endEditing;
- (void) beginEditing;

- (void) bringSelfToFront;

- (void) registerKeyboardObservers;
- (void) unregisterKeyboardObservers;

- (BOOL) contentShouldSend;

//
- (void) showPanelContainer;
- (void) keyboardDidShow;
- (void) keyboardDidHide;

@end
