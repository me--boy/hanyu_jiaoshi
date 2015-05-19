//
//  DFMikeButton.m
//  dafan
//
//  Created by iMac on 14-9-26.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFMikeButton.h"

@implementation DFMikeButton

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchDownForMikeButton:self];
    
    [super touchesBegan:touches withEvent:event];
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchUpForMikeButton:self];
    
    [super touchesEnded:touches withEvent:event];
}

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.delegate touchUpForMikeButton:self];
    
    [super touchesCancelled:touches withEvent:event];
}


@end
