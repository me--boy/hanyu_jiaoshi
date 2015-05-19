//
//  DFChatMemberTableViewCell.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChatMemberTableViewCell.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"

@interface DFChatMemberTableViewCell ()

@property(nonatomic, strong) SYCircleBorderImageView* avatarView;
@property(nonatomic, strong) UILabel* nicknameLabel;
@property(nonatomic, strong) UILabel* provinceCityLabel;

@property(nonatomic, strong) UIImageView* keyboardImageView;
@property(nonatomic, strong) UIImageView* mikeImageView;

@property(nonatomic, strong) UIButton* positionButton;
@property(nonatomic, strong) UIButton* rightButton;

@property(nonatomic, strong) UIImageView* verifyImageView;
@property(nonatomic, strong) UIImageView* memberImageView;


@end

@implementation DFChatMemberTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

#define kMarginLeft 9.f
#define kMarginRight 14.f
#define kAvatarMarginTop 11.f
#define kAvatarSize 56.f

#define kSubviewsSpace 9.f
#define kNicknameMargintTop (kAvatarMarginTop + 7.f)
#define kProvinceCityNicknameSpace 14.f

#define kBottomRightImageMarginTop 37.f
#define kBottomRightImageSize 30.f

#define kFlagIconMarginTop 18.f
#define kFlagIconSize 18.f

- (void) initSubviews
{
    self.avatarView = [[SYCircleBorderImageView alloc] initWithFrame:CGRectMake(kMarginLeft, kAvatarMarginTop, kAvatarSize, kAvatarSize)];
//    [self.avatarView circleWithColor:kChatTableCellMainGrayColor radius:0];
    [self.contentView addSubview:self.avatarView];
    
    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(kMarginLeft + kAvatarSize + kSubviewsSpace,  kNicknameMargintTop, 0, 16)];
    self.nicknameLabel.textColor = [UIColor blackColor];
    self.nicknameLabel.backgroundColor = [UIColor clearColor];
    self.nicknameLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.nicknameLabel];
    
    self.provinceCityLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.nicknameLabel.frame.origin.x, self.nicknameLabel.frame.origin.y + self.nicknameLabel.frame.size.height + kProvinceCityNicknameSpace, 70, 15)];
    self.provinceCityLabel.textColor = kChatMemberTableCellMainGrayColor;
    self.provinceCityLabel.backgroundColor = [UIColor clearColor];
    self.provinceCityLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:self.provinceCityLabel];
    
    self.memberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kFlagIconMarginTop, kFlagIconSize, kFlagIconSize)];
    self.memberImageView.image = [UIImage imageNamed:@"user_member.png"];
    [self.contentView addSubview:self.memberImageView];
    
    self.verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kFlagIconMarginTop, kFlagIconSize, kFlagIconSize)];
    self.verifyImageView.image = [UIImage imageNamed:@"user_teacher.png"];
    [self.contentView addSubview:self.verifyImageView];
    
    self.positionButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kFlagIconMarginTop, 46, kFlagIconSize)];
    self.positionButton.backgroundColor = [UIColor clearColor];
    [self.positionButton setBackgroundImage:[UIImage imageNamed:@"chats_position_bkg.png"] forState:UIControlStateNormal];
    self.positionButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.positionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.contentView addSubview:self.positionButton];
    
    self.keyboardImageView = [[UIImageView alloc] initWithFrame:[self keyboardFrame]];
    self.keyboardImageView.image = [UIImage imageNamed:@"chats_keyboard_disable.png"];
    [self.contentView addSubview:self.keyboardImageView];
    
    self.mikeImageView = [[UIImageView alloc] initWithFrame:[self mikeFrame]];
    self.mikeImageView.image = [UIImage imageNamed:@"chats_mike_disable.png"];
    [self.contentView addSubview:self.mikeImageView];
    
    self.rightButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - kMarginRight - 40.f, 17.f, 40.f, 15.f)];
    [self.rightButton setTitleColor:kChatMemberTableCellMainGrayColor forState:UIControlStateNormal];
    [self.rightButton setTitleColor:kMainDarkColor forState:UIControlStateSelected];
    self.rightButton.userInteractionEnabled = NO;
    self.rightButton.titleLabel.font = [UIFont systemFontOfSize:13];
    [self.contentView addSubview:self.rightButton];
}

