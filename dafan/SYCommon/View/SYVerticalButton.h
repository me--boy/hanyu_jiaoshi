//
//  SYVerticalButton.h
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYVerticalButton : UIButton

@property(nonatomic) CGFloat marginTop;
@property(nonatomic) CGFloat marginBottom;

- (void) setTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font;

@end
