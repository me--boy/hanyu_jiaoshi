//
//  MYTabBar.m
//  MY
//
//  Created by iMac on 14-7-16.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTabBar.h"
#import "DFColorDefine.h"
#import "SYConstDefine.h"
#import "UIView+SYShape.h"

@interface SYTabBar ()

@property(nonatomic, strong) UIImageView* backgroundImageView;

@property(nonatomic, strong) NSMutableDictionary* markedImageViews;

@end

@implementation SYTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _selectedIndex = -1;
        
        self.tabButtons = [NSMutableArray array];
        self.markedImageViews = [NSMutableDictionary dictionary];
        [self initBackgroundImageView];
    }
    return self;
}
/**
 *  初始化背景图片
 */
- (void) initBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addSubview:self.backgroundImageView];
}
/**
 *  设置背景图片
 */
- (void) setBackgroundImage:(UIImage *)backgroundImage
{
    if (_backgroundImage != backgroundImage)
    {
        _backgroundImage = backgroundImage;
        self.backgroundImageView.image = backgroundImage;
    }
}

- (void) markTab:(NSInteger)idx
{
    if (idx >= 0 && idx < self.tabButtons.count)
    {
        NSString* idxKey = [NSString stringWithFormat:@"%d", idx];
        UIButton* button = [self.tabButtons objectAtIndex:idx];
        
        UIImageView* markedImageView = [self.markedImageViews objectForKey:idxKey];
        if (markedImageView == nil)
        {
            markedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(button.frame.origin.x + button.frame.size.width - 24, 4, 6, 6)];
            markedImageView.backgroundColor = [UIColor redColor];
            [markedImageView circledWithColor:[UIColor redColor] strokeWidth:1];
            [self addSubview:markedImageView];
            
            [self.markedImageViews setObject:markedImageView forKey:idxKey];
        }
    }
}

- (void) clearMarkTab:(NSInteger)idx
{
    if (idx >= 0 && idx < self.tabButtons.count)
    {
        NSString* idxKey = [NSString stringWithFormat:@"%d", idx];
        UIImageView* markedImageView = [self.markedImageViews objectForKey:idxKey];
        [markedImageView removeFromSuperview];
        [self.markedImageViews removeObjectForKey:idxKey];
    }
}

- (void) setTabButtons:(NSArray *)tabButtons
{
    if (![_tabButtons isEqualToArray:tabButtons])
    {
        [_tabButtons makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        _tabButtons = tabButtons;
        
        [self addTabButtonsAsSubViews:tabButtons];
    }
}

- (void) addTabButtonsAsSubViews:(NSArray *)tabButtons
{
    NSInteger count = tabButtons.count;
    CGFloat tabWidth = self.frame.size.width / count;
    for (NSInteger tabIdx = 0; tabIdx < count; ++tabIdx)
    {
        UIButton* button = [tabButtons objectAtIndex:tabIdx];
        
        button.frame = CGRectMake(tabIdx * tabWidth, 0, tabWidth, self.frame.size.height);
        button.tag = tabIdx;
        
//        [button setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
//        [button setTitleColor:kMainColor forState:UIControlStateSelected];
        
        [button addTarget:self action:@selector(tabButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:button];
    }
}

- (void) tabButtonClicked:(UIButton *)button
{
    if ([self.delegate tabBar:self shouldSelectedIndex:button.tag])
    {
        if (button.selected)
        {
            return;
        }
        
        [self clearMarkTab:button.tag];
        
        _selectedIndex = button.tag;
        
        for (UIButton* aButton in self.tabButtons)
        {
            aButton.selected = aButton == button;
        }
        
        [self.delegate tabBar:self didSelectIndex:_selectedIndex];
    }
}

- (void) setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex && selectedIndex >= 0 && selectedIndex < self.tabButtons.count)
    {
        [((UIButton *)[self.tabButtons objectAtIndex:selectedIndex]) sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
