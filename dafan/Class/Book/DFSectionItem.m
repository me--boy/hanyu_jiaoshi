//
//  DFSectionItem.m
//  dafan
//
//  Created by iMac on 14-8-27.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFSectionItem.h"

@interface DFSectionItem ()

@property(nonatomic) NSInteger persistentId;

@property(nonatomic, strong) NSString* title;

@property(nonatomic, strong) NSString* voiceUrl;

@property(nonatomic, strong) NSArray* sentences;

@end

@implementation DFSectionItem

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        self.title = [dictionary objectForKey:@"title"];
        self.voiceUrl = [dictionary objectForKey:@"voice"];
        
        self.prepviewed = [[dictionary objectForKey:@"ispreview"] integerValue] == 1;
        
        NSMutableArray* sentences = [NSMutableArray array];
        for (NSDictionary* dict in [dictionary objectForKey:@"sentencelist"])
        {
            DFSentenceItem* sentence = [[DFSentenceItem alloc] initWithDictionary:dict];
            [sentences addObject:sentence];
        }
        if (sentences.count > 0)
        {
            self.sentences = [NSArray arrayWithArray:sentences];
        }
    }
    return self;
}

@end
