//
//  UIView+SYShape.h
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, MYBorderInteraction)
{
    MYBorderInteractionTop = 1,
    MYBorderInteractionLeft = 1 << 1,
    MYBorderInteractionBottom = 1 << 2,
    MYBorderInteractionRight = 1 << 3
};

@interface UIView (SYShape)

- (void)setWhiteBorder:(CALayer *)layer;
- (void)setBorderColor:(CALayer *)layer color:(UIColor *)color;
- (void)setLayerBorder:(CALayer *)layer Color:(UIColor *)color borderWidth:(CGFloat)borderWidth;

- (void)setBorderInteraction:(NSInteger)borderInteractionMask withColor:(UIColor *)color;
- (void)setBorderInteraction:(NSInteger)borderInteractionMask withColor:(UIColor *)color width:(NSInteger)width;

- (void) circledWithColor:(UIColor *)color strokeWidth:(CGFloat)width;

- (void)makeViewASCircle:(CALayer *)layer withRaduis:(CGFloat)radius color:(CGColorRef)color strokeWidth:(CGFloat)lineWidth;

@end
