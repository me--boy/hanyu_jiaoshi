//
//  Prompt.m
//  MY
//
//  Created by 胡少华 on 14-3-28.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYPrompt.h"

@interface SYPrompt ()
- (void)setDuration:(CGFloat) duration_;

//- (void)dismisToast;
- (void)toastTaped:(UIButton *)sender_;

- (void)showAnimation;
- (void)hideAnimation;

- (void)show;
- (void)showFromTopOffset:(CGFloat) topOffset_;
- (void)showFromBottomOffset:(CGFloat) bottomOffset_;
@end

@implementation SYPrompt

@synthesize orientationSensitive;

//initialize
- (void)dealloc{
    [self dismissToast];
}

- (id)initWithText:(NSString *)text_{
    if (self = [super init]) {
        
        text = [text_ copy];
        
        UIFont *font = [UIFont boldSystemFontOfSize:14];
        CGSize textSize = [text sizeWithFont:font
                           constrainedToSize:CGSizeMake(280, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
        if (textSize.width < 160)
        {
            textSize.width = 160;
        }
        if (textSize.height < 64)
        {
            textSize.height = 64;
        }
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, textSize.width + 12, textSize.height + 12)];
        textLabel.backgroundColor = [UIColor clearColor];
        textLabel.textColor = [UIColor whiteColor];
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.font = font;
        textLabel.text = text;
        textLabel.numberOfLines = 0;
        
        contentView = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, textLabel.frame.size.width, textLabel.frame.size.height)];
        contentView.layer.cornerRadius = 5.0f;
        //contentView.layer.borderWidth = 1.0f;
        //contentView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.5].CGColor;
        contentView.backgroundColor = [UIColor colorWithRed:0.0f
                                                      green:0.0f
                                                       blue:0.0f
                                                      alpha:0.7f];
        [contentView addSubview:textLabel];
        contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [contentView addTarget:self
                        action:@selector(toastTaped:)
              forControlEvents:UIControlEventTouchDown];
        contentView.alpha = 0.0f;
        
        duration = DEFAULT_DISPLAY_DURATION;
        self.orientationSensitive = YES;
        //        CFRetain(self);
    }
    return self;
}



-(void)dismissToast{
    [contentView removeFromSuperview];
    if (self.orientationSensitive) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarOrientationNotification
                                                      object:nil];
    }
    
    //    CFRelease(self);
}

-(void)toastTaped:(UIButton *)sender_{
    [self hideAnimation];
}

- (void)setDuration:(CGFloat) duration_{
    if (duration_ == 0.0f) {
        duration_ = NSIntegerMax;
    }
    duration = duration_;
}

-(void)showAnimation{
    [UIView beginAnimations:@"show" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:0.3];
    contentView.alpha = 1.0f;
    [UIView commitAnimations];
}

-(void)hideAnimation{
    [UIView beginAnimations:@"hide" context:NULL];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(dismissToast)];
    [UIView setAnimationDuration:0.3];
    contentView.alpha = 0.0f;
    [UIView commitAnimations];
}

- (void)deviceOrientationDidChanged:(NSNotification *)notify{
//    [self setViewOrientation];
}

- (void)showInView:(UIView *)view withCenterPosition:(CGPoint)centerSize{
    if (self.orientationSensitive) {
        //监听设备方向改变
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChanged:)
                                                     name:UIApplicationDidChangeStatusBarOrientationNotification
                                                   object:nil];
        
        
    }
    contentView.center = centerSize;
    [view  addSubview:contentView];
    [self showAnimation];
    [self performSelector:@selector(hideAnimation) withObject:nil afterDelay:duration];
}

- (void)show{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self showInView:window withCenterPosition:[UIApplication sharedApplication].keyWindow.center];
}

- (void) showToast
{
    [self show];
}

- (void)showInView:(UIView *)view
{
    [self showInView:view withCenterPosition:view.center];
}

- (void)showWithCenterPosition:(CGPoint)centerSize
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [self showInView:window withCenterPosition:centerSize];
}

- (void)showFromTopOffset:(CGFloat) top_{
    CGPoint centerWindowPoint = [UIApplication sharedApplication].keyWindow.center;
    CGPoint newCenter = CGPointMake(centerWindowPoint.x, top_ + contentView.frame.size.height/2);
    [self showWithCenterPosition:newCenter];
}

- (void)showFromBottomOffset:(CGFloat) bottom_{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    CGPoint newCenter = CGPointMake(window.center.x, window.frame.size.height-(bottom_ + contentView.frame.size.height/2));
    [self showWithCenterPosition:newCenter];
}

+ (SYPrompt *)showWithText:(NSString *)text_
                 duration:(CGFloat)duration_{
    SYPrompt *toast = [[SYPrompt alloc] initWithText:text_];
    [toast setDuration:duration_];
    [toast show];
    
    return toast;
}


+ (SYPrompt *) showWithText:(NSString *)text inView:(UIView *)view
{
    SYPrompt *toast = [[SYPrompt alloc] initWithText:text];
    [toast setDuration:DEFAULT_DISPLAY_DURATION];
    [toast showInView:view];
    
    return toast;
}

+ (SYPrompt *)showWithText:(NSString *)text_
                 duration:(CGFloat)duration_
                   inView:(UIView *)view
     orientationSensitive:(BOOL)orientationSensitive
{
    SYPrompt *toast = [[SYPrompt alloc] initWithText:text_];
    toast.orientationSensitive = orientationSensitive;
    [toast setDuration:duration_];
    [toast showInView:view];
    
    return toast;
}

+ (SYPrompt *)showWithText:(NSString *)text_
                topOffset:(CGFloat)topOffset_
                 duration:(CGFloat)duration_{
    SYPrompt *toast = [[SYPrompt alloc] initWithText:text_];
    [toast setDuration:duration_];
    [toast showFromTopOffset:topOffset_];
    
    return toast;
}

+ (SYPrompt *)showWithText:(NSString *)text_
             bottomOffset:(CGFloat)bottomOffset_
                 duration:(CGFloat)duration_{
    SYPrompt *toast = [[SYPrompt alloc] initWithText:text_];
    [toast setDuration:duration_];
    [toast showFromBottomOffset:bottomOffset_];
    
    return toast;
}

+ (SYPrompt *)showWithText:(NSString *)text_{
    return [SYPrompt showWithText:text_ duration:DEFAULT_DISPLAY_DURATION];
}

+ (SYPrompt *)showWithText:(NSString *)text_
                topOffset:(CGFloat)topOffset_{
    return [SYPrompt showWithText:text_  topOffset:topOffset_ duration:DEFAULT_DISPLAY_DURATION];
}

+ (SYPrompt *)showWithText:(NSString *)text_
             bottomOffset:(CGFloat)bottomOffset_{
    return [SYPrompt showWithText:text_  bottomOffset:bottomOffset_ duration:DEFAULT_DISPLAY_DURATION];
}

+ (SYPrompt *)showWithText:(NSString *)text_ inView:(UIView *)view orientationSensitive:(BOOL)orientationSensitive{
    
    return [SYPrompt showWithText:text_ duration:DEFAULT_DISPLAY_DURATION inView:view orientationSensitive:orientationSensitive];
}

@end
