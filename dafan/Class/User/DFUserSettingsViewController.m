//
//  DFUserSettingsViewController.m
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUserSettingsViewController.h"
#import "SYCircleBorderImageView.h"
#import "SYConstDefine.h"
#import "DFPreference.h"
#import "DFCommonImages.h"
#import "DFEditUserInfoViewCotroller.h"
#import "DFMembershipViewController.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFMyCoursesViewController.h"
#import "DFSettingsViewController.h"
#import "SYVerticalButton.h"
#import "DFMyIncomingViewController.h"
#import "DFNotificationDefines.h"
#import "DFCoursesViewController.h"
#import "DFLoginViewController.h"
#import "DFPromoViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYBaseContentViewController+EGORefresh.h"

@interface DFUserSettingsViewController ()

@property(nonatomic, strong) UIScrollView* scrollView;

@property(nonatomic, strong) SYCircleBorderImageView* avatarImageView;

@property(nonatomic, strong) UIButton* loginButton;
@property(nonatomic, strong) UILabel* nicknameLabel;
@property(nonatomic, strong) UILabel* cityLabel;
@property(nonatomic, strong) UIImageView* genderImageView;
@property(nonatomic, strong) UIImageView* memberImageView;
@property(nonatomic, strong) UIImageView* verifyImageView;

@property(nonatomic, strong) UIButton* courseButton;
//@property(nonatomic, strong) UIButton* memeberButton;
@property(nonatomic, strong) UIButton* incomingButton;
@property(nonatomic, strong) UIButton* promoButton;
@property(nonatomic, strong) UIButton* settingsButton;

@end

@implementation DFUserSettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self initSubviews];
    [self addObservers];
    [self requestUserInfo];
}

- (void) requestUserInfo
{
    if ([[DFPreference sharedPreference] hasLogin])
    {
        typeof(self) __weak bself = self;
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUserInfo] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            if (success)
            {
                [[DFPreference sharedPreference].currentUser updateWithDictionary:[resultInfo objectForKey:@"info"]];
                [bself setHeaderVieLogin];
            }
        }];
        [self.requests addObject:request];
    }
}

- (void) reloadDataForRefresh
{
    [self requestUserInfo];
}

- (void) addObservers
{
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(userLogin:) name:kNotificationUserLogin  object:nil];
    [notify addObserver:self selector:@selector(userLogout:) name:kNotificationUserLogout object:nil];
    [notify addObserver:self selector:@selector(userInfoUpdated:) name:kNotificationUserInfoUpdated object:nil];
}

- (void) userInfoUpdated:(id)sender
{
    [self setHeaderVieLogin];
}

- (void) userLogin:(NSNotification *)notification
{
    [self enableRefreshAtHeaderForScrollView:self.scrollView];
    [self setHeaderVieLogin];
}

- (void) userLogout:(NSNotification *)notification
{
    [self disableRefreshAtHeaderForScrollView:self.scrollView];
    [self setHeaderViewLogout];
}

- (void) configCustomNavigationBar
{
    self.title = @"个人设置";
}

- (void) initSubviews
{
    self.title = @"个人设置";
    
    UIImageView* bkgImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bkgImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_blackboard.png"]];
    [self.view addSubview:bkgImageView];
    
    CGRect topFrame = self.customNavigationBar.frame;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, topFrame.size.height, self.view.frame.size.width, self.view.frame.size.height - topFrame.size.height)];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    [self initHeaderView];
    [self initContentView];
    [self setHeaderViewDatas];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.settingsButton.frame.origin.y + self.settingsButton.frame.size.height + 16);
    if ([[DFPreference sharedPreference] hasLogin])
    {
        [self enableRefreshAtHeaderForScrollView:self.scrollView];
    }
}

#define kAvatarSize 76.f
#define kLoginButtonWidth 86.f
#define kLoginButtonHeight 25.f
#define kHeaderViewHeight 142.f

#define kUserFlagOriginY 93.f
#define kNicknameOriginY 95.f
#define kUserFlagSize 19.f

//- (void) loginButtonClicked:(id)sender
//{
//    DFLoginViewController* controller = [[DFLoginViewController alloc] init];
//    [self.navigationController pushViewController:controller animated:YES];
//}
//
//- (void) avatarClicked:(id)sender
//{
//    
//}

