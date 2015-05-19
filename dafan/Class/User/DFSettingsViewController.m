//
//  MYSettingsViewController.m
//  MY
//
//  Created by 胡少华 on 14-4-26.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFSettingsViewController.h"
#import "SYConstDefine.h"
//#import "MYFeedbackViewController.h"
//#import "MYAboutViewController.h"
//#import "MYRegisterViewController.h"
#import "DFPasswordViewController.h"
#import "DFVersionRelease.h"
#import "SYDeviceDescription.h"
#import "DFLoginViewController.h"
#import "DFUrlDefine.h"
#import "DFNotificationDefines.h"
#import "DFColorDefine.h"
#import "DFFeedbackViewController.h"
#import "SYPrompt.h"
#import "DFUserProfile.h"
#import "UIView+SYShape.h"
#import "DFPreference.h"
#import "UIAlertView+SYExtension.h"
#import "SYHttpRequest.h"
#import "DFAboutViewController.h"
#import "DFAgreementViewController.h"
#import "SYBaseContentViewController+DFLogInOut.h"

#define kSettingsTableViewCellResueID @"SettingsTableViewCellResueID"
#define kRowHeight 49
#define kSectionHeight 9
#define kTextMarginTop 19
#define kTextHeight 15
#define kTextWidth 130

#define kArrowMarginTop 18
#define kArrowMarginRight 16
#define kArrowWidth 8
#define kArrowHeight 13

#define kImageSize 22
#define kImageMarginLeft 16
#define kImageMarginTop 13

#define kTextMarginLeft (kImageMarginLeft + kImageSize + 18)

#define kAlertviewTagLogout 1024
#define kAlertviewTagUpdate 1025

@interface DFSettingsTableViewCell : UITableViewCell

@end

@implementation DFSettingsTableViewCell

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageFrame = self.imageView.frame;
    imageFrame.origin.x = kImageMarginLeft;
    imageFrame.origin.y = kImageMarginTop;
    imageFrame.size = CGSizeMake(kImageSize, kImageSize);
    self.imageView.frame = imageFrame;
    
    CGRect textFrame = self.textLabel.frame;
    textFrame.origin.x = kTextMarginLeft;
    textFrame.origin.y = kTextMarginTop;
    textFrame.size = CGSizeMake(kTextWidth, kTextHeight);
    self.textLabel.frame = textFrame;
    
    CGRect arrowFrame = self.accessoryView.frame;
    arrowFrame.origin.y = kArrowMarginTop;
    arrowFrame.origin.x = self.frame.size.width - kArrowMarginRight - kArrowWidth;
    arrowFrame.size = CGSizeMake(kArrowWidth, kArrowHeight);
    self.accessoryView.frame = arrowFrame;
}

@end

typedef NS_ENUM(NSInteger, DFSettingsSection)
{
    DFSettingsSection0,
    DFSettingsSection1,
    DFSettingsSectionCount
};

typedef NS_ENUM(NSInteger, DFSettingsSection0Item)
{
    DFSettingsSection0ItemUpdatePassword,
    DFSettingsSection0ItemFeedback,
    DFSettingsSection0ItemCount
};

typedef NS_ENUM(NSInteger, DFSettingsSection1Item)
{
    DFSettingsSection1ItemRating,
    DFSettingsSection1ItemCheckUpdate,
    DFSettingsSection1ItemAbout,
    DFSettingsSection1ItemAgreement,
    DFSettingsSection1ItemCount
};

@interface DFSettingsViewController ()<UIAlertViewDelegate>

@property(nonatomic, strong) NSString* updateUrl;
@property(nonatomic, strong) UIButton* logInOutButton;

@end

@implementation DFSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UITableViewStyle) tableViewStyle
{
    return UITableViewStyleGrouped;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    [self registerLogInOutObservers];
    [self configTableView];
}

- (void) userDidLogin
{
    [self.logInOutButton setTitle:@"退出登录" forState:UIControlStateNormal];
}

