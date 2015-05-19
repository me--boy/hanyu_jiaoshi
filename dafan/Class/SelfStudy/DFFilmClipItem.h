//
//  DFFilmClipItem.h
//  dafan
//
//  Created by iMac on 14-9-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFFilmClipItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSString* sourceUrl;
@property(nonatomic, readonly) NSString* previewImageUrl;
@property(nonatomic, readonly) NSString* title;
@property(nonatomic, readonly) NSInteger watchCount; //学习

@property(nonatomic) NSInteger collectionCount;

@property(nonatomic) NSInteger commentCount;
@property(nonatomic) NSInteger shareCount;
@property(nonatomic) BOOL isCollected;

- (id) initWithItemDictionary:(NSDictionary *)dictionary;

@end
