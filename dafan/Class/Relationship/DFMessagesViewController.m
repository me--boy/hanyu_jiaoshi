//
//  MYFriendsTableViewController.m
//  MY
//
//  Created by iMac on 14-4-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFMessagesViewController.h"
#import "UIImageView+WebCache.h"
#import "UIAlertView+SYExtension.h"
#import "SYConstDefine.h"
#import "SYHttpRequest.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "DFUrlDefine.h"
#import "DFNotificationDefines.h"
#import "DFFilePath.h"
#import "SYScrollPageViewController.h"
#import "DFMessageViewController.h"
#import "SYLoadingButton.h"
#import "SYTabBarController.h"
#import "DFPreference.h"
#import "DFCommonImages.h"
#import "DFUserProfile.h"
#import "DFContactMessageCell.h"
#import "DFColorDefine.h"
#import "DFUrlDefine.h"
#import "DFContactMessageItem.h"
#import "UIView+SYShape.h"
#import "DFGroupMessageCell.h"

#import "DFGroupMessageItem.h"

@interface DFMessagesViewController ()

@property(nonatomic) DFMessageStyle style;
@property(nonatomic, strong) NSMutableArray* items;
@property(nonatomic) NSInteger offsetId;
@property(nonatomic, strong) UIView* emptyView;

@end

@implementation DFMessagesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithStyle:(DFMessageStyle)style
{
    self = [super init];
    if (self)
    {
        self.style = style;
        self.items = [NSMutableArray array];
    }
    return self;
}

- (void) setUserId:(NSInteger)userId
{
    if (userId != _userId)
    {
        _userId = userId;
        
        if ([self isViewLoaded])
        {
            [self requestItems:YES];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configTableView];
    [self configCustomNavigationBar];
    [self registerObservers];
}

- (void) registerObservers
{
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    if (self.style == DFMessageStyleGroup)
    {
        [notify addObserver:self selector:@selector(preferenceUpdated:) name:kNotificationClasscircleNameUpdated object:nil];
        [notify addObserver:self selector:@selector(preferenceUpdated:) name:kNotificationClasscircleIgnoreUpdated object:nil];
        [notify addObserver:self selector:@selector(registeredCourse:) name:kNotificationRegisterCourseFinished object:nil];
        [notify addObserver:self selector:@selector(registeredCourse:) name:kNotificationRegisterCourseSucceed object:nil];
    }
}


- (void) registeredCourse:(NSNotification *)notification
{
    [self requestItems:YES];
}

- (void) preferenceUpdated:(NSNotification *)notification
{
    DFGroupMessageItem* item = notification.object;
    NSUInteger index = [self.items indexOfObject:item];
    if (index != NSNotFound)
    {
        DFGroupMessageItem* sameItem = [self.items objectAtIndex:index];
        sameItem.title = item.title;
        sameItem.ignoreNewMessage = item.ignoreNewMessage;
        [self.tableView reloadData];
    }
}

- (void) configCustomNavigationBar
{
    switch (self.style) {
        case DFMessageStyleGroup:
            self.title = @"班级圈";
            break;
        case DFMessageStyleContact:
            self.title = @"最近联系人";
        default:
            break;
    }
}

- (void) configTableView
{
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    
    [self setClickToFetchMoreTableFooterView];
    
    self.tableView.rowHeight = 75;
}

- (void) requestMoreDataForTableFooterClicked
{
    [super requestMoreDataForTableFooterClicked];
    [self requestItems:NO];
}

- (NSString *) emptyFooterTitle
{
    return @"";
}

- (void) loadData
{
    [self requestItems:YES];
}

- (void) viewDidAppearInScrollPageController
{
    [super viewDidAppearInScrollPageController];
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    switch (self.style) {
        case DFMessageStyleContact:
            user.newContactMessageCount = 0;
            [self.scrollPageController clearBadgeForTabIdx:1];
            
            if (user.needRequestContactMessages)
            {
                [self requestItems:YES];
                user.needRequestContactMessages = NO;
            }
            
            break;
        case DFMessageStyleGroup:
            user.newGroupMessageCount = 0;
            [self.scrollPageController clearBadgeForTabIdx:0];
            
            if (user.needRequestGroupMessages)
            {
                [self requestItems:YES];
                user.needRequestGroupMessages = NO;
            }
            break;
            
        default:
            break;
    }
}

- (NSString *) urlForRequestData
{
    switch (self.style) {
        case DFMessageStyleGroup:
            return [DFUrlDefine urlForClassCircles];
        case DFMessageStyleContact:
            return [DFUrlDefine urlForRecentContacts];
        default:
            break;
    }
}

- (void) reloadDataForRefresh
{
    [self requestItems:YES];
}

- (void) requestItems:(BOOL)reload
{
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:!reload ? self.offsetId : 0] forKey:@"offsetid"];
    
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[self urlForRequestData] postValues:dict finished:^(BOOL success, NSDictionary * resultInfo, NSString* errorMessage){
        
        if (reload)
        {
            [bself.items removeAllObjects];
        }
        
        if (success)
        {
            NSArray* infos = [resultInfo objectForKey:@"info"];
            [bself reloadDataWithInfos:infos];
            bself.offsetId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];
            
            if (reload)
            {
                [infos writeToFile:(self.style == DFMessageStyleGroup ? [DFFilePath homeClasscircleCacheFilePath] : [DFFilePath homeMyMessagesCacheFilePath]) atomically:YES];
            }
        }
        else
        {
            if (reload)
            {
                NSArray* infos = [NSArray arrayWithContentsOfFile:(self.style == DFMessageStyleGroup ? [DFFilePath homeClasscircleCacheFilePath] : [DFFilePath homeMyMessagesCacheFilePath])];
                [bself reloadDataWithInfos:infos];
            }
            [UIAlertView showNOPWithText:errorMessage];
            [bself setTableFooterStauts:YES empty:NO];
        }
        
        [bself hideProgress];
    }];
    [self.requests addObject:request];
}