- (void) userDidLogout
{
    [self.logInOutButton setTitle:@"登录" forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configTableView
{
    self.tableView.rowHeight = kRowHeight;
    
    self.tableView.sectionHeaderHeight = 8;
    self.tableView.sectionFooterHeight = 8;
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 16)];
    self.tableView.tableHeaderView = headerView;
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 130)];

    self.logInOutButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 16, footerView.frame.size.width, 48)];
    self.logInOutButton.backgroundColor = kMainDarPinkColor;
    [self.logInOutButton setTitle:([[DFPreference sharedPreference] hasLogin] ? @"退出登录" : @"登录") forState:UIControlStateNormal];
    [self.logInOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInOutButton addTarget:self action:@selector(logInOutButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [footerView addSubview:self.logInOutButton];
    self.tableView.tableFooterView = footerView;
}

- (void) logInOutButtonClicked:(UIButton *)sender
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self showLogoutAlert];
    }
    else
    {
        DFLoginViewController* controller = [[DFLoginViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void) showLogoutAlert
{
    UIAlertView* logoutAlert = [[UIAlertView alloc] initWithTitle:@"注销" message:@"确定退出注销吗?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    logoutAlert.delegate = self;
    logoutAlert.tag = kAlertviewTagLogout;
    [logoutAlert show];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return DFSettingsSectionCount;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case DFSettingsSection0:
            return DFSettingsSection0ItemCount;
        case DFSettingsSection1:
            return DFSettingsSection1ItemCount;
        default:
            return 0;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFSettingsTableViewCell* cell = (DFSettingsTableViewCell *)[self.tableView dequeueReusableCellWithIdentifier:kSettingsTableViewCellResueID];
    
    if (cell == nil)
    {
        cell = [[DFSettingsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kSettingsTableViewCellResueID];
        cell.textLabel.textColor = RGBCOLOR(96, 99, 102);
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_arrow.png"]];
    }
    
    switch (indexPath.section) {
        case DFSettingsSection0:
        {
            switch (indexPath.row) {
                case DFSettingsSection0ItemUpdatePassword:
                {
                    cell.textLabel.text = @"修改密码";
                    cell.imageView.image = [UIImage imageNamed:@"settings_reset_password.png"];
                }
                    break;
                case DFSettingsSection0ItemFeedback:
                {
                    cell.textLabel.text = @"意见反馈";
                    cell.imageView.image = [UIImage imageNamed:@"settings_feedback.png"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case DFSettingsSection1:
        {
            switch (indexPath.row) {
                case DFSettingsSection1ItemRating:
                {
                    cell.textLabel.text = @"打分评价";
                    cell.imageView.image = [UIImage imageNamed:@"settings_rating.png"];
                }
                    break;
                case DFSettingsSection1ItemCheckUpdate:
                {
                    cell.textLabel.text = @"检查更新";
                    cell.imageView.image = [UIImage imageNamed:@"settings_check_update.png"];
                }
                    break;
                case DFSettingsSection1ItemAbout:
                {
                    cell.textLabel.text = @"关于产品";
                    cell.imageView.image = [UIImage imageNamed:@"settings_about.png"];
                }
                    break;
                    
                case DFSettingsSection1ItemAgreement:
                {
                    cell.textLabel.text = @"服务条款";
                    cell.imageView.image = [UIImage imageNamed:@"settings_provision.png"];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case DFSettingsSection0:
        {
            switch (indexPath.row) {
                case DFSettingsSection0ItemUpdatePassword:
                {
                    if (![[DFPreference sharedPreference] hasLogin])
                    {
                        [SYPrompt showWithText:@"请先登录，再修改密码～"];
                        return;
                    }
                    if (![DFPreference sharedPreference].isThirdPartyLogin)
                    {
                        DFPasswordViewController* passwordController = [[DFPasswordViewController alloc] init];
                        passwordController.passwordSetType = PasswordSetTypeReset;
                        [self.navigationController pushViewController:passwordController animated:YES];
                    }
                    else
                    {
                        [SYPrompt showWithText:@"您是通过第三方登录，不能修改密码"];
                    }
                }
                    break;
                case DFSettingsSection0ItemFeedback:
                {
                    DFFeedbackViewController* controller = [[DFFeedbackViewController alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case DFSettingsSection1:
        {
            switch (indexPath.row) {
                case DFSettingsSection1ItemRating:
                {
                    [self rating];
                }
                    break;
                case DFSettingsSection1ItemCheckUpdate:
                {
                    [self checkUpdate];
                }
                    break;
                case DFSettingsSection1ItemAbout:
                {
                    DFAboutViewController* controller = [[DFAboutViewController alloc] init];
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                    
                case DFSettingsSection1ItemAgreement:
                {
                    DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
                    controller.agreementStyle = DFAgreementStyleService;
                    [self.navigationController pushViewController:controller animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
}

- (void) rating
{
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreRateUrl_iOS7]];
    }
    else{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppstoreRateUrl]];
    }
}

- (void) checkUpdate
{
    [self showProgress];
    typeof(self) __weak bself = self;
    [[DFPreference sharedPreference] checkUpdate:YES completion:^(BOOL success) {
        [bself hideProgress];
    }];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        switch (alertView.tag) {
            case kAlertviewTagLogout:
                [[DFPreference sharedPreference] logout];
                [self leftButtonClicked:nil];
                break;
                
            default:
                break;
        }
        
    }
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
