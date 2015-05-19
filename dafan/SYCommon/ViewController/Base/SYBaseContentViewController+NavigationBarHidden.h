//
//  MYBaseContentViewController+NavigationBarHidden.h
//  MY
//
//  Created by iMac on 14-5-28.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"

@interface SYBaseContentViewController (NavigationBarHidden)

- (void) setCustomNavigationBarHidden:(BOOL)hide;

- (BOOL) customNavigationBarHidden;

- (void) setCustomNavigationBarHidden:(BOOL)hide animation:(BOOL)animation;

@end
