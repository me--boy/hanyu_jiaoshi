//
//  Prompt.h
//  MY
//
//  Created by 胡少华 on 14-3-28.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPrompt : NSObject{
    NSString *text;
    UIButton *contentView;
    CGFloat  duration;//toast显示的时长，以秒为单位，值为0时表示一直显示，这时需要手动隐藏
}

#define DEFAULT_DISPLAY_DURATION 2.0f

@property (assign,nonatomic) BOOL orientationSensitive;

+ (SYPrompt *) showWithText:(NSString *)text inView:(UIView *)view;

+ (SYPrompt *)showWithText:(NSString *) text_;
+ (SYPrompt *)showWithText:(NSString *) text_
                 duration:(CGFloat)duration_;

+ (SYPrompt *)showWithText:(NSString *) text_
                topOffset:(CGFloat) topOffset_;
+ (SYPrompt *)showWithText:(NSString *) text_
                topOffset:(CGFloat) topOffset
                 duration:(CGFloat) duration_;

+ (SYPrompt *)showWithText:(NSString *) text_
             bottomOffset:(CGFloat) bottomOffset_;
+ (SYPrompt *)showWithText:(NSString *) text_
             bottomOffset:(CGFloat) bottomOffset_
                 duration:(CGFloat) duration_;
+ (SYPrompt *)showWithText:(NSString *) text_ inView:(UIView *)view orientationSensitive:(BOOL)orientationSensitive;

-(void)showToast;
-(void)dismissToast;//用于手动隐藏toast,当duration为0时

@end
