//
//  MYTabBarController.m
//  MY
//
//  Created by iMac on 14-7-16.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTabBarController.h"
//#import "DeviceDescription.h"
#import "SYConstDefine.h"

@interface SYTabBarController ()

@property(nonatomic, strong) SYTabBar* tabBar;

@end

@implementation SYTabBarController

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
    // Do any additional setup after loading the view.
    _selectedIndex = -1;
    
    [self initTabBar];
}

- (SYBaseContentViewController *) selectedViewController
{
    return [self.tabBarViewControllers objectAtIndex:self.selectedIndex];
}

- (void) setTabBarViewControllers:(NSArray *)tabBarViewControllers
{
    if (_tabBarViewControllers != tabBarViewControllers)
    {
        _tabBarViewControllers = tabBarViewControllers;
        
        for (SYBaseContentViewController* controller in tabBarViewControllers)
        {
            [self addChildViewController:controller];
        }
    }
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[self selectedViewController] viewDidAppear:animated];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[self selectedViewController] viewDidDisappear:animated];
}

#define kTabBarHeight 50

- (void) initTabBar
{
    CGSize size = self.view.frame.size;
    self.tabBar = [[SYTabBar alloc] initWithFrame:CGRectMake(0, size.height - kTabBarHeight, size.width, kTabBarHeight)];
//    self.tabBar.backgroundImage = [UIImage imageNamed:@"tab_bkg.png"];
    self.tabBar.delegate = self;
    [self.view addSubview:self.tabBar];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setSelectedIndex:(NSInteger)selectedIndex
{
    if (_selectedIndex != selectedIndex && selectedIndex >= 0 && selectedIndex < self.tabBarViewControllers.count)
    {
        NSInteger originIndex = _selectedIndex;
        
        if (_selectedIndex >= 0)
        {
            SYBaseContentViewController* oldViewController = [self.tabBarViewControllers objectAtIndex:_selectedIndex];
            [oldViewController.view removeFromSuperview];
            [oldViewController viewDidDisappear:NO];
        }
        
        SYBaseContentViewController* newViewController = [self.tabBarViewControllers objectAtIndex:selectedIndex];
        _selectedIndex = selectedIndex;
        newViewController.customTabBarController = self;
        
        
        if ([newViewController isViewLoaded])
        {
            [self.view insertSubview:newViewController.view belowSubview:self.tabBar];
            [newViewController viewDidAppear:NO];
        }
        else
        {
            [self.view insertSubview:newViewController.view belowSubview:self.tabBar];
            CGRect newViewFrame = newViewController.view.frame;
            newViewFrame.origin.y = 0;
            newViewFrame.size.height = self.view.frame.size.height - kTabBarHeight;
            newViewController.view.frame = newViewFrame;
            
            if (originIndex < 0) //第一次不调用
            {
                [newViewController viewWillAppear:NO];
            }
        }
        
        self.tabBar.selectedIndex = selectedIndex;
    }
}

- (BOOL) tabBar:(SYTabBar *)tabBar shouldSelectedIndex:(NSInteger)index
{
    return YES;
}

- (void) tabBar:(SYTabBar *)tabBar didSelectIndex:(NSInteger)index
{
    self.selectedIndex = index;
}

@end
