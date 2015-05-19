//
//  MYFaceTextInputPanel.m
//  MY
//
//  Created by 胡少华 on 14-6-19.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYFaceTextInputPanel.h"
#import "SYFacesPanel.h"
#import "NSString+SYFace.h"
#import "UIAlertView+SYExtension.h"
#import "UIView+SYShape.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"

@interface SYFaceTextInputPanel ()

@property(nonatomic, weak) UIView* canvasView;

@property(nonatomic, strong) UIView* inputBarView;

@property(nonatomic, strong) UIButton* faceButton;
@property(nonatomic, strong) UIView* textContainerView;
@property(nonatomic, strong) UITextView* textView;
@property(nonatomic, strong) UIButton* sendButton;

@property(nonatomic, strong) UIView* panelContainerView;

@property(nonatomic) BOOL isEditing;

@property(nonatomic, strong) SYFacesPanel* facesPanel;

@end

@implementation SYFaceTextInputPanel
@synthesize isEditing = _isEditing;
@synthesize panelContainerView = _panelContainerView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithCanvasView:(UIView *)canvasView
{
    self = [super initWithFrame:canvasView.bounds];
    if (self)
    {
        self.canvasView = canvasView;
        [self initSubviews];
    }
    return self;
}

- (void) dealloc
{
    [self unregisterKeyboardObservers];
}

- (void) initSubviews
{
//    [self registerKeyboardObservers];
    
    CGSize size = self.canvasView.frame.size;
    self.inputBarView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - kDefaultFooterViewHeight, size.width, kDefaultFooterViewHeight)];
    self.inputBarView.clipsToBounds = YES;
    [self addSubview:self.inputBarView];
    
    UIImageView* bkgImageView = [[UIImageView alloc] initWithFrame:self.inputBarView.bounds];
    bkgImageView.image = [[UIImage imageNamed:@"text_bkg.png"]  resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [self.inputBarView addSubview:bkgImageView];
    
    [self initPanelContainerView];
    [self initFacesPanel];
    
    [self initFaceButton];
    [self initInputView];
    [self initSendButton];
}

- (void) setInputBarHidden:(BOOL)inputBarHidden
{
    if (inputBarHidden ^ _inputBarHidden)
    {
        _inputBarHidden = inputBarHidden;
        
        CGSize size = self.canvasView.frame.size;
        CGRect frame = self.inputBarView.frame;
        frame.origin.y = inputBarHidden ? size.height : size.height - kDefaultFooterViewHeight;
        self.inputBarView.frame = frame;
    }
}

- (void) putInBelowView:(UIView *)view
{
    [self.canvasView insertSubview:self belowSubview:view];
}

- (void) putInBack
{
//    [self.textContainerView makeViewASCircle:self.textContainerView.layer withRaduis:2 color:kMainDarkColor.CGColor strokeWidth:1];
    [self.canvasView insertSubview:self atIndex:0];
}

#define kPanelHeight 216.0f

- (void) initPanelContainerView
{
    CGSize size = self.canvasView.frame.size;
    self.panelContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height, size.width, kPanelHeight)];
    [self addSubview:self.panelContainerView];
}

- (void) initFacesPanel
{
    self.facesPanel = [[SYFacesPanel alloc] initWithFrame:self.panelContainerView.bounds];
//    self.facesPanel.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.facesPanel.backgroundColor = [UIColor whiteColor];
    self.facesPanel.delegate = self;
    [self.panelContainerView addSubview:self.facesPanel];
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.isEditing)
    {
        UITouch* touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        CGRect inputBarFrame = self.inputBarView.frame;
        if (point.y < inputBarFrame.origin.y + inputBarFrame.size.height - kDefaultFooterViewHeight)
        {
            [self endEditing];
            return;
        }
    }
    [super touchesBegan:touches withEvent:event];
}

- (void) initFaceButton
{
    self.faceButton = [[UIButton alloc] initWithFrame:CGRectMake(0, (kDefaultFooterViewHeight - kFaceButtonSize) / 2, kFaceButtonSize, kFaceButtonSize)];
//    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.faceButton.backgroundColor = [UIColor clearColor];
//    self.faceButton.imageView.contentMode = UIViewContentModeCenter;
    [self.faceButton setImage:[UIImage imageNamed:@"default_face.png"] forState:UIControlStateNormal];
    [self.faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputBarView addSubview:self.faceButton];
}



