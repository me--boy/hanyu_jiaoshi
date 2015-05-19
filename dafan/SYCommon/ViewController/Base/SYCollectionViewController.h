//
//  MYCollectionViewController.h
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"

#define kDefaultCollectionFooterViewHeight 40.f

@interface SYCollectionViewController : SYBaseContentViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property(nonatomic, readonly) UICollectionView* collectionView;

- (UICollectionViewLayout *) collectionViewLayout;

@property(nonatomic) BOOL loadingFooterViewEnabled; //if yes, call before viewDidLoad

- (void) requestMoreDataForTableFooterClicked;

- (NSString *)emptyFooterTitle;
- (NSString *)normalFooterTitle;

- (void) setCollectionFooterStauts:(BOOL)haveNext empty:(BOOL)empty;

- (CGFloat) totalCellHeight;


@end