- (void) headAreadButtonClicked:(UIButton *)sender
{
    DFPreference* prefer = [DFPreference sharedPreference];
    if (![prefer hasLogin])
    {
        DFLoginViewController* controller = [[DFLoginViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else
    {
        DFEditUserInfoViewCotroller* controller = [[DFEditUserInfoViewCotroller alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void) initHeaderView
{
    CGSize size = self.view.frame.size;
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kHeaderViewHeight)];
    [self.scrollView addSubview:headerView];
    
    self.avatarImageView = [[SYCircleBorderImageView alloc] initWithFrame:CGRectMake((size.width - kAvatarSize) / 2, 12, kAvatarSize, kAvatarSize)];
    [self.avatarImageView circleWithColor:RGBCOLOR(255, 255, 255) radius:0 strokeWidth:2];
//    [self.avatarImageView.button addTarget:self action:@selector(avatarClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.avatarImageView.userInteractionEnabled = NO;
    [self.scrollView addSubview:self.avatarImageView];
    
    self.loginButton = [[UIButton alloc] initWithFrame:CGRectMake((size.width - kLoginButtonWidth) / 2, 100, kLoginButtonWidth, kLoginButtonHeight)];
    [self.loginButton setBackgroundImage:[UIImage imageNamed:@"user_login_button.png"] forState:UIControlStateNormal];
    self.loginButton.backgroundColor = [UIColor clearColor];
    [self.loginButton setTitle:@"点击登录" forState:UIControlStateNormal];
    [self.loginButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.loginButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.loginButton addTarget:self action:@selector(loginButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.loginButton.userInteractionEnabled = NO;
    [self.scrollView addSubview:self.loginButton];
    
    self.nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, kNicknameOriginY, 0, 0)];
    self.nicknameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.nicknameLabel.backgroundColor = [UIColor clearColor];
    self.nicknameLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.nicknameLabel];
    
    self.cityLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 115, self.view.frame.size.width, 14)];
    self.cityLabel.font = [UIFont systemFontOfSize:13];
    self.cityLabel.textAlignment = NSTextAlignmentCenter;
    self.cityLabel.backgroundColor = [UIColor clearColor];
    self.cityLabel.textColor = [UIColor whiteColor];
    [self.scrollView addSubview:self.cityLabel];
    
    self.genderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kUserFlagOriginY, kUserFlagSize, kUserFlagSize)];
    self.genderImageView.image = [UIImage imageNamed:@"user_male.png"];
    [self.scrollView addSubview:self.genderImageView];
    
    self.memberImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kUserFlagOriginY, kUserFlagSize, kUserFlagSize)];
    self.memberImageView.image = [UIImage imageNamed:@"user_member.png"];
    [self.scrollView addSubview:self.memberImageView];
    
    self.verifyImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, kUserFlagOriginY, kUserFlagSize, kUserFlagSize)];
    self.verifyImageView.image = [UIImage imageNamed:@"user_teacher.png"];
    [self.scrollView addSubview:self.verifyImageView];
    
    UIButton* headAreaButton = [[UIButton alloc] initWithFrame:headerView.bounds];
    headAreaButton.backgroundColor = [UIColor clearColor];
    [headAreaButton addTarget:self action:@selector(headAreadButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [headerView addSubview:headAreaButton];
}

- (void) layoutView:(UIView *)view origin:(CGPoint)origin
{
    CGRect frame = view.frame;
    frame.origin = origin;
    view.frame = frame;
}

- (void) setHeaderViewDatas
{
    if ([DFPreference sharedPreference].hasLogin)
    {
        [self setHeaderVieLogin];
    }
    else
    {
        [self setHeaderViewLogout];
    }
}

#define kTestAvatarUrl @"http://static.maiqinqin.com/www/img/defaultavatar/avatar491.jpg"

- (void) setHeaderVieLogin
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;

    self.cityLabel.hidden = NO;
    self.nicknameLabel.hidden = NO;
    self.genderImageView.hidden = NO;
    
    self.loginButton.hidden = YES;
    
    //[DFCommonImages defaultAvatarImage]
    [self.avatarImageView setImageWithUrl:user.avatarUrl placeHolder:[DFCommonImages defaultAvatarImage]];
//    [self.avatarImageView setImageWithUrl:kTestAvatarUrl placeHolder:nil];
    self.nicknameLabel.text = user.nickname;
    self.cityLabel.text = user.city;
    self.genderImageView.image = [UIImage imageNamed:(user.gender == SYGenderTypeMale ? @"user_male.png" : @"user_female.png")];
    self.memberImageView.hidden = user.member != DFMemberTypeVip;
    
    switch (user.role) {
        case DFUserRoleTeacher:
            self.verifyImageView.hidden = NO;
            self.verifyImageView.image = [UIImage imageNamed:@"user_teacher.png"];
            break;
        case DFUserRoleStudent:
            self.verifyImageView.hidden = NO;
            self.verifyImageView.image = [UIImage imageNamed:@"user_student.png"];
            break;
            
        default:
            self.verifyImageView.hidden = YES;
            break;
    }

    
    [self layoutHeaderViewLogin];
}

