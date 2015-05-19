//
//  MYFocusButton.h
//  MY
//
//  Created by iMac on 14-5-7.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, SYFocusButtonState)
{
    SYFocusButtonStateUnfocused,
    SYFocusButtonStateFocused,
    SYFocusButtonStateMutalfcoused,
    SYFocusButtonStateLoading,
    SYFocusButtonStateCount
};

@interface SYFocusButton : UIButton

@property(nonatomic) SYFocusButtonState focusState;

- (void) setTitle:(NSString *)title forFocusState:(SYFocusButtonState)status;
- (void) setTitleColor:(UIColor *)title forFocusState:(SYFocusButtonState)status;
- (void) setImage:(UIImage *)image forFocusState:(SYFocusButtonState)status;

@end
