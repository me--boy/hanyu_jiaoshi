//
//  DFCourseTeacherTableViewCell.h
//  dafan
//
//  Created by iMac on 14-8-13.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DFStarRatingView.h"

@interface DFCourseTeacherTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *teacherNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *teacherBerifMessage;
@property (weak, nonatomic) IBOutlet DFStarRatingView *starView;
@property (weak, nonatomic) IBOutlet UILabel *studentsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *memberImageView;

@end
