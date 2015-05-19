//
//  MYBaseContentViewController+NavigationBarHidden.m
//  MY
//
//  Created by iMac on 14-5-28.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYStandardNavigationBar.h"
#import "SYBaseContentViewController+NavigationBarHidden.h"

@implementation SYBaseContentViewController (NavigationBarHidden)

- (void) setCustomNavigationBarHidden:(BOOL)hide animation:(BOOL)animation
{
    __block CGRect fakeNaivFrame = self.customNavigationBar.frame;
    fakeNaivFrame.size.width = self.view.frame.size.width;
    self.customNavigationBar.titleButton.center = CGPointMake(self.view.frame.size.width / 2, self.customNavigationBar.titleButton.center.y);
    if (!hide)//不隐藏
    {
        if (animation)
        {
            
            fakeNaivFrame.origin.y = -fakeNaivFrame.size.height;
            self.customNavigationBar.frame = fakeNaivFrame;
            [[self customNavigationBarSuperView] addSubview:self.customNavigationBar];
            
            [UIView animateWithDuration:0.2 animations:^{
                fakeNaivFrame.origin.y = 0;
                self.customNavigationBar.frame = fakeNaivFrame;
            } completion:^(BOOL finished){
                
            }];
        }
        else
        {
            
            fakeNaivFrame.origin.y = 0;
            self.customNavigationBar.frame = fakeNaivFrame;
            
            [[self customNavigationBarSuperView] addSubview:self.customNavigationBar];
        }
    }
    else//隐藏
    {
        
        if (animation)
        {
            fakeNaivFrame.origin.y = 0;
            self.customNavigationBar.frame = fakeNaivFrame;
            
            [UIView animateWithDuration:0.2 animations:^{
                
                fakeNaivFrame.origin.y = -fakeNaivFrame.size.height;
                self.customNavigationBar.frame = fakeNaivFrame;
                
            } completion:^(BOOL finished){
                
                [self.customNavigationBar removeFromSuperview];
                
            }];
        }
        else
        {
            [self.customNavigationBar removeFromSuperview];
        }
        
    }
}

- (void) setCustomNavigationBarHidden:(BOOL)hide
{
    [self setCustomNavigationBarHidden:hide animation:NO];
}

- (BOOL) customNavigationBarHidden
{
    return self.customNavigationBar.superview == nil;
}

@end
