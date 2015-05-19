//
//  SYScrollPageViewController.h
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"

@class SYScrolledTabBar;

@interface SYScrollPageViewController : SYBaseContentViewController<UIScrollViewDelegate>
{
    UIScrollView* _scrollView;
    //    UISegmentedControl* _segmentControl;
    
    SYScrolledTabBar* _scrolledTabBar;
    
    NSMutableArray* _hasLoadedTabViewControllers;
}

@property(nonatomic, readonly) NSInteger currentTabIdx;

@property(nonatomic, readonly) SYScrolledTabBar* scrolledTabBar;

- (NSArray *) tabBarViewControllers;

- (SYBaseContentViewController *) currentTabBarViewController;

- (SYBaseContentViewController *) tabBarViewControllerAtIndex:(NSInteger)index;

- (CGFloat) bottomMargin;

- (void) setBadgeCount:(NSInteger)count forTabIdx:(NSInteger)idx;
- (void) setBadgeCount:(NSInteger)count forSubTabViewController:(SYBaseContentViewController *)controller;

- (void) clearBadgeForTabIdx:(NSInteger)idx;

- (void) selectTabAtIdx:(NSInteger)idx;

@end