#define kSpaceH 5.f

- (void) layoutHeaderViewLogin
{
    [self.nicknameLabel sizeToFit];
    
    CGRect nickFrame = self.nicknameLabel.frame;
    CGFloat iconsWidth = kSpaceH + self.genderImageView.frame.size.width;
    if (!self.memberImageView.hidden)
    {
        iconsWidth += kSpaceH + self.memberImageView.frame.size.width;
    }
    if (!self.verifyImageView.hidden)
    {
        iconsWidth += kSpaceH + self.verifyImageView.frame.size.width;
    }
    iconsWidth += kSpaceH;
    
    CGSize size = self.view.frame.size;
    CGFloat offsetX = 0;
    if (nickFrame.size.width / 2 + iconsWidth < size.width)
    {
        nickFrame.origin.x = size.width / 2 - nickFrame.size.width / 2;
        offsetX = nickFrame.origin.x + nickFrame.size.width + kSpaceH;
        
        [self layoutView:self.genderImageView origin:CGPointMake(offsetX, kUserFlagOriginY)];
        offsetX += self.genderImageView.frame.size.width + kSpaceH;
        
        if (!self.memberImageView.hidden)
        {
            [self layoutView:self.memberImageView origin:CGPointMake(offsetX, kUserFlagOriginY)];
            offsetX += self.memberImageView.frame.size.width + kSpaceH;
        }
        if (!self.verifyImageView.hidden)
        {
            [self layoutView:self.verifyImageView origin:CGPointMake(offsetX, kUserFlagOriginY)];
            offsetX += self.verifyImageView.frame.size.width + kSpaceH;
        }
    }
    else
    {
        offsetX = size.width;
        if (!self.verifyImageView.hidden)
        {
            offsetX -= self.verifyImageView.frame.size.width - kSpaceH;
            [self layoutView:self.verifyImageView origin:CGPointMake(offsetX, kUserFlagOriginY)];
        }
        if (!self.memberImageView.hidden)
        {
            offsetX -= self.memberImageView.frame.size.width - kSpaceH;
            [self layoutView:self.memberImageView origin:CGPointMake(offsetX, kUserFlagOriginY)];
        }
        offsetX -= self.genderImageView.frame.size.width - kSpaceH;
        [self layoutView:self.genderImageView origin:CGPointMake(offsetX, kUserFlagOriginY)];
        
        offsetX -= kSpaceH - nickFrame.size.width;
        if (offsetX < kSpaceH)
        {
            offsetX = kSpaceH;
        }
        nickFrame.origin.x = offsetX;
    }
    self.nicknameLabel.frame = nickFrame;
    
}

- (void) setHeaderViewLogout
{
    self.loginButton.hidden = NO;
    self.avatarImageView.imageView.image = [DFCommonImages defaultAvatarImage];
    self.nicknameLabel.hidden = YES;
    self.cityLabel.hidden = YES;
    self.genderImageView.hidden = YES;
    self.memberImageView.hidden = YES;
    self.verifyImageView.hidden = YES;
}

#define kGridButtonHeight 105.f

