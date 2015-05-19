//
//  DFFilmClipComment.m
//  dafan
//
//  Created by iMac on 14-9-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFFilmClipComment.h"
#import "NSString+HTMLCoreText.h"
#import "NSString+SYCoreText.h"
#import "CoreTextView.h"

@interface DFFilmClipComment ()



@end

@implementation DFFilmClipComment

- (id) initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dict objectForKey:@"id"] integerValue];
        
        self.chatItem = [[DFChatItem alloc] init];
        
        self.chatItem.userId = [[dict objectForKey:@"userid"] integerValue];
        self.chatItem.avatarUrl = [dict objectForKey:@"avatar"];
        
        NSString* nickname = [dict objectForKey:@"nickname"];
        NSString* content = [dict objectForKey:@"content"];
        
        NSString* htmlString = htmlString = [NSString stringWithFormat:@"<span color=\"#df0494\">%@</span>&nbsp;：<span color=\"#27373f\">%@</span>", nickname, [content replaceFacesWithHtmlFormat]];
        
        self.chatItem.textContent = [NSAttributedString attributedStringWithHTML:htmlString renderer:nil];
        
    }
    return self;
}

@end
