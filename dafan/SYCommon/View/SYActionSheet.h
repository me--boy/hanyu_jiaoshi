//
//  MYActionSheet.h
//  MY
//
//  Created by iMac on 14-5-26.
//  Copyright (c) 2014年 shaohua.hu. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kActionSheetButtonHeight 48

@class SYActionSheet;
@protocol SYActionSheetDelegate <NSObject>

- (void) actionSheetDidDismiss:(SYActionSheet *)actionSheet;

@end

@interface SYActionSheet : UIView

//@property(nonatomic, readonly) NSArray* actionButtons;
@property(nonatomic, weak) id<SYActionSheetDelegate> delegate;

- (id) initWithTitle:(NSString *)title;

- (id) initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles;

- (void) showInView:(UIView *)view;

- (void) dismiss;

- (UIView *) actionGroupView;

- (UIButton *) buttonAtIndex:(NSInteger)index;

@end
