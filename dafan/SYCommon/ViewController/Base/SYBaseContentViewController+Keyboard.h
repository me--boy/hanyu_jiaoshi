//
//  MYBaseContentViewController+Keyboard.h
//  MY
//
//  Created by 胡少华 on 14-4-14.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"

@interface SYBaseContentViewController (Keyboard)

- (void) registerKeyboardObservers;

- (void) unregisterKeyboardObservers;

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration;
- (void) keyboardWithFrame:(CGRect)frame willHideInDuration:(NSTimeInterval)duration;
- (void) keyboardWillChangeFrame:(CGRect)frame inDuration:(NSTimeInterval)duration;

@end
