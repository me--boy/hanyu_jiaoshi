//
//  MYFilePath.h
//  MY
//
//  Created by 胡少华 on 14-5-7.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYFilePath : NSObject

+ (NSString *) libraryCacheDirectory;
+ (NSString *) librayDirectory;

+ (BOOL) fileExists:(NSString *)filePath;
+ (void) ensureDirectory:(NSString *)directoriesPath;

// Library/user
+ (NSString *) userDirectory;
+ (NSString *) userProfilePathWithId:(NSString *)userIdText; //dict

// Library/color_bar
+ (NSString *) colorBarDirectory;
+ (NSString *) colorBarConfigFilePath;
+ (NSString *) colorBarItemFilePath:(NSInteger)colorBarId;

// Library/voice
+ (NSString *) voiceDirectoryPath; //message, chat

//voice
+ (NSString *) currentVoiceAMRFilePath;
+ (NSString *) currentVoiceWAVFilePath;
+ (void) clearCurrentVoiceFilePath;

//home  
+ (NSString *) homeCachesDirectory;

//skip
+ (BOOL)addSkipBackupAttributeToItemAtPath:(NSString *)filePath;

@end
