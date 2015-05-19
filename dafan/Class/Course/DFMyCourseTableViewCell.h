//
//  DFMyCourseTableViewCell.h
//  dafan
//
//  Created by iMac on 14-8-13.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYUserInfoButton.h"

@interface DFMyCourseTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *avatarButton;
@property (weak, nonatomic) IBOutlet UILabel *courseTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *subjectLabel;
/**
 *  进入课堂按钮
 */
@property (weak, nonatomic) IBOutlet SYUserInfoButton *gotoClassroomButton;
/**
 *  教室的表图
 */
@property (weak, nonatomic) IBOutlet UIImageView *classingImageView;

@end
