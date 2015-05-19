//
//  MYTabBar.h
//  MY
//
//  Created by iMac on 14-7-16.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SYTabBar;
@protocol SYTabBarDelegate <NSObject>

- (BOOL) tabBar:(SYTabBar *)tabBar shouldSelectedIndex:(NSInteger)index;
- (void) tabBar:(SYTabBar *)tabBar didSelectIndex:(NSInteger)index;

@end

@interface SYTabBar : UIView

@property(nonatomic, weak) id<SYTabBarDelegate> delegate;
@property(nonatomic, strong) NSArray* tabButtons;
@property(nonatomic, strong) UIImage* backgroundImage;
@property(nonatomic) NSInteger selectedIndex;

- (void) markTab:(NSInteger)idx;
- (void) clearMarkTab:(NSInteger)idx;

@end
