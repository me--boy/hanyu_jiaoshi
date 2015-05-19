//
//  MYCoreTextView.m
//  CoreTextViewTest
//
//  Created by iMac on 14-6-27.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <CoreText/CoreText.h>
#import "SYCoreTextView.h"

@implementation SYCoreTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (self.faceAttributedString != nil)
    {
        [self drawFaceText];
    }
}

- (void) drawFaceText
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height);
    CGContextConcatCTM(context, flipVertical);
    
    CTFramesetterRef ctFramesetter = CTFramesetterCreateWithAttributedString((CFMutableAttributedStringRef)self.faceAttributedString);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGRect bounds = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    CGPathAddRect(path, NULL, bounds);
    
    CTFrameRef ctFrame = CTFramesetterCreateFrame(ctFramesetter, CFRangeMake(0, 0), path, NULL);
    
    CTFrameDraw(ctFrame, context);
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    NSInteger lineCount = CFArrayGetCount(lines);
    CGPoint lineOrigins[lineCount];
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0, 0), lineOrigins);
    for (NSInteger idx = 0; idx < lineCount; ++idx)
    {
        CTLineRef line = CFArrayGetValueAtIndex(lines, idx);
        CGFloat lineAscent;
        CGFloat lineDescent;
        CGFloat lineLeading;
        
        CTLineGetTypographicBounds(line, &lineAscent, &lineDescent, &lineLeading);
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        NSInteger runCount = CFArrayGetCount(runs);
        for (NSInteger runIdx = 0; runIdx < runCount; ++runIdx)
        {
            CGFloat runAscent;
            CGFloat runDescent;
            CGPoint lineOrigin = lineOrigins[idx];
            
            CTRunRef run = CFArrayGetValueAtIndex(runs, runIdx);
            NSDictionary* attributes = (NSDictionary *)CTRunGetAttributes(run);
            CGRect runRect;
            runRect.size.width = CTRunGetTypographicBounds(run, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
            
            runRect = CGRectMake(lineOrigin.x + CTLineGetOffsetForStringIndex(line, CTRunGetStringRange(run).location, NULL), lineOrigin.y - runDescent, runRect.size.width, runAscent + runDescent);
            
            NSString* imageName = [attributes objectForKey:@"imageName"];
            UIImage* image = [UIImage imageNamed:imageName];
            if (image)
            {
                CGRect imageDrawRect;
                imageDrawRect.size = runRect.size;//image.size;
                imageDrawRect.origin.x = runRect.origin.x + lineOrigin.x;
                imageDrawRect.origin.y = lineOrigin.y;
                CGContextDrawImage(context, imageDrawRect, image.CGImage);
            }
        }
    }
    
    CFRelease(ctFrame);
    CFRelease(path);
    CFRelease(ctFramesetter);
}

@end
