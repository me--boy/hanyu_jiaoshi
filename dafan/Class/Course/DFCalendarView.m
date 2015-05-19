//
//  DFCalendarView.m
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCalendarView.h"
#import "SYPrompt.h"
#import "DFCalendarEvent.h"
#import "SYConstDefine.h"
#import "UIImage+SYExtension.h"
#import "UIView+SYShape.h"

@interface DFCalendarItemButton : UIButton

@property(nonatomic, strong) NSString* dateText;
@property(nonatomic, strong) NSDate* date;

@property(nonatomic, strong) DFCalendarEvent* event;

@property(nonatomic, strong) UILabel* eventLabel;

@end

#define kCalendarEventHeight 12
#define kCalendarTextColor RGBCOLOR(171, 187, 200)
#define kCalendarTextSize 10.f

@implementation DFCalendarItemButton
/**
 *  底部事件标签
 */
- (void) addSubviewEventLabel
{
    self.eventLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height - kCalendarEventHeight, self.frame.size.width, kCalendarEventHeight)];
    self.eventLabel.backgroundColor = [UIColor clearColor];
    self.eventLabel.font = [UIFont systemFontOfSize:kCalendarTextSize];
    self.eventLabel.textColor = kCalendarTextColor;
    self.eventLabel.adjustsFontSizeToFitWidth = YES;
    self.eventLabel.minimumScaleFactor = 0.5;
    self.eventLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.eventLabel];
}
/**
 *  设置事件
 */
- (void) setEvent:(DFCalendarEvent *)event
{
    if (_event != event)
    {
        _event = event;
        
        if (event.event.length > 0)
        {
            if (self.eventLabel == nil)
            {
                [self addSubviewEventLabel];
            }
            self.eventLabel.text = event.event;
        }
        else
        {
            [self.eventLabel removeFromSuperview];
            self.eventLabel = nil;
        }
    }
}

@end

//#define kCalendarItemSize 44.f

#define kCalendarColumnCount 7
#define kCalendarRowCount 7
#define kCalendarOriginX 6.f
#define kLineColor RGBCOLOR(171, 187, 200)

@interface DFCalendarView ()

@property(nonatomic, strong) NSMutableDictionary* calendarButtons;
/**
 *  每个日期的 宽度和高度
 */
@property(nonatomic) CGFloat dayButtonSize;

@property(nonatomic, strong) NSMutableDictionary* eventDictionary;//yyyy-MM-dd : event

//@property(nonatomic, strong) DFCalendarItemButton* movingButton;
/**
 *  选中的按钮
 */
@property(nonatomic, strong) DFCalendarItemButton* selectedButton;

@property(nonatomic) CGRect touchDownButtonOriginFrame;

@property(nonatomic, strong) UIView* movingMaskView;

@property(nonatomic, strong) NSMutableArray* selectedDates;

@property(nonatomic, strong) UIView* firstLine;
/**
 *  日历的模式
 */
@property(nonatomic) DFCalendarMode mode;
/**
 *  第一堂课时间
 */
@property(nonatomic, strong) NSDate* firstEventDate;
/**
 *  最后一堂课的时间
 */
@property(nonatomic, strong) NSDate* lastEventDate;


@end

@implementation DFCalendarView

- (id)initWithFrame:(CGRect)frame mode:(DFCalendarMode)mode
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.dayButtonSize = (self.frame.size.width - 2 * kCalendarOriginX) / kCalendarColumnCount;
        self.mode = mode;
        self.eventDictionary = [NSMutableDictionary dictionary];
        self.selectedDates = [NSMutableArray array];
    }
    return self;
}

- (void) setEvents:(NSArray *)events
{
    if (_events != events)
    {
        _events = events;
        
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        
        self.firstEventDate = [(DFCalendarEvent *)events.firstObject date];
        self.lastEventDate = [(DFCalendarEvent *)events.lastObject date];
        
        for (DFCalendarEvent* event in events)
        {
            NSString* dateText = [dateFormatter stringFromDate:event.date];
            [self.eventDictionary setObject:event forKey:dateText];
        }
    }
}

#define kMaskSizeThanButton 4.f

