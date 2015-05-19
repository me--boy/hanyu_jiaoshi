//
//  DFSelfStudyViewController.h
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
// 天生有才 主控制器

#import "SYBaseContentViewController.h"
#import "DFChapterSectionViewController.h"
#import "DFFilmClipsViewController.h"

@interface DFSelfStudyViewController : SYBaseContentViewController

@property(nonatomic, readonly) DFChapterSectionViewController* dailyViewController;
@property(nonatomic, readonly) DFFilmClipsViewController* filmClipsViewController;

- (void) selectLeft;
- (void) selectRight;

@end
