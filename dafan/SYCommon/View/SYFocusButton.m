//
//  MYFocusButton.m
//  MY
//
//  Created by iMac on 14-5-7.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYFocusButton.h"

@interface SYFocusButton ()

//@property(nonatomic, strong) NSString* focusedTitle;
//@property(nonatomic, strong) NSString* unfocusedTitle;
//@property(nonatomic, strong) NSString* mutualFocusedTitle;
//@property(nonatomic, strong) NSString* loadingTitle;
//
//@property(nonatomic, strong) UIImage* focusedImage;
//@property(nonatomic, strong) UIImage* unfocusedImage;
//@property(nonatomic, strong) UIImage* mutualFocusedImage;
//@property(nonatomic, strong) UIImage* loadingImage;

@property(nonatomic, strong) NSMutableArray* stateTitles;
@property(nonatomic, strong) NSMutableArray* stateTitleColors;
@property(nonatomic, strong) NSMutableArray* stateImages;

@property(nonatomic, strong) UIActivityIndicatorView* loadingActivity;

@end

@implementation SYFocusButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _focusState = -1;
        self.stateTitles = [NSMutableArray arrayWithCapacity:SYFocusButtonStateCount];
        self.stateTitleColors = [NSMutableArray arrayWithCapacity:SYFocusButtonStateCount];
        self.stateImages = [NSMutableArray arrayWithCapacity:SYFocusButtonStateCount];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        // Initialization code
        _focusState = -1;
        self.stateTitles = [NSMutableArray arrayWithCapacity:SYFocusButtonStateCount];
        self.stateTitleColors = [NSMutableArray arrayWithCapacity:SYFocusButtonStateCount];
        self.stateImages = [NSMutableArray arrayWithCapacity:SYFocusButtonStateCount];
    }
    return self;
}

- (void) setTitleColor:(UIColor *)titleColor forFocusState:(SYFocusButtonState)status
{
    if (self.stateTitleColors.count > status)
    {
        self.stateTitleColors[status] = titleColor;
    }
    else
    {
        for (NSInteger idx = self.stateTitleColors.count; idx <= status; ++idx)
        {
            self.stateTitleColors[idx] = titleColor;
        }
    }
}

- (void) setTitle:(NSString *)title forFocusState:(SYFocusButtonState)status
{
    if (self.stateTitles.count > status)
    {
        self.stateTitles[status] = title;
    }
    else
    {
        for (NSInteger idx = self.stateTitles.count; idx <= status; ++idx)
        {
            self.stateTitles[idx] = title;
        }
    }
}

- (void) setImage:(UIImage *)image forFocusState:(SYFocusButtonState)status
{
    if (self.stateImages.count > status)
    {
        self.stateImages[status] = image;
    }
    else
    {
        for (NSInteger idx = self.stateImages.count; idx <= status; ++idx)
        {
            self.stateImages[idx] = image;
        }
    }
}

- (void) setFocusState:(SYFocusButtonState)focusState
{
    if (focusState != _focusState)
    {
        _focusState = focusState;
        
        if (self.focusState == SYFocusButtonStateLoading)
        {
            [self setTitle:@"" forState:UIControlStateNormal];
            [self setImage:nil forState:UIControlStateNormal];
            
            CGSize size = self.frame.size;
            
            self.loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            self.loadingActivity.center = CGPointMake(size.width / 2, size.height / 2);
            [self addSubview:self.loadingActivity];
            [self.loadingActivity startAnimating];
        }
        else
        {
            [self.loadingActivity removeFromSuperview];
            self.loadingActivity = nil;
            
            [self setTitle:(self.stateTitles.count > focusState ? self.stateTitles[focusState] : @"") forState:UIControlStateNormal];
            [self setTitleColor:(self.stateTitleColors.count > focusState ? self.stateTitleColors[focusState] : [UIColor blackColor]) forState:UIControlStateNormal];
            [self setImage:(self.stateImages.count > focusState ? self.stateImages[focusState] : nil) forState:UIControlStateNormal];
        }
        
        self.enabled = focusState != SYFocusButtonStateLoading;
    }
}

@end
