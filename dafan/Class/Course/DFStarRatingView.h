//
//  DFStarRatingView.h
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFStarRatingView : UIView


@property(nonatomic) NSInteger numberOfStars;

@property(nonatomic) CGFloat starSpace;
@property(nonatomic) UIEdgeInsets contentInsects;

@property(nonatomic) NSInteger pickedStarCount;

- (void) reloadData;

@end
