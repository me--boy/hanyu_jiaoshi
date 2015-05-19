//
//  MYDashLineView.h
//  SliderTest
//
//  Created by iMac on 14-6-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYDashLineView : UIView

@property(nonatomic, strong) UIColor* lineColor;

- (id) initWithOrigin:(CGPoint)point width:(CGFloat)width;
- (id) initWithOrigin:(CGPoint)point height:(CGFloat)height;

@end
