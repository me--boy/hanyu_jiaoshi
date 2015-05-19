//
//  SYBaseContentViewController.h
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "SYStandardNavigationBar.h"

typedef NS_ENUM(NSInteger, MYCustomTranslationDirection)
{
    MYCustomTranslationDirectionHorizontal = 0,
    MYCustomTranslationDirectionVertical
};

typedef NS_ENUM(NSInteger, SYNavigationBarStyle)
{
    SYNavigationBarStyleNone = -1,
    SYNavigationBarStyleStandard = 0
};

@class EGORefreshTableHeaderView;
@class SYScrollPageViewController;
@class SYTabBarController;

@interface SYBaseContentViewController : UIViewController

{
    UIScrollView*              _refreshabedScrollView;
    EGORefreshTableHeaderView* _refreshHeaderView;
    BOOL                       _isReloading;
    
    NSMutableArray* _requests;
    MBProgressHUD* _progressActivity;
}

@property(nonatomic) BOOL noBorderAtBottomOfCustomNavigatonBar;

////first object move in or out
//@property(nonatomic) MYCustomTranslationDirection customDirection;

@property(nonatomic) SYNavigationBarStyle navigationBarStyle;

@property(nonatomic, readonly) NSMutableArray* requests;
/**
 *  导航条
 */
@property(nonatomic, readonly) SYStandardNavigationBar* customNavigationBar;

@property(nonatomic, weak) SYScrollPageViewController* scrollPageController;
/**
 *  自定义的TabBar
 */
@property(nonatomic, weak) SYTabBarController* customTabBarController;

@property(nonatomic, readonly) NSString* headerTitle;
/**
 *  左按钮点击事件
 */
- (void) leftButtonClicked:(id)sender;
/**
 *  右按钮点击事件
 */
- (void) rightButtonClicked:(id)sender;
/**
 *  展示HUB
 */
- (void) showProgresWithText:(NSString *)text inView:(UIView *)view;

- (void) showProgress;

- (void) hideProgress;
/**
 *  加载数据
 */
- (void) loadData;
/**
 *  取消所有的网络请求
 */
- (void) cancelAllRequest;

- (UIView *) customNavigationBarSuperView;

- (void) viewDidAppearInScrollPageController;

- (void) viewDidDisappearInScrollPageController;

- (void) closeMeAnimated:(BOOL)animated;

- (void) prepareToClose;

@end
