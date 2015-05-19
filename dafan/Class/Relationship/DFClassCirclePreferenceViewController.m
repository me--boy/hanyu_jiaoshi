//
//  DFClassCirclePreferenceViewController.m
//  dafan
//
//  Created by iMac on 14-10-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFClassCirclePreferenceViewController.h"
#import "DFUserBasic.h"
#import "UIView+SYShape.h"
#import "SYPrompt.h"
#import "UIImageView+WebCache.h"
#import "DFCommonImages.h"
#import "UIAlertView+SYExtension.h"
#import "SYDeviceDescription.h"
#import "DFNotificationDefines.h"
#import "DFUrlDefine.h"
#import "SYHttpRequest.h"
#import "DFColorDefine.h"
#import "DFCourseViewController.h"
#import "DFPreference.h"
#import "DFAppDelegate.h"
#import "SYTextViewInputController.h"

@interface DFClassCirclePreferenceViewController () <UIAlertViewDelegate, SYTextViewInputControllerDelegate>

@property(nonatomic, strong) UIScrollView* scrollView;
@property(nonatomic, strong) UIView* usersContainerView;
@property(nonatomic, strong) UIView* otherContainerView;

@property(nonatomic, strong) UILabel* classroomTitleLabel;
@property(nonatomic, strong) UIButton* ignoreMessageButton;

@end

@implementation DFClassCirclePreferenceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configCustomNavigationBar];
    [self initSubviews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configCustomNavigationBar
{
    self.title = @"班级设置";
    [self.customNavigationBar setRightButtonWithStandardTitle:@"课程详情"];
}

- (void) rightButtonClicked:(id)sender
{
    DFCourseViewController* controller = [[DFCourseViewController alloc] initWithMode:DFCalendarModeRead];
    controller.courseId = self.preference.courseId;
    [self.navigationController pushViewController:controller animated:YES];
}

#define kPaddingLeftRight 9.f
#define kUserSpace 16.f
#define kUserAvatarSize 47.f
#define kUserAvatarNickSpace 5.f
#define kUserAvatarMarginTopBottom 10.f
#define kNicknameHeight 11.f

- (void) initSubviews
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.scrollView];
    
    [self addUsersContainerView];
    [self addOtherViews];
    [self addQuitButton];
}

- (void) addUsersContainerView
{
    CGFloat navigationHeight = self.customNavigationBar.frame.size.height;
    CGSize size = self.view.frame.size;
    CGFloat totalWidth = size.width - 2 * kPaddingLeftRight;
    
    CGRect usersFrame = CGRectMake(kPaddingLeftRight, navigationHeight + 16, totalWidth, 0);
    self.usersContainerView = [[UIView alloc] initWithFrame:usersFrame];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:self.usersContainerView.bounds];
    bkgView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    UIImage* bkgImage = [[UIImage imageNamed:@"agreement_field_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    bkgView.image = bkgImage;
    [self.usersContainerView addSubview:bkgView];
    
    CGFloat offsetX = kUserSpace;
    CGFloat offsetY = kUserAvatarMarginTopBottom;
    for (DFUserBasic* user in self.preference.userMembers)
    {
        if (offsetX + kUserAvatarSize + kUserSpace > totalWidth)
        {
            offsetX = kUserSpace;
            offsetY += kUserAvatarSize + kUserAvatarNickSpace + kNicknameHeight + kUserAvatarMarginTopBottom;
        }
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(offsetX, offsetY, kUserAvatarSize, kUserAvatarSize)];
        [imageView setImageWithURL:[NSURL URLWithString:user.avatarUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
        [imageView makeViewASCircle:imageView.layer withRaduis:4 color:[UIColor grayColor].CGColor strokeWidth:1];
        [self.usersContainerView addSubview:imageView];
        
        UILabel* nicknameLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, offsetY + kUserAvatarSize + kUserAvatarNickSpace, kUserAvatarSize, kNicknameHeight)];
        nicknameLabel.backgroundColor = [UIColor clearColor];
        nicknameLabel.font = [UIFont systemFontOfSize:10];
        nicknameLabel.textColor = RGBCOLOR(132, 143, 149);
        nicknameLabel.text = user.nickname;
        nicknameLabel.textAlignment = NSTextAlignmentCenter;
        [self.usersContainerView addSubview:nicknameLabel];
        
        offsetX += kUserAvatarSize + kUserSpace;
    }
    
    usersFrame.size.height = offsetY + kUserAvatarSize + kUserAvatarNickSpace + kNicknameHeight + kUserAvatarMarginTopBottom;
    self.usersContainerView.frame = usersFrame;
    
    [self.scrollView addSubview:self.usersContainerView];
}

