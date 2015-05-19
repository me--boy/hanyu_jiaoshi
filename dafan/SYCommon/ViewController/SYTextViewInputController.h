//
//  MYTextViewController.h
//  MY
//
//  Created by iMac on 14-4-18.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"

@class SYTextViewInputController;
@protocol SYTextViewInputControllerDelegate <NSObject>

- (void) textViewInputController:(SYTextViewInputController *)textViewController inputText:(NSString *)text;

@end

typedef NS_ENUM(NSInteger, SYTextInputStyle) {
    SYTextInputStyleEdit,
    SYTextInputStyleCommit
};

@interface SYTextViewInputController : SYBaseContentViewController
{
    UITextView* _textView;
}

- (id) initWithInputStyle:(SYTextInputStyle)style;

@property(nonatomic, weak) id<SYTextViewInputControllerDelegate> delegate;

@property(nonatomic, readonly) UITextView* textView;
@property(nonatomic) NSInteger tag;
@property(nonatomic, strong) NSString* defaultText;
@property(nonatomic) NSInteger maxTextCount;
@property(nonatomic) NSInteger numberOfLines;
@property(nonatomic, strong) NSString* titleText;
@property(nonatomic) UIKeyboardType keyboardType;

@property(nonatomic, strong) NSString* placeHolder;


@end
