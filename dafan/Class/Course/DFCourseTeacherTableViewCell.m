//
//  DFCourseTeacherTableViewCell.m
//  dafan
//
//  Created by iMac on 14-8-13.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCourseTeacherTableViewCell.h"

@implementation DFCourseTeacherTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
    self.starView.numberOfStars = 5;
    self.starView.contentInsects = UIEdgeInsetsMake(0, 0, 0, 0);
    self.starView.starSpace = 4;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#define kViewSpace 8.f

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    [self.teacherNameLabel sizeToFit];
    
    CGRect nameFrame = self.teacherNameLabel.frame;
    CGRect memberFrame = self.memberImageView.frame;
    
    if (nameFrame.origin.x + nameFrame.size.width + kViewSpace + memberFrame.size.width + kViewSpace < self.frame.size.width)
    {
        memberFrame.origin.x = nameFrame.origin.x + nameFrame.size.width + kViewSpace;
        
        self.memberImageView.frame = memberFrame;
    }
    else
    {
        memberFrame.origin.x = self.frame.size.width - kViewSpace - memberFrame.size.width;
        nameFrame.size.width = memberFrame.origin.x - kViewSpace - nameFrame.origin.x;
        
        self.memberImageView.frame = memberFrame;
        self.teacherNameLabel.frame = nameFrame;
    }
    
}

@end
