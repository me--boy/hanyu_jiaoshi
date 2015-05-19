//
//  DFGroupMessageCell.h
//  dafan
//
//  Created by iMac on 14-10-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYCoreTextView.h"

@interface DFGroupMessageCell : UITableViewCell

@property(nonatomic, readonly) UIImageView* avatarImageView;

@property(nonatomic, readonly) UILabel* titleLabel;
@property(nonatomic, readonly) SYCoreTextView* lastMessageTextView;

@property(nonatomic, readonly) UILabel* dateLabel;
@property(nonatomic, readonly) UIImageView* ignoreImageView;

- (void) setUnreadCount:(NSInteger)count;

@end
