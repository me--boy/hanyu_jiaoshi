//
//  MYCollectionViewController.m
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYCollectionViewController.h"
#import "SYDeviceDescription.h"
#import "SYScrollPageViewController.h"
#import "SYLoadingButton.h"
#import "SYStandardNavigationBar.h"
#import "SYCollectionReuseLoadingView.h"

@interface SYCollectionViewController ()

@property(nonatomic, strong) UICollectionView* collectionView;

@property(nonatomic, weak) SYLoadingButton* loadingButton;

@end

@implementation SYCollectionViewController

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
    
    [self initCollectionView];
}

- (UICollectionViewLayout *) collectionViewLayout
{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    
    return layout;
}

#define kFooterViewIdentifier @"FooterViewIdentifier"

- (void) initCollectionView
{
    CGRect navigationBarFrame = self.customNavigationBar.frame;
//    CGRect scrollBarFrame = self.scrollPageController.scrolledTabBar.frame;
    
    CGRect rect = self.view.bounds;
    rect.origin.y = navigationBarFrame.size.height;
    rect.size.height -= rect.origin.y;//+ scrollBarFrame.size.height + scrollBarFrame.origin.y;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:[self collectionViewLayout]];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.showsVerticalScrollIndicator = NO;

    [self.view addSubview:self.collectionView];
    
    if (self.loadingFooterViewEnabled)
    {
        [self.collectionView registerClass:[SYCollectionReuseLoadingView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterViewIdentifier];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat) totalCellHeight
{
    return 0;
}

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    CGFloat totalCellHeight = [self totalCellHeight];
    if (self.collectionView.frame.size.height > totalCellHeight + kDefaultCollectionFooterViewHeight)
    {
        return CGSizeMake(self.view.frame.size.width, self.collectionView.frame.size.height - totalCellHeight);
    }
    return CGSizeMake(self.view.frame.size.width, kDefaultCollectionFooterViewHeight);
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}


- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SYCollectionReuseLoadingView* footerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooterViewIdentifier forIndexPath:indexPath];
//    footerView.backgroundColor = [UIColor clearColor];
    
    CGRect footerFrame = footerView.loadingButton.frame;
    footerFrame.size.height = kDefaultCollectionFooterViewHeight;
    footerView.loadingButton.frame = footerFrame;
    
    self.loadingButton = footerView.loadingButton;
    [self.loadingButton removeTarget:self action:@selector(collectionFooterViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.loadingButton addTarget:self action:@selector(collectionFooterViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.loadingButton.hidden = !self.loadingFooterViewEnabled;
    
    return footerView;
}

- (void) collectionFooterViewButtonClicked:(id)sender
{
    [self disableLoadingFooterView];
    [self requestMoreDataForTableFooterClicked];
}

- (void) requestMoreDataForTableFooterClicked
{
    
}

- (NSString *)emptyFooterTitle
{
    return @"没有更多了...";
}

- (NSString *)normalFooterTitle
{
    return @"点击获取更多";
}

- (void) disableLoadingFooterView
{
    [self.loadingButton setTitle:@"" forState:UIControlStateDisabled];
    self.loadingButton.disableShowLoadingWhenDisabled = NO;
    self.loadingButton.enabled = NO;
}

- (void) setCollectionFooterStauts:(BOOL)haveNext empty:(BOOL)empty
{
    if (haveNext)
    {
        self.loadingButton.enabled = YES;
        [self.loadingButton setTitle:[self normalFooterTitle] forState:UIControlStateNormal];
    }
    else
    {
        [self.loadingButton setTitle:(empty ? [self emptyFooterTitle] : @"没有更多了...") forState:UIControlStateDisabled];
        self.loadingButton.disableShowLoadingWhenDisabled = YES;
        self.loadingButton.enabled = NO;
    }
}

//- (void) scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGPoint offset = scrollView.contentOffset;
//    
//    if (self.loadingButton != nil)
//    {
//        if (self.loadingButton.enabled && offset.y + scrollView.frame.size.height >= scrollView.contentSize.height + 44)
//        {
//            [self.loadingButton sendActionsForControlEvents:UIControlEventTouchUpInside];
//        }
//    }
//}

@end