#define kRowHeight 53.f
#define kMarginRight 22.f

- (void) addOtherViews
{
    CGFloat totalWidth = self.view.frame.size.width - 2 * kPaddingLeftRight;
    CGRect usersFrame = self.usersContainerView.frame;
    
    CGRect otherViewFrame = CGRectMake(kPaddingLeftRight, usersFrame.origin.y + usersFrame.size.height + 16, totalWidth, kRowHeight * 2);
    self.otherContainerView = [[UIView alloc] initWithFrame:otherViewFrame];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:self.otherContainerView.bounds];
    UIImage* bkgImage = [[UIImage imageNamed:@"agreement_field_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    bkgView.image = bkgImage;
    [self.otherContainerView addSubview:bkgView];
    
    UIButton* editClassTitleButton = [[UIButton alloc] initWithFrame:CGRectMake(9, 0, totalWidth - 18, kRowHeight)];
    editClassTitleButton.backgroundColor = [UIColor clearColor];
    editClassTitleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    [editClassTitleButton setImage:[UIImage imageNamed:@"default_arrow.png"] forState:UIControlStateNormal];
    [editClassTitleButton addTarget:self action:@selector(editClassTitleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.otherContainerView addSubview:editClassTitleButton];
    
    UILabel* classroomTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, 0, 56, kRowHeight)];
    classroomTitleLabel.backgroundColor = [UIColor clearColor];
    classroomTitleLabel.textColor = RGBCOLOR(51, 51, 51);
    classroomTitleLabel.font = [UIFont systemFontOfSize:13];
    classroomTitleLabel.text = @"班级名称";
    [self.otherContainerView addSubview:classroomTitleLabel];
    
    self.classroomTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 0, totalWidth - 80 - kMarginRight - 8, kRowHeight)];
    self.classroomTitleLabel.textAlignment = NSTextAlignmentRight;
    self.classroomTitleLabel.font = [UIFont systemFontOfSize:13];
    self.classroomTitleLabel.text = self.preference.title;
    self.classroomTitleLabel.textColor = RGBCOLOR(132, 143, 149);
    [self.otherContainerView addSubview:self.classroomTitleLabel];
    
    UIImageView* seperatorView = [[UIImageView alloc] initWithFrame:CGRectMake(5, kRowHeight, totalWidth - 10, 0.5)];
    seperatorView.backgroundColor = RGBCOLOR(191, 191, 191);
    [self.otherContainerView addSubview:seperatorView];
    
    UILabel* ignoreMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(9, kRowHeight, 72, kRowHeight)];
    ignoreMessageLabel.backgroundColor = [UIColor clearColor];
    ignoreMessageLabel.textColor = RGBCOLOR(51, 51, 51);
    ignoreMessageLabel.font = [UIFont systemFontOfSize:13];
    ignoreMessageLabel.text = @"消息免打扰";
    [self.otherContainerView addSubview:ignoreMessageLabel];
    
    self.ignoreMessageButton = [[UIButton alloc] initWithFrame:CGRectMake(totalWidth - 57 - kMarginRight, kRowHeight + 6, 57, 41)];
    self.ignoreMessageButton.backgroundColor = [UIColor clearColor];
    [self.ignoreMessageButton setImage:[UIImage imageNamed:@"switch_off.png"] forState:UIControlStateNormal];
    [self.ignoreMessageButton setImage:[UIImage imageNamed:@"switch_on.png"] forState:UIControlStateSelected];
    [self.ignoreMessageButton addTarget:self action:@selector(ignoreMessageButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.ignoreMessageButton.selected = self.preference.ignoreNewMessage;
    [self.otherContainerView addSubview:self.ignoreMessageButton];
    
    [self.scrollView addSubview:self.otherContainerView];
}

- (void) addQuitButton
{
    CGRect otherFrame = self.otherContainerView.frame;
    UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(8, otherFrame.origin.y + otherFrame.size.height + 47, otherFrame.size.width, 38)];
    button.backgroundColor = kMainDarkColor;
    [button makeViewASCircle:button.layer withRaduis:5 color:kMainDarkColor.CGColor strokeWidth:1];
    [button setTitle:@"退出班级圈" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(quitButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:button];
    
    self.scrollView.contentSize = CGSizeMake(otherFrame.size.width, otherFrame.origin.y + otherFrame.size.height +  20.f);
}

- (void) popToRoot
{
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        UINavigationController* navi = (UINavigationController *)(((DFAppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController);
        [navi popViewControllerAnimated:NO];
    }];
}

- (void) quitButtonClicked:(id)sender
{
    [self showConfirmQuitAlertView];
}

- (void) showConfirmQuitAlertView
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出班级?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alertView show];
    
