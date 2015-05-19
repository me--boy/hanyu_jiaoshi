//
//  DFMikeButton.h
//  dafan
//
//  Created by iMac on 14-9-26.
//  Copyright (c) 2014年 com. All rights reserved.
//  麦克风 button

#import <UIKit/UIKit.h>

@class DFMikeButton;
@protocol DFMikeButtonDelegate <NSObject>

- (void) touchDownForMikeButton:(DFMikeButton *)button;
- (void) touchUpForMikeButton:(DFMikeButton *)button;

@end

@interface DFMikeButton : UIButton

@property(nonatomic, weak) id<DFMikeButtonDelegate> delegate;

@end
