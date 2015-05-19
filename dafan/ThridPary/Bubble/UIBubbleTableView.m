//
//  UIBubbleTableView.m
//
//  Created by Alex Barinov
//  Project home page: http://alexbarinov.github.com/UIBubbleTableView/
//
//  This work is licensed under the Creative Commons Attribution-ShareAlike 3.0 Unported License.
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/3.0/
//

#import "UIBubbleTableView.h"
#import "SYConstDefine.h"
#import "NSBubbleData.h"
#import "UIBubbleHeaderTableViewCell.h"
#import "UIBubbleTypingTableViewCell.h"

@interface UIBubbleTableView ()

@property (nonatomic, retain) NSMutableArray *bubbleSection;
@property(nonatomic, strong) NSMutableArray* sectionTitles;

@end

@implementation UIBubbleTableView

@synthesize bubbleDataSource = _bubbleDataSource;
@synthesize snapInterval = _snapInterval;
@synthesize bubbleSection = _bubbleSection;
@synthesize typingBubble = _typingBubble;
@synthesize showAvatars = _showAvatars;

#pragma mark - Initializators

- (void)initializator
{
    // UITableView properties
    
    self.backgroundColor = [UIColor clearColor];
    self.separatorStyle = UITableViewCellSeparatorStyleNone;
    assert(self.style == UITableViewStylePlain);
    
    self.delegate = self;
    self.dataSource = self;
    
    // UIBubbleTableView default properties
    
    self.snapInterval = 120;
    self.typingBubble = NSBubbleTypingTypeNobody;
}

- (id)init
{
    self = [super init];
    if (self) [self initializator];
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) [self initializator];
    return self;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) [self initializator];
    return self;
}

#if !__has_feature(objc_arc)
- (void)dealloc
{
    [_bubbleSection release];
	_bubbleSection = nil;
	_bubbleDataSource = nil;
    [super dealloc];
}
#endif

#pragma mark - Override

- (void)reloadData
{
//    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    
    // Cleaning up
	self.bubbleSection = nil;
    
    // Loading new data
    int count = 0;
#if !__has_feature(objc_arc)
    self.bubbleSection = [[[NSMutableArray alloc] init] autorelease];
#else
    self.bubbleSection = [[NSMutableArray alloc] init];
#endif
    
    self.sectionTitles = [NSMutableArray array];
    
    if (self.bubbleDataSource && (count = [self.bubbleDataSource rowsForBubbleTable:self]) > 0)
    {
#if !__has_feature(objc_arc)
        NSMutableArray *bubbleData = [[[NSMutableArray alloc] initWithCapacity:count] autorelease];
#else
        NSMutableArray *bubbleData = [[NSMutableArray alloc] initWithCapacity:count];
#endif
        
        for (int i = 0; i < count; i++)
        {
            NSObject *object = [self.bubbleDataSource bubbleTableView:self dataForRow:i];
            assert([object isKindOfClass:[NSBubbleData class]]);
            [bubbleData addObject:object];
        }
        
        [bubbleData sortUsingComparator:^NSComparisonResult(id obj1, id obj2)
         {
             NSBubbleData *bubbleData1 = (NSBubbleData *)obj1;
             NSBubbleData *bubbleData2 = (NSBubbleData *)obj2;
             
             return [bubbleData1.date compare:bubbleData2.date];            
         }];
        
        NSDate *last = [NSDate dateWithTimeIntervalSince1970:0];
        NSMutableArray *currentSection = nil;
        
        NSDateFormatter* formater = [[NSDateFormatter alloc] init];
        formater.dateFormat = @"MM-dd HH:mm";
        
        NSString* lastDaySectionTitle = nil;
        
        for (int i = 0; i < count; i++)
        {
            NSBubbleData *data = (NSBubbleData *)[bubbleData objectAtIndex:i];
            
            if ([data.date timeIntervalSinceDate:last] > self.snapInterval)
            {
#if !__has_feature(objc_arc)
                currentSection = [[[NSMutableArray alloc] init] autorelease];
#else
                currentSection = [[NSMutableArray alloc] init];
#endif
                [self.bubbleSection addObject:currentSection];
                
//                NSString* lastSectionTitle = self.sectionTitles.lastObject;
                NSString* curSectionTitle = [formater stringFromDate:data.date];
                if ([[lastDaySectionTitle substringToIndex:5] isEqualToString:[curSectionTitle substringToIndex:5]]) //day相同
                {
                    curSectionTitle = [curSectionTitle substringFromIndex:6];
                }
                else
                {
                    lastDaySectionTitle = curSectionTitle;
                }
                [self.sectionTitles addObject:curSectionTitle];
                
            }
            
            [currentSection addObject:data];
            last = data.date;
        }
    }
    
    [super reloadData];
}

