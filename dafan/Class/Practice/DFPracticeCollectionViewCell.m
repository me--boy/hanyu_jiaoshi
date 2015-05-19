//
//  DFPracticeCollectionViewCell.m
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPracticeCollectionViewCell.h"

@implementation DFPracticeCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#define kSpace 4.f

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self.titleLabel sizeToFit];
    
    CGRect titleFrame = self.titleLabel.frame;
    CGRect lockFrame = self.lockImageView.frame;
    
    if (!self.lockImageView.hidden)
    {
        if (titleFrame.origin.x + titleFrame.size.width + kSpace + lockFrame.size.width + kSpace  > self.typeButton.frame.origin.x)
        {
            lockFrame.origin.x = self.typeButton.frame.origin.x - kSpace - lockFrame.size.width;
            self.lockImageView.frame = lockFrame;
            
            titleFrame.size.width = lockFrame.origin.x - kSpace - titleFrame.origin.x;
            self.titleLabel.frame = titleFrame;
        }
        else
        {
            lockFrame.origin.x = titleFrame.origin.x + titleFrame.size.width + kSpace;
            self.lockImageView.frame = lockFrame;
        }
    }
    else
    {
        if (titleFrame.origin.x + titleFrame.size.width + kSpace > self.typeButton.frame.origin.x)
        {
            titleFrame.size.width = self.typeButton.frame.origin.x - kSpace - titleFrame.origin.x;
            self.titleLabel.frame = titleFrame;
        }
    }
    
    [self.userCountLabel sizeToFit];
    CGRect userCountFrame = self.userCountLabel.frame;
    userCountFrame.origin.x = self.typeButton.frame.origin.x + self.typeButton.frame.size.width - userCountFrame.size.width;
    self.userCountLabel.frame = userCountFrame;
    
    CGRect userCountImageFrame = self.userCountImageView.frame;
    userCountImageFrame.origin.x = userCountFrame.origin.x - kSpace - userCountImageFrame.size.width;
    self.userCountImageView.frame = userCountImageFrame;
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
