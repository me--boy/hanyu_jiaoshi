//
//  MYBannerBar.m
//  MY
//
//  Created by iMac on 14-6-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBannerBar.h"
#import "SYConstDefine.h"
#import "UIImageView+WebCache.h"

#define kCoderKeyType @"type"
#define kCoderKeyImage @"img"
#define kCoderKeyTitle @"title"
#define kCoderKeyOptionalId @"redirect_id"
#define kCoderKeyWebUrl @"redirect_url"
/**
 模型对象
 */
@implementation SYBannerBarItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.type = [[dictionary objectForKey:kCoderKeyType] integerValue];
        self.imageUrl = [dictionary objectForKey:kCoderKeyImage];
        self.optionalId = [[dictionary objectForKey:kCoderKeyOptionalId] integerValue];
        self.webViewUrl = [dictionary objectForKey:kCoderKeyWebUrl];
        self.title = [dictionary objectForKey:kCoderKeyTitle];
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self)
    {
        self.type = [[aDecoder decodeObjectForKey:kCoderKeyType] integerValue];
        self.imageUrl = [aDecoder decodeObjectForKey:kCoderKeyImage];
        self.optionalId = [[aDecoder decodeObjectForKey:kCoderKeyOptionalId] integerValue];
        self.webViewUrl = [aDecoder decodeObjectForKey:kCoderKeyWebUrl];
        self.title = [aDecoder decodeObjectForKey:kCoderKeyTitle];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInteger:self.type] forKey:kCoderKeyType];
    [aCoder encodeObject:self.imageUrl forKey:kCoderKeyImage];
    [aCoder encodeObject:[NSNumber numberWithInteger:self.optionalId] forKey:kCoderKeyOptionalId];
    [aCoder encodeObject:self.webViewUrl forKey:kCoderKeyWebUrl];
    [aCoder encodeObject:self.title forKey:kCoderKeyTitle];
}
@end

@interface SYBannerBarView ()

//@property(nonatomic, strong) UIImageView* backgroundImageView;
//@property(nonatomic, strong) UIImageView* pageIndicatorBackgroundImageView;


@end

@implementation SYBannerBarView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [self initSubviews];
        self.pageImageViews = [NSMutableArray array];
    }
    return self;
}

- (void) initSubviews
{
    CGSize size = self.frame.size;
    
//    self.pageIndicatorBackgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, size.height - 18, size.width, 10)];
//    self.pageIndicatorBackgroundImageView.userInteractionEnabled = YES;
//    [self addSubview:self.pageIndicatorBackgroundImageView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(size.width - 52, size.height - 22, 44, 22)];
    self.pageControl.pageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.backgroundColor = [UIColor clearColor];
    [self addSubview:self.pageControl];
}

- (void) scrollPageFrom:(NSInteger)oldIndex to:(NSInteger)newIdx
{
    UIImageView* oldImageView = [self.pageImageViews objectAtIndex:oldIndex];
    UIImageView* newImageView = [self.pageImageViews objectAtIndex:newIdx];
    
    __block CGRect rect = self.bounds;
    rect.origin.x = rect.size.width;
    newImageView.frame = rect;
    
    
    [self insertSubview:newImageView belowSubview:self.pageControl];
    
    [UIView animateWithDuration:0.2 animations:^{
    
        rect.origin.x = 0;
        newImageView.frame = rect;
        
        rect.origin.x = -rect.size.width;
        oldImageView.frame = rect;
        
    
    } completion:^(BOOL finished){
    
        
    
    }];
}

- (void) setLoadingInfos:(NSArray *)loadingInfos
{
    if (loadingInfos != _loadingInfos)
    {
        _loadingInfos = loadingInfos;
        
        CGSize size = self.frame.size;
        
        NSInteger count = loadingInfos.count;
        for (NSInteger idx = 0; idx < count; ++idx)
        {
            SYBannerBarItem* item = [loadingInfos objectAtIndex:idx];
            UIImageView* imageView = nil;
            
            if (self.pageImageViews.count > idx)
            {
                imageView = [self.pageImageViews objectAtIndex:idx];
            }
            else
            {
                imageView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width * idx, 0, size.width, size.height)];
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFill;
                [self insertSubview:imageView belowSubview:self.pageControl];
                [self.pageImageViews addObject:imageView];
            }
            
            [imageView setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:nil];
            
            NSLog(@"%ld",(long)idx);
            
            imageView.tag = idx;
            
            UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self.pageImageViewTarget action:self.pageImageViewAction];
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:tap];
        }
        
        self.pageControl.numberOfPages = loadingInfos.count;
        self.pageControl.currentPage = 0;
    }
}

@end

@interface SYBannerBar ()

@property(nonatomic, strong) NSTimer* bannerPlayTimer;
@property(nonatomic, strong) UISwipeGestureRecognizer* swipeGesture;

@end

@implementation SYBannerBar

- (id) init
{
    self = [super init];
    if (self)
    {
        [self initSwipeGesture];
    }
    return self;
}

- (void) startBannerPlayTimer
{
    [self stopBannerPlayTimer];
    if (self.bannerView.loadingInfos.count > 0)
    {
        self.bannerPlayTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(showNextBanner:) userInfo:nil repeats:YES];
    }
}

- (void) setBannerView:(SYBannerBarView *)bannerView
{
    if (_bannerView != bannerView)
    {
        [bannerView removeGestureRecognizer:self.swipeGesture];
        [_bannerView removeGestureRecognizer:self.swipeGesture];
        _bannerView = bannerView;
        
        [_bannerView addGestureRecognizer:self.swipeGesture];
    }
}

- (void) initSwipeGesture
{
    self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
    self.swipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self.bannerView addGestureRecognizer:self.swipeGesture];
}

- (void) swipeGestureRecognized:(UIGestureRecognizer *)gesture
{
    if (self.bannerView.loadingInfos.count > 1)
    {
        [self stopBannerPlayTimer];
        [self startBannerPlayTimer];
        [self showNextBanner:nil];
    }
}

- (void) stopBannerPlayTimer
{
    [self.bannerPlayTimer invalidate];
    self.bannerPlayTimer = nil;
}

- (void) showNextBanner:(id)timer
{
    if (self.bannerView.loadingInfos.count > 1)
    {
        NSInteger oldIndex = self.bannerView.pageControl.currentPage;
        if (self.bannerView.pageControl.currentPage == self.bannerView.pageControl.numberOfPages - 1)
        {
            self.bannerView.pageControl.currentPage = 0;
        }
        else
        {
            self.bannerView.pageControl.currentPage += 1;
        }
        
        [self.bannerView scrollPageFrom:oldIndex to:self.bannerView.pageControl.currentPage];
//        [self.bannerView.pageControl sendActionsForControlEvents:UIControlEventValueChanged];
    }
}

@end
