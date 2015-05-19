//
//  DFDailySceneItem.h
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFDailySceneItem : NSObject

@property(nonatomic, readonly) NSInteger persistentId;
@property(nonatomic, readonly) NSString* subject;
@property(nonatomic, readonly) NSInteger sectionCount;

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
