//
//  UIBubbleTableView.h
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import <UIKit/UIKit.h>

#import "UIBubbleTableViewDataSource.h"
#import "UIBubbleTableViewCell.h"

typedef enum _NSBubbleTypingType
{
    NSBubbleTypingTypeNobody = 0,
    NSBubbleTypingTypeMe = 1,
    NSBubbleTypingTypeSomebody = 2
} NSBubbleTypingType;

@class UIBubbleTableView;
@protocol MYBubbleTableViewDelegate <NSObject>

- (void) bubbleTableViewDidScroll:(UIBubbleTableView *)tableView;
- (void) bubbleTableViewDidEndDragging:(UIBubbleTableView *)scrollView willDecelerate:(BOOL)decelerate;
- (void) bubbleViewDidEndDecelerating:(UIBubbleTableView *)scrollView;

@optional
- (void) avatarView:(NSBubbleType)type tappedForBubbleTableView:(UIBubbleTableView *)bubbleTableView;

@end

@interface UIBubbleTableView : UITableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) IBOutlet id<UIBubbleTableViewDataSource> bubbleDataSource;
@property (nonatomic) NSTimeInterval snapInterval;
@property (nonatomic) NSBubbleTypingType typingBubble;
@property (nonatomic) BOOL showAvatars;

@property(nonatomic, weak) id<MYBubbleTableViewDelegate> bubbleDelegate;

- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated;

@end
