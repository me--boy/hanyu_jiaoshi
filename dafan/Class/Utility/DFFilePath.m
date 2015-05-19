//
//  DFFilePath.m
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFFilePath.h"

@implementation DFFilePath

+ (NSString *) homeCourseTeachersCacheFilePath
{
    return [[SYFilePath homeCachesDirectory] stringByAppendingPathComponent:@"course_teachers"];
}

+ (NSString *) homeDailiesCacheFilePath
{
    return [[SYFilePath homeCachesDirectory] stringByAppendingPathComponent:@"dailies"];
}

+ (NSString *) homeFilmclipsCacheFilePath
{
    return [[SYFilePath homeCachesDirectory] stringByAppendingPathComponent:@"filmclips"];
}

+ (NSString *) homePracticesCacheFilePath
{
    return [[SYFilePath homeCachesDirectory] stringByAppendingPathComponent:@"practices"];
}

+ (NSString *) homeMyMessagesCacheFilePath
{
    return [[SYFilePath homeCachesDirectory] stringByAppendingPathComponent:@"my_messages"];
}

+ (NSString *) homeClasscircleCacheFilePath
{
    return [[SYFilePath homeCachesDirectory] stringByAppendingPathComponent:@"classcircle"];
}

+ (NSString *) dailiesDirectory
{
    return [[SYFilePath librayDirectory] stringByAppendingPathComponent:@"daily"];
}

+ (NSString *) dailyTextFilPathWithChapterId:(NSInteger)chapterId
{
    return [[DFFilePath dailiesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"daily_chapter_%d", chapterId]];
}

+ (NSString *) audiosDirectory
{
    return [[DFFilePath librayDirectory] stringByAppendingPathComponent:@"audio/"];
}

+ (NSString *) sentenceAudiosDirectory
{
    return [[DFFilePath audiosDirectory] stringByAppendingPathComponent:@"sentence/"];
}

+ (NSString *) sentenceVoicesDirectory
{
    return [[DFFilePath voiceDirectoryPath] stringByAppendingPathComponent:@"sentence/"];
}

+ (NSString *) sentenceVoicesWithId:(NSInteger)sentenceId
{
    return [[DFFilePath sentenceVoicesDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.wav", sentenceId]];
}

@end
