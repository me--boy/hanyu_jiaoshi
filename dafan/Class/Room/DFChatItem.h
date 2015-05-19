//
//  DFChatItem.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFChatItem : NSObject

@property(nonatomic, strong) NSString* avatarUrl;
@property(nonatomic) NSInteger userId;

@property(nonatomic, strong) NSAttributedString* textContent;

@property(nonatomic, readonly) CGSize textContentSize;

@property(nonatomic) CGFloat chatTableCellHeight;

- (void) resetTextContentSizeWithConstraintSize:(CGSize)size;

//- (id) initWithDictionary:(NSDictionary *)dictionary;

@end
