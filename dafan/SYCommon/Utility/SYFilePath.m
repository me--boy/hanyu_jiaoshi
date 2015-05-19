//
//  MYFilePath.m
//  MY
//
//  Created by 胡少华 on 14-5-7.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYFilePath.h"

@implementation SYFilePath

+ (NSString *) libraryCacheDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [paths firstObject];
}

+ (NSString *) librayDirectory
{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

+ (NSString *) colorBarDirectory
{
    return [[SYFilePath librayDirectory] stringByAppendingPathComponent:@"color_bar/"];
}

+ (BOOL) fileExists:(NSString *)filePath
{
    BOOL isDirectory;
    return [[NSFileManager defaultManager] fileExistsAtPath:filePath isDirectory:&isDirectory] && !isDirectory;
}

+ (void) ensureDirectory:(NSString *)directoriesPath
{
    NSFileManager* fileMgr = [NSFileManager defaultManager];
    BOOL directory;
    if ([fileMgr fileExistsAtPath:directoriesPath isDirectory:&directory])
    {
        if (!directoriesPath)
        {
            NSError* error;
            [fileMgr removeItemAtPath:directoriesPath error:&error];
            
            [self createDirectory:directoriesPath];
        }
    }
    else
    {
        [self createDirectory:directoriesPath];
    }
}

+ (void) createDirectory:(NSString *)directoriesPath
{
    [[NSFileManager defaultManager] createDirectoryAtPath:directoriesPath withIntermediateDirectories:YES attributes:nil error:nil];
}

+ (NSString *) colorBarConfigFilePath
{
    return [[SYFilePath colorBarDirectory] stringByAppendingPathComponent:@"color_bar_config"];
}

+ (NSString *) colorBarItemFilePath:(NSInteger)colorBarId
{
    return [[SYFilePath colorBarDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"color%ld.gif", (long)colorBarId]];
}

+ (NSString *) voiceDirectoryPath
{
    return [[SYFilePath librayDirectory] stringByAppendingPathComponent:@"voice/"];
}

+ (NSString *) currentVoiceAMRFilePath
{
    return [[SYFilePath voiceDirectoryPath] stringByAppendingPathComponent:@"current_voice.amr"];
}

+ (NSString *) currentVoiceWAVFilePath
{
    return [[SYFilePath voiceDirectoryPath] stringByAppendingPathComponent:@"current_voice.wav"];
}

+ (void) clearCurrentVoiceFilePath
{
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:[SYFilePath currentVoiceAMRFilePath] error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:[SYFilePath currentVoiceWAVFilePath] error:&error];
}
/**
 *  在云端不备份指定路径的文件
 *
 *  @param filePath 文件的路径
 *
 *  @return true -->设置成功
 */
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath
{
    if (![SYFilePath fileExists:filePath])
    {
        return NO;
    }
    NSError *error = nil;
    NSURL* url = [NSURL fileURLWithPath:filePath];
    BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
    }
    return success;
}

//user
+ (NSString *) userDirectory
{
    return [[SYFilePath librayDirectory] stringByAppendingPathComponent:@"user/"];
}

+ (NSString *) userProfilePathWithId:(NSString *)userIdText
{
    return [[SYFilePath userDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"user%@", userIdText]];
}

+ (NSString *) homeCachesDirectory
{
    return [[SYFilePath libraryCacheDirectory] stringByAppendingPathComponent:@"home/"];
}

@end
