//
//  MYFocusTableViewCell.m
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFContactMessageCell.h"
#import "UIView+SYShape.h"
#import "SYConstDefine.h"
#import "SYFocusButton.h"
#import "DFColorDefine.h"
#import "UIView+SYShape.h"
#import "UIImage+SYExtension.h"

@interface DFContactMessageCell ()

//left
@property(nonatomic, strong) UIImageView* avatarImageView;
@property(nonatomic, strong) UILabel* hintLabel;

//mid
//first
@property(nonatomic, strong) UILabel* nicknameLabel;
@property(nonatomic, strong) UIImageView* memberImageView;
@property(nonatomic, strong) UIImageView* verifyImageView;

//second
@property(nonatomic, strong) UILabel* genderCityLabel;

//third
@property(nonatomic, strong) SYCoreTextView* coreTextView;

//right
@property(nonatomic, strong) UILabel* dateLabel;

@end

@implementation DFContactMessageCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initSubviews];
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define kCellPaddingHori 14
#define kCellAvatarSize 47
#define kFlagIconSize 19

#define kFocusButtonWidth 68
#define kFocusButtonHeight 28

- (void) initSubviews
{
    CGSize size = self.frame.size;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    //左部，头像
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPaddingHori, (size.height - kCellAvatarSize) / 2, kCellAvatarSize, kCellAvatarSize)];
    self.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.avatarImageView makeViewASCircle:self.avatarImageView.layer withRaduis:6 color:RGBCOLOR(219, 219, 219).CGColor strokeWidth:1];
    [self.contentView addSubview:self.avatarImageView];
    
    //右部
    //  第一行
    //      昵称
    CGFloat midViewX = kCellPaddingHori + kCellAvatarSize + 13;
    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(midViewX, 14, 0, 0)];
    self.nicknameLabel.textColor = RGBCOLOR(39, 55, 63);
    self.nicknameLabel.backgroundColor = [UIColor clearColor];
    self.nicknameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.nicknameLabel];
    //      会员
    self.memberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, kFlagIconSize, kFlagIconSize)];
    self.memberImageView.image = [UIImage imageNamed:@"user_member.png"];
    [self.contentView addSubview:self.memberImageView];
    //      学生标示
    self.verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 13, kFlagIconSize, kFlagIconSize)];
    self.verifyImageView.image = [UIImage imageNamed:@"user_teacher.png"];
    [self.contentView addSubview:self.verifyImageView];
    
    //  第二行 性别－城市
    self.genderCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(midViewX, 38, 164, 12)];
    self.genderCityLabel.font = [UIFont systemFontOfSize:12];
    self.genderCityLabel.text = @"";
    self.genderCityLabel.backgroundColor = [UIColor clearColor];
    self.genderCityLabel.textColor = RGBCOLOR(155, 155, 155);
    [self.contentView addSubview:self.genderCityLabel];
    
    //  第三行 最新消息
    self.coreTextView = [[SYCoreTextView alloc] initWithFrame:CGRectMake(midViewX, 55, 220, 18)];
    self.coreTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.coreTextView];
    
    //最右
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width - 48, 18, 48, 12)];
    self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.font = [UIFont systemFontOfSize:11];
    self.dateLabel.textColor = RGBCOLOR(149, 149, 149);
    [self.contentView addSubview:self.dateLabel];
}

- (void) ensureHintLabel
{
    if (self.hintLabel == nil)
    {
        CGRect avatarFrame = self.avatarImageView.frame;
        self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(avatarFrame.origin.x + avatarFrame.size.width - 8, 6, 16, 16)];
        self.hintLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        self.hintLabel.backgroundColor = [UIColor redColor];
        self.hintLabel.textColor = [UIColor whiteColor];
        self.hintLabel.textAlignment = NSTextAlignmentCenter;
        self.hintLabel.font = [UIFont systemFontOfSize:13];
        [self.hintLabel circledWithColor:[UIColor redColor] strokeWidth:1];
    }
}

- (void) setUnreadCount:(NSInteger)count
{
    if (count > 0)
    {
        [self ensureHintLabel];
        
        [self.contentView addSubview:self.hintLabel];
        self.hintLabel.text = [NSString stringWithFormat:@"%d", count];
    }
    else if (self.hintLabel.superview != nil)
    {
        [self.hintLabel removeFromSuperview];
    }
}

#define kViewSpace 5

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat maxX = self.dateLabel.frame.origin.x;
    
    [self.nicknameLabel sizeToFit];
    CGRect nicknameFrame = self.nicknameLabel.frame;
    
    CGRect memberFrame = self.memberImageView.frame;
    CGRect verifyFrame = self.verifyImageView.frame;
    
    CGFloat totoalWidth = nicknameFrame.size.width + kViewSpace;
    if (!self.memberImageView.hidden)
    {
        totoalWidth += memberFrame.size.width + kViewSpace;
    }
    if (!self.verifyImageView.hidden)
    {
        totoalWidth += verifyFrame.size.width + kViewSpace;
    }
    
//    CGFloat offsetX = 0;
    if (nicknameFrame.origin.x + totoalWidth < maxX)
    {
        CGFloat offsetX = nicknameFrame.origin.x + nicknameFrame.size.width + kViewSpace;
        if (!self.memberImageView.hidden)
        {
            memberFrame.origin.x = offsetX;
            offsetX += memberFrame.size.width + kViewSpace;
            self.memberImageView.frame = memberFrame;
        }
        if (!self.verifyImageView.hidden)
        {
            verifyFrame.origin.x = offsetX;
            self.verifyImageView.frame = verifyFrame;
        }
    }
    else
    {
        CGFloat offsetX = maxX;
        if (!self.verifyImageView.hidden)
        {
            offsetX -= kViewSpace + verifyFrame.size.width;
            verifyFrame.origin.x = offsetX;
            self.verifyImageView.frame = verifyFrame;
        }
        if (!self.memberImageView.hidden)
        {
            offsetX -= kViewSpace + memberFrame.size.width;
            memberFrame.origin.x = offsetX;
            self.memberImageView.frame = memberFrame;
        }
        
        nicknameFrame.size.width = offsetX - kViewSpace - nicknameFrame.origin.x;
        self.nicknameLabel.frame = nicknameFrame;
    }
}

@end