- (void) initContentView
{
    CGSize size = self.view.frame.size;
    
    UIView* sepH0 = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderViewHeight, size.width, 0.5)];
    sepH0.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.scrollView addSubview:sepH0];
    
    UIView* sepH1 = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderViewHeight + kGridButtonHeight, size.width, 0.5)];
    sepH1.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.scrollView addSubview:sepH1];
    
    UIView* sepH2 = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderViewHeight + kGridButtonHeight * 2, size.width, 0.5)];
    sepH2.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.scrollView addSubview:sepH2];
    
//    UIView* sepH3 = [[UIView alloc] initWithFrame:CGRectMake(0, kHeaderViewHeight + kGridButtonHeight * 3, size.width / 2, 0.5)];
//    sepH3.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
//    [self.scrollView addSubview:sepH3];
    
    UIView* sepV = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width / 2, kHeaderViewHeight, 0.5, kGridButtonHeight * 2)];
    sepV.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
    [self.scrollView addSubview:sepV];
    
    self.courseButton = [self gridButtonWithImage:[UIImage imageNamed:@"user_lessons.png"] title:@"我的课程" origin:CGPointMake(0, kHeaderViewHeight) action:@selector(courseButtonClicked:)];
    [self.scrollView addSubview:self.courseButton];
    
//    self.memeberButton = [self gridButtonWithImage:[UIImage imageNamed:@"user_enable_memeber.png"] title:@"开通会员" origin:CGPointMake(size.width / 2, kHeaderViewHeight) action:@selector(enableMemeberButtonClicked:)];
//    [self.scrollView addSubview:self.memeberButton];
    
    self.incomingButton = [self gridButtonWithImage:[UIImage imageNamed:@"user_incoming.png"] title:@"我的收入" origin:CGPointMake(size.width / 2, kHeaderViewHeight) action:@selector(incomingButtonClicked:)];
    [self.scrollView addSubview:self.incomingButton];
    
    self.promoButton = [self gridButtonWithImage:[UIImage imageNamed:@"user_promo.png"] title:@"我的邀请码" origin:CGPointMake(0, kHeaderViewHeight + kGridButtonHeight) action:@selector(promoButtonClicked:)];
    [self.scrollView addSubview:self.promoButton];
    
    self.settingsButton = [self gridButtonWithImage:[UIImage imageNamed:@"user_settings.png"] title:@"设置" origin:CGPointMake(size.width / 2, kHeaderViewHeight + kGridButtonHeight) action:@selector(settingsButtonClicked:)];
    [self.scrollView addSubview:self.settingsButton];
}

- (SYVerticalButton *) gridButtonWithImage:(UIImage *)image title:(NSString *)title origin:(CGPoint)point action:(SEL)action
{
    SYVerticalButton* button = [[SYVerticalButton alloc] initWithFrame:CGRectMake(point.x, point.y, self.view.frame.size.width / 2, kGridButtonHeight)];
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.marginTop = 23.f;
    button.marginBottom = 18.f;
    
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    [button setTitle:title image:image font:[UIFont systemFontOfSize:15]];
    
    return button;
}

- (BOOL) canPushController
{
    if (![[DFPreference sharedPreference] validateLogin:^BOOL{
        
        DFLoginViewController* controller = [[DFLoginViewController alloc] init];
        [self.navigationController pushViewController:controller animated:YES];
        
        return YES;
    }])
    {
        return NO;
    }
    return YES;
}

- (void) courseButtonClicked:(id)sender
{
    if (![self canPushController])
    {
        return;
    }
    DFMyCoursesViewController* controller = [[DFMyCoursesViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) incomingButtonClicked:(id)sender
{
    if (![self canPushController])
    {
        return;
    }
    DFMyIncomingViewController* controller = [[DFMyIncomingViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) settingsButtonClicked:(id)sener
{
    DFSettingsViewController* controller = [[DFSettingsViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) promoButtonClicked:(id)sender
{
    if (![self canPushController])
    {
        return;
    }
    DFPromoViewController* controller = [[DFPromoViewController alloc] initWithNibName:@"DFPromoViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) enableMemeberButtonClicked:(id)sender
{
    if (![self canPushController])
    {
        return;
    }
    DFMembershipViewController* controller = [[DFMembershipViewController alloc] initWithNibName:@"DFMembershipViewController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
