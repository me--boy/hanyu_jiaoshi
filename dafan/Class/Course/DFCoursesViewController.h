//
//  DFMyCoursesViewController.h
//  dafan
//
//  Created by iMac on 14-8-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYTableViewController.h"
#import "DFCourseItem.h"

typedef NS_ENUM(NSInteger, DFCourseStyle)
{
    DFCourseStyleInClass = 1,//正在上课
    DFCourseStyleRecommend, //其他老师
    DFCourseStyleRegisterable, //可报名
    DFCourseStyleStudent, //该学生学习的
    DFCourseStyleTeacher    //该老师教授的
};

@interface DFCoursesViewController : SYTableViewController
{
    NSMutableArray* _courses;
    NSMutableArray* _animatingImages;
}

- (id) initWithStyle:(DFCourseStyle)style;

- (NSArray *) coursesWithInfos:(NSArray *)infos;

- (DFCourseItem *)courseItemForIndexPath:(NSIndexPath *)indexPath;

@end
