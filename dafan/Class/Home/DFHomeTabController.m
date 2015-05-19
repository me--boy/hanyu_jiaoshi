//
//  DFHomeTabController.m
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFColorDefine.h"
#import "DFHomeTabController.h"
#import "SYConstDefine.h"
#import "SYStandardNavigationBar.h"
#import "SYBaseContentViewController+DFLogInOut.h"
#import "DFPreference.h"
#import "DFAgreementViewController.h"
#import "DFUserProfile.h"
#import "DFNotificationDefines.h"


@interface DFHomeTabController ()

@end

#define kTabBarBackgroundColor kMainDarkColor
#define kTabButtonSelectedTitleColor [UIColor whiteColor]//RGBCOLOR(164, 164, 164)

@implementation DFHomeTabController

- (void) loadView
{
    [super loadView];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self.customNavigationBar removeFromSuperview];
    
    [self initDFSubViewControllers];
    [self initDFTabBar];
    
    [self addObservers];
    [self checkNewsInfo];
}

- (void) addObservers
{
    NSNotificationCenter* notify = [NSNotificationCenter defaultCenter];
    [notify addObserver:self selector:@selector(newsCountChanged:) name:kNotificationNewsCountChanged object:nil];
    [self registerLogInOutObservers];
}

- (void) userDidLogin
{
    [self checkNewsInfo];
}

- (void) userDidLogout
{
    [self.tabBar clearMarkTab:DFTabBarIDRelationship];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //在第一次使用时弹出 用户协议 视图控制器
    [self checkUserAgreement];
}

- (void) initDFSubViewControllers
{
    self.courseViewController = [[DFHomeCourseTeacherViewController alloc] init];
    
    self.selfStudyViewController = [[DFSelfStudyViewController alloc] init];
    
    self.practiceViewController = [[DFPracticeViewController alloc] init];
    
    self.relationshipsViewController = [[DFRelationshipsViewController alloc] initWithUserId:[DFPreference sharedPreference].currentUser.persistentId];
    
    self.tabBarViewControllers = [NSArray arrayWithObjects:self.courseViewController, self.selfStudyViewController, self.practiceViewController, self.relationshipsViewController, nil];
}

- (UIButton *) tabBarButtonWithTitle:(NSString *)title image:(UIImage *)image selectedImage:(UIImage *)selectedImage
{
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectZero];
    
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:kTabButtonSelectedTitleColor forState:UIControlStateNormal];
    [button setTitleColor:kMainDarPinkColor forState:UIControlStateSelected];
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    button.imageEdgeInsets = UIEdgeInsetsMake(6, 27, 12, 28);
    button.titleEdgeInsets = UIEdgeInsetsMake(34, -17, 3, 8);
    [button setImage:image forState:UIControlStateNormal];
    [button setImage:selectedImage forState:UIControlStateSelected];
    [button setBackgroundImage:[UIImage imageNamed:@"tab_button_selected_bkg.png"] forState:UIControlStateSelected];
    
    button.titleLabel.font = [UIFont systemFontOfSize:11];
    
    return button;
}

- (void) initDFTabBar
{
    self.tabBar.backgroundColor = kTabBarBackgroundColor;
    
    UIButton* showButton = [self tabBarButtonWithTitle:@"我的课表" image:[UIImage imageNamed:@"tab_course_normal.png"] selectedImage:[UIImage imageNamed:@"tab_course_selected.png"]];
    UIButton* ktvButton = [self tabBarButtonWithTitle:@"天生我才" image:[UIImage imageNamed:@"tab_self_study_normal.png"] selectedImage:[UIImage imageNamed:@"tab_self_study_selected.png"]];
    UIButton* contestButton = [self tabBarButtonWithTitle:@"约起来吧" image:[UIImage imageNamed:@"tab_practice_normal.png"] selectedImage:[UIImage imageNamed:@"tab_practice_selected.png"]];
    UIButton* friendButton = [self tabBarButtonWithTitle:@"学习圈子" image:[UIImage imageNamed:@"tab_relationships_normal.png"] selectedImage:[UIImage imageNamed:@"tab_relationships_selected.png"]];
    
    self.tabBar.tabButtons = [NSArray arrayWithObjects:showButton, ktvButton, contestButton, friendButton, nil];
    
    self.selectedIndex = 0;
}

- (void) setSelectedIndex:(NSInteger)selectedIndex
{
    NSInteger originSelectedIndex = self.selectedIndex;
    [super setSelectedIndex:selectedIndex];
    if (originSelectedIndex == DFTabBarIDSelfStudy)
    {
        [self.selfStudyViewController.dailyViewController clearSelectedChapterSection];
    }
}


- (BOOL) tabBar:(SYTabBar *)tabBar shouldSelectedIndex:(NSInteger)index
{
    if (index == 3)
    {
        DFPreference* preference = [DFPreference sharedPreference];
        if (![preference validateLogin:^{
            return NO;
        }])
        {
            return NO;
        }
        
        [self.tabBar clearMarkTab:index];
    }
    
    return YES;
}

- (void) checkUserAgreement
{
    if (![[DFPreference sharedPreference] userAgreeAgreement])
    {
        DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
        controller.agreementStyle = DFAgreementStyleUser;
        
        [self presentViewController:controller animated:NO completion:^{}];
    }
}

- (void) checkNewsInfo
{
    DFPreference* prefer = [DFPreference sharedPreference];
    if ([prefer hasLogin])
    {
        [prefer requestNewsCount];
    }
}

- (void) newsCountChanged:(NSNotification *)notification
{
    if (self.selectedIndex != DFTabBarIDRelationship)
    {
        [self.tabBar markTab:DFTabBarIDRelationship];
    }
}

@end
