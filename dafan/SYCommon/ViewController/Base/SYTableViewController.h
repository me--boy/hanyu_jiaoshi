//
//  SYTableViewController.h.h
//  MY
//
//  Created by iMac on 14-4-3.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYBaseContentViewController.h"

#define kDefaultTableRowHeight 56

@interface SYTableViewController : SYBaseContentViewController<UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, readonly) UITableView* tableView;

//

- (void) setClickToFetchMoreTableFooterView;

- (NSString *) emptyFooterTitle; //无数据时显示
- (NSString *)normalFooterTitle;

- (void) setTableFooterStauts:(BOOL)haveNext empty:(BOOL)empty; //获取到数据时显示

- (void) requestMoreDataForTableFooterClicked; //被点击时，实现获取更多数据

- (UITableViewStyle) tableViewStyle;


@end
