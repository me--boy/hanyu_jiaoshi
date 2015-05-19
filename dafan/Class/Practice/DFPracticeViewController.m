//
//  DFPracticeViewController.m
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPracticeViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYDeviceDescription.h"
#import "DFChannelItem.h"
#import "SYHttpRequest.h"
#import "DFNotificationDefines.h"
#import "DFUrlDefine.h"
#import "SYPopoverMenu.h"
#import "DFFilePath.h"
#import "DFPreference.h"
#import "DFUserProfile.h"
#import "UIAlertView+SYExtension.h"
#import "DFCommonImages.h"
#import "DFPracticeCollectionViewCell.h"
#import "SYBaseNavigationController.h"
#import "DFAgreementViewController.h"
#import "UIImageView+WebCache.h"
#import "DFUrlDefine.h"
#import "SYBaseContentViewController+DFLogInOut.h"
#import "DFChannelZoneViewController.h"
#import "SYBaseContentViewController+EGORefresh.h"

@interface DFPracticeViewController ()<UIAlertViewDelegate>

@property(nonatomic, strong) NSMutableArray* items;
@property(nonatomic) NSInteger offsetId;

@end

@implementation DFPracticeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) loadView
{
    [super loadView];
    
    self.loadingFooterViewEnabled = YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self addObservers];
    [self configCustomNavigationBar];
    [self configCollectionView];
    
    self.items = [NSMutableArray array];
    [self requestItems:YES];
}

- (void) userDidLogin
{
    [self reloadTopRightButton];
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(channelSettingsUpdated:) name:kNotificationChannelSettingsUpdated object:nil];
}

- (void) channelSettingsUpdated:(NSNotification *)notification
{
    [self.collectionView reloadData];
}

- (void) userDidLogout
{
    self.customNavigationBar.rightButton.hidden = YES;
}

- (void) requestItems:(BOOL)reload
{
    [self showProgress];
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForChannels] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (reload)
        {
            [bself.items removeAllObjects];
        }
        if (success)
        {
            NSArray* infos = [[resultInfo objectForKey:@"info"] objectForKey:@"list"];
            bself.offsetId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];
            [bself reloadDataWithInfos:infos];
            [bself setCollectionFooterStauts:bself.offsetId > 0 empty:bself.items.count == 0];
            if (reload)
            {
                [infos writeToFile:[DFFilePath homePracticesCacheFilePath] atomically:YES];
            }
        }
        else
        {
            if (reload)
            {
                NSArray* infos = [NSArray arrayWithContentsOfFile:[DFFilePath homePracticesCacheFilePath]];
                [bself reloadDataWithInfos:infos];
            }
            [UIAlertView showNOPWithText:errorMsg];
            [bself setCollectionFooterStauts:YES empty:NO];
        }
        [bself hideProgress];
    }];
    [self.requests addObject:request];
}
/**
 *  字典转模型
 */
- (void) reloadDataWithInfos:(NSArray *)infos
{
    for (NSDictionary* info in infos)
    {
        DFChannelItem* item = [[DFChannelItem alloc] initWithListItemDictionary:info];
        [self.items addObject:item];
    }
    [self.collectionView reloadData];
    [self setCollectionFooterStauts:self.offsetId > 0 empty:self.items.count == 0];
}

- (void) configCustomNavigationBar
{
    self.title = @"约起来吧";
    
    self.customNavigationBar.leftButton.hidden = YES;
    [self.customNavigationBar setRightButtonWithStandardTitle:@"创建频道"];
    [self reloadTopRightButton];
}

- (void) reloadTopRightButton
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    
    self.customNavigationBar.rightButton.hidden = (user.role != DFUserRoleStudent && user.role != DFUserRoleTeacher);
}

