//
//  DFFilmClipComment.h
//  dafan
//
//  Created by iMac on 14-9-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DFChatItem.h"

@interface DFFilmClipComment : NSObject

@property(nonatomic, strong) DFChatItem* chatItem;
@property(nonatomic) NSInteger persistentId;

- (id) initWithDictionary:(NSDictionary *)dict;

@end