- (CGRect) keyboardFrame
{
    return CGRectMake(self.frame.size.width - 20.f - kBottomRightImageSize - kBottomRightImageSize - kSubviewsSpace, kBottomRightImageMarginTop, kBottomRightImageSize, kBottomRightImageSize);
}

- (CGRect) mikeFrame
{
    return CGRectMake(self.frame.size.width - 20.f - kBottomRightImageSize, kBottomRightImageMarginTop, kBottomRightImageSize, kBottomRightImageSize);
}

#define kViewSpace 4.f

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self.nicknameLabel sizeToFit];
    
    CGRect nicknameFrame = self.nicknameLabel.frame;
    CGRect verifyFrame = self.verifyImageView.frame;
    CGRect memberFrame = self.memberImageView.frame;
    CGRect positionFrame = self.positionButton.frame;
    
    CGFloat totalWidth = nicknameFrame.size.width;
    if (!self.positionButton.hidden)
    {
        totalWidth += kViewSpace + positionFrame.size.width;
    }
    if (!self.verifyImageView.hidden)
    {
        totalWidth += kViewSpace + verifyFrame.size.width;
    }
    if (!self.memberImageView.hidden)
    {
        totalWidth += kViewSpace + memberFrame.size.width;
    }
    if (!self.rightButton.hidden)
    {
        totalWidth += kViewSpace + self.rightButton.frame.size.width;
    }
    totalWidth += kMarginRight;
    
    if (nicknameFrame.origin.x + totalWidth < self.frame.size.width)
    {
        CGFloat offsetX = nicknameFrame.origin.x + nicknameFrame.size.width + kViewSpace;
        if (!self.positionButton.hidden)
        {
            positionFrame.origin.x = offsetX;
            offsetX += positionFrame.size.width + kViewSpace;
        }
        if (!self.verifyImageView.hidden)
        {
            verifyFrame.origin.x = offsetX;
            offsetX += verifyFrame.size.width + kViewSpace;
        }
        if (!self.memberImageView.hidden)
        {
            memberFrame.origin.x = offsetX;
            offsetX += memberFrame.size.width + kViewSpace;
        }
    }
    else
    {
        CGFloat offsetX = self.frame.size.width - kMarginRight;
        if (!self.rightButton.hidden)
        {
            offsetX -= self.rightButton.frame.size.width + kViewSpace;
        }
        
        if (!self.memberImageView.hidden)
        {
            memberFrame.origin.x = offsetX - memberFrame.size.width;
            offsetX -= memberFrame.size.width + kViewSpace;
        }
        if (!self.verifyImageView.hidden)
        {
            verifyFrame.origin.x = offsetX - verifyFrame.size.width;
            offsetX -= verifyFrame.size.width + kViewSpace;
        }
        if (!self.positionButton.hidden)
        {
            positionFrame.origin.x = offsetX - positionFrame.size.width;
            offsetX -= positionFrame.size.width + kViewSpace;
        }
        nicknameFrame.size.width = offsetX - nicknameFrame.origin.x;
        self.nicknameLabel.frame = nicknameFrame;
    }
    if (!self.positionButton.hidden)
    {
        self.positionButton.frame = positionFrame;
    }
    if (!self.verifyImageView.hidden)
    {
        self.verifyImageView.frame = verifyFrame;
    }
    if (!self.memberImageView.hidden)
    {
        self.memberImageView.frame = memberFrame;
    }
    
    if (!self.keyboardImageView.hidden)
    {
        self.keyboardImageView.frame = self.mikeImageView.hidden ? [self mikeFrame] : [self keyboardFrame];
    }
}

@end
