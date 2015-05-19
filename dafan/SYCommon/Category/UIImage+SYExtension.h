//
//  UIImage+Extension.h
//  MY
//
//  Created by iMac on 14-4-21.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (SYExtension)

-(UIImage*)subImageWithRect:(CGRect)rect;
-(UIImage*)scaleToSize:(CGSize)size;

+ (UIImage *) imageWithColor:(UIColor *)color size:(CGSize)size;



@end
