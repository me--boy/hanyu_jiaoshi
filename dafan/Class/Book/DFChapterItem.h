//
//  DFChapterItem.h
//  dafan
//
//  Created by iMac on 14-8-27.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFSectionItem.h"

typedef NS_ENUM(NSInteger, DFDownloadStatus)
{
    DFDownloadStatusUnknown,
    DFDownloadStatusReady,
    DFDownloadStatusWaiting,
    DFDownloadStatusDoing,
    DFDownloadStatusSucceed,
    DFDownloadStatusFailed
};

@interface DFChapterItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSString* title;

@property(nonatomic, readonly) NSString* compressedFileUrl;
@property(nonatomic) CGFloat progress;
@property(nonatomic) DFDownloadStatus downloadedStatus;

@property(nonatomic, readonly) NSArray* sections;

- (void) updateSectionsWithDictionaries:(NSArray *)dictionaries;

- (id) initWithClassroomDictionary:(NSDictionary *)dictionary;
- (id) initWithChapterSectionDictionary:(NSDictionary *)dictionary;
- (id) initWithCoursePrepDictionary:(NSDictionary *)dictionary;

@end
