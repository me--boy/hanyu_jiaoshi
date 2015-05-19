//
//  DFChatMemberViewController.m
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChatMemberViewController.h"
#import "DFUserMemberItem.h"
#import "DFChatMemberTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "DFCommonImages.h"
#import "SYCircleBorderImageView.h"
#import "DFTypeEnum.h"
#import "DFUrlDefine.h"
#import "DFColorDefine.h"
#import "SYHttpRequest.h"
#import "DFPreference.h"
#import "UIAlertView+SYExtension.h"
#import "DFUserProfile.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "DFChatUserContextMenuController.h"
#import "SYContextMenu.h"

@interface DFChatMemberViewController ()<DFChatUserContextMenuControllerDelegate>

//@property(nonatomic, strong) NSMutableArray* members;
@property(nonatomic) DFChatsUserStyle userStyle;
@property(nonatomic, strong) DFChatUserContextMenuController* contextMenuController;

@property(nonatomic, strong) UILabel* footerLabel;

@end

@implementation DFChatMemberViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithChatUserStyle:(DFChatsUserStyle)userStyle
{
    self = [super init];
    if (self)
    {
        self.userStyle = userStyle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - table

- (void) configTableView
{
    self.tableView.rowHeight = 76.f;
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    
    switch (self.userStyle) {
        case DFChatsUserStyleClassroomStudent:
        case DFChatsUserStyleClassroomTeacher:
        case DFChatsUserStyleClassroomVisitor:
        {
            self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 24)];
            self.footerLabel.backgroundColor = [UIColor clearColor];
            self.footerLabel.textColor = [UIColor grayColor];
            self.footerLabel.font = [UIFont systemFontOfSize:12];
            self.tableView.tableFooterView = self.footerLabel;
        }
            break;
            
        default:

            break;
    }
}

- (void) setClassroomVisitorCount:(NSInteger)classroomVisitorCount
{
    _classroomVisitorCount = classroomVisitorCount;
    self.footerLabel.text = [NSString stringWithFormat:@"    旁听人数：%d", classroomVisitorCount];
}

- (void) reloadDataForRefresh
{
    if ([self.delegate respondsToSelector:@selector(refreshMemberForChatMemberViewController:)])
    {
        [self.delegate refreshMemberForChatMemberViewController:self];
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.members.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFChatMemberTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[DFChatMemberTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        switch (self.userStyle) {
            case DFChatsUserStyleClassroomStudent:
            case DFChatsUserStyleClassroomTeacher:
            case DFChatsUserStyleClassroomVisitor:
                [cell.rightButton setTitle:@"在线" forState:UIControlStateSelected];
                [cell.rightButton setTitle:@"旷课" forState:UIControlStateNormal];
                cell.positionButton.userInteractionEnabled = NO;
                break;
                
            default:
                cell.positionButton.hidden = YES;
                cell.rightButton.hidden = YES;
                break;
        }
    }
    
    DFUserMemberItem* item = [self.members objectAtIndex:indexPath.row];
    
    [cell.avatarView setImageWithUrl:item.avatarUrl placeHolder:[DFCommonImages defaultAvatarImage]];
    [cell.positionButton setTitle:item.positionText forState:UIControlStateNormal];
    
    if (item.userId != [DFPreference sharedPreference].currentUser.persistentId)
    {
        [cell.avatarView circleWithColor:kChatMemberTableCellMainGrayColor radius:0];
        cell.nicknameLabel.textColor = [UIColor blackColor];
        cell.nicknameLabel.text = item.nickname;
    }
    else
    {
        [cell.avatarView circleWithColor:kMainDarkColor radius:0];
        cell.nicknameLabel.textColor = kMainDarkColor;
        cell.nicknameLabel.text = @"我";
    }
    
    cell.provinceCityLabel.text = item.provinceCity;
    cell.rightButton.selected = item.inClassroom;
    [cell.positionButton setTitle:item.positionText forState:UIControlStateNormal];
    
    if (self.userStyle == DFChatsUserStyleRoomAdministrator || self.userStyle == DFChatsUserStyleRoomVisitor)
    {
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
    }
    else
    {
        cell.verifyImageView.hidden = YES;
    }
    
    cell.memberImageView.hidden = item.member != DFMemberTypeVip;
    
    cell.keyboardImageView.hidden = !item.disableTextChat;
    cell.mikeImageView.hidden = !item.disableVoiceChat;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFUserMemberItem* item = [self.members objectAtIndex:indexPath.row];
    
    if ([DFPreference sharedPreference].currentUser.persistentId == item.userId)
    {
        return;
    }
    
    self.contextMenuController = [[DFChatUserContextMenuController alloc] initWithChatUserStyle:self.userStyle member:item];
    self.contextMenuController.urlRequests = self.requests;
    self.contextMenuController.delegate = self;
    self.contextMenuController.channeldId = self.channelId;
    self.contextMenuController.courseId = self.courseId;
    [self.contextMenuController popupInView:self.parentViewController.view];
}

- (void) chatUserContextMenuControllerDidDismiss:(DFChatUserContextMenuController *)controller
{
    self.contextMenuController = nil;
}

- (void) menuActionDidStartForChatUserContextMenuController:(DFChatUserContextMenuController *)controller
{
    [self showProgress];
}

- (void) menuActionDidFinishForChatUserContextMenuController:(DFChatUserContextMenuController *)controller
{
    [self hideProgress];
}

//- (void) menuActionDidSucceedForChatUserContextMenuController:(DFChatUserContextMenuController *)controller
//{
//    [self.tableView reloadData];
//}

@end
