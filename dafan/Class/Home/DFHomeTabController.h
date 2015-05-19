//
//  DFHomeTabController.h
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SYTabBarController.h"
#import "DFHomeCourseTeacherViewController.h"
#import "DFSelfStudyViewController.h"
#import "DFPracticeViewController.h"
#import "DFRelationshipsViewController.h"

typedef NS_ENUM(NSInteger, DFTabBarID)
{
    DFTabBarIDCourse,
    DFTabBarIDSelfStudy,
    DFTabBarIDPractice,
    DFTabBarIDRelationship,
    DFTabBarIDCount
};

@interface DFHomeTabController : SYTabBarController

@property(nonatomic, strong) DFHomeCourseTeacherViewController* courseViewController;
@property(nonatomic, strong) DFSelfStudyViewController* selfStudyViewController;
@property(nonatomic, strong) DFPracticeViewController* practiceViewController;
@property(nonatomic, strong) DFRelationshipsViewController* relationshipsViewController;

@end
