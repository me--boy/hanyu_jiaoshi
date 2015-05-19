//
//  SYContextMenu.h
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SYContextMenuItem : NSObject

@property(nonatomic) NSInteger menuId;
@property(nonatomic, strong) NSString* menutitle;

+ (SYContextMenuItem *) contextMenuItemWithID:(NSInteger)menuId title:(NSString *)title;

@end

@class SYContextMenu;
@protocol SYContextMenuDelegate <NSObject>

- (void) contextMenuDidDismiss:(SYContextMenu *)contextMenu;
- (void) contextMenu:(SYContextMenu *)menu selectItem:(SYContextMenuItem *)item;

@end


@interface SYContextMenu : UIView

@property(nonatomic, weak) id<SYContextMenuDelegate> delegate;

- (id) initWithTitle:(NSString *)title menuItems:(NSArray *)menuItems;

- (void) showInView:(UIView *)view;

@end
