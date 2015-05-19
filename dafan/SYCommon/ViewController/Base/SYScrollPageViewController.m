//
//  SYScrollPageViewController.m
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYConstDefine.h"
#import "UIView+SYShape.h"
#import "SYScrolledTabBar.h"
#import "SYStandardNavigationBar.h"
#import "SYScrollPageViewController.h"

#import "DFColorDefine.h"

@interface SYScrollPageViewController ()<SYScrolledTabBarDelegate>
@property(nonatomic, strong) UIScrollView* scrollView;

@property(nonatomic, strong) SYScrolledTabBar* scrolledTabBar;

@property(nonatomic, strong) NSArray* privateTabViewController;

@property(nonatomic, strong) NSMutableArray* hasLoadedTabViewControllers;
/**
 *  提醒数字
 */
@property(nonatomic, strong) NSMutableArray* badgeLabels;

@property(nonatomic) NSInteger currentTabIdx;

@end

@implementation SYScrollPageViewController

@synthesize scrollView = _scrollView;
//@synthesize segmentControl = _segmentControl;
@synthesize hasLoadedTabViewControllers = _hasLoadedTabViewControllers;

- (SYBaseContentViewController *) currentTabBarViewController
{
    return [self.privateTabViewController objectAtIndex:self.currentTabIdx];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super init];
    if (self)
    {
        self.noBorderAtBottomOfCustomNavigatonBar = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.hasLoadedTabViewControllers = [NSMutableArray array];
    [self initSubviews];
    [self loadDataIfCurrentViewControllerHasNotLoadData];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.currentTabBarViewController viewDidAppearInScrollPageController];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - initSubViews

//#define kSegmentPaddingLeft 20
//#define kSegmentPaddingTop 8
//#define kSegmentHeight 30
//
//#define kScrollViewMarginTop 8

- (void) initSubviews
{
    [self initSegmentControl];
    [self initScrollView];
    [self addSubTabBarViewControllers];
}

- (void) initSegmentControl
{
    CGFloat offsetY = 0;
    CGRect navigationBarFrame = self.customNavigationBar.frame;
    offsetY += navigationBarFrame.origin.y + navigationBarFrame.size.height;
    
    self.scrolledTabBar = [[SYScrolledTabBar alloc] initWithFrame:CGRectMake(0, offsetY, self.view.frame.size.width, 40)];
    self.scrolledTabBar.backgroundImageView.image = [UIImage imageNamed:@"scroll_bar_bg.png"];
    self.scrolledTabBar.normalTitleColor = RGBCOLOR(51, 51, 51);
    self.scrolledTabBar.selectedTitleColor = kMainDarkColor;
    self.scrolledTabBar.delegate = self;
    [self.view addSubview:self.scrolledTabBar];
    
}

- (void) initScrollView
{
    CGRect segmentFrame = self.scrolledTabBar.frame;
    CGSize size = self.view.frame.size;
    CGFloat offsetY = segmentFrame.origin.y + segmentFrame.size.height;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, offsetY, size.width, size.height - offsetY - [self bottomMargin])];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    self.scrollView.bounces = NO;
    [self.view addSubview:self.scrollView];

    [self.scrollView addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == self.scrollView && [keyPath isEqualToString:@"frame"])
    {
        CGSize contentSize = self.scrollView.contentSize;
        contentSize.height = self.scrollView.frame.size.height;
        self.scrollView.contentSize = contentSize;
    }
}

- (void) addSubTabBarViewControllers
{
    NSInteger idx = 0;
    CGSize size = self.scrollView.frame.size;
    
    self.privateTabViewController = [self tabBarViewControllers];
    
    NSMutableArray* tabItems = [NSMutableArray array];
    for (SYBaseContentViewController* viewController in self.privateTabViewController)
    {
        [self addChildViewController:viewController];
        
        viewController.navigationBarStyle = SYNavigationBarStyleNone;
        viewController.scrollPageController = self;
        
        viewController.view.frame = CGRectMake(idx * size.width, 0, size.width, size.height);
        [self.scrollView addSubview:viewController.view];
        
        SYTabBarButtonItem* tabItem = [[SYTabBarButtonItem alloc] init];
        tabItem.title = viewController.headerTitle;
        [tabItems addObject:tabItem];
        ++idx;
    }
    self.scrolledTabBar.selectedIndex = self.currentTabIdx;
    self.scrolledTabBar.tabButtonItems = tabItems;
    [self.scrolledTabBar reloadData];
    
    self.scrollView.contentSize = CGSizeMake(size.width * self.privateTabViewController.count, size.height);
    
    [self scrollToCurIdx];
}

- (void) scrollToCurIdx
{
    [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * self.currentTabIdx, 0) animated:YES];
    
    [self loadDataIfCurrentViewControllerHasNotLoadData];
}

- (void) selectTabAtIdx:(NSInteger)idx
{
    if (idx >= 0 && idx < self.privateTabViewController.count)
    {
        self.currentTabIdx = idx;
        [self.scrollView setContentOffset:CGPointMake(self.view.frame.size.width * self.currentTabIdx, 0) animated:NO];
        [self loadDataIfCurrentViewControllerHasNotLoadData];
    }
}

