//
//  DFChapterSectionViewController.h
//  dafan
//
//  Created by iMac on 14-8-29.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYTableViewController.h"

typedef NS_ENUM(NSInteger, DFChapterSectionStyle)
{
    DFChapterSectionStyleDailySence,
    
    DFChapterSectionStyleCourse,
    
    DFChapterSectionStylePrep
};

typedef void(^chapterSectionSelected)(NSInteger chapterId, NSInteger sectionId);

@interface DFChapterSectionViewController : SYTableViewController

- (id) initWithChapterSectionStyle:(DFChapterSectionStyle)style;

@property(nonatomic) NSInteger selectedChapterId;

@property(nonatomic) NSInteger selectedSectionId;

@property(nonatomic) NSInteger courseId; //DFChapterSectionStyleCourse, DFChapterSectionStylePrep有效

@property(nonatomic, copy) chapterSectionSelected pickedBlock;

- (void) clearSelectedChapterSection;

@end
