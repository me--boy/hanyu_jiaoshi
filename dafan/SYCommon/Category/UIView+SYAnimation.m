//
//  UIView+Animation.m
//  MY
//
//  Created by 胡少华 on 14-3-25.
//  Copyright (c) 2014年 halley. All rights reserved.
//


#import "UIView+SYAnimation.h"

@implementation UIView (SYAnimation)

- (void) startRotate
{
    //    self.hidden = NO;
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //kCAMediaTimingFunctionLinear 表示时间方法为线性，使得足球匀速转动
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotation.toValue = [NSNumber numberWithFloat:4 * M_PI];
    rotation.duration = 1.5;
    rotation.repeatCount = HUGE_VALF;
    rotation.autoreverses = NO;
    
    [self.layer addAnimation:rotation forKey:@"rotation"];
}

- (void) stopRoatate
{
    //    self.hidden = YES;
    [self.layer removeAnimationForKey:@"rotation"];
}

- (void) rotate:(CGFloat)angle duration:(CGFloat)duration
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //kCAMediaTimingFunctionLinear 表示时间方法为线性，使得足球匀速转动
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotation.toValue = [NSNumber numberWithFloat:angle];
    rotation.duration = duration;
    rotation.removedOnCompletion = NO;
    rotation.repeatCount = 1;
    rotation.autoreverses = NO;
    rotation.fillMode = kCAFillModeForwards;
    
    
    [self.layer addAnimation:rotation forKey:@"rotation"];
    
//    self.layer.speed = 0;
}

- (void) translateX:(CGFloat)xOffset duration:(CGFloat)duration repeatCount:(NSInteger)repeatCout
{
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    //kCAMediaTimingFunctionLinear 表示时间方法为线性，使得足球匀速转动
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotation.toValue = [NSNumber numberWithFloat:xOffset];
    rotation.duration = duration;
    rotation.removedOnCompletion = NO;
    rotation.repeatCount = repeatCout;
    rotation.autoreverses = NO;
    rotation.fillMode = kCAFillModeForwards;
    
    [self.layer addAnimation:rotation forKey:@"translationX"];
}

- (void) translateX:(CGFloat)xOffset duration:(CGFloat)duration
{
    [self translateX:xOffset duration:duration repeatCount:1];
}

- (void) stopTranslateX
{
    [self.layer removeAnimationForKey:@"translationX"];
}

- (void) rotate:(CGFloat)angle translateX:(CGFloat)xOffset duration:(CGFloat)duration
{
    CAAnimationGroup* group = [CAAnimationGroup animation];
    group.duration = 1;
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *rotation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //kCAMediaTimingFunctionLinear 表示时间方法为线性，使得足球匀速转动
    rotation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    rotation.toValue = [NSNumber numberWithFloat:angle];
    rotation.duration = duration;
    rotation.removedOnCompletion = NO;
    rotation.repeatCount = 1;
    rotation.autoreverses = NO;
    rotation.fillMode = kCAFillModeForwards;
    
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    //kCAMediaTimingFunctionLinear 表示时间方法为线性，使得足球匀速转动
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    translation.toValue = [NSNumber numberWithFloat:xOffset];
    translation.duration = duration;
    translation.removedOnCompletion = NO;
    rotation.repeatCount = 1;
    translation.autoreverses = NO;
    translation.fillMode = kCAFillModeForwards;
    
    group.animations = [NSArray arrayWithObjects:rotation, translation, nil];
    
    [self.layer addAnimation:group forKey:nil];
//    group.animation = 1.0;
}

@end
