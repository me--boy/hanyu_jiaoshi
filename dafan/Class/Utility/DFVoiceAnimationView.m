//
//  DFVoiceAnimationView.m
//  dafan
//
//  Created by iMac on 14-10-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFVoiceAnimationView.h"

@interface DFVoiceAnimationView ()

@property(nonatomic, strong) UIImageView* backgroundImageView;
@property(nonatomic, strong) UIImageView* mikeImageView;
@property(nonatomic, strong) UIImageView* animatingImageView;

@end

@implementation DFVoiceAnimationView

#define KViewSize 96

- (void) addSubviews
{
    
    
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.image = [UIImage imageNamed:@"floating_voice_bkg.png"];
    [self addSubview:self.backgroundImageView];
    
    self.mikeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 20, 38, 55)];
    self.mikeImageView.image = [UIImage imageNamed:@"floating_voice.png"];
    [self addSubview:self.mikeImageView];
    
    NSMutableArray* images = [NSMutableArray array];
    for (NSInteger idx = 1; idx <= 4; ++idx)
    {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"floating_voice_%d.png", idx]];
        [images addObject:image];
    }
    self.animatingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(65, 45, 14, 29)];
    self.animatingImageView.animationDuration = 1.2;
    self.animatingImageView.animationRepeatCount = INT16_MAX;
    self.animatingImageView.animationImages = images;
    [self addSubview:self.animatingImageView];
}

+ (DFVoiceAnimationView *) showVoiceAnimationViewAtX:(CGFloat)originX y:(CGFloat)originY
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    DFVoiceAnimationView* view = [[DFVoiceAnimationView alloc] initWithFrame:CGRectMake(originX, originY, KViewSize, KViewSize)];
    [view addSubviews];
    [window addSubview:view];
    
    [view showAnimating];
    
    return view;
}

+ (DFVoiceAnimationView *) showVoiceAnimationViewFromBottom:(CGFloat)bottom
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize size = window.frame.size;
    
    return [DFVoiceAnimationView showVoiceAnimationViewAtX:(size.width - KViewSize) / 2 y:(size.height - bottom - KViewSize)];
}

+ (DFVoiceAnimationView *) showVoiceAnimationView
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGSize size = window.frame.size;
    
    return [DFVoiceAnimationView showVoiceAnimationViewAtX:(size.width - KViewSize) / 2 y:(size.height - KViewSize) / 2];
}

- (void) showAnimating
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (self.superview != window)
    {
        [window addSubview:self];
    }
    if (!self.animatingImageView.isAnimating)
    {
        [self.animatingImageView startAnimating];
    }
}

- (void) hideAnimating
{
    [self.animatingImageView stopAnimating];
    [self removeFromSuperview];
}

@end
