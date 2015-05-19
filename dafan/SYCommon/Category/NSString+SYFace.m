//
//  NSString+SYFace.m
//  dafan
//
//  Created by iMac on 14-8-21.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "NSString+SYFace.h"
static NSArray* stFaceDescriptions = nil;


@implementation NSString (SYFace)

+ (NSString *)faceTextForID:(NSInteger)faceId
{
    
    if (stFaceDescriptions == nil)
    {
        stFaceDescriptions = @[@"[鼓掌]", @"[亲亲]", @"[ 色 ]", @"[坏笑]",
                               @"[害羞]", @"[得意]", @"[调皮]", @"[龇牙]",
                               @"[偷笑]", @"[可爱]", @"[白眼]", @"[擦汗]",
                               @"[抠鼻]", @"[微笑]", @"[ 糗 ]", @"[鼻涕]",
                               @"[委屈]", @"[快哭了]", @"[阴险]", @"[ 吓 ]",
                               @"[可怜]", @"[ 强 ]", @"[胜利]", @"[抱拳]",
                               @"[勾引]", @"[爱你]", @"[握手]", @"[憨笑]",
                               @"[闭嘴]", @"[ 睡 ]", @"[泪奔]", @"[尴尬]",
                               @"[发怒]", @"[惊讶]", @"[难过]", @"[ 酷 ]",
                               @"[冷汗]", @"[抓狂]", @"[傲慢]", @"[饥饿]",
                               @"[ 困 ]", @"[惊恐]", @"[流泪]", @"[流汗]",
                               @"[大兵]", @"[奋斗]", @"[咒骂]", @"[拳头]",
                               @"[差劲]", @"[NO]", @"[ 弱 ]", @"[抱抱]",
                               @"[心碎]", @"[ 嘘 ]", @"[疑问]", @"[ 晕 ]",
                               @"[ 🔥 ]", @"[敲头]", @"[再见]", @"[左哼哼]",
                               @"[右哼哼]", @"[哈欠]", @"[鄙视]", @"[撇嘴]",
                               @"[ 💓 ]", @"[ ❤️ ]", @"[ 🙏 ]", @"[ 👏 ]",
                               @"[足球]", @"[示爱]", @"[ 🍺 ]", @"[ 🍻 ]",
                               @"[西瓜]", @"[啤酒]", @"[篮球]", @"[乒乓球]",
                               @"[七星瓢虫]", @"[菜刀]", @"[生日蛋糕]", @"[ 屎 ]",
                               @"[100分]", @"[月亮]", @"[孩纸]", @"[太阳]",
                               @"[礼物]", @"[闪电]", @"[ 🎤 ]", @"[喝彩]",
                               @"[ 🍝 ]", @"[ 🍜 ]", @"[吃饭]", @"[头疼]"];
    }
    
    return stFaceDescriptions[faceId];
}

- (NSString *) replaceFacesIDWithFaceDescriptions
{
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.{0,4}\\]"
                                                                           options:NSRegularExpressionUseUnicodeWordBoundaries
                                                                             error:&error];
    NSMutableString* string = [NSMutableString stringWithString:@""];
    __block NSInteger lastIdx = 0;
    
    [regex enumerateMatchesInString:self options:0 range:NSMakeRange(0, self.length) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop){
        NSRange range = result.range;
        NSLog(@"%d,%d", range.location, range.length);
        
        
        NSString* regexString = [self substringWithRange:range];
        NSInteger idx = [stFaceDescriptions indexOfObject:regexString];
        
        if (idx != NSNotFound)
        {
            [string appendString:[self substringWithRange:NSMakeRange(lastIdx, range.location - lastIdx)]];
            
            [string appendFormat:@"[face%d]",idx];
        }
        else
        {
            [string appendString:[self substringWithRange:NSMakeRange(lastIdx, range.location + range.length - lastIdx)]];
            
        }
        lastIdx = range.location + range.length;
    }];
    
    [string appendString:[self substringFromIndex:lastIdx]];
    
    return string;
}

- (NSString *) faceDescriptionSuffix
{
    if ([self hasSuffix:@"]"])
    {
        NSRange range = [self rangeOfString:@"[" options:NSBackwardsSearch];
        if (range.length > 0 && self.length - range.location - 1 - 1 > 0)
        {
            NSString* string = [self substringFromIndex:range.location];
            if ([stFaceDescriptions indexOfObject:string] != NSNotFound)
            {
                return string;
            }
        }
    }
    return @"";
}

@end