- (void) addContactItems:(NSArray *)infos
{
    NSMutableArray* newItems = [NSMutableArray array];
    for (NSDictionary* info in infos)
    {
        DFContactMessageItem* item = [[DFContactMessageItem alloc] initWithDictionary:info];
        [newItems addObject:item];
    }
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd";
    for (DFContactMessageItem* item in newItems)
    {
        if (item.timeintervalSince1970 > 0)
        {
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:item.timeintervalSince1970];
            item.dateText = [formatter stringFromDate:date];
        }
        else
        {
            item.dateText = @"";
        }
    }
    [self.items addObjectsFromArray:newItems];
}

- (void) addGroupItems:(NSArray *)infos
{
    NSMutableArray* newItems = [NSMutableArray array];
    for (NSDictionary* info in infos)
    {
        DFGroupMessageItem* item = [[DFGroupMessageItem alloc] initWithClassCircleItemInfo:info];
        [newItems addObject:item];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM-dd";
    for (DFGroupMessageItem* item in newItems)
    {
        if (item.timeintervalSince1970 > 0)
        {
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:item.timeintervalSince1970];
            item.dateText = [formatter stringFromDate:date];
        }
        else
        {
            item.dateText = @"";
        }
    }
    [self.items addObjectsFromArray:newItems];
}