//    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion < 8)
//    {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:@"确定退出班级?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
//        [alertView show];
//    }
//    else
//    {
//        typeof(self) __weak bself = self;
//        UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定退出班级?" preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
//            
//        }];
//        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//            [bself quitFromClassCircle];
//        }];
//        [controller addAction:cancelAction];
//        [controller addAction:okAction];
//        
//        [self presentViewController:controller animated:YES completion:^{
//            
//        }];
//        
//    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self quitFromClassCircle];
    }
}

- (void) quitFromClassCircle
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForQuitFromClass] postValues:@{@"class_id" : [NSNumber numberWithInt:self.preference.persistentId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [bself popToRoot];
        }
        else
        {
            [UIAlertView showWithTitle:@"退出" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) editClassTitleButtonClicked:(id)sender
{
    if ([DFPreference sharedPreference].currentUser.persistentId == self.preference.adminUserId)
    {
        SYTextViewInputController* nicknameControlelr = [[SYTextViewInputController alloc] init];
        nicknameControlelr.maxTextCount = 12;
        nicknameControlelr.numberOfLines = 1;
        nicknameControlelr.defaultText = self.preference.title;
        nicknameControlelr.titleText = @"班级名称";
        nicknameControlelr.delegate = self;
        [self.navigationController pushViewController:nicknameControlelr animated:YES];
    }
    else
    {
        [SYPrompt showWithText:@"只有老师才能修改！"];
    }
}

- (void) textViewInputController:(SYTextViewInputController *)textViewController inputText:(NSString *)text
{
    self.classroomTitleLabel.text = text;
    self.preference.title = text;
    //@{@"class_id" : [NSNumber numberWithInteger:self.preference.persistentId]
    
    typeof(self) __weak bself = self;
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:text forKey:@"classname"];
    [dict setObject:[NSNumber numberWithInt:self.preference.persistentId] forKey:@"class_id"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUpdateClasscircle] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"修改名称成功！"];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationClasscircleNameUpdated object:bself.preference];
        }
        else
        {
            [UIAlertView showWithTitle:@"修改名称" message:errorMsg];
        }
        
    }];
    [self.requests addObject:request];
}

- (void) ignoreMessageButtonClicked:(id)sender
{
    self.ignoreMessageButton.selected = !self.ignoreMessageButton.selected;
    
    self.preference.ignoreNewMessage = self.ignoreMessageButton.selected;
    
    typeof(self) __weak bself = self;
    [self showProgress];
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:self.preference.persistentId] forKey:@"class_id"];
    [dict setObject:[NSNumber numberWithInt:self.ignoreMessageButton.selected ? 1 : 2] forKey:@"ban_type"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForUpdateClasscircle] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        
        if (success)
        {
            [SYPrompt showWithText:(self.ignoreMessageButton.selected ? @"已打开免消息打扰" : @"已关闭免消息打扰")];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationClasscircleNameUpdated object:bself.preference];
        }
        else
        {
            bself.ignoreMessageButton.selected = !bself.ignoreMessageButton.selected;
            [UIAlertView showWithTitle:@"修改名称" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

@end
