//
//  DFVoiceSentenceItem.m
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFSentenceItem.h"
#import "SYDeviceDescription.h"

static int stTestId = 0;

@interface DFSentenceItem ()

//@property(nonatomic) CGSize dialectSize;
//@property(nonatomic) CGSize mandarinSize;
@property(nonatomic) NSInteger persistentId;
@property(nonatomic, strong) NSString* voiceUrl;

@end

@implementation DFSentenceItem

+ (DFSentenceItem *) testVoiceItem
{
    DFSentenceItem* item = [[DFSentenceItem alloc] init];
    
    NSMutableString* dialect = [[NSMutableString alloc] initWithString:@"风急天高猿啸哀。"];
    
    if (stTestId >= 0)
        [dialect appendString:@"渚清沙白鸟飞回。"];
    if (stTestId >= 1)
        [dialect appendString:@"无边落木萧萧下。"];
    if (stTestId >= 2)
        [dialect appendString:@"不尽长江滚滚来。"];
    if (stTestId >= 3)
        [dialect appendString:@"万里悲情常作客。"];
    if (stTestId >= 4)
        [dialect appendString:@"百年多病独登台。"];
    if (stTestId >= 5)
        [dialect appendString:@"艰难苦恨繁霜鬓。"];
    if (stTestId >= 6)
        [dialect appendString:@"潦倒新停浊酒杯。"];
    
    item.dialect = dialect;
    item.mandarin = dialect;
    
    ++stTestId;
    
    return item;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self)
    {
        self.persistentId = [[dictionary objectForKey:@"id"] integerValue];
        self.dialect = [dictionary objectForKey:@"dialect_content"];
        self.mandarin = [dictionary objectForKey:@"content"];
        self.voiceUrl = [dictionary objectForKey:@"voice"];
    }
    return self;
}

- (CGSize) dialectSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion < 7)
    {
        return [self.dialect sizeWithFont:font constrainedToSize:maxSize];
    }
    else
    {
        return [self.dialect boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font} context:nil].size;
    }
}
- (CGSize) mandarinSizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize
{
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion < 7)
    {
        return [self.mandarin sizeWithFont:font constrainedToSize:maxSize];
    }
    else
    {
        return [self.mandarin boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) attributes:@{NSFontAttributeName: font} context:nil].size;
    }
}


@end
