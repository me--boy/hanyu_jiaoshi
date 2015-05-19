//
//  DFVoiceSentenceItem.h
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFSentenceItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSString* voiceUrl;

@property(nonatomic, strong) NSString* dialect; //方言
@property(nonatomic, strong) NSString* mandarin; //普通话

@property(nonatomic) CGSize normalDialectSize;
@property(nonatomic) CGSize normalMandarinSize;
@property(nonatomic) CGFloat normalCellHeight;

@property(nonatomic) CGSize selectedDialectSize;
@property(nonatomic) CGSize selectedMandarinSize;
@property(nonatomic) CGFloat selectedCellHeight;

+ (DFSentenceItem *) testVoiceItem;
- (id) initWithDictionary:(NSDictionary *)dictionary;

//- (void) setNormalDialectSizeWithFont:(UIFont *)font maxSize:(CGSize)size;
//- (void) setNormalMandarinSizeWithFont:(UIFont *)font maxSize:(CGSize)size;
//
//- (void) setSelectedDialectSizeWithFont:(UIFont *)font maxSize:(CGSize)size;
//- (void) setSelectedMandarinSizeWithFont:(UIFont *)font maxSize:(CGSize)size;

- (CGSize) dialectSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;
- (CGSize) mandarinSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

@end
