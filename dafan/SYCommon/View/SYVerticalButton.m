//
//  SYVerticalButton.m
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYVerticalButton.h"

@implementation SYVerticalButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setTitle:(NSString *)title image:(UIImage *)image font:(UIFont *)font
{
    [self setTitle:title forState:UIControlStateNormal];
    [self setImage:image forState:UIControlStateNormal];
    self.titleLabel.font = font;
    
    self.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    CGPoint center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
    UIEdgeInsets imageEdgeInsets = UIEdgeInsetsZero;
    imageEdgeInsets.top = self.marginTop;
    imageEdgeInsets.left = center.x - self.imageView.center.x;
    imageEdgeInsets.bottom = self.bounds.size.height - self.marginTop - self.imageView.frame.size.height;
    imageEdgeInsets.right = self.imageView.center.x - center.x;
    
    UIEdgeInsets titleEdgeInsets = UIEdgeInsetsZero;
    titleEdgeInsets.top = CGRectGetHeight(self.bounds) - self.marginBottom - CGRectGetHeight(self.titleLabel.bounds);
    titleEdgeInsets.left = center.x - self.titleLabel.center.x;
    titleEdgeInsets.right = self.titleLabel.center.x - center.x;
    titleEdgeInsets.bottom = self.marginBottom;
    
    self.imageEdgeInsets = imageEdgeInsets;
    self.titleEdgeInsets = titleEdgeInsets;
}

@end