#pragma mark - UITableViewDelegate implementation

#pragma mark - UITableViewDataSource implementation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
	
	[self.bubbleDelegate bubbleTableViewDidScroll:self];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[self.bubbleDelegate bubbleTableViewDidEndDragging:self willDecelerate:decelerate];
}



- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self.bubbleDelegate bubbleViewDidEndDecelerating:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int result = [self.bubbleSection count];
    if (self.typingBubble != NSBubbleTypingTypeNobody) result++;
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // This is for now typing bubble
	if (section >= [self.bubbleSection count]) return 1;
    
    return [[self.bubbleSection objectAtIndex:section] count] + 1;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        return MAX([UIBubbleTypingTableViewCell height], self.showAvatars ? 44 : 0);
    }
    
    // Header
    if (indexPath.row == 0)
    {
        return [UIBubbleHeaderTableViewCell height];
    }
    
    NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    return MAX(data.insets.top + data.view.frame.size.height + data.insets.bottom + 16, self.showAvatars ? 44 : 0);
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%@",indexPath);
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Now typing
	if (indexPath.section >= [self.bubbleSection count])
    {
        static NSString *typeingCellId = @"tblBubbleTypingCell";
        UIBubbleTypingTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:typeingCellId];
        
        if (cell == nil) cell = [[UIBubbleTypingTableViewCell alloc] init];

        cell.type = self.typingBubble;
        cell.showAvatar = self.showAvatars;
        
        return cell;
    }

    // Header with date and time
    if (indexPath.row == 0)
    {
        static NSString *headerCellId = @"tblBubbleHeaderCell";
        UIBubbleHeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:headerCellId];
//        NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:0];
        
        
        if (cell == nil) cell = [[UIBubbleHeaderTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:headerCellId];

        cell.dateString = [self.sectionTitles objectAtIndex:indexPath.section];
       
        return cell;
    }
    
    // Standard bubble    
    static NSString *cellId = @"tblBubbleCell";
    UIBubbleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    NSBubbleData *data = [[self.bubbleSection objectAtIndex:indexPath.section] objectAtIndex:indexPath.row - 1];
    if (cell == nil)
    {
        cell = [[UIBubbleTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        
        cell.avatarImage.userInteractionEnabled = YES;
        if (self.bubbleDelegate != nil)
        {
            UITapGestureRecognizer* tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnAvatarImage:)];
            [cell.avatarImage addGestureRecognizer:tap];
        }
    }
    
    cell.avatarImage.tag = data.type;
    
    cell.data = data;
    cell.showAvatar = self.showAvatars;
    
    return cell;
}

- (void) tapOnAvatarImage:(UIGestureRecognizer *)gesture
{
    if ([self.bubbleDelegate respondsToSelector:@selector(avatarView:tappedForBubbleTableView:)])
    {
        [self.bubbleDelegate avatarView:gesture.view.tag tappedForBubbleTableView:self];
    }
}

#pragma mark - Public interface

- (void) scrollBubbleViewToBottomAnimated:(BOOL)animated
{
    NSInteger lastSectionIdx = [self numberOfSections] - 1;
    
    if (lastSectionIdx >= 0)
    {
    	[self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self numberOfRowsInSection:lastSectionIdx] - 1) inSection:lastSectionIdx] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}


@end
