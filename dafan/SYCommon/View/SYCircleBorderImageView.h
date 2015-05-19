//
//  MYCircleBorderImageView.h
//  MY
//
//  Created by iMac on 14-5-12.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYCircleBorderImageView : UIView

//@property(nonatomic, strong) UIImage* image;
@property(nonatomic, readonly) UIImageView* imageView;
@property(nonatomic, readonly) UIButton* button;


//- (void) setTapGestureWithAction:(SEL)action forTarget:(id)target;

- (void) circleWithColor:(UIColor *)color radius:(CGFloat)radius;
- (void) circleWithColor:(UIColor *)color radius:(CGFloat)radius strokeWidth:(CGFloat)strokeWidth;

- (void) setImageWithUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeHolderImage;

@end
