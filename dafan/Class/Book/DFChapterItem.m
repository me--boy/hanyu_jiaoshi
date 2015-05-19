//
//  DFChapterItem.m
//  dafan
//
//  Created by iMac on 14-8-27.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChapterItem.h"

@interface DFChapterItem()

@property(nonatomic) NSInteger persistentId;

@property(nonatomic, strong) NSString* title;

@property(nonatomic, strong) NSArray* sections;

@property(nonatomic, strong) NSString* compressedFileUrl;

@end

@implementation DFChapterItem

- (void) updateSectionsWithDictionaries:(NSArray *)dictionaries
{
    NSMutableArray* sections = [NSMutableArray array];
    for (NSDictionary* dict in dictionaries)
    {
        DFSectionItem* section = [[DFSectionItem alloc] initWithDictionary:dict];
        [sections addObject:section];
    }
    if (sections.count > 0)
    {
        self.sections = [NSArray arrayWithArray:sections];
    }
    else
    {
        self.sections = nil;
    }
}

- (id) initWithClassroomDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"chapter_id"] integerValue];
        self.title = [dictionary objectForKey:@"chapter_title"];
        self.compressedFileUrl = [dictionary objectForKey:@"download_url"];
        
        NSMutableArray* sections = [NSMutableArray array];
        for (NSDictionary* dict in [dictionary objectForKey:@"sectionlist"])
        {
            DFSectionItem* section = [[DFSectionItem alloc] initWithDictionary:dict];
            [sections addObject:section];
        }
        if (sections.count > 0)
        {
            self.sections = [NSArray arrayWithArray:sections];
        }
    }
    return self;
}

- (id) initWithChapterSectionDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        self.title = [dictionary objectForKey:@"content"];
        self.compressedFileUrl = [dictionary objectForKey:@"download_url"];
        
        NSMutableArray* sections = [NSMutableArray array];
        for (NSDictionary* dict in [dictionary objectForKey:@"sectionlist"])
        {
            DFSectionItem* section = [[DFSectionItem alloc] initWithDictionary:dict];
            [sections addObject:section];
        }
        if (sections.count > 0)
        {
            self.sections = [NSArray arrayWithArray:sections];
        }
    }
    return self;
}

- (id) initWithCoursePrepDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"chapter_id"] integerValue];
        self.title = [dictionary objectForKey:@"chapter_content"];
        
        NSMutableArray* sections = [NSMutableArray array];
        for (NSDictionary* dict in [dictionary objectForKey:@"sections"])
        {
            DFSectionItem* section = [[DFSectionItem alloc] initWithDictionary:dict];
            [sections addObject:section];
        }
        if (sections.count > 0)
        {
            self.sections = [NSArray arrayWithArray:sections];
        }
        
    }
    return self;
}

@end
