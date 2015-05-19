//
//  SYContextMenu.m
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYContextMenu.h"
#import "DFColorDefine.h"
#import "UIView+SYShape.h"
#import "SYDeviceDescription.h"

@implementation SYContextMenuItem

+ (SYContextMenuItem *) contextMenuItemWithID:(NSInteger)menuId title:(NSString *)title
{
    SYContextMenuItem* item = [[SYContextMenuItem alloc] init];
    item.menuId = menuId;
    item.menutitle = title;
    return item;
}

@end

@interface SYContextMenuCell : UITableViewCell


@end

@implementation SYContextMenuCell

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    self.textLabel.frame = self.bounds;
}

@end

@interface SYContextMenu ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIView* contentView;

@property(nonatomic, strong) UITableView* tableView;
@property(nonatomic, strong) NSArray* menuItems;
@property(nonatomic, strong) NSString* title;

@end


#define kMenuHeight 48.f
#define kHeaderHeight kMenuHeight

#define kMaxMenuItemCount 3
#define kTopBorderWidth 4.f

#define kFooterButtonHeight kMenuHeight
#define kFooterHeight 64.f


@implementation SYContextMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithTitle:(NSString *)title menuItems:(NSArray *)menuItems
{
    self = [super init];
    if (self)
    {
        self.title = title;
        self.menuItems = menuItems;
    }
    return self;
}

- (void) showInView:(UIView *)view
{
    self.frame = view.bounds;
    [view addSubview:self];
    
    if (self.contentView == nil)
    {
        [self initSubviews];
    }
    
    typeof(self) __weak bself = self;
    CGRect frame = self.contentView.frame;
    frame.origin.y = self.frame.size.height - frame.size.height;
    [UIView animateWithDuration:0.3 animations:^{
        bself.contentView.frame = frame;
    }];
}

- (void) initSubviews
{
    CGFloat tableHeight = 0;
    
    UILabel* titleLabel = nil;
    if (self.title.length > 0)
    {
        tableHeight += kHeaderHeight;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kHeaderHeight)];
        titleLabel.text = self.title;
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.backgroundColor = [UIColor whiteColor];
        [titleLabel setBorderInteraction:MYBorderInteractionBottom withColor:RGBCOLOR(212, 212, 212)];
    }
    if (self.menuItems.count >= kMaxMenuItemCount)
    {
        tableHeight += kMaxMenuItemCount * kMenuHeight;
    }
    else
    {
        tableHeight += self.menuItems.count * kMenuHeight;
    }

    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kTopBorderWidth, self.frame.size.width, tableHeight - kTopBorderWidth) style:UITableViewStylePlain];
    self.tableView.separatorColor = RGBCOLOR(212, 212, 212);
    self.tableView.tableHeaderView = titleLabel;
    self.tableView.rowHeight = kMenuHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    if (self.menuItems.count <= kMaxMenuItemCount)
    {
        self.tableView.bounces = NO;
    }
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, tableHeight, self.frame.size.width, kFooterHeight)];
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(0, kFooterHeight - kFooterButtonHeight, self.frame.size.width, kFooterButtonHeight)];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:cancelButton];
    
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height, self.frame.size.width, tableHeight + kFooterHeight)];
    [self.contentView setBorderInteraction:MYBorderInteractionTop withColor:kMainDarkColor width:kTopBorderWidth];
    self.contentView.backgroundColor = RGBCOLOR(243, 243, 243);
    [self addSubview:self.contentView];
    
    [self.contentView addSubview:self.tableView];
    [self.contentView addSubview:footerView];
}

- (void) cancelButtonClicked:(id)sender
{
    [self dismiss];
}

- (void) dismiss
{
    typeof(self) __weak bself = self;
    CGSize size = self.frame.size;
    [UIView animateWithDuration:0.3 animations:^{
        bself.contentView.frame = CGRectMake(0, size.height, size.width, bself.contentView.frame.size.height);
        
    } completion:^(BOOL finished){
        
        [bself.delegate contextMenuDidDismiss:bself];
        
        [bself removeFromSuperview];
    }];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYContextMenuCell* cell = (SYContextMenuCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[SYContextMenuCell alloc] initWithReuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = RGBCOLOR(51, 51, 51);
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    SYContextMenuItem* item = [self.menuItems objectAtIndex:indexPath.row];
    cell.textLabel.text = item.menutitle;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    SYContextMenuItem* item = [self.menuItems objectAtIndex:indexPath.row];
    
    [self.delegate contextMenu:self selectItem:item];
    
    [self dismiss];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    if (point.y < self.contentView.frame.origin.y)
    {
        [self dismiss];
    }
    
}

@end