- (void) reloadDataWithInfos:(NSArray *)infos
{
    switch (self.style) {
        case DFMessageStyleContact:
            [self addContactItems:infos];
            break;
            
        default:
            [self addGroupItems:infos];
            break;
    }
    
    [self setTableFooterStauts:self.offsetId > 0 empty:self.items.count == 0];
    
    [self.tableView reloadData];
    
    if (self.items.count == 0)
    {
        [self showNoItemView];
    }
    else
    {
        [self hideNoItemView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview delegate & datasource

#define kFriendCell @"FriendCell"

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self.style) {
        case DFMessageStyleContact:
            return [self contactMessageCellForIndexPath:indexPath];

        default:
            return [self groupMessageCellForIndexPath:indexPath];
    }
}

- (DFGroupMessageCell *) groupMessageCellForIndexPath:(NSIndexPath *)indexPath
{
    DFGroupMessageCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kFriendCell];
    if (cell == nil)
    {
        cell = [[DFGroupMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFriendCell];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    DFGroupMessageItem* item = [self.items objectAtIndex:indexPath.row];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:item.adminAvatarUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
    
    [cell setUnreadCount:item.unreadCount];
    
    cell.titleLabel.text = item.title;
    
    cell.dateLabel.text = item.dateText;
    
    cell.ignoreImageView.hidden = !item.ignoreNewMessage;
    
    cell.lastMessageTextView.faceAttributedString = item.lastMessage;
    [cell.lastMessageTextView setNeedsDisplay];
    
    return cell;
}

- (DFContactMessageCell *) contactMessageCellForIndexPath:(NSIndexPath *)indexPath
{
    DFContactMessageCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kFriendCell];
    if (cell == nil)
    {
        cell = [[DFContactMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kFriendCell];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    
    DFContactMessageItem* item = [self.items objectAtIndex:indexPath.row];
    [cell.avatarImageView setImageWithURL:[NSURL URLWithString:item.avatarUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
    
    cell.nicknameLabel.text = item.nickname;
    
    cell.memberImageView.hidden = item.member != DFMemberTypeVip;
    switch (item.userRole) {
        case DFUserRoleTeacher:
            cell.verifyImageView.hidden = NO;
            cell.verifyImageView.image = [UIImage imageNamed:@"user_teacher.png"];
            break;
        case DFUserRoleStudent:
            cell.verifyImageView.hidden = NO;
            cell.verifyImageView.image = [UIImage imageNamed:@"user_student.png"];
            break;
            
        default:
            cell.verifyImageView.hidden = YES;
            break;
    }
    
    cell.genderCityLabel.text = [NSString stringWithFormat:@"%@ %@", (item.gender == SYGenderTypeMale ? @"男" : @"女"), item.city];
    [cell setUnreadCount:item.unreadCount];
    
    cell.dateLabel.text = item.dateText;
    
    cell.coreTextView.faceAttributedString = item.lastMessage;
    [cell.coreTextView setNeedsDisplay];
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (self.style) {
        case DFMessageStyleContact:
            [self selectContactAtIndexPath:indexPath];
            break;
            
        default:
            [self selectGroupAtIndexPath:indexPath];
            break;
    }
}

- (void) selectContactAtIndexPath:(NSIndexPath *)index
{
    DFContactMessageItem* item = [self.items objectAtIndex:index.row];
    
    DFMessageViewController* controller = [[DFMessageViewController alloc] initWithUserId:item.userId];
    controller.nickname = item.nickname;
    controller.avatarUrl = item.avatarUrl;
    [self.navigationController pushViewController:controller animated:YES];
    
    typeof(self) __weak bself = self;
    controller.closedBlock = ^(NSString* newMessage, NSInteger timeinteral){
        [bself updateNewMessage:newMessage userId:item.userId unread:NO];
    };
    
    item.unreadCount = 0;
    DFContactMessageCell* cell = (DFContactMessageCell *)[self.tableView cellForRowAtIndexPath:index];
    [cell setUnreadCount:0];
}

- (void) selectGroupAtIndexPath:(NSIndexPath *)index
{
    DFGroupMessageItem* item = [self.items objectAtIndex:index.row];
    
    DFMessageViewController* controller = [[DFMessageViewController alloc] initWithClassCircleId:item.persistentId];
//    controller.nickname = item.title;
//    controller.avatarUrl = item.adminAvatarUrl;
    [self.navigationController pushViewController:controller animated:YES];
    
    typeof(self) __weak bself = self;
    controller.closedBlock = ^(NSString* newMessage, NSInteger timeinteral){
        [bself updateNewMessage:newMessage classcircleId:item.persistentId unread:NO];
    };
    
    item.unreadCount = 0;
    DFGroupMessageItem* cell = (DFGroupMessageItem *)[self.tableView cellForRowAtIndexPath:index];
    [cell setUnreadCount:0];
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.style == DFMessageStyleContact;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSString *) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

#define kRegisterButtonMarginLeftRight 50

- (void) showNoItemView
{
    if (self.emptyView == nil)
    {
        self.emptyView = [[UIView alloc] initWithFrame:self.tableView.frame];
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 126) / 2, 18, 126, 126)];
        imageView.image = [UIImage imageNamed:@"default_contact_big.png"];
        [self.emptyView addSubview:imageView];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 164, self.view.frame.size.width, 48)];
        label.font = [UIFont systemFontOfSize:16];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = RGBCOLOR(155, 155, 155);
        label.numberOfLines = 0;
        if (self.style == DFMessageStyleContact)
        {
            label.text = @"还没有和任何人私聊过哦～";
        }
        else
        {
            label.text = @"报名才有班级圈哦～";
        }
        
        label.textAlignment = NSTextAlignmentCenter;
        [self.emptyView addSubview:label];
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.emptyView.frame.size.width, 126 + 48)];
        button.backgroundColor = [UIColor clearColor];
        [button addTarget:self action:@selector(refreshButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.emptyView addSubview:button];
        
        [self.view addSubview:self.emptyView];
    }
}

- (void) refreshButtonClicked:(id)sender
{
    [self requestItems:YES];
}

- (void) hideNoItemView
{
    [self.emptyView removeFromSuperview];
    self.emptyView = nil;
}

- (void) updateNewMessage:(NSString *)textContent userId:(NSInteger)userId unread:(BOOL)unread
{
    if (self.style == DFMessageStyleGroup)
    {
        return;
    }
    
    NSInteger index = 0;
    for (DFContactMessageItem* message in self.items)
    {
        if (message.userId == userId)
        {
            NSString* nickname = [NSString stringWithFormat:@"%@:", message.nickname];
            if ([textContent hasPrefix:nickname])
            {
                [message updateContentWithText:[textContent substringFromIndex:nickname.length]];
            }
            else
            {
                [message updateContentWithText:textContent];
            }
            if (unread)
            {
                ++message.unreadCount;
            }
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM-dd";
            message.dateText = [formatter stringFromDate:[NSDate date]];
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        ++index;
    }
    
    if (index >= self.items.count)
    {
        [self requestItems:YES];
    }
}

- (void) updateNewMessage:(NSString *)textContent classcircleId:(NSInteger)classcircleId unread:(BOOL)unread
{
    if (self.style == DFMessageStyleContact)
    {
        return;
    }
    
    NSInteger index = 0;
    for (DFGroupMessageItem* message in self.items)
    {
        if (message.persistentId == classcircleId)
        {
            [message updateContentWithText:textContent];
            if (unread)
            {
                ++message.unreadCount;
            }
            
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"MM-dd";
            message.dateText = [formatter stringFromDate:[NSDate date]];
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            break;
        }
        ++index;
    }
    
    if (index >= self.items.count)
    {
        [self requestItems:YES];
    }
}


@end
