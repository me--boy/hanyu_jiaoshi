//
//  DFChatItem.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChatItem.h"
#import <CoreText/CoreText.h>

@interface DFChatItem ()

//@property(nonatomic, strong) NSString* avatarUrl;
//@property(nonatomic) NSInteger userId;
//@property(nonatomic, strong) NSAttributedString* textContent;
//
@property(nonatomic) CGSize textContentSize;

@end

#define kTestAvatarUrl @"http://static.maiqinqin.com/www/img/defaultavatar/avatar491.jpg"

@implementation DFChatItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.avatarUrl = kTestAvatarUrl;
        self.textContent = [[NSAttributedString alloc] initWithString:@"tianqijdsldfkjsl"];
    }
    return self;
}

- (void) resetTextContentSizeWithConstraintSize:(CGSize)size
{
    id setter = CFBridgingRelease(CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.textContent));
    self.textContentSize = CTFramesetterSuggestFrameSizeWithConstraints((__bridge CTFramesetterRef)(setter), CFRangeMake(0, 0), NULL, size, NULL);
}


@end
