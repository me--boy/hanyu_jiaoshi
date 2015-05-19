//
//  SYBaseContentViewController.m
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"
#import "SYStandardNavigationBar.h"
#import "MBProgressHUD.h"
#import "SYConstDefine.h"
#import "SYTabBarController.h"
#import "UIView+SYShape.h"
#import "SYDeviceDescription.h"
#import "SYHttpRequest.h"
#import "DFColorDefine.h"
#import "SYScrollPageViewController.h"

@interface SYBaseContentViewController ()

@property(nonatomic, strong) UIButton* leftButton;
@property(nonatomic, strong) UIButton* rightButton;

@property(nonatomic, strong) NSMutableArray* requests;

@property(nonatomic, strong) MBProgressHUD* progressActivity;
@property(nonatomic) BOOL hasLoadData;

@property(nonatomic, strong) SYStandardNavigationBar* customNavigationBar;

@property(nonatomic, strong) NSString* headerTitle;

@end

@implementation SYBaseContentViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) showProgress
{
    [self showProgresWithText:@"" inView:self.view];
}

- (void) showProgresWithText:(NSString *)text inView:(UIView *)view
{
    if (self.progressActivity == nil)
    {
        self.progressActivity = [MBProgressHUD showHUDAddedTo:view animated:NO];
    }
    else
    {
        [self.progressActivity show:NO];
    }
    
    if (text.length > 0)
    {
        self.progressActivity.labelText = text;
    }
}

- (NSMutableArray *) requests
{
    if (_requests == nil)
    {
        _requests = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _requests;
}

- (void) hideProgress
{
    [self.progressActivity hide:YES];
    [self.progressActivity removeFromSuperview];
    self.progressActivity = nil;
}

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
    
    self.view.backgroundColor = RGBCOLOR(237, 237, 237);
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        self.extendedLayoutIncludesOpaqueBars = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.navigationBarStyle == SYNavigationBarStyleStandard)
    {
        [self initCustomNavigationBar];
    }
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.customNavigationBar.superview == [self customNavigationBarSuperView])
    {
        [self.view bringSubviewToFront:self.customNavigationBar];
    }
}

- (BOOL) prefersStatusBarHidden
{
    return NO;
}

- (UIStatusBarStyle) preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define kCustomNavigationBarHeight 44.0f
#define kStatusBarHeight 20.0f

- (void) initCustomNavigationBar
{
    CGRect customNavigationFrame = CGRectMake(0, 0, self.view.frame.size.width, kCustomNavigationBarHeight);
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {//iOS6 版本以上的View是全屏化的
        customNavigationFrame.size.height += kStatusBarHeight;
    }
    self.customNavigationBar = [[SYStandardNavigationBar alloc] initWithFrame:customNavigationFrame];
    
    self.customNavigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.customNavigationBar setLeftButtonWithStandardImage:[UIImage imageNamed:@"back_icon_white.png"]];
    
    self.customNavigationBar.backgroundColor = kMainDarkColor;
    [self.customNavigationBar.titleButton setTitleColor:kMainLightColor forState:UIControlStateNormal];
    [self.customNavigationBar.leftButton setTitleColor:kMainLightColor forState:UIControlStateNormal];
    [self.customNavigationBar.rightButton setTitleColor:kMainLightColor forState:UIControlStateNormal];
    
    [self.customNavigationBar.leftButton addTarget:self action:@selector(leftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.customNavigationBar.rightButton addTarget:self action:@selector(rightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.customNavigationBar];
    
    if (!self.noBorderAtBottomOfCustomNavigatonBar)
    {
//        [self.customNavigationBar setBorderInteraction:MYBorderInteractionBottom withColor:RGBCOLOR(216, 216, 216)];
    }
}

- (void) cancelAllRequest
{
    for (SYHttpRequest* request in self.requests)
    {
        [request cancel];
    }
    [self.requests removeAllObjects];
}

- (void) leftButtonClicked:(id)sender
{
    [self closeMeAnimated:YES];
}

- (void) prepareToClose
{
    [self.progressActivity removeFromSuperview];
    
    [self cancelAllRequest];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) closeMeAnimated:(BOOL)animated
{
    [self prepareToClose];
    
    if (self.navigationController == nil)
    {
        [self dismissViewControllerAnimated:animated completion:^{}];
        return;
    }
    
    if ([self.navigationController.viewControllers firstObject] == self)
    {
        [self.navigationController dismissViewControllerAnimated:animated completion:^{}];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:animated];
    }
}

- (void) setTitle:(NSString *)title
{
    self.headerTitle = title;
    [self.customNavigationBar.titleButton setTitle:title forState:UIControlStateNormal];
}

- (void) rightButtonClicked:(id)sender
{
    
}

- (void) loadData
{
    
}

- (UINavigationController *)navigationController
{
    UINavigationController* navigationController = [super navigationController];
    if (navigationController == nil)
    {
        navigationController = self.parentViewController.navigationController;
    }
//    if (self.scrollPageController != nil)
//    {
//        return  self.scrollPageController.navigationController;
//    }
//    else if (self.customTabBarController != nil)
//    {
//        return self.customTabBarController.navigationController;
//    }
    
    return navigationController;
}

- (UIView *) customNavigationBarSuperView
{
    return self.view;
}

- (void) viewDidAppearInScrollPageController
{
    
}

- (void) viewDidDisappearInScrollPageController
{
    
}

@end
