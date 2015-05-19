//
//  MYFullShareActionSheet.m
//  MY
//
//  Created by iMac on 14-6-30.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYFullShareActionSheet.h"

@interface SYFullShareActionSheet ()

@property(nonatomic, strong) UIButton* weiboButton;
@property(nonatomic, strong) UIButton* qZoneButton;
@property(nonatomic, strong) UIButton* wechatFriendsCircleButton;
@property(nonatomic, strong) UIButton* qqFriendButton;
@property(nonatomic, strong) UIButton* wechatFriendButton;
@property(nonatomic, strong) UIButton* messageButton;

@end


@implementation SYFullShareActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (UIView *) actionGroupView
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 100)];
    
    
//    self.weiboButton = [self actionButtonAtIndex:0];
//    self.qZoneButton = [self actionButtonAtIndex:1];
//    self.wechatFriendsCircleButton = [self actionButtonAtIndex:2];
//    self.qqFriendButton = [self actionButtonAtIndex:3];
//    self.wechatFriendButton = [self actionButtonAtIndex:4];
//    self.messageButton = [self actionButtonAtIndex:5];
    
    self.wechatFriendsCircleButton = [self actionButtonAtIndex:0];
    self.wechatFriendButton = [self actionButtonAtIndex:1];
    
    [self.weiboButton setImage:[UIImage imageNamed:@"share_weibo.png"] forState:UIControlStateNormal];
    //    self.weiboButton.titleEdgeInsets = UIEdgeInsetsMake(68, -44, 8, 0);x
    [self.weiboButton setTitle:@"新浪微博" forState:UIControlStateNormal];
    
    [self.qZoneButton setImage:[UIImage imageNamed:@"share_qzone.png"] forState:UIControlStateNormal];
    //    self.qZoneButton.titleEdgeInsets = UIEdgeInsetsMake(68, -44, 8, 0);
    [self.qZoneButton setTitle:@"qq空间" forState:UIControlStateNormal];
    
    [self.wechatFriendsCircleButton setImage:[UIImage imageNamed:@"share_wechat_friend_circle.png"] forState:UIControlStateNormal];
    self.wechatFriendsCircleButton.titleEdgeInsets = UIEdgeInsetsMake(68, -42, 8, 0);
    [self.wechatFriendsCircleButton setTitle:@"微信朋友圈" forState:UIControlStateNormal];
    
    [self.qqFriendButton setImage:[UIImage imageNamed:@"share_qq_friend.png"] forState:UIControlStateNormal];
    [self.qqFriendButton setTitle:@"qq好友" forState:UIControlStateNormal];
    
    [self.wechatFriendButton setImage:[UIImage imageNamed:@"share_wechat_friend.png"] forState:UIControlStateNormal];
    [self.wechatFriendButton setTitle:@"微信好友" forState:UIControlStateNormal];
    
    [self.messageButton setTitle:@"短信分享" forState:UIControlStateNormal];
    [self.messageButton setImage:[UIImage imageNamed:@"share_sms.png"] forState:UIControlStateNormal];
    [self.messageButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    
    [view addSubview:self.weiboButton];
    [view addSubview:self.qZoneButton];
    [view addSubview:self.wechatFriendsCircleButton];
    [view addSubview:self.qqFriendButton];
    [view addSubview:self.wechatFriendButton];
    [view addSubview:self.messageButton];
    
    [self.weiboButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.qZoneButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.wechatFriendsCircleButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.qqFriendButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [self.wechatFriendButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    return view;
}

- (UIButton *) actionButtonAtIndex:(NSInteger)index
{
    CGFloat originX = 1 + index % 3 * 106;
    CGFloat originY = index / 3 * 96;
    
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, 106, 96)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleEdgeInsets = UIEdgeInsetsMake(68, -44, 8, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(3, 23, 36, 4);
    return button;
}

@end
