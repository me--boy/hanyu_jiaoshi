//
//  DFTeacherCourseTableViewCell.h
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYUserInfoButton.h"

@interface DFTeacherCourseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *courseTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *tuitionLabel;
@property (weak, nonatomic) IBOutlet UILabel *studentCountLabel;
@property (weak, nonatomic) IBOutlet SYUserInfoButton *gotoClassroomButton;
@property (weak, nonatomic) IBOutlet SYUserInfoButton *courseDetailButton;


@end
