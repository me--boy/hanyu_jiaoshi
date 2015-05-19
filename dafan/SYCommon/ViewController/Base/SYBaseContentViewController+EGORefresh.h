//
//  MYBaseContentViewController+EGORefresh.h
//  MY
//
//  Created by iMac on 14-4-9.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface SYBaseContentViewController (EGORefresh)<UIScrollViewDelegate, EGORefreshTableHeaderDelegate>
/**
 *  使指定的scrollView具有下拉刷新的功能
 */
- (void) enableRefreshAtHeaderForScrollView:(UIScrollView *)scrollView;
/**
 *  取消指定的scrollView具有下拉刷新的功能
 */
- (void) disableRefreshAtHeaderForScrollView:(UIScrollView *)scrollView;

- (void) reloadDataForRefresh;

- (void) reloadDataFinished;

@end
