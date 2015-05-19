//
//  DFFilePath.h
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYFilePath.h"

@interface DFFilePath : SYFilePath

+ (NSString *) homeCourseTeachersCacheFilePath;     //课程老师
+ (NSString *) homeDailiesCacheFilePath;            //日常用语
+ (NSString *) homeFilmclipsCacheFilePath;          //影视片段
+ (NSString *) homePracticesCacheFilePath;          //个人广场
+ (NSString *) homeMyMessagesCacheFilePath;         //私信
+ (NSString *) homeClasscircleCacheFilePath;            //班级圈

// library/daily
+ (NSString *) dailiesDirectory;
+ (NSString *) dailyTextFilPathWithChapterId:(NSInteger)chapterId;

// library/audio
+ (NSString *) audiosDirectory;

// library/audio/sentence
+ (NSString *) sentenceAudiosDirectory;

// library/voice/sentence/
+ (NSString *) sentenceVoicesDirectory;
+ (NSString *) sentenceVoicesWithId:(NSInteger)sentenceId;

@end
