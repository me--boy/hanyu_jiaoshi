//
//  DFFilmClipItem.m
//  dafan
//
//  Created by iMac on 14-9-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFFilmClipItem.h"

@interface DFFilmClipItem ()

@property(nonatomic) NSInteger persistentId;
@property(nonatomic, strong) NSString* sourceUrl;
@property(nonatomic, strong) NSString* previewImageUrl;
@property(nonatomic, strong) NSString* title;

@property(nonatomic) NSInteger watchCount;

@end

@implementation DFFilmClipItem

- (id) initWithItemDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        self.sourceUrl = [dictionary objectForKey:@"url"];
//        self.sourceUrl = @"http://www.baidu.com";
        
        self.previewImageUrl = [dictionary objectForKey:@"img"];
        self.title = [dictionary objectForKey:@"title"];
        
        self.watchCount = [[dictionary objectForKey:@"student_count"] integerValue];
        self.collectionCount = [[dictionary objectForKey:@"fav_count"] integerValue];
        
        self.commentCount = [[dictionary objectForKey:@"comment_count"] integerValue];
        self.shareCount = [[dictionary objectForKey:@"share_count"] integerValue];
        
        self.isCollected = [[dictionary objectForKey:@"is_fav"] integerValue] == 1;
    }
    return self;
}

@end
