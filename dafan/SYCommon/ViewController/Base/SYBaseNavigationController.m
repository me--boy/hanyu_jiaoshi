//
//  MYBaseNavigationController.m
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseNavigationController.h"
#import "SYConstDefine.h"
#import "SYDeviceDescription.h"

@interface SYBaseNavigationController ()


@end

@implementation SYBaseNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationBarHidden = YES;
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (![SYDeviceDescription sharedDeviceDescription] > 7)
    {
        [self setNeedsStatusBarAppearanceUpdate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL) shouldAutorotate
{
    return NO;
}


- (NSUInteger)supportedInterfaceOrientations {
    return self.landscape ? UIInterfaceOrientationMaskLandscape : UIInterfaceOrientationMaskPortrait;
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (BOOL) prefersStatusBarHidden
{
    return NO;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
