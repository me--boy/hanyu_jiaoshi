//
//  DFTeacherCourseTableViewCell.m
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFTeacherCourseTableViewCell.h"

@implementation DFTeacherCourseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
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

#define kSpace 5.f

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self.courseTitleLabel sizeToFit];
    [self.dateTimeLabel sizeToFit];
    CGRect courseTitleFrame = self.courseTitleLabel.frame;
    CGRect dateTimeFrame = self.dateTimeLabel.frame;
    
    if (courseTitleFrame.origin.x + courseTitleFrame.size.width + kSpace + dateTimeFrame.size.width + kSpace < self.frame.size.width)
    {
        dateTimeFrame.origin.x = courseTitleFrame.origin.x + courseTitleFrame.size.width + kSpace;
    }
    else
    {
        dateTimeFrame.origin.x = self.frame.size.width - kSpace - dateTimeFrame.size.width;
        
        courseTitleFrame.size.width = dateTimeFrame.origin.x - kSpace - courseTitleFrame.origin.x;
        self.courseTitleLabel.frame = courseTitleFrame;
    }
    self.dateTimeLabel.frame = dateTimeFrame;
}

@end
