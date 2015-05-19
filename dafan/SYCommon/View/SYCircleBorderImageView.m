//
//  MYCircleBorderImageView.m
//  MY
//
//  Created by iMac on 14-5-12.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYCircleBorderImageView.h"
#import "UIImageView+WebCache.h"
#import "UIView+SYShape.h"
#import "SYConstDefine.h"

@interface SYCircleBorderImageView ()

@property(nonatomic, strong) UIImageView* imageView;
@property(nonatomic, strong) UIButton* button;

@end

@implementation SYCircleBorderImageView
//@dynamic image;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initSubviews];
        
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initSubviews];
        self.backgroundColor = [UIColor clearColor];
        [self sendSubviewToBack:self.imageView];
    }
    return self;
}

- (void) initSubviews
{
    CGRect rect = self.bounds;
    rect.origin = CGPointMake(1, 1);
    rect.size.width -= 1;
    rect.size.height -= 1;
    
    self.imageView = [[UIImageView alloc] initWithFrame:rect];
    [self addSubview:self.imageView];
    
    self.button = [[UIButton alloc] initWithFrame:self.bounds];
//    self.button.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.3];
    [self addSubview:self.button];
}

- (void) setImage:(UIImage *)image
{
    self.imageView.image = image;
}

- (void) relayoutImageViewOffsetWidth:(CGFloat)width
{
    CGRect rect = self.bounds;
    rect.origin.x = width;
    rect.origin.y = width;
    rect.size.width -= 2 * width;
    rect.size.height -= 2 * width;
    self.imageView.frame = rect;
}

- (void) circleWithColor:(UIColor *)color radius:(CGFloat)radius strokeWidth:(CGFloat)strokeWidth
{
//    self.backgroundColor = color;
    [self relayoutImageViewOffsetWidth:strokeWidth];
    
    if (radius == 0)
    {
        self.button.backgroundColor = [UIColor clearColor];
        [self circledWithColor:color strokeWidth:strokeWidth];
        [self.imageView circledWithColor:self.backgroundColor strokeWidth:1];
    }
    else
    {
        [self makeViewASCircle:self.layer withRaduis:radius color:color.CGColor strokeWidth:strokeWidth];
    }
}

- (void) circleWithColor:(UIColor *)color radius:(CGFloat)radius
{
    [self circleWithColor:color radius:radius strokeWidth:1];
}

- (void) setTapGestureWithAction:(SEL)action forTarget:(id)target
{
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}


//- (UIImage *) image
//{
//    return self.imageView.image;
//}

- (void) setImageWithUrl:(NSString *)imageUrl placeHolder:(UIImage *)placeHolderImage
{
    [self.imageView setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:placeHolderImage];
}

- (void) setAvatarImageWithUrl:(NSString *)avatarUrl
{
    
}

- (void) setGiftImageWithUrl:(NSString *)giftUrl
{
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
