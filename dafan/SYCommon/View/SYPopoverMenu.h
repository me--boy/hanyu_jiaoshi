//
//  SYPopoverMenu.h
//  dafan
//
//  Created by iMac on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>


@class SYPopoverMenu;

@protocol SYPopoverMenuDelegate <NSObject>

- (void) popoverMenu:(SYPopoverMenu *)menu select:(NSInteger)menuId;

@end

@interface SYPopoverMenuItem : NSObject

@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) UIImage* image;

@end

@interface SYPopoverMenu : UIView

//@property(nonatomic) UIEdgeInsets contentInsets; //default up

@property(nonatomic, weak) id<SYPopoverMenuDelegate> delegate;

- (id) initWithMenuItems:(NSArray *)menuItems;

- (void) showFromView:(UIView *)view;

@end
