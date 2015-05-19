//
//  SYBaseContentViewController+DFLogInOut.h
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"

@interface SYBaseContentViewController (DFLogInOut)

- (void) registerLogInOutObservers;

- (void) unregisterLogInOutObservers;

- (void) userDidLogin;

- (void) userDidLogout;

@end
