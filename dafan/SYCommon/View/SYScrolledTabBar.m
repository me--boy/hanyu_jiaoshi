//
//  SYScrolledTabBar.m
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYScrolledTabBar.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"

@implementation SYTabBarButtonItem


@end

@interface SYScrolledTabBar ()

@property(nonatomic, strong) NSMutableArray* tabButtons;

@property(nonatomic, strong) UIView* indicatorView;

@property(nonatomic, strong) NSMutableArray* tabButtonContentWidth;

@property(nonatomic) CGFloat tabButtonWidth;

@property(nonatomic, strong) UIImageView* backgroundImageView;

@end

@implementation SYScrolledTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:self.backgroundImageView];
        
        self.tabButtons = [NSMutableArray array];
        self.tabButtonContentWidth = [NSMutableArray array];
        
        self.indicatorView = [[UIView alloc] initWithFrame:CGRectMake(0, frame.size.height - 3, 0, 2)];
        self.indicatorView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        [self addSubview:self.indicatorView];
    }
    return self;
}

- (void) addSubTabButtons
{
    CGFloat tabCount = self.tabButtonItems.count;
    
    if (tabCount > 0)
    {
        self.tabButtonWidth = self.frame.size.width / tabCount;
    }
    for (NSInteger idx = 0; idx < tabCount; ++idx)
    {
        SYTabBarButtonItem* buttonItem = [self.tabButtonItems objectAtIndex:idx];
        
        UIFont* font = [UIFont systemFontOfSize:15];
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(idx * self.tabButtonWidth, 0, self.tabButtonWidth, self.frame.size.height)];
        
        [button setTitleColor:(buttonItem.normalTitleColor != nil ? buttonItem.normalTitleColor : self.normalTitleColor) forState:UIControlStateNormal];
        [button setTitleColor:(buttonItem.selectedTitleColor != nil ? buttonItem.selectedTitleColor : self.selectedTitleColor) forState:UIControlStateSelected];
        [button setTitle:buttonItem.title forState:UIControlStateNormal];
        [button setImage:buttonItem.normalImage forState:UIControlStateNormal];
        [button setImage:buttonItem.selectedImage forState:UIControlStateSelected];
        button.titleEdgeInsets = buttonItem.titleInsets;
        button.imageEdgeInsets = buttonItem.imageInsets;
        button.titleLabel.font = font;
        button.tag = idx;
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabButtons addObject:button];
        [self addSubview:button];
        
        CGFloat titleWidth = [buttonItem.title sizeWithFont:font].width;
        CGFloat contentWidth = 0;
        CGFloat imageWidth = buttonItem.normalImage.size.width;
        if (imageWidth > 0)
        {
            contentWidth += imageWidth;
            contentWidth += buttonItem.titleInsets.left - buttonItem.titleInsets.right;
            if (buttonItem.titleInsets.left - buttonItem.titleInsets.right < 0)
            {
                contentWidth += titleWidth;
            }
            
            contentWidth += buttonItem.imageInsets.left - buttonItem.imageInsets.right;
            if (buttonItem.imageInsets.left - buttonItem.imageInsets.right > 0)
            {
                contentWidth += imageWidth;
            }
            contentWidth += ABS((buttonItem.imageInsets.left - buttonItem.imageInsets.right) + (buttonItem.titleInsets.left - buttonItem.titleInsets.right));
        }
        else
        {
            contentWidth = titleWidth;
        }
        contentWidth += 8;
        if (contentWidth < self.tabButtonWidth / 2)
        {
            contentWidth = self.tabButtonWidth / 2;
        }
        [self.tabButtonContentWidth addObject:[NSNumber numberWithFloat:contentWidth]];
        
        if (self.selectedIndex == idx)
        {
            CGRect indicatorFrame = self.indicatorView.frame;
            indicatorFrame.size.width = contentWidth;
            indicatorFrame.origin.x = button.frame.origin.x + (self.tabButtonWidth - contentWidth) / 2;
            self.indicatorView.frame = indicatorFrame;
            if (buttonItem.indicatorColor != nil)
            {
                self.indicatorView.backgroundColor = buttonItem.indicatorColor;
            }
        }
        
        button.selected = self.selectedIndex == idx;
    }
}

- (void) reloadData
{
    for (UIButton* button in self.tabButtons)
    {
        [button removeFromSuperview];
    }
    [self.tabButtons removeAllObjects];
    [self.tabButtonContentWidth removeAllObjects];
    
    if (self.normalTitleColor == nil)
    {
        self.normalTitleColor = RGBCOLOR(95, 95, 95);
    }
    if (self.selectedTitleColor == nil)
    {
        self.selectedTitleColor = kMainDarkColor;
    }
    if (self.indicatorColor == nil)
    {
        self.indicatorColor = kMainDarkColor;
    }
    
    self.indicatorView.backgroundColor = self.indicatorColor;
    [self addSubTabButtons];
    
    [self bringSubviewToFront:self.indicatorView];
    
}

- (void) tabButtonClicked:(UIButton *)button
{
    if (!button.selected)
    {
        //        for (UIButton* aButton in self.tabButtons)
        //        {
        //            aButton.selected = NO;
        //        }
        //        button.selected = YES;
        
        [self.delegate scrolledTabBar:self selectIndex:button.tag];
        
        //        [UIView animateWithDuration:0.15 animations:^{
        //
        //            CGRect indicatorFrame = self.indicatorView.frame;
        //            indicatorFrame.size.width = [[self.tabButtonContentWidth objectAtIndex:button.tag] floatValue];
        //            indicatorFrame.origin.x = button.frame.origin.x + (button.frame.size.width - indicatorFrame.size.width) / 2;
        //            self.indicatorView.frame = indicatorFrame;
        //
        //        }];
    }
}

- (void) setIndicatorPositionFactor:(CGFloat)factor selectTab:(BOOL)selected
{
    NSInteger floor = floorf(factor);
    NSInteger ceil = ceilf(factor);
    
    if (ceil == floor && floor == self.selectedIndex)
    {
        return;
    }
    
    CGFloat ceilWidth = [[self.tabButtonContentWidth objectAtIndex:ceil] floatValue];
    CGFloat floorWidth = [[self.tabButtonContentWidth objectAtIndex:floor] floatValue];
    
    CGFloat baseX = self.frame.size.width * factor / self.tabButtonItems.count;
    
    CGRect indicatorFrame = self.indicatorView.frame;
    indicatorFrame.size.width = floorWidth + (ceil - floor) * (ceilWidth - floorWidth);
    indicatorFrame.origin.x = baseX + (self.tabButtonWidth - indicatorFrame.size.width) / 2;// - indicatorFrame.size.width / 2;
    self.indicatorView.frame = indicatorFrame;
    
    if (ceil == floor)
    {
        if (selected)
        {
            self.selectedIndex = ceil;
            for (NSInteger idx = 0; idx < self.tabButtons.count; ++idx)
            {
                UIButton* button = [self.tabButtons objectAtIndex:idx];
                button.selected = idx == ceil;
            }
        }
        SYTabBarButtonItem* buttonItem = [self.tabButtonItems objectAtIndex:ceil];
        if (buttonItem.indicatorColor != nil)
        {
            self.indicatorView.backgroundColor = buttonItem.indicatorColor;
        }
    }
    
}

@end
