//
//  UIView+SYShape.m
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "UIView+SYShape.h"

@implementation UIView (SYShape)

- (void) addOnSideBorderWithFrame:(CGRect)frame color:(UIColor *)color
{
    CALayer* border = [CALayer layer];
    border.frame = frame;
    border.backgroundColor = color.CGColor;
    [self.layer addSublayer:border];
}

- (void)setWhiteBorder:(CALayer *)layer{
    [self setBorderColor:layer color:[UIColor whiteColor]];
}

- (void) setBorderInteraction:(NSInteger)borderInteractionMask withColor:(UIColor *)color
{
    [self setBorderInteraction:borderInteractionMask withColor:color width:1];
}

- (void)setBorderInteraction:(NSInteger)borderInteractionMask withColor:(UIColor *)color width:(NSInteger)width
{
    CGSize size = self.frame.size;
    if (borderInteractionMask & MYBorderInteractionTop)
    {
        [self addOnSideBorderWithFrame:CGRectMake(0, 0, size.width, width) color:color];
    }
    if (borderInteractionMask & MYBorderInteractionLeft)
    {
        [self addOnSideBorderWithFrame:CGRectMake(0, 0, width, size.height) color:color];
    }
    if (borderInteractionMask & MYBorderInteractionBottom)
    {
        [self addOnSideBorderWithFrame:CGRectMake(0, size.height - width, size.width, width) color:color];
    }
    if (borderInteractionMask & MYBorderInteractionRight)
    {
        [self addOnSideBorderWithFrame:CGRectMake(0, size.width - width, width, size.height) color:color];
    }
}

- (void)setBorderColor:(CALayer *)layer color:(UIColor *)color
{
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:1];
    [layer setBorderColor:color.CGColor];
}

- (void)setLayerBorder:(CALayer *)layer Color:(UIColor *)color borderWidth:(CGFloat)borderWidth {
    [layer setMasksToBounds:YES];
    [layer setBorderWidth:borderWidth];
    [layer setBorderColor:color.CGColor];
}

- (void) circledWithColor:(UIColor *)color strokeWidth:(CGFloat)width
{
    CGFloat radius = self.layer.bounds.size.width / 2;
    [self makeViewASCircle:self.layer withRaduis:radius color:color.CGColor strokeWidth:width];
}


- (void)makeViewASCircle:(CALayer *)layer withRaduis:(CGFloat)radius color:(CGColorRef)color strokeWidth:(CGFloat)lineWidth {
    
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.backgroundColor = [UIColor greenColor].CGColor;
    circleLayer.path = [UIBezierPath bezierPathWithRoundedRect:layer.bounds cornerRadius:radius].CGPath;
    //    circleLayer.path = [UIBezierPath bezierPathWithArcCenter:self.center radius:radius startAngle:0 endAngle:2 * M_1_PI clockwise:YES].CGPath;
    circleLayer.strokeColor = color;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.lineWidth = lineWidth;
    [layer addSublayer:circleLayer];
    
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
}

@end
