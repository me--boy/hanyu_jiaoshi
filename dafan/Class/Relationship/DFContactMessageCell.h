//
//  MYFocusTableViewCell.h
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYFocusButton.h"
#import "SYCircleBorderImageView.h"
#import "SYCoreTextView.h"
#import "SYCircleBorderImageView.h"

@interface DFContactMessageCell : UITableViewCell

@property(nonatomic, readonly) UIImageView* avatarImageView;

@property(nonatomic, readonly) UILabel* nicknameLabel;
@property(nonatomic, readonly) UIImageView* memberImageView;
@property(nonatomic, readonly) UIImageView* verifyImageView;

@property(nonatomic, readonly) UILabel* genderCityLabel;

@property(nonatomic, readonly) SYCoreTextView* coreTextView;

@property(nonatomic, readonly) UILabel* dateLabel;

- (void) setUnreadCount:(NSInteger)count;

@end
