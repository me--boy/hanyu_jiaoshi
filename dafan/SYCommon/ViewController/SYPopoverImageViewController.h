//
//  SYPopoverImageViewController.h
//  dafan
//
//  Created by iMac on 14/10/24.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYPopoverImageViewController : UIViewController

@property(nonatomic, readonly) UIImageView* imageView;

@property(nonatomic, strong) UIImage* image;

- (id) initWithImage:(UIImage *)image;
- (id) initWithImageUrl:(NSString *)imageUrl;

- (void) popoverFromView:(UIView *)view;

@end
