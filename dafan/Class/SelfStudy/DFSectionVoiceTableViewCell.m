//
//  DFSectionVoiceTableViewCell.m
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFSectionVoiceTableViewCell.h"

@implementation DFSectionVoiceTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.backgroundColor = [UIColor clearColor];
        
        self.dialectLabel = [[UILabel alloc] init];
        self.dialectLabel.numberOfLines = 0;
        self.dialectLabel.backgroundColor = [UIColor clearColor];
        self.dialectLabel.font = [UIFont systemFontOfSize:kSectionVoiceTableCellDialectFontSize];
        [self.contentView addSubview:self.dialectLabel];
        
        self.mandarinLabel = [[UILabel alloc] init];
        self.mandarinLabel.numberOfLines = 0;
        self.mandarinLabel.backgroundColor = [UIColor clearColor];
        self.mandarinLabel.font = [UIFont systemFontOfSize:kSectionVoiceTableCellMandarinFontSize];
        [self.contentView addSubview:self.mandarinLabel];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
    
    UIView* selectedBackgroundView = [[UIView alloc] initWithFrame:self.bounds];
    selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    self.selectedBackgroundView = selectedBackgroundView;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.dialectLabel.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top, self.dialectSize.width, self.dialectSize.height);
    
    self.mandarinLabel.frame = CGRectMake(self.contentInsets.left, self.contentInsets.top + self.dialectSize.height + self.labelSpace, self.mandarinSize.width, self.mandarinSize.height);
    
    if (self.repeatPanel.superview == self.contentView)
    {
        CGRect mandrainFrame = self.mandarinLabel.frame;
        CGRect repeatPanelFrame = self.repeatPanel.frame;
        repeatPanelFrame.origin.y = mandrainFrame.origin.y + mandrainFrame.size.height + self.contentInsets.bottom;
        self.repeatPanel.frame = repeatPanelFrame;
    }
}

@end
