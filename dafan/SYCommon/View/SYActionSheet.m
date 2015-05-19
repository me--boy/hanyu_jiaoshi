//
//  MYActionSheet.m
//  MY
//
//  Created by iMac on 14-5-26.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYActionSheet.h"
#import "UIView+SYShape.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"

@interface SYActionSheet ()

@property(nonatomic, strong) NSString* actionTitle;

@property(nonatomic, strong) NSString* message;
@property(nonatomic, strong) NSArray* buttonTitles;

@property(nonatomic, strong) NSMutableArray* actionButtons;

@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UIButton* cancelButton;
@property(nonatomic, strong) UIView* contentView;
@property(nonatomic, strong) UIView* actionContainerView; //同method actionGroupView

@end

//#define kPadding 20

@implementation SYActionSheet

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithTitle:(NSString *)title
{
    self = [super init];
    if (self)
    {
        self.actionTitle = title;
        
        [self addTapCloseGesture];
        [self initActionGropFrameView];
        [self initTitleLabel];
        [self initCancelButton];
    }
    return self;
}

- (id) initWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray *)buttonTitles
{
    self = [super init];
    if (self)
    {
        self.actionTitle = title;
        self.message = message;
        self.buttonTitles = buttonTitles;
        
        [self addTapCloseGesture];
        [self initActionGropFrameView];
        [self initTitleLabel];
        [self initCancelButton];
    }
    return self;
}

- (void) initCancelButton
{
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.backgroundColor = [UIColor whiteColor];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton addTarget:self action:@selector(cancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.cancelButton];
}

- (void) cancelButtonClicked:(id)sender
{
    [self dismiss];
}

- (void) initActionGropFrameView
{
    self.contentView = [[UIView alloc] init];
    self.contentView.backgroundColor = RGBCOLOR(243, 243, 243);
    [self addSubview:self.contentView];
    
    self.actionContainerView = [self actionGroupView];
    self.actionContainerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.actionContainerView];
}

- (void) initTitleLabel
{
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.text = self.actionTitle;
    self.titleLabel.font = [UIFont systemFontOfSize:17];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:self.titleLabel];
}

#define kTitleHeight 48
#define kTopBorderWidth 4


- (void) showInView:(UIView *)view
{
    self.frame = view.bounds;
    [view addSubview:self];
    
    CGSize size = self.frame.size;
    
    if (self.actionTitle.length > 0)
    {
        self.titleLabel.frame = CGRectMake(0, kTopBorderWidth, size.width, kTitleHeight);
    }

    CGRect actionsViewFrame = self.actionContainerView.frame;

    actionsViewFrame.origin.y = kTopBorderWidth + self.titleLabel.frame.size.height;
    self.actionContainerView.frame = actionsViewFrame;
    
    CGFloat frameViewHeight = kTopBorderWidth + self.titleLabel.frame.size.height + self.actionContainerView.frame.size.height + 4 + 4 + 50;

    self.contentView.frame = CGRectMake(0, size.height, size.width, frameViewHeight);
    [self.contentView setBorderInteraction:MYBorderInteractionTop withColor:kMainDarkColor width:kTopBorderWidth];
    
    self.cancelButton.frame = CGRectMake(0, frameViewHeight - 50, size.width, kActionSheetButtonHeight);

    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.3 animations:^{
        bself.contentView.frame = CGRectMake(0, size.height - frameViewHeight, size.width, frameViewHeight);

    }];
}

- (void) addTapCloseGesture
{
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.3];
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnMaskView:)];
    [self addGestureRecognizer:tapGesture];
}

- (void) tapOnMaskView:(UIGestureRecognizer *)gesture
{
    if ([gesture locationInView:self].y < self.contentView.frame.origin.y)
    {
        [self dismiss];
    }
}

- (void) dismiss
{
    typeof(self) __weak bself = self;
    CGSize size = self.frame.size;
    [UIView animateWithDuration:0.3 animations:^{
        bself.contentView.frame = CGRectMake(0, size.height, size.width, bself.contentView.frame.size.height);
        
    } completion:^(BOOL finished){
        
        [bself.delegate actionSheetDidDismiss:bself];
        
        [bself removeFromSuperview];
    }];
}

#define kViewWidth self.frame.size.width
#define kMessageMarginHorizontal 16

- (UIView *)actionGroupView
{
    if (self.buttonTitles.count > 0)
    {
        
        self.actionButtons = [NSMutableArray array];
        
        UIView* view = [[UIView alloc] initWithFrame:self.bounds];
        
        CGFloat originY = 8;
        if (self.message.length > 0)
        {
            UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = RGBCOLOR(51, 51, 51);
            label.font = [UIFont systemFontOfSize:14];
            label.text = self.message;
            label.numberOfLines = 0;
            [view addSubview:label];
            
            CGSize labelSize = [label sizeThatFits:CGSizeMake(kViewWidth - 2 * kMessageMarginHorizontal, 360)];
            label.frame = CGRectMake(kMessageMarginHorizontal, 0, kViewWidth - 2 * kMessageMarginHorizontal, labelSize.height);
            if (labelSize.height < label.font.lineHeight + 1)
            {
                label.textAlignment = NSTextAlignmentCenter;
            }
            
            originY += labelSize.height;
        }
        
        NSInteger count = self.buttonTitles.count;
        for (NSInteger idx = 0; idx < count; ++idx)
        {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, originY + kActionSheetButtonHeight * idx, kViewWidth, kActionSheetButtonHeight)];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitle:self.buttonTitles[idx] forState:UIControlStateNormal];
            [button setTitleColor:RGBCOLOR(51, 51, 51) forState:UIControlStateNormal];
            if (self.actionTitle.length > 0 || idx > 0)
            {
                [button setBorderInteraction:MYBorderInteractionTop withColor:RGBCOLOR(212, 212, 212)];
            }
            
            [button addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
            [view addSubview:button];
            
            [self.actionButtons addObject:button];
        }
        view.frame = CGRectMake(0, 0, kViewWidth, originY + count * kActionSheetButtonHeight);
        
        return view;
    }
    else
    {
        return [[UIView alloc] initWithFrame:CGRectZero];
    }
}

- (UIButton *) buttonAtIndex:(NSInteger)index
{
    if (index >= 0 && index < self.actionButtons.count)
    {
        return self.actionButtons[index];
    }
    
    return nil;
}



@end
