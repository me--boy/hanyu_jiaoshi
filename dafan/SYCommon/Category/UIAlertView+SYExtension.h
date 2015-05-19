//
//  UIAlertView+Extension.h
//  MY
//
//  Created by iMac on 14-4-8.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (SYExtension)

+ (void) showNOPWithText:(NSString *)message;

+ (UIAlertView *) showWithTitle:(NSString *)title message:(NSString *)message;

@end