- (void) rightButtonClicked:(id)sender
{
    DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
    controller.agreementStyle = DFAgreementStyleChannel;
    SYBaseNavigationController* navigationController = [[SYBaseNavigationController alloc] initWithRootViewController:controller];
    [self.navigationController presentViewController:navigationController animated:YES completion:^{}];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - collectionview

#define kCollectionCellId @"PracticeCell"

- (void) configCollectionView
{
    [self.collectionView registerNib:[UINib nibWithNibName:@"DFPracticeCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:kCollectionCellId];
    
    [self enableRefreshAtHeaderForScrollView:self.collectionView];
}

- (void) requestMoreDataForTableFooterClicked
{
    [self requestItems:NO];
}

- (void) reloadDataForRefresh
{
    [self requestItems:YES];
}

#define kCollectionItemHeight 81.f
#define kCollectionMarginTop 7.f
#define kCollectionLineSpace 7.f
#define kCollectionMarginLeftRight 6.f

- (UICollectionViewLayout *)collectionViewLayout
{
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(self.view.frame.size.width - 2 * kCollectionMarginLeftRight, kCollectionItemHeight);
    layout.sectionInset = UIEdgeInsetsMake(kCollectionMarginTop, kCollectionMarginLeftRight, 0, kCollectionMarginLeftRight);
    layout.minimumLineSpacing = kCollectionLineSpace;
    layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, kDefaultCollectionFooterViewHeight);
    
    return layout;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DFPracticeCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionCellId forIndexPath:indexPath];
    
    DFChannelItem* item = [self.items objectAtIndex:indexPath.item];
    
    cell.lockImageView.hidden = item.password.length == 0;
    [cell.imageView setImageWithURL:[NSURL URLWithString:item.imageUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
    cell.titleLabel.text = item.title;
    cell.channelIDLabel.text = [NSString stringWithFormat:@"ID  %d", item.persistendId];
    [cell.typeButton setTitle:item.typeText forState:UIControlStateNormal];
    cell.userCountLabel.text = [NSString stringWithFormat:@"%d/%d", item.livingUserCount, item.limitUserCount];
    
    [cell setNeedsLayout];
    
    return cell;
}

- (CGFloat) totalCellHeight
{
    if (self.items.count > 0)
    {
        CGFloat height = kCollectionMarginTop;
        height += kCollectionItemHeight* self.items.count;
        return height;
    }
    else
    {
        return 0;
    }
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![[DFPreference sharedPreference] validateLogin:^{
        return NO;
    }])
    {
        return;
    }
    
    DFChannelItem* item = [self.items objectAtIndex:indexPath.item];
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    
    if (user.member == DFMemberTypeVip)//vip
    {
        if (item.password.length == 0 || item.adminUserId == [DFPreference sharedPreference].currentUser.persistentId)
        {//无秘密啊或管理员
            DFChannelZoneViewController* controller = [[DFChannelZoneViewController alloc] initWithChannelItem:item];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            [self showChatroomPasswordAlertView:indexPath.row];
        }
    }
    else
    {
        if (item.livingUserCount >= item.limitUserCount && item.adminUserId != [DFPreference sharedPreference].currentUser.persistentId)
        {//不是管理员或人数已满
            [UIAlertView showNOPWithText:@"人数已满，请稍后再尝试！"];
            return;
        }
        
        if (item.password.length == 0 || item.adminUserId == [DFPreference sharedPreference].currentUser.persistentId)
        {
            DFChannelZoneViewController* controller = [[DFChannelZoneViewController alloc] initWithChannelItem:item];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            [self showChatroomPasswordAlertView:indexPath.row];
        }
    }
}

#define kAlertViewTagPassword 1028

- (void) showChatroomPasswordAlertView:(NSInteger)rowIndex
{
    DFChannelItem* item = [self.items objectAtIndex:rowIndex];
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"输入密码" message:item.title delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"进入", nil];
    alertView.alertViewStyle = UIAlertViewStyleSecureTextInput;
    alertView.tag = rowIndex + 1;
//    alertView.tag = kAlertViewTagPassword;
    UITextField* passwordField = [alertView textFieldAtIndex:0];
    passwordField.keyboardType = UIKeyboardTypeNumberPad;
    [alertView show];
}

- (BOOL) alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if (alertView.tag > 0)
    {
        UITextField* field = [alertView textFieldAtIndex:0];
        DFChannelItem* item = [self.items objectAtIndex:alertView.tag - 1];
        return [field.text isEqualToString:item.password];
    }
    return YES;
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag > 0 && buttonIndex == 1)
    {
        DFChannelItem* item = [self.items objectAtIndex:alertView.tag - 1];
        DFChannelZoneViewController* controller = [[DFChannelZoneViewController alloc] initWithChannelItem:item];
        [self.navigationController pushViewController:controller animated:YES];
    }
    
}

@end
