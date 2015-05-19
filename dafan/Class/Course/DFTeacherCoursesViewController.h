//
//  DFTeacherCoursesViewController.h
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYTableViewController.h"
#import "DFTeacherItem.h"

@interface DFTeacherCoursesViewController : SYTableViewController

- (id) initWithTeacherId:(NSInteger)teacherId;

@property(nonatomic, strong) DFTeacherItem* defaultTeacherItem;

@end
