//
//  SYTableViewController.h.m
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTableViewController.h"
#import "SYDeviceDescription.h"
#import "EGORefreshTableHeaderView.h"
#import "SYConstDefine.h"
#import "SYScrollPageViewController.h"
#import "SYLoadingButton.h"
#import "SYScrolledTabBar.h"
#import "SYScrollPageViewController.h"
#import "SYStandardNavigationBar.h"

@interface SYTableViewController ()

@property(nonatomic, strong) UITableView* tableView;
@property(nonatomic, strong) SYLoadingButton* tableFooterViewButton;

@end

@implementation SYTableViewController

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
    
    [self initTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define kTabBarHeight 48

- (void) initTableView
{
    CGRect navigationBarFrame = self.customNavigationBar.frame;
    
    CGRect rect = self.view.bounds;
    rect.origin.y = navigationBarFrame.size.height;
    rect.size.height -= rect.origin.y;
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:[self tableViewStyle]];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = kDefaultTableRowHeight;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.backgroundView.backgroundColor = [UIColor clearColor];
    
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    self.tableView.separatorColor = RGBCOLOR(218, 218, 218);
    
    [self.view addSubview:self.tableView];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (UITableViewStyle) tableViewStyle
{
    return UITableViewStylePlain;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - footer click to more

- (void) setClickToFetchMoreTableFooterView
{
    if (self.tableFooterViewButton == nil)
    {
        self.tableFooterViewButton = [[SYLoadingButton alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 40)];
        
        [self.tableFooterViewButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        self.tableFooterViewButton.backgroundColor = [UIColor clearColor];
        self.tableFooterViewButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.tableFooterViewButton addTarget:self action:@selector(tableFooterViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.tableView.tableFooterView != self.tableFooterViewButton)
    {
        self.tableView.tableFooterView = self.tableFooterViewButton;
    }
}

- (void) tableFooterViewButtonClicked:(id)sender
{
    [self requestMoreDataForTableFooterClicked];
}

- (void) requestMoreDataForTableFooterClicked
{
    [self disableTableFooterButton];
}

- (NSString *)emptyFooterTitle
{
    return @"没有更多了...";
}

- (NSString *)normalFooterTitle
{
    return @"点击获取更多";
}

- (void) setTableFooterStauts:(BOOL)haveNext empty:(BOOL)empty
{
    if (haveNext)
    {
        self.tableFooterViewButton.enabled = YES;
        [self.tableFooterViewButton setTitle:[self normalFooterTitle] forState:UIControlStateNormal];
    }
    else
    {
        [self.tableFooterViewButton setTitle:(empty ? [self emptyFooterTitle] : @"没有更多了...") forState:UIControlStateDisabled];
        self.tableFooterViewButton.disableShowLoadingWhenDisabled = YES;
        self.tableFooterViewButton.enabled = NO;
    }
}

- (void) disableTableFooterButton
{
    [self.tableFooterViewButton setTitle:@"" forState:UIControlStateDisabled];
    self.tableFooterViewButton.disableShowLoadingWhenDisabled = NO;
    self.tableFooterViewButton.enabled = NO;
}

#pragma mark - scroll view

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint offset = scrollView.contentOffset;
//    
//    if (self.tableFooterViewButton != nil)
//    {
//        if (self.tableFooterViewButton.enabled && offset.y + scrollView.frame.size.height >= scrollView.contentSize.height + 44)
//        {
//            [self.tableFooterViewButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//        }
//    }
//}

@end
