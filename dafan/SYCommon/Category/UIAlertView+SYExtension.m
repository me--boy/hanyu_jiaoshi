
//
//  UIAlertView+Extension.m
//  MY
//
//  Created by iMac on 14-4-8.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "UIAlertView+SYExtension.h"

@implementation UIAlertView (SYExtension)

+ (void) showNOPWithText:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    [alert show];
}

+ (UIAlertView *) showWithTitle:(NSString *)title message:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
    [alert show];
    return alert;
}

@end
