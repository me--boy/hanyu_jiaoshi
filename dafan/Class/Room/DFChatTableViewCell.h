//
//  DFChatTableViewCell.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreTextView.h"
#import "SYCircleBorderImageView.h"

#define kChatTableViewCellAvatarSize 27.f

@interface DFChatTableViewCell : UITableViewCell

@property(nonatomic, readonly) SYCircleBorderImageView* avatarView;
@property(nonatomic, readonly) CoreTextView* coreTextView;

@property(nonatomic) UIEdgeInsets contentInsets;
@property(nonatomic) CGFloat avatarTextSpace;

@property(nonatomic) CGFloat coreTextOriginY;
@property(nonatomic) CGSize coreTextSize;


@end
