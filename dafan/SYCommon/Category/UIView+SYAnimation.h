//
//  UIView+Animation.h
//  MY
//
//  Created by 胡少华 on 14-3-25.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (SYAnimation)

- (void) startRotate;
- (void) stopRoatate;

- (void) rotate:(CGFloat)angle duration:(CGFloat)duration;

- (void) translateX:(CGFloat)xOffset duration:(CGFloat)duration;
- (void) translateX:(CGFloat)xOffset duration:(CGFloat)duration repeatCount:(NSInteger)repeatCout;
- (void) stopTranslateX;

- (void) rotate:(CGFloat)angle translateX:(CGFloat)xOffset duration:(CGFloat)duration;

@end
