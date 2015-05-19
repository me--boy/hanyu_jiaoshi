//
//  MYLoadingButton.m
//  MY
//
//  Created by iMac on 14-5-26.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYLoadingButton.h"

@interface SYLoadingButton ()

@property(nonatomic, strong) UIActivityIndicatorView* loadingActivity;

@end

@implementation SYLoadingButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void) setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    if (enabled)
    {
        [self.loadingActivity stopAnimating];
        [self.loadingActivity removeFromSuperview];
        self.loadingActivity = nil;
    }
    else
    {
        if (!self.disableShowLoadingWhenDisabled)
        {
            if (self.loadingActivity == nil)
            {
                CGSize size = self.frame.size;
                self.loadingActivity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                self.loadingActivity.center = CGPointMake(size.width / 2, size.height / 2);
                [self addSubview:self.loadingActivity];
            }
            [self.loadingActivity startAnimating];
        }
        else
        {
            [self.loadingActivity stopAnimating];
            [self.loadingActivity removeFromSuperview];
            self.loadingActivity = nil;
        }
        
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
