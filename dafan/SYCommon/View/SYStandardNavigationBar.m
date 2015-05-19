//
//  SYStandardNavigationBar.m
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYStandardNavigationBar.h"
#import "SYConstDefine.h"

@interface SYStandardNavigationBar ()

@property(nonatomic, strong) UIButton* titleButton;
@property(nonatomic, strong) UIButton* leftButton;
@property(nonatomic, strong) UIButton* rightButton;

@end

@implementation SYStandardNavigationBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubviews];
    }
    return self;
}


#define kMarginX 8
#define kButtonWidth (64 + kMarginX)
#define kButtonHeight 44
#define kTitleFontSize 18
#define kButtonTitleFontSize 15

- (void) initSubviews
{
    //标题
    CGSize size = self.frame.size;
    
    CGFloat baseOriginY = size.height - kButtonHeight;
    
    CGFloat titleOriginX = 32;
    CGFloat titleWidth = size.width - 2 * titleOriginX;
    self.titleButton = [[UIButton alloc] initWithFrame:CGRectMake(titleOriginX, baseOriginY, titleWidth, kButtonHeight)];
    self.titleButton.backgroundColor = [UIColor clearColor];
    [self.titleButton setTitleColor:kPageTitleColor forState:UIControlStateNormal];
    self.titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:kTitleFontSize];
    //    self.titleButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    [self addSubview:self.titleButton];
    //左按钮
    self.leftButton = [[UIButton alloc] initWithFrame:CGRectMake(0, baseOriginY, kButtonWidth, kButtonHeight)];
    self.leftButton.contentEdgeInsets = UIEdgeInsetsMake(0, kMarginX, 0, 0);
    self.leftButton.backgroundColor = [UIColor clearColor];
    [self.leftButton setImage:[UIImage imageNamed:@"back_icon_white.png"] forState:UIControlStateNormal];
    [self.leftButton setTitleColor:kPageTitleColor forState:UIControlStateNormal];
//    [self.leftButton setTitle:@"返回" forState:UIControlStateNormal];
    self.leftButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
    [self addSubview:self.leftButton];
    //右按钮
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, baseOriginY, 0, 0)];
    self.rightButton.backgroundColor = [UIColor clearColor];
    self.rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kMarginX);
    [self.rightButton setTitleColor:kPageTitleColor forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:kButtonTitleFontSize];
    [self addSubview:self.rightButton];
}

- (void) setRightButtonWithStandardTitle:(NSString *)title
{
    [self.rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    [self.rightButton setImage:nil forState:UIControlStateNormal];
    [self.rightButton setTitle:title forState:UIControlStateNormal];
    CGRect frame = self.rightButton.frame;
    frame.origin.x = self.frame.size.width - kButtonWidth;
    frame.size = CGSizeMake(kButtonWidth, kButtonHeight);
    self.rightButton.frame = frame;
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void) setRightButtonWithStandardImage:(UIImage *)image
{
    [self.rightButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    [self.rightButton setTitle:@"" forState:UIControlStateNormal];
    [self.rightButton setImage:image forState:UIControlStateNormal];
    CGRect rightFrame = self.rightButton.frame;
    rightFrame.origin.x = self.frame.size.width - kButtonHeight;
    
    rightFrame.size = CGSizeMake(kButtonHeight, kButtonHeight);
    self.rightButton.frame = rightFrame;
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

- (void) setLeftButtonWithStandardTitle:(NSString *)title
{
    [self.leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self.leftButton setImage:nil forState:UIControlStateNormal];
    [self.leftButton setTitle:title forState:UIControlStateNormal];
}

- (void) setLeftButtonWithStandardImage:(UIImage *)image
{
    [self.leftButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    
    [self.leftButton setTitle:@"" forState:UIControlStateNormal];
    [self.leftButton setImage:image forState:UIControlStateNormal];
}

- (void) layoutStandardRightButton
{
    CGRect rightFrame = self.rightButton.frame;
    rightFrame.origin.x = self.frame.size.width - kButtonHeight;
    rightFrame.size = CGSizeMake(kButtonHeight, kButtonHeight);
    self.rightButton.frame = rightFrame;
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
}

@end