- (SYBaseContentViewController *) tabBarViewControllerAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.privateTabViewController.count)
    {
        return [self.privateTabViewController objectAtIndex:index];
    }
    return nil;
}

#pragma mark - segmentChanged


- (void) scrolledTabBar:(SYScrolledTabBar *)tabbar selectIndex:(NSInteger)index
{
    [self scrollViewFrom:self.currentTabIdx to:index];
}

#pragma mark - scrollViewDelegate

- (void) scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.scrolledTabBar setIndicatorPositionFactor:self.scrollView.contentOffset.x / self.scrollView.frame.size.width selectTab:NO];
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self resetSegmentForScrollViewScrolled];
}

- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self resetSegmentForScrollViewScrolled];
}

- (void) resetSegmentForScrollViewScrolled
{
    NSInteger idx = self.scrollView.contentOffset.x / self.scrollView.frame.size.width;
    
    [self scrollViewFrom:self.currentTabIdx to:idx];
}

- (void) scrollViewFrom:(NSInteger)oldIdx to:(NSInteger)newIdx
{
    if (newIdx != oldIdx)
    {
        SYBaseContentViewController* oldViewController = [self.privateTabViewController objectAtIndex:oldIdx];
        SYBaseContentViewController* newViewController = [self.privateTabViewController objectAtIndex:newIdx];
        
        [self.scrolledTabBar setIndicatorPositionFactor:newIdx selectTab:YES];
        
        [oldViewController viewDidDisappearInScrollPageController];
        [newViewController viewDidAppearInScrollPageController];
        
        if (newIdx - self.currentTabIdx > 1)
        {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * (newIdx - 1), 0) animated:NO];
        }
        else if (self.currentTabIdx - newIdx > 1)
        {
            [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * (newIdx + 1), 0) animated:NO];
        }
        
        [self.scrollView setContentOffset:CGPointMake(self.scrollView.frame.size.width * newIdx, 0) animated:YES];
        
        self.currentTabIdx = newIdx;
        [self loadDataIfCurrentViewControllerHasNotLoadData];
    }
}

- (void) loadDataIfCurrentViewControllerHasNotLoadData
{
    SYBaseContentViewController* newViewController = [self.privateTabViewController objectAtIndex:self.currentTabIdx];
    if (![self.hasLoadedTabViewControllers containsObject:newViewController])
    {
        [self.hasLoadedTabViewControllers addObject:newViewController];
        [newViewController loadData];
    }
}

- (void) setCurrentTabIdx:(NSInteger)currentTabIdx
{
    _currentTabIdx = currentTabIdx;
    [self clearBadgeForTabIdx:currentTabIdx];
}

#pragma mark -

- (NSArray *) tabBarViewControllers
{
    return nil;
}

- (CGFloat) bottomMargin
{
    return 0;
}

#pragma mark -

- (void) setBadgeCount:(NSInteger)count forSubTabViewController:(SYBaseContentViewController *)controller
{
    NSInteger idx = [self.privateTabViewController indexOfObject:controller];
    if (NSNotFound != idx)
    {
        [self setBadgeCount:count forTabIdx:idx];
    }
}

- (void) setBadgeCount:(NSInteger)count forTabIdx:(NSInteger)idx
{
    if (idx >=0 && idx < self.privateTabViewController.count && count > 0)
    {
        [self.hasLoadedTabViewControllers removeObject:[self.privateTabViewController objectAtIndex:idx]];
        
        if (self.badgeLabels == nil)
        {
            self.badgeLabels = [NSMutableArray array];
        }
        
        CGFloat width = 0;
        CGFloat height = 16;
        UILabel* label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor redColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:13];
        label.textAlignment = NSTextAlignmentCenter;
        label.tag = idx;
        if (count >= 100)
        {
            label.text = @"99+";
            width = 28;
        }
        else if (count >= 10)
        {
            label.text = [NSString stringWithFormat:@"%d", count];
            width = 28;
        }
        else
        {
            label.text = [NSString stringWithFormat:@"%d", count];
            width = 16;
        }
        //设置位置
        CGFloat x = self.scrolledTabBar.frame.origin.x + self.scrolledTabBar.frame.size.width / self.scrolledTabBar.tabButtonItems.count * (idx + 1) - width - 28;
        CGFloat y = self.scrolledTabBar.frame.origin.y + (self.scrolledTabBar.frame.size.height - height) / 2;
        label.frame = CGRectMake(x, y, width, height);
        if (count >= 10)
        {
            [label makeViewASCircle:label.layer withRaduis:7 color:[UIColor redColor].CGColor strokeWidth:1];
        }
        else
        {
            [label circledWithColor:[UIColor redColor] strokeWidth:1];
        }
        [self.view addSubview:label];
        
        [self.badgeLabels addObject:label];
    }
}

- (void) clearBadgeForTabIdx:(NSInteger)idx
{
    for (UILabel* label in self.badgeLabels)
    {
        if (label.tag == idx)
        {
            [label removeFromSuperview];
            [self.badgeLabels removeObject:label];
            break;
        }
    }
}

@end
