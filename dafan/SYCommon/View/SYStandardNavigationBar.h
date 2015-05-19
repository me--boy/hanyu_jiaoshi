//
//  SYStandardNavigationBar.h
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//  自定义的导航条

#import <UIKit/UIKit.h>

@interface SYStandardNavigationBar : UIView

@property(nonatomic, readonly) UIButton* titleButton;
@property(nonatomic, readonly) UIButton* leftButton;
@property(nonatomic, readonly) UIButton* rightButton;

//size (64,44)
//fontsize 16
//textcolor white
- (void) setRightButtonWithStandardTitle:(NSString *)title;
- (void) setRightButtonWithStandardImage:(UIImage *)image;

- (void) setLeftButtonWithStandardTitle:(NSString *)title;
- (void) setLeftButtonWithStandardImage:(UIImage *)image;

//- (void) layoutStandardRightButton;

@end
