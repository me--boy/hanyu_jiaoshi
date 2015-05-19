//
//  DFPracticeCollectionViewCell.h
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DFPracticeCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *channelIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *userCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *typeButton;
@property (weak, nonatomic) IBOutlet UIImageView *lockImageView;
@property (weak, nonatomic) IBOutlet UIImageView *userCountImageView;

@end
