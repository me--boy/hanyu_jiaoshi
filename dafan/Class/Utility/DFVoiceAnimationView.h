//
//  DFVoiceAnimationView.h
//  dafan
//
//  Created by iMac on 14-10-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFVoiceAnimationView : UIView

+ (DFVoiceAnimationView *) showVoiceAnimationViewAtX:(CGFloat)originX y:(CGFloat)originY;
+ (DFVoiceAnimationView *) showVoiceAnimationViewFromBottom:(CGFloat)bottom;
+ (DFVoiceAnimationView *) showVoiceAnimationView;

- (void) showAnimating;
- (void) hideAnimating;

@end
