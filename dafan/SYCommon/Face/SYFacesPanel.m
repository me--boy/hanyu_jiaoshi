//
//  MYFacesPanel.m
//  MY
//
//  Created by 胡少华 on 14-4-11.
//  Copyright (c) 2014年 halley. All rights reserved.
//



#import "SYFacesPanel.h"
#import "SYConstDefine.h"
#import "UIView+SYShape.h"

#define kFaceItemWidth 45
#define kFaceItemHeight 42

#define kFacePaddingLeft 2
#define kFacePaddingRight 3
#define kFacePaddingTop 4

#define kFaceMarginVerti 4

#define kPageCount 4
#define kRowsPerPage 4
#define kColumnsPerRow 7



@interface SYFacesPanel ()<UIScrollViewDelegate>

@property(nonatomic, strong) UIPageControl* pageControl;


@end

@implementation SYFacesPanel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self initSubViews];
    }
    return self;
}

- (void) initSubViews
{
    
    CGRect bounds = self.bounds;
    //页数显示视图
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, bounds.size.height - 30 - 8, bounds.size.width, 30)];
    self.pageControl.numberOfPages = kPageCount;
//    self.pageControl.backgroundColor = [UIColor yellowColor];
    self.pageControl.pageIndicatorTintColor = [UIColor grayColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    self.pageControl.currentPage = 0;
    [self addSubview:self.pageControl];
    
    
    NSInteger itemIdx = 0;
    
    UIScrollView* scrollView = [[UIScrollView alloc] initWithFrame:bounds];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.pagingEnabled = YES;
    scrollView.delegate = self;
    scrollView.contentSize = CGSizeMake(self.bounds.size.width * kPageCount, self.bounds.size.height);
    [self addSubview:scrollView];
    
    for (NSInteger page = 0; page < kPageCount; ++page)
    {
        CGRect rect = self.bounds;
        rect.origin.x = page * rect.size.width;
        UIView* pageView = [[UIView alloc] initWithFrame:rect];
        [scrollView addSubview:pageView];
        
        CGFloat offsetY = kFacePaddingTop + kFaceMarginVerti;
        
        for (NSInteger row = 0; row < kRowsPerPage; ++row)
        {
            CGFloat offsetX = kFacePaddingLeft;
            for (NSInteger col = 0; col < kColumnsPerRow; ++col)
            {
                UIButton* faceButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, offsetY, kFaceItemWidth, kFaceItemHeight)];
                faceButton.backgroundColor = [UIColor clearColor];
                faceButton.contentEdgeInsets = UIEdgeInsetsMake(7, 7, 7, 8);
                UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"face%d.png", itemIdx]];
                if (image != nil)
                {
                    [faceButton setImage:image forState:UIControlStateNormal];
                }
                else
                {
                    [faceButton setTitle:[NSString stringWithFormat:@"%d", itemIdx] forState:UIControlStateNormal];
                }
                [faceButton addTarget:self action:@selector(faceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                faceButton.tag = itemIdx;
                [pageView addSubview:faceButton];
                
                offsetX += kFaceItemWidth;
                
                ++itemIdx;
                if (itemIdx % (kRowsPerPage * kColumnsPerRow - 1) == 0)
                {
                    [self addDelButtonToPageView:pageView];
                    break;
                }
                if (itemIdx > 91)
                {
                    [self addDelButtonToPageView:pageView];
                    return;
                }
            }
            offsetY += kFaceItemHeight + kFaceMarginVerti;
        }
    }
}
/**
 *  添加删除按钮
 */
- (void) addDelButtonToPageView:(UIView *)pageView
{
    UIButton* sendButton = [[UIButton alloc] initWithFrame:CGRectMake(273, 146, kFaceItemWidth, kFaceItemHeight)];
    [sendButton setImage:[UIImage imageNamed:@"face_del.png"] forState:UIControlStateNormal];
    sendButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    sendButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [sendButton addTarget:self action:@selector(delButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [sendButton makeViewASCircle:sendButton.layer withRaduis:4 color:kMainBackgroundColor.CGColor strokeWidth:1];
    [pageView addSubview:sendButton];
}

- (void) faceButtonClicked:(UIButton *)button
{
    NSInteger idx = button.tag;
//    [self.delegate inputText:[NSString stringWithFormat:@"[face%d]", idx] AtFacePanel:self];
    [self.delegate face:idx clickedAtFacePanel:self];
}

- (void) delButtonClicked:(id)sender
{
    [self.delegate delButtonClickedAtFacePanel:self];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat pageIdx = scrollView.contentOffset.x / self.bounds.size.width;
    self.pageControl.currentPage = pageIdx;
}




@end