- (CGFloat) drawDaysFromOriginY:(CGFloat)pointY
{
    [self addCalendarHeaderButtonsAtOriginY:pointY];
    
    NSDate* currrentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    if (self.firstEventDate == nil)
    {
        self.firstEventDate = currrentDate;
    }
    
    NSDateComponents* todayComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitWeekOfYear) fromDate:currrentDate];
    NSInteger currentYear = todayComponents.year;
    NSInteger currentDay = todayComponents.day;
    NSInteger currentMonth = todayComponents.month;
    NSInteger currentWeek = todayComponents.weekOfYear;
    
    NSInteger beginYear = 0;
    NSInteger beginWeek = 0;
    //取出第一堂课所在的 年 和 该年的第几周
    NSDateComponents* firstEventDateComponents = [calendar components:(NSCalendarUnitYear | NSCalendarUnitWeekOfYear) fromDate:self.firstEventDate];
    NSInteger firstYear = firstEventDateComponents.year;
    NSInteger firstWeek = firstEventDateComponents.weekOfYear;
    
    if ([self.firstEventDate earlierDate:currrentDate] == self.firstEventDate)
    {//第一堂课在今天之前，以第一堂课所在的周为第一周
        beginYear = firstYear;
        beginWeek = firstWeek;
    }
    else
    {
        beginYear = currentYear;
        beginWeek = currentWeek;
    }
    //开始的日期
    NSDateComponents* beginMondayComponent = [[NSDateComponents alloc] init];
    beginMondayComponent.weekday = 1;
    beginMondayComponent.weekOfYear = beginWeek;
    beginMondayComponent.year = beginYear;
    
    NSDate* beginMondayDate = [calendar dateFromComponents:beginMondayComponent];
    //设置日期格式
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    
    self.calendarButtons = [NSMutableDictionary dictionary];
    
    NSInteger dayIdx = 0;
    CGFloat originX = kCalendarOriginX;
    CGFloat originY = pointY + self.dayButtonSize;
    
    for (NSInteger row = 0; row < kCalendarRowCount; ++row)
    {
        originY = pointY + (1 + row) * self.dayButtonSize;
        
        for (NSInteger column = 0; column < kCalendarColumnCount; ++column)
        {
            NSDateComponents* components = [[NSDateComponents alloc] init];
            components.day = dayIdx++;
            //在beginMondayDate的日期上面 递加时间
            NSDate* date = [calendar dateByAddingComponents:components toDate:beginMondayDate options:0];
            
            NSString* dateText = [dateFormatter stringFromDate:date];
            
            NSDateComponents* dayComponents = [calendar components:NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
            NSInteger day = dayComponents.day;
//            NSInteger week = dayComponents.weekOfYear;
            NSInteger month = dayComponents.month;
            NSInteger year = dayComponents.year;
            NSString* text = @"";
            BOOL isToday = NO;
            if (day == currentDay && month == currentMonth)
            {
                isToday = YES;
                text = @"今天";
            }
            else if (day == 1)
            {
                if (month == 1)
                {
                    text = [NSString stringWithFormat:@"%d年", year];
                }
                else
                {
                    text = [NSString stringWithFormat:@"%d月", month];
                }
            }
            else
            {
                text = [NSString stringWithFormat:@"%d", day];
            }
            
            originX = kCalendarOriginX + column * self.dayButtonSize;
            
            DFCalendarItemButton* button = [self calendarItemButtonWithText:text origin:CGPointMake(originX, originY)];
            button.userInteractionEnabled = YES;
            button.dateText = dateText;
            button.date = date;
            button.event = [self.eventDictionary objectForKey:dateText];
            
            if (year < currentYear ||(year == currentYear && month < currentMonth) || (year == currentYear && month == currentMonth && day <= currentDay))
            {//在今天以前按钮应设置不可点击状态
                button.userInteractionEnabled = NO;
                if (button.event.event != nil)
                {
                    button.enabled = NO;
//                    if (!isToday)
//                    {
//                        button.enabled = NO;
//                    }
//                    else
//                    {
//                        button.selected = YES;
//                    }
                }
            }
            else if (button.event.event != nil)
            {
                button.selected = YES;
            }
            
            switch (self.mode) {
                case DFCalendarModeNew:
                    [button addTarget:self action:@selector(calendarItemButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                    break;
                case DFCalendarModeEdit:
                    if (button.selected)
                    {//添加拖拽
                        [self addDragEventsForButton:button];
                    }
                    break;
                case DFCalendarModeRead:
                    button.userInteractionEnabled = NO;
                    break;
                default:
                    break;
            }
            
            button.tag = row * kCalendarColumnCount + column;
            [self addSubview:button];
            [self.calendarButtons setObject:button forKey:dateText];
        }
    }
    //添加每行的分割线
    for (NSInteger row = 0; row < kCalendarRowCount + 1; ++row)
    {
        [self addCalenarLinesAtOriginY:pointY + row * self.dayButtonSize];
    }
    //最后一行
    [self addCalenarLinesAtOriginY:pointY + (kCalendarRowCount + 1) * self.dayButtonSize];
    //添加每列的分割线
    for (NSInteger column = 0; column < kCalendarColumnCount; ++column)
    {
        [self addCalenarLinesAtOriginX:kCalendarOriginX + column * self.dayButtonSize fromOriginY:pointY];
    }
    //最后一列
    [self addCalenarLinesAtOriginX:kCalendarOriginX + kCalendarColumnCount * self.dayButtonSize fromOriginY:pointY];
    
//    self.contentSize = CGSizeMake(self.frame.size.width, self.contentY + (kCalendarRowCount + 1) * kCalendarItemSize + 4);
    
    if (self.mode == DFCalendarModeEdit)
    {
        self.movingMaskView = [[UIView alloc] initWithFrame:CGRectMake(-kMaskSizeThanButton, -kMaskSizeThanButton, self.dayButtonSize + 2 * kMaskSizeThanButton, self.dayButtonSize + 2 * kMaskSizeThanButton)];
        self.movingMaskView.backgroundColor = RGBCOLOR(0xff, 0xcd, 0xd8);
        [self.movingMaskView setBorderColor:self.movingMaskView.layer color:[UIColor blueColor]];
    }
    
    return pointY + (kCalendarRowCount + 1) * self.dayButtonSize + 4;
}

- (void) setItemDisabledForEditMode
{
    for (UIButton* button in self.calendarButtons.allValues)
    {
        button.userInteractionEnabled = NO;
    }
}
/**
 *  添加target
 */
- (void) addDragEventsForButton:(UIButton *)button
{
    [button addTarget:self action:@selector(calendarItemButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(calendarItemButtonDraged:event:) forControlEvents:UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(calendarItemButtonDragEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpInside];
}
/**
 *  移除targets
 */
- (void) removeDragEventsForButton:(UIButton *)button
{
    [button removeTarget:self action:@selector(calendarItemButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [button removeTarget:self action:@selector(calendarItemButtonDraged:event:) forControlEvents:UIControlEventTouchDragInside];
    [button removeTarget:self action:@selector(calendarItemButtonDragEnd:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpInside];
}

- (void) calendarItemButtonClicked:(DFCalendarItemButton *)sender
{
    if (sender.selected)
    {
        sender.selected = NO;
        [self.selectedDates removeObject:sender.date];
    }
    else
    {
        if (self.selectedDates.count >= self.eventCountForNew)
        {
            [SYPrompt showWithText:[NSString stringWithFormat:@"最多只能选择%d天", self.eventCountForNew] inView:self];
            return;
        }
        sender.selected = YES;
        [self.selectedDates addObject:sender.date];
    }
}

- (NSArray *) newDates
{
    [self.selectedDates sortedArrayUsingSelector:@selector(compare:)];
    return [NSArray arrayWithArray:self.selectedDates];
}

- (NSArray *) editEvents
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSMutableArray* array = [NSMutableArray array];
    for (DFCalendarItemButton* button in self.calendarButtons.allValues)
    {
        if (button.selected)
        {
            DFCalendarEvent* event = button.event;
            NSString* dateText = [formatter stringFromDate:event.date];
            if (![dateText isEqualToString:button.dateText])
            {
                event.date = button.date;
                [array addObject:event];
            }
        }
    }
    return array;
}

- (void) logSizes
{
    NSLog(@"%f, %f; %f, %f", self.frame.size.width, self.frame.size.height, self.contentSize.width, self.contentSize.height);
}
/**
 *  按钮按下事件处理
 */
- (void) calendarItemButtonTouchDown:(DFCalendarItemButton *)sender
{
    [self logSizes];
    [self insertSubview:sender belowSubview:self.firstLine];
    self.touchDownButtonOriginFrame = sender.frame;
    //使maskView作为按钮按钮的子视图
    [sender insertSubview:self.movingMaskView atIndex:0];
}
/**
 *  使按钮随着手指移动
 */
- (void) calendarItemButtonDraged:(DFCalendarItemButton *)sender event:(UIEvent *)event
{
    UITouch* touch = [[event touchesForView:sender] anyObject];
    
    CGPoint previousLocation = [touch previousLocationInView:sender];
    CGPoint location = [touch locationInView:sender];
    
    CGFloat deltaX = location.x - previousLocation.x;
    CGFloat deltaY = location.y - previousLocation.y;
    
    sender.center = CGPointMake(sender.center.x + deltaX, sender.center.y + deltaY);
}
/**
 *  拖拽结束
 */
- (void) calendarItemButtonDragEnd:(DFCalendarItemButton *)button
{
    DFCalendarItemButton* destButton = [self destbuttonWithMovingButton:button];
    if (destButton == nil)
    {
        [UIView animateWithDuration:0.2 animations:^{
            button.frame = self.touchDownButtonOriginFrame;
        } completion:^(BOOL finished){
            [self.movingMaskView removeFromSuperview];
        }];
    }
    else
    {
        if (destButton.selected)//表示两堂课之间交换
        {
            [UIView animateWithDuration:0.2 animations:^{
                button.frame = destButton.frame;
            } completion:^(BOOL finished){
                
                [self.movingMaskView removeFromSuperview];
                button.frame = self.touchDownButtonOriginFrame;
                
                DFCalendarEvent* destEvent = destButton.event;
                DFCalendarEvent* originEvent = button.event;
                destButton.event = originEvent;
                button.event = destEvent;
            }];
        }
        else//某堂课和某普通的一天的交换
        {
            [UIView animateWithDuration:0.2 animations:^{
                button.frame = destButton.frame;
            } completion:^(BOOL finished){
                
                destButton.event = button.event;
                destButton.selected = YES;
                [self addDragEventsForButton:destButton];
                
                [self.movingMaskView removeFromSuperview];
                button.frame = self.touchDownButtonOriginFrame;
                button.selected = NO;
                button.event = nil;
                [self removeDragEventsForButton:button];
            }];
        }
    }
}
/**
 *  找到目标的button
 *
 *  @param movingButton 移动的button
 */
- (DFCalendarItemButton *) destbuttonWithMovingButton:(UIButton *)movingButton
{
    for (DFCalendarItemButton* button in self.calendarButtons.allValues)
    {
        if (button != movingButton && CGRectContainsPoint(button.frame, movingButton.center))
        {
            if (button.userInteractionEnabled && button.enabled)
            {
                return button;
            }
            else
            {
                break;
            }
        }
    }
    return nil;
}
/**
 *  添加在水平方向的分割线
 */
- (void) addCalenarLinesAtOriginY:(CGFloat)originY
{
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(kCalendarOriginX, originY, kCalendarColumnCount * self.dayButtonSize, 0.5)];
    lineView.backgroundColor = kLineColor;
    [self addSubview:lineView];
    
    if (self.firstLine == nil)
    {
        self.firstLine = lineView;
    }
}
/**
 *  添加在竖直方向的分割线
 */
- (void) addCalenarLinesAtOriginX:(CGFloat)originX fromOriginY:(CGFloat)originY
{
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(originX, originY, 0.5, (kCalendarRowCount + 1) * self.dayButtonSize)];//加1是因为在竖直的方向上面多了周日到周六一行
    lineView.backgroundColor = kLineColor;
    [self addSubview:lineView];
}
/**
 *  添加首列的 周日 至 周六
 */
- (void) addCalendarHeaderButtonsAtOriginY:(CGFloat)originY
{
    UIButton* sundayButton = [self calendarItemButtonWithText:@"周日" origin:CGPointMake(kCalendarOriginX, originY)];
    [self addSubview:sundayButton];
    
    UIButton* mondayButton = [self calendarItemButtonWithText:@"周一" origin:CGPointMake(kCalendarOriginX + self.dayButtonSize, originY)];
    [self addSubview:mondayButton];
    
    UIButton* tuesdayButton = [self calendarItemButtonWithText:@"周二" origin:CGPointMake(kCalendarOriginX + 2 * self.dayButtonSize, originY)];
    [self addSubview:tuesdayButton];
    
    UIButton* wedsnedayButton = [self calendarItemButtonWithText:@"周三" origin:CGPointMake(kCalendarOriginX + 3 * self.dayButtonSize, originY)];
    [self addSubview:wedsnedayButton];
    
    UIButton* thursdayButton = [self calendarItemButtonWithText:@"周四" origin:CGPointMake(kCalendarOriginX + 4 * self.dayButtonSize, originY)];
    [self addSubview:thursdayButton];
    
    UIButton* fridayButton = [self calendarItemButtonWithText:@"周五" origin:CGPointMake(kCalendarOriginX + 5 * self.dayButtonSize, originY)];
    [self addSubview:fridayButton];
    
    UIButton* saturdayButton = [self calendarItemButtonWithText:@"周六" origin:CGPointMake(kCalendarOriginX + 6 * self.dayButtonSize, originY)];
    [self addSubview:saturdayButton];
}
/**
 *  快速创建一个button
 */
- (DFCalendarItemButton *) calendarItemButtonWithText:(NSString *)text origin:(CGPoint)point
{
    DFCalendarItemButton* button = [[DFCalendarItemButton alloc] initWithFrame:CGRectMake(point.x, point.y, self.dayButtonSize, self.dayButtonSize)];
    button.userInteractionEnabled = NO;
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:text forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:12];
    [button setTitleColor:kCalendarTextColor forState:UIControlStateNormal];
    
    [button setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(1, 1)] forState:UIControlStateNormal];
//    [button setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(0xca, 0xc9, 0xc7) size:CGSizeMake(1, 1)] forState:UIControlStateDisabled];
    [button setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(0xea, 0xe9, 0xe7) size:CGSizeMake(1, 1)] forState:UIControlStateDisabled];
    [button setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(0xd0, 0xed, 0xf8) size:CGSizeMake(1, 1)] forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageWithColor:RGBCOLOR(0xd0, 0xed, 0xf8) size:CGSizeMake(1, 1)] forState:UIControlStateHighlighted];
    return button;
}

@end
