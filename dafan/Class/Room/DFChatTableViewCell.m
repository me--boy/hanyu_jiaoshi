//
//  DFChatTableViewCell.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChatTableViewCell.h"
#import "DFColorDefine.h"

@interface DFChatTableViewCell ()

@property(nonatomic, strong) SYCircleBorderImageView* avatarView;
@property(nonatomic, strong) CoreTextView* coreTextView;

@end

@implementation DFChatTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    self.avatarView = [[SYCircleBorderImageView alloc] initWithFrame:CGRectMake(0, 0, kChatTableViewCellAvatarSize, kChatTableViewCellAvatarSize)];
    [self.avatarView circleWithColor:RGBCOLOR(196, 196, 196) radius:0];
    [self.contentView addSubview:self.avatarView];
    
    self.coreTextView = [[CoreTextView alloc] init];
    self.coreTextView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.coreTextView];
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.avatarView.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, kChatTableViewCellAvatarSize, kChatTableViewCellAvatarSize);
    self.coreTextView.frame = CGRectMake(self.contentInsets.left + kChatTableViewCellAvatarSize + self.avatarTextSpace, self.coreTextOriginY, self.coreTextSize.width, self.coreTextSize.height);
    
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


@end
