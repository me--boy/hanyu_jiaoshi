//
//  DFChatMemberTableViewCell.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYCircleBorderImageView.h"
#import "SYConstDefine.h"

#define kChatMemberTableCellMainGrayColor RGBCOLOR(132, 143, 149)

@interface DFChatMemberTableViewCell : UITableViewCell

@property(nonatomic, readonly) SYCircleBorderImageView* avatarView;
@property(nonatomic, readonly) UILabel* nicknameLabel;
@property(nonatomic, readonly) UILabel* provinceCityLabel;

@property(nonatomic, readonly) UIImageView* verifyImageView;
@property(nonatomic, readonly) UIImageView* memberImageView;

@property(nonatomic, readonly) UIImageView* keyboardImageView;
@property(nonatomic, readonly) UIImageView* mikeImageView;

@property(nonatomic, readonly) UIButton* positionButton;

@property(nonatomic, readonly) UIButton* rightButton; //在线，旷课，拍卖中...


@end
