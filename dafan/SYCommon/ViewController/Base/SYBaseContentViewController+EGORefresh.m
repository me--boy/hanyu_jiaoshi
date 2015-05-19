//
//  MYBaseContentViewController+EGORefresh.m
//  MY
//
//  Created by iMac on 14-4-9.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController+EGORefresh.h"

@implementation SYBaseContentViewController (EGORefresh)

- (void) enableRefreshAtHeaderForScrollView:(UIScrollView *)scrollView
{
    _refreshabedScrollView = scrollView;
    if (_refreshHeaderView == nil)
    {
        _refreshHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - scrollView.bounds.size.height + scrollView.contentInset.top, scrollView.frame.size.width, scrollView.bounds.size.height)];
        _refreshHeaderView.delegate = self;
//        _refreshHeaderView.scrollViewBaseContentInset = scrollView.contentInset;
        [scrollView addSubview:_refreshHeaderView];
    }
}

- (void) disableRefreshAtHeaderForScrollView:(UIScrollView *)scrollView
{
    _refreshabedScrollView = nil;
    [_refreshHeaderView removeFromSuperview];
    _refreshHeaderView = nil;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[_refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}



- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self reloadDataFinished];
}

- (void) reloadDataForRefresh
{
    
}

- (void) reloadDataFinished{
	
	//  model should call this when its done loading
	_isReloading = NO;
	[_refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_refreshabedScrollView];
	
}

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
	
	[self reloadDataForRefresh];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	
	return _isReloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}


@end
