//
//  SYScrolledTabBar.h
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYTabBarButtonItem : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) UIImage* normalImage;
@property(nonatomic, strong) UIImage* selectedImage;
@property(nonatomic, strong) UIColor* normalTitleColor;
@property(nonatomic, strong) UIColor* selectedTitleColor;

@property(nonatomic) UIEdgeInsets titleInsets;
@property(nonatomic) UIEdgeInsets imageInsets;

@property(nonatomic, strong) UIColor* indicatorColor;

@end

@class SYScrolledTabBar;

@protocol SYScrolledTabBarDelegate <NSObject>

- (void) scrolledTabBar:(SYScrolledTabBar *)tabbar selectIndex:(NSInteger)index;

@end

@interface SYScrolledTabBar : UIView

@property(nonatomic, strong) NSArray* tabButtonItems;

@property(nonatomic, readonly) UIImageView* backgroundImageView;

@property(nonatomic, strong) UIColor* normalTitleColor;
@property(nonatomic, strong) UIColor* selectedTitleColor;
@property(nonatomic, strong) UIColor* indicatorColor;

@property(nonatomic) NSInteger selectedIndex;

@property(nonatomic, weak) id<SYScrolledTabBarDelegate> delegate;


- (void) reloadData;

- (void) setIndicatorPositionFactor:(CGFloat)factor selectTab:(BOOL)selected;

@end
