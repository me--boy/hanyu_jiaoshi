//
//  DFStarRatingView.m
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFStarRatingView.h"


@interface DFStarRatingView ()

@property(nonatomic, strong) NSMutableArray* starImageViews;

@property(nonatomic) CGSize starSize;

@end

@implementation DFStarRatingView

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
    }
    return self;
}

- (void) initSubviews
{
    self.starImageViews = [NSMutableArray array];
}

- (void) setNumberOfStars:(NSInteger)numberOfStars
{
    if (_numberOfStars != numberOfStars)
    {
        _numberOfStars = numberOfStars;
        
        [self reloadData];
    }
}

- (void) setStarSpace:(CGFloat)starSpace
{
    if (_starSpace != starSpace)
    {
        _starSpace = starSpace;
        
        [self reloadData];
    }
}

- (void) setContentInsects:(UIEdgeInsets)contentInsects
{
    if (UIEdgeInsetsEqualToEdgeInsets(contentInsects, _contentInsects))
    {
        _contentInsects = contentInsects;
        
        [self reloadData];
    }
}

- (void) setPickedStarCount:(NSInteger)pickedStarCount
{
    if (_pickedStarCount != pickedStarCount)
    {
        _pickedStarCount = pickedStarCount;
        
        [self reloadData];
    }
}

- (void) reloadData
{
    if (self.starImageViews.count > self.numberOfStars)
    {
        NSRange removingRang = NSMakeRange(self.numberOfStars, self.starImageViews.count - self.numberOfStars);
        NSArray* removingImageviews = [self.starImageViews subarrayWithRange:removingRang];
        [self.starImageViews removeObjectsInRange:removingRang];
        [removingImageviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    else if (self.starImageViews.count < self.numberOfStars)
    {
        for (NSInteger idx = self.starImageViews.count; idx < self.numberOfStars; ++idx)
        {
            UIImageView* imageView = [self starImageViewWithTag:idx];
            [self.starImageViews addObject:imageView];
            [self addSubview:imageView];
        }
    }
    
    [self resetStarSize];
    
    for (NSInteger idx = 0; idx < self.numberOfStars; ++idx)
    {
        UIImageView* starImageView = [self.starImageViews objectAtIndex:idx];
        CGRect starFrame = starImageView.frame;
        starFrame.origin.x = self.contentInsects.left + (self.starSize.width + self.starSpace) * idx;
        starFrame.origin.y = self.contentInsects.top;
        starFrame.size = self.starSize;
        starImageView.frame = starFrame;
        
//        starImageView.highlighted = self.pickedStarCount > idx;
        starImageView.image = [UIImage imageNamed:self.pickedStarCount > idx ? @"rating_star_highlight.png" : @"rating_star_normal.png"];
    }
}

- (void) resetStarSize
{
    CGSize starSize = self.starSize;
    starSize.width = (self.frame.size.width - self.contentInsects.left - self.contentInsects.right - self.starSpace * (self.numberOfStars - 1)) / self.numberOfStars;
    starSize.height = self.frame.size.height - self.contentInsects.top - self.contentInsects.bottom;
    self.starSize = starSize;
}

- (UIImageView *) starImageViewWithTag:(NSInteger)tag
{
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"rating_star_normal.png"]];
//    imageView.highlightedImage = [UIImage imageNamed:@"rating_star_highlight.png"];
    imageView.tag = tag;
    return imageView;
}


@end
