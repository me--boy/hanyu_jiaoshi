//
//  DFFilmClipsViewController.m
//  dafan
//
//  Created by iMac on 14-8-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFFilmClipsViewController.h"
#import "DFFilmClipCollectionCell.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "UIImageView+WebCache.h"
#import "DFCommonImages.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFFilePath.h"
#import "DFFilmClipViewController.h"
#import "DFFilmClipItem.h"
#import "UIAlertView+SYExtension.h"

@interface DFFilmClipsViewController ()

@property(nonatomic, strong) NSMutableArray* items;
@property(nonatomic) NSInteger offsetId;

@end

@implementation DFFilmClipsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.loadingFooterViewEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = [NSMutableArray array];
    
    [self configCollectionView];
    [self requestDatas:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - items

- (void) requestDatas:(BOOL)reload
{
    typeof(self) __weak bself = self;
    
    NSDictionary* dict = nil;
    if (!reload)
    {
        dict = @{@"offsetid": [NSNumber numberWithInt:self.offsetId]};
    }
    else
    {
        [self showProgress];
    }
    
    SYHttpRequest* requet = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForFilmClips] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        
        if (reload)
        {
            [bself.items removeAllObjects];
        }
        if (success)
        {
            bself.offsetId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];;
            
            NSArray* infos = [[resultInfo objectForKey:@"info"] objectForKey:@"list"];
            [bself reloadDataWithInfos:infos];
            [bself setCollectionFooterStauts:bself.offsetId > 0 empty:bself.items.count == 0];
            if (reload)
            {
                [infos writeToFile:[DFFilePath homeFilmclipsCacheFilePath] atomically:YES];
            }
        }
        else
        {
            if (reload)
            {
                NSArray* infos = [NSArray arrayWithContentsOfFile:[DFFilePath homeFilmclipsCacheFilePath]];
                [bself reloadDataWithInfos:infos];
            }
            [UIAlertView showNOPWithText:errorMsg];
            [bself setCollectionFooterStauts:YES empty:NO];
        }
    }];
    [self.requests addObject:requet];
}

- (void) reloadDataWithInfos:(NSArray *)infos
{
    for (NSDictionary* info in infos)
    {
        DFFilmClipItem* item = [[DFFilmClipItem alloc] initWithItemDictionary:info];
        [self.items addObject:item];
    }
    
    [self.collectionView reloadData];
}

- (void) requestMoreDataForTableFooterClicked
{
    [self requestDatas:NO];
}

#define kCollectionViewReuseIdentifier @"FlimClipsCell"

- (void) configCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFFilmClipCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kCollectionViewReuseIdentifier];
    [self enableRefreshAtHeaderForScrollView:self.collectionView];
    self.loadingFooterViewEnabled = YES;
}

- (void) reloadDataForRefresh
{
    [self requestDatas:YES];
}

#pragma mark - collection view

#define kCollectionMarginTop 5.f
#define kCollectionMarginBottom 5.f
#define kCollectionItemWidth 151.f
#define kCollectionItemHeight 124.f

- (CGFloat) totalCellHeight
{
    CGFloat height = kCollectionMarginTop + kCollectionItemHeight* self.items.count / 2;
    if (self.items.count % 2 > 0)
    {
        height += kCollectionItemHeight;
    }
    return height;
}

- (UICollectionViewLayout *) collectionViewLayout
{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(kCollectionItemWidth, kCollectionItemHeight);
    layout.sectionInset = UIEdgeInsetsMake(kCollectionMarginTop, 7.f, kCollectionMarginBottom, 7.f);
    layout.minimumInteritemSpacing = 4.f;
    layout.minimumLineSpacing = 9.f;
    
    return layout;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

#define kTestAvatarUrl @"http://static.maiqinqin.com/www/img/defaultavatar/avatar491.jpg"

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DFFilmClipCollectionCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewReuseIdentifier forIndexPath:indexPath];
    
    DFFilmClipItem* item = [self.items objectAtIndex:indexPath.item];
    
    [cell.previewImageView setImageWithURL:[NSURL URLWithString:item.previewImageUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
    
    cell.titleLabel.text = item.title;
    cell.detailLabel.text = [NSString stringWithFormat:@"%d人学习过   赞%d", item.watchCount, item.collectionCount];
    
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DFFilmClipItem* item = [self.items objectAtIndex:indexPath.item];
    DFFilmClipViewController* controller = [[DFFilmClipViewController alloc] initWithFilmClip:item];
    [self.navigationController pushViewController:controller animated:YES];
}

@end
