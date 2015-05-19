

//
//  DFSectionItem.h
//  dafan
//
//  Created by iMac on 14-8-27.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DFSentenceItem.h"

@interface DFSectionItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;

@property(nonatomic, readonly) NSString* title;

@property(nonatomic, readonly) NSString* voiceUrl;

@property(nonatomic, readonly) NSArray* sentences;

@property(nonatomic) BOOL prepviewed;

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
