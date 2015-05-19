//
//  DFGroupMessageCell.m
//  dafan
//
//  Created by iMac on 14-10-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFGroupMessageCell.h"
#import "UIView+SYShape.h"
#import "DFColorDefine.h"

@interface DFGroupMessageCell ()

@property(nonatomic, strong) UIImageView* avatarImageView;
@property(nonatomic, strong) UILabel* hintLabel;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) SYCoreTextView* lastMessageTextView;

@property(nonatomic, strong) UILabel* dateLabel;
@property(nonatomic, strong) UIImageView* ignoreImageView;

@end

@implementation DFGroupMessageCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define kCellPaddingHori 14
#define kCellAvatarSize 47
#define kFlagIconSize 19

#define kFocusButtonWidth 68
#define kFocusButtonHeight 28

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    CGSize size = self.frame.size;
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    //左部，头像
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kCellPaddingHori, (size.height - kCellAvatarSize) / 2, kCellAvatarSize, kCellAvatarSize)];
    self.avatarImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    [self.avatarImageView makeViewASCircle:self.avatarImageView.layer withRaduis:3 color:RGBCOLOR(219, 219, 219).CGColor strokeWidth:1];
    [self.contentView addSubview:self.avatarImageView];
    
    //右部
    //  第一行
    //      昵称
    CGFloat midViewX = kCellPaddingHori + kCellAvatarSize + 13;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(midViewX, 19, 190, 16)];
    self.titleLabel.textColor = RGBCOLOR(39, 55, 63);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.titleLabel];
    
    //  第三行 最新消息
    self.lastMessageTextView = [[SYCoreTextView alloc] initWithFrame:CGRectMake(midViewX, 45, 164, 18)];
    self.lastMessageTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.lastMessageTextView];
    
    //最右
    self.dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(size.width - 48, 20, 48, 12)];
    self.dateLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.dateLabel.backgroundColor = [UIColor clearColor];
    self.dateLabel.font = [UIFont systemFontOfSize:11];
    self.dateLabel.textColor = RGBCOLOR(149, 149, 149);
    [self.contentView addSubview:self.dateLabel];
    
    self.ignoreImageView = [[UIImageView alloc] initWithFrame:CGRectMake(size.width - 34, 40, 17, 17)];
    self.ignoreImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.ignoreImageView.hidden = YES;
    self.ignoreImageView.image = [UIImage imageNamed:@"message_ignore.png"];
    [self.contentView addSubview:self.ignoreImageView];
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

@end
