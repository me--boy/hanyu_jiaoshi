//
//  SYBaseContentViewController+DFLogInOut.m
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController+DFLogInOut.h"
#import "DFNotificationDefines.h"

@implementation SYBaseContentViewController (DFLogInOut)

- (void) registerLogInOutObservers
{
    [self unregisterLogInOutObservers];
    
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(userLogin:) name:kNotificationUserLogin object:nil];
    [notify addObserver:self selector:@selector(userLogout:) name:kNotificationUserLogout object:nil];
}

- (void) unregisterLogInOutObservers
{
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify removeObserver:self name:kNotificationUserLogin object:nil];
    [notify removeObserver:self name:kNotificationUserLogout object:nil];
}

- (void) userDidLogin
{
    
}

- (void) userDidLogout
{
    
}

- (void) userLogin:(NSNotification *)notification
{
    [self userDidLogin];
}


- (void) userLogout:(NSNotification *)notification
{
    [self userDidLogout];
}

@end
