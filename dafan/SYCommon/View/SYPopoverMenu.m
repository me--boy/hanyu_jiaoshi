//
//  SYPopoverMenu.m
//  dafan
//
//  Created by iMac on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYPopoverMenu.h"

@implementation SYPopoverMenuItem

@end

@interface SYPopoverMenuCell : UITableViewCell

@end

#define kImageSize 19.f
#define kPaddingH 9.f

@implementation SYPopoverMenuCell

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
//    if (self.imageView.image != nil)
//    {
//        self.imageView.frame = CGRectMake(kPaddingH, (size.height - kImageSize) / 2, kImageSize, kImageSize);
//    }
//    else
    {
        self.imageView.frame = CGRectMake(kPaddingH, (size.height - kImageSize) / 2, kImageSize, kImageSize);
    }
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x = self.imageView.frame.origin.x + self.imageView.frame.size.width + 5;
    textFrame.size.width = size.width - kPaddingH - textFrame.origin.x;
    self.textLabel.frame = textFrame;
    
}

@end

@interface SYPopoverMenu () <UITableViewDataSource, UITableViewDelegate>

@property(nonatomic, strong) NSArray* menuItems;

@property(nonatomic, strong) UITableView* tableView;

@end

// 12,6   10 25

#define kTableViewRowHeight 37.f
#define kTableViewWidth 149.f

#define kTableViewPaddingTop 12.f
#define kTableViewPaddingBottom 6.f

@implementation SYPopoverMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithMenuItems:(NSArray *)menuItems
{
    self = [self initWithFrame:[UIScreen mainScreen].bounds];
    if (self)
    {
        self.menuItems = menuItems;
        
        [self initSubviews];
    }
    return self;
}

- (void) popDownAnimated
{
    [self.tableView.layer removeAnimationForKey:@"hide"];
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    anim.duration = 0.3f;
    anim.fromValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
    anim.toValue = [NSValue valueWithCGRect:self.tableView.bounds];
//    anim.byValue  = [NSValue valueWithCGRect:self.tableView.bounds];
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.repeatCount = 1;
    anim.autoreverses = NO;
    
    [self.tableView.layer addAnimation:anim forKey:@"show"];
}

- (void) hideAnimated
{
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"bounds"];
    anim.duration = 0.3f;
    anim.fromValue = [NSValue valueWithCGRect:self.tableView.bounds];
    anim.toValue = [NSValue valueWithCGRect:CGRectMake(0, 0, self.tableView.frame.size.width, 0)];
//    anim.byValue  = [NSValue valueWithCGRect:self.tableView.bounds];
    anim.removedOnCompletion = NO;
    anim.fillMode = kCAFillModeForwards;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    anim.repeatCount = 1;
    anim.delegate = self;
    anim.autoreverses = NO;
    
    [self.tableView.layer addAnimation:anim forKey:@"hide"];
}

- (void) showFromView:(UIView *)view
{
    UIWindow* keyWindow = [UIApplication sharedApplication].keyWindow;
    
    [keyWindow addSubview:self];
    
    CGPoint point = [view convertPoint:CGPointMake(view.frame.size.width / 2, view.frame.size.height) toView:keyWindow];
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.origin.x = point.x - 126.f;
    tableFrame.origin.y = point.y - 7;
    self.tableView.frame = tableFrame;
    
    [self popDownAnimated];
}

- (void) initSubviews
{
    CGFloat height = self.menuItems.count * kTableViewRowHeight + kTableViewPaddingBottom + kTableViewPaddingTop;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kTableViewWidth, height) style:UITableViewStylePlain];
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.bounces = NO;
    self.tableView.rowHeight = kTableViewRowHeight;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self addSubview:self.tableView];
    
     self.tableView.layer.anchorPoint = CGPointMake(0.91f, 0.f);
    
    self.tableView.contentInset = UIEdgeInsetsMake(kTableViewPaddingTop, 0, kTableViewPaddingBottom, 0);
    
    UIImage* image = [[UIImage imageNamed:@"pop_down_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(40, 20, 20, 44) resizingMode:UIImageResizingModeStretch];
    UIImageView* backgroundImageView = [[UIImageView alloc] initWithImage:image];
    backgroundImageView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = backgroundImageView;
}

#pragma mark - 

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SYPopoverMenuCell* cell = [self.tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[SYPopoverMenuCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
    }
    
    SYPopoverMenuItem* item = [self.menuItems objectAtIndex:indexPath.row];
    
    cell.imageView.image = item.image;
    cell.textLabel.text = item.title;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate popoverMenu:self select:indexPath.row];
    
    [self hideAnimated];
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.tableView.frame, point))
    {
        [super touchesBegan:touches withEvent:event];
    }
    else
    {
        [self hideAnimated];
    }
}

- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    self.tableView.frame = CGRectMake(0, 0, 0, 0);
//    [self.tableView removeFromSuperview];
    [self removeFromSuperview];
}


@end
