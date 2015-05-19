//
//  MYCollectionReuseLoadingView.m
//  MY
//
//  Created by iMac on 14-8-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYCollectionReuseLoadingView.h"
#import "SYLoadingButton.h"

@interface SYCollectionReuseLoadingView ()

@property(nonatomic, strong) SYLoadingButton* loadingButton;

@end

@implementation SYCollectionReuseLoadingView

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubviews];
    }
    return self;
}

- (void) initSubviews
{
    self.loadingButton = [[SYLoadingButton alloc] initWithFrame:self.bounds];
    [self.loadingButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.loadingButton.backgroundColor = [UIColor clearColor];
    self.loadingButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.loadingButton];
}

@end
