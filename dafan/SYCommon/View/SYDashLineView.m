//
//  MYDashLineView.m
//  SliderTest
//
//  Created by iMac on 14-6-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYDashLineView.h"

@implementation SYDashLineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithOrigin:(CGPoint)point width:(CGFloat)width
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, width, 1)];
    if (self)
    {
        
    }
    return self;
}

- (id) initWithOrigin:(CGPoint)point height:(CGFloat)height
{
    self = [super initWithFrame:CGRectMake(point.x, point.y, 1, height)];
    if (self)
    {
        
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    
    CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);  //设置线条终点形状
    
    const CGFloat lengths[] = {4,4};
    CGContextRef line = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(line, self.lineColor.CGColor);
    
    CGContextSetLineDash(line, 0,lengths, 1);  //画虚线
    CGContextMoveToPoint(line, 0.0, 0.0);    //开始画线
    if (self.frame.size.width == 1)
    {
        CGContextAddLineToPoint(line, 0.0, self.frame.size.height);
    }
    else
    {
        CGContextAddLineToPoint(line, self.frame.size.width, 0.0);
    }
    
    CGContextStrokePath(line);
}


@end