- (void) initInputView
{
    CGRect faceFrame = self.faceButton.frame;
    NSInteger textContainerViewX = faceFrame.origin.x + faceFrame.size.width;
    NSInteger textContainerViewY = (kDefaultFooterViewHeight - kContentHeight) / 2;
    NSInteger textContainerViewW = self.frame.size.width - kSendButtonWidth - kSendButtonMarginRight - faceFrame.origin.x - faceFrame.size.width - 6;
    
    self.textContainerView = [[UIImageView alloc] initWithFrame:CGRectMake(textContainerViewX, textContainerViewY, textContainerViewW, kContentHeight)];
    
    [((UIImageView *)self.textContainerView) setImage:[[UIImage imageNamed:@"text_input_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch]];
    self.textContainerView.userInteractionEnabled = YES;
    [self.inputBarView addSubview:self.textContainerView];
    
    self.textView = [[UITextView alloc] initWithFrame:self.textContainerView.bounds];//] textContainer:nil];
    
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.textView.returnKeyType = UIReturnKeySend;
    self.textView.font = [UIFont systemFontOfSize:14];
    self.textView.textColor = [UIColor blackColor];
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.opaque = NO;
    self.textView.delegate = self;
    [self.textContainerView addSubview:self.textView];
}

- (void) initSendButton
{
    self.sendButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - kSendButtonWidth - kSendButtonMarginRight, (kDefaultFooterViewHeight - kContentHeight) / 2, kSendButtonWidth, 34)];
//    self.faceButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.sendButton setTitleColor:RGBCOLOR(155, 155, 155) forState:UIControlStateNormal];
    [self.sendButton setTitleColor:RGBCOLOR(255, 255, 255) forState:UIControlStateSelected];
    self.sendButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self.sendButton setTitle:@"发送" forState:UIControlStateNormal];
    UIImage* normalImage = [[UIImage imageNamed:@"text_input_border.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [self.sendButton setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.sendButton setBackgroundImage:[UIImage imageNamed:@"text_send_selected.png"] forState:UIControlStateSelected];
//    [self.sendButton makeViewASCircle:self.sendButton.layer withRaduis:3 color:[UIColor whiteColor].CGColor strokeWidth:1];
    [self.sendButton addTarget:self action:@selector(sendButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.inputBarView addSubview:self.sendButton];
}

- (void) sendButtonClicked:(id)sender
{
    if ([self.delegate facePanelShouldEditing])
    {
        [self sendContent];
    }
}

- (BOOL) contentShouldSend
{
    return self.textView.text.length > 0;
}

- (void) sendContent
{
    if (![self contentShouldSend])
    {
        [UIAlertView showNOPWithText:@"说点什么吧"];
        return;
    }
    
    [self.delegate sendText:[self.textView.text replaceFacesIDWithFaceDescriptions] forFacePanel:self];
}

- (void) faceButtonClicked:(id)sender
{
    self.isEditing = YES;
    
    if (!self.textView.isFirstResponder)//键盘未弹出
    {
        //在底部
        //已经上升 facebutton click, keyboard show, facebuton
        
        [self showPanelContainer];
    }
    else
    {
        //键盘已经弹出，关闭键盘
        [self.textView resignFirstResponder];
        
        [self showPanelContainer];
    }
}

- (void) beginEditing
{
    self.isEditing = YES;
    [self bringSelfToFront];
}

- (void) bringSelfToFront
{
    [self.canvasView bringSubviewToFront:self];
}

- (void) showPanelContainer
{
    [self bringSelfToFront];
    
    CGSize size = self.frame.size;
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        CGRect panelFrame = bself.panelContainerView.frame;
        panelFrame.origin.y = size.height - kPanelHeight;
        bself.panelContainerView.frame = panelFrame;
        
        CGRect inputBarFrame = bself.inputBarView.frame;
        inputBarFrame.origin.y = panelFrame.origin.y - inputBarFrame.size.height;
        bself.inputBarView.frame = inputBarFrame;
        
        [bself.delegate facePanelBeginEditing:bself];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) showInputBarWithKeyboardFrame:(CGRect)keyboardFrame duration:(CGFloat)duration option:(NSInteger)animationOption
{
    [self bringSelfToFront];
    
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:duration delay:0 options:animationOption animations:^{
        
        CGRect inputBarFrame = bself.inputBarView.frame;
        inputBarFrame.origin.y = keyboardFrame.origin.y - inputBarFrame.size.height;
        bself.inputBarView.frame = inputBarFrame;
        
        [bself.delegate facePanelBeginEditing:bself];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) resetInputBarWithDuraion:(CGFloat)duration option:(NSInteger)animationOption
{
    [self.canvasView sendSubviewToBack:self];
    
    CGSize size = self.frame.size;
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:duration delay:0 options:animationOption animations:^{
        
        CGRect panelFrame = bself.panelContainerView.frame;
        panelFrame.origin.y = size.height;
        bself.panelContainerView.frame = panelFrame;
        
        CGRect inputBarFrame = bself.inputBarView.frame;
        inputBarFrame.origin.y = size.height - (bself.inputBarHidden ? 0 : inputBarFrame.size.height);
        bself.inputBarView.frame = inputBarFrame;
        
        [bself.delegate facePanelEndEditing:bself];
        
    } completion:^(BOOL finished){
        
    }];
}

- (void) registerKeyboardObservers
{
    [self unregisterKeyboardObservers];
    
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [notify addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [notify addObserver:self selector:@selector(keyboardFrameWillChanged:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void) unregisterKeyboardObservers
{
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [notify removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [notify removeObserver:self  name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

- (void) keyboardDidShow
{
    
}

- (void) keyboardDidHide
{
    
}

- (void) keyboardWillShow:(NSNotification *)notification
{
    self.isEditing = YES;
    
    NSDictionary* userInfo = notification.userInfo;
    
    NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    NSValue* animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue* optionalValue = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSInteger option;
    [optionalValue getValue:&option];
    
    [self showInputBarWithKeyboardFrame:keyboardFrame duration:animationDuration option:option];
    
    [self keyboardDidShow];
}

- (void) keyboardFrameWillChanged:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    NSValue* beginFrameValue = [userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    NSValue* endFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect beginFrame = [beginFrameValue CGRectValue];
    CGRect endFrame = [endFrameValue CGRectValue];
    
    if (CGSizeEqualToSize(beginFrame.size, endFrame.size))
    {
        return;
    }
    
    NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    NSValue* animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue* optionalValue = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSInteger option;
    [optionalValue getValue:&option];
    
    [self showInputBarWithKeyboardFrame:keyboardFrame duration:animationDuration option:option];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    NSValue* animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue* optionalValue = [userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    NSInteger option;
    [optionalValue getValue:&option];
    
    if (!self.isEditing)
    {
        [self resetInputBarWithDuraion:animationDuration option:option];
        
    }
    [self keyboardDidHide];
    
}

#pragma mark - textviewDelegate

//TODO:业务逻辑，移除
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return [self.delegate facePanelShouldEditing];
}

- (void) textViewDidChange:(UITextView *)textView
{
    self.sendButton.selected = textView.text.length > 0;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (textView.markedTextRange == nil)
    {
        if ([text isEqualToString:@"\n"])
        {
            [self sendContent];
            return NO;
        }
        else if ([text isEqualToString:@""])
        {
            [self deleteLastCharacterForTextInput];
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - 

- (void) endEditing
{
    if (self.isEditing)
    {
        self.isEditing = NO;
        if (self.textView.isFirstResponder)
        {
            [self.textView resignFirstResponder];
        }
        else
        {
            [self resetInputBarWithDuraion:0.2 option:UIViewAnimationOptionCurveEaseInOut];
        }
        self.textView.text = @"";
    }
    
}

#pragma mark - facepanel delegate

- (void) face:(NSInteger)faceID clickedAtFacePanel:(SYFacesPanel *)facePanel
{
    [self.textView insertText:[NSString faceTextForID:faceID]];
    CGSize size = self.textView.contentSize;
    if (size.height > self.textView.frame.size.height)
    {
        self.textView.contentOffset = CGPointMake(0, size.height - self.textView.frame.size.height);
    }
}

- (void) delButtonClickedAtFacePanel:(SYFacesPanel *)panel
{
    [self deleteLastCharacterForTextInput];
}

- (void) deleteLastCharacterForTextInput
{
    NSString* suffix = [self.textView.text faceDescriptionSuffix];
    if (suffix.length > 0)
    {
        for (NSInteger idx = 0; idx < suffix.length; ++idx)
        {
            [self.textView deleteBackward];
        }
    }
    else
    {
        [self.textView deleteBackward];
    }
}

@end
