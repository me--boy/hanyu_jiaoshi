//
//  MYTabBarController.h
//  MY
//
//  Created by iMac on 14-7-16.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"
#import "SYTabBar.h"

@interface SYTabBarController : SYBaseContentViewController<SYTabBarDelegate>

@property(nonatomic, readonly) SYTabBar* tabBar;
@property(nonatomic) NSInteger selectedIndex;
@property(nonatomic, strong) NSArray* tabBarViewControllers;

@end
