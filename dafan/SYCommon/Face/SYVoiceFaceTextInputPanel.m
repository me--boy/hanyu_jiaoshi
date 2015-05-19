//
//  MYVoiceFaceTextInputPanel.m
//  MY
//
//  Created by iMac on 14-8-6.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYVoiceFaceTextInputPanel.h"
//#import "ConstDefine.h"
#import "DFColorDefine.h"

@interface SYVoiceFaceTextInputPanel ()

@property(nonatomic, strong) UIButton* voiceButton;
@property(nonatomic, strong) UIImageView* voiceMarkedImageView;
@property(nonatomic, strong) SYRecordPanel* recordPanel;

@end

@implementation SYVoiceFaceTextInputPanel

- (id)initWithCanvasView:(UIView *)canvasView
{
    self = [super initWithCanvasView:canvasView];
    if (self) {
        // Initialization code
        [self configSubviews];
    }
    return self;
}

#define kFaceOriginX 4.f
#define kVoiceTextViewSpace 4.f
#define kTextViewWidth 156
#define kTextViewSendButtonSpace 8
#define kSendButtonSize CGSizeMake(51, 34.f)

#define kMarkedOriginXFromVoice 28
#define kMarginOriginY 7
#define kMarkedIconSize 9.f

- (void) configSubviews
{
    CGSize inputBarSize = self.inputBarView.frame.size;
    
    CGRect faceFrame = self.faceButton.frame;
    faceFrame.origin.y = 0;
    faceFrame.origin.x = kFaceOriginX;
    faceFrame.size.height = inputBarSize.height;
    faceFrame.size.width = faceFrame.size.height;
    self.faceButton.frame = faceFrame;

    [self.faceButton addTarget:self action:@selector(faceButtonOwnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.voiceButton = [[UIButton alloc] initWithFrame:CGRectMake(faceFrame.origin.x + faceFrame.size.width, faceFrame.origin.y, faceFrame.size.width, faceFrame.size.height)];
    self.voiceButton.backgroundColor = [UIColor clearColor];
    [self.voiceButton setImage:[UIImage imageNamed:@"post_voice_selected.png"] forState:UIControlStateSelected];
    [self.voiceButton setImage:[UIImage imageNamed:@"post_voice_normal.png"] forState:UIControlStateNormal];
    [self.voiceButton addTarget:self action:@selector(voiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputBarView addSubview:self.voiceButton];
    
    CGRect voiceFrame = self.voiceButton.frame;
    
    self.voiceMarkedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(voiceFrame.origin.x + kMarkedOriginXFromVoice, kMarginOriginY, kMarkedIconSize, kMarkedIconSize)];
    self.voiceMarkedImageView.hidden = YES;
    self.voiceMarkedImageView.image = [UIImage imageNamed:@"flag_point.png"];
    [self.inputBarView addSubview:self.voiceMarkedImageView];
    //重新设置textView的Frame 即重新设置self.textContainerViewFrame
    
    CGRect tempRect = self.voiceMarkedImageView.frame;
    NSInteger textContainerViewX = tempRect.origin.x + tempRect.size.width + 8;
    NSInteger textContainerViewY = (kDefaultFooterViewHeight - kContentHeight) / 2;
    NSInteger textContainerViewW = self.frame.size.width - kSendButtonWidth - kSendButtonMarginRight - faceFrame.origin.x - faceFrame.size.width - 6 - self.voiceButton.frame.size.width - self.voiceMarkedImageView.frame.size.width;
    
    self.textContainerView.frame = CGRectMake(textContainerViewX, textContainerViewY, textContainerViewW, kContentHeight);
    
    
    CGRect inputContainerFrame = self.textContainerView.frame;
//    inputContainerFrame.origin.x = voiceFrame.origin.x + voiceFrame.size.width + kVoiceTextViewSpace;
//    inputContainerFrame.size.width = kTextViewWidth;
//    self.textContainerView.frame = inputContainerFrame;
    
    CGRect sendFrame = self.sendButton.frame;
//    sendFrame.size = kSendButtonSize;
    sendFrame.origin.x = inputContainerFrame.origin.x + inputContainerFrame.size.width + kTextViewSendButtonSpace;
    self.sendButton.frame = sendFrame;
    [self.sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [self.sendButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];

    self.recordPanel = [[SYRecordPanel alloc] initWithFrame:_panelContainerView.bounds];
    self.recordPanel.backgroundColor = RGBCOLOR(237, 237, 237);
    [_panelContainerView addSubview:self.recordPanel];
}

- (void) faceButtonOwnClicked:(id)sender
{
    self.faceButton.selected = YES;
    self.voiceButton.selected = NO;
    
    [_panelContainerView bringSubviewToFront:self.facesPanel];
}

- (void) voiceButtonClicked:(id)sender
{
    self.voiceButton.selected = YES;
    self.faceButton.selected = NO;
    
    [_panelContainerView bringSubviewToFront:self.recordPanel];
    
    _isEditing = YES;
    typeof(self) __weak bself = self;
    
    if (!self.textView.isFirstResponder)//键盘未弹出
    {
        //在底部
        //已经上升 facebutton click, keyboard show, facebuton
        [bself showPanelContainer];
    }
    else
    {
        //键盘已经弹出，关闭键盘
        [bself.textView resignFirstResponder];
        
        [bself showPanelContainer];
    }
}

- (void) keyboardDidShow
{
    self.voiceButton.selected = NO;
    self.faceButton.selected = NO;
}

- (void) endEditing
{
    [super endEditing];
    [self.recordPanel reset];
    self.voiceButton.selected = NO;
    self.faceButton.selected = NO;
}

#pragma mark - textview delegate

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0)
    {
        self.sendButton.selected = YES;
    }
    else
    {
        self.sendButton.selected = !self.voiceMarkedImageView.hidden;
    }
}

- (BOOL) contentShouldSend
{
    return self.textView.text.length > 0 || !self.voiceMarkedImageView.hidden;
}


@end
