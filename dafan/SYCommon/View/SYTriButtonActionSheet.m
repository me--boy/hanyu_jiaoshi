//
//  MYTurntableInviteActionSheet.m
//  MY
//
//  Created by iMac on 14-5-26.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTriButtonActionSheet.h"

@interface SYTriButtonActionSheet ()

@property(nonatomic, strong) UIButton* leftButton;
@property(nonatomic, strong) UIButton* middleButton;
@property(nonatomic, strong) UIButton* rightButton;



@end

@implementation SYTriButtonActionSheet

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
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 96)];
    
    self.leftButton = [self actionButtonAtIndex:0];
    self.middleButton = [self actionButtonAtIndex:1];
    self.rightButton = [self actionButtonAtIndex:2];
    
    [self.leftButton setTitle:@"微信分享" forState:UIControlStateNormal];
    [self.leftButton setImage:[UIImage imageNamed:@"share_wechat_friends.png"] forState:UIControlStateNormal];

    [self.leftButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.middleButton setTitle:@"QQ分享" forState:UIControlStateNormal];
    [self.middleButton setImage:[UIImage imageNamed:@"share_qq.png"] forState:UIControlStateNormal];
    [self.middleButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.rightButton setTitle:@"短信分享" forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"share_sms.png"] forState:UIControlStateNormal];
    [self.rightButton addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [view addSubview:self.leftButton];
    [view addSubview:self.middleButton];
    [view addSubview:self.rightButton];
    
    return view;
}

- (UIButton *) actionButtonAtIndex:(NSInteger)index
{
    CGFloat originX = 1 + index * 106;
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(originX, 0, 106, 96)];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    button.titleEdgeInsets = UIEdgeInsetsMake(68, -56, 8, 0);
    button.imageEdgeInsets = UIEdgeInsetsMake(3, 23, 36, 4);
    return button;
}

@end
