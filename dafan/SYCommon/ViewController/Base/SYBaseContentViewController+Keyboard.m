//
//  MYBaseContentViewController+Keyboard.m
//  MY
//
//  Created by 胡少华 on 14-4-14.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController+Keyboard.h"

@implementation SYBaseContentViewController (Keyboard)

- (void) registerKeyboardObservers
{
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

- (void) keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    NSValue* animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self keyboardWithFrame:keyboardFrame willShowInDuration:animationDuration];
    
}

- (void) keyboardFrameWillChanged:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    NSValue* animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [self keyboardWillChangeFrame:keyboardFrame inDuration:animationDuration];
}

- (void) keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* userInfo = notification.userInfo;
    
    NSValue* animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    NSValue *keyboardFrameValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameValue CGRectValue];
    
    [self keyboardWithFrame:keyboardFrame willHideInDuration:animationDuration];
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    
}
- (void) keyboardWithFrame:(CGRect)frame willHideInDuration:(NSTimeInterval)duration
{
    
}
- (void) keyboardWillChangeFrame:(CGRect)frame inDuration:(NSTimeInterval)duration
{
    
}

@end
