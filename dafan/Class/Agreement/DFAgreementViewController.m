//
//  DFTeacherAgreementViewController.m
//  dafan
//
//  Created by 胡少华 on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFAgreementViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYDeviceDescription.h"
#import "DFPreference.h"
#import "DFColorDefine.h"
//#import "SYBaseContentViewController+DFNavigationBar.h"
#import "DFCreateChannelViewController.h"
#import "DFBaseInfoForApplyTeacherViewController.h"

@interface DFAgreementViewController ()

@property(nonatomic,strong) UIView* agreeBottomBar;

@end

@implementation DFAgreementViewController

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
    // Do any additional setup after loading the view.
    
    [self configSubview];
}

- (void) configSubview
{
    UITextView* textView = [[UITextView alloc] initWithFrame:CGRectZero];
    textView.editable = NO;
    textView.font = [UIFont systemFontOfSize:13];
    textView.textColor = RGBCOLOR(117, 127, 129);
    textView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:textView];
    
    switch (self.agreementStyle) {
        case DFAgreementStyleUser:
        {
            self.title = @"用户使用许可";
            if (![DFPreference sharedPreference].userAgreeAgreement)
            {
                [self addBottomBar];
                self.customNavigationBar.leftButton.hidden = YES;
                [self.customNavigationBar setRightButtonWithStandardTitle:@"完成"];
            }
            
            NSString* filePath = [[NSBundle mainBundle] pathForResource:@"user_license" ofType:@"txt"];
            NSString* content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            textView.text = content;
        }
            break;
        case DFAgreementStyleService:
        {
            self.title = @"服务条款";
            
            NSString* filePath = [[NSBundle mainBundle] pathForResource:@"services" ofType:@"txt"];
            NSString* content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            textView.text = content;
        }
            break;
        case DFAgreementStyleChannel:
        {
            self.title = @"创建频道";
            [self addBottomBar];
            [self.customNavigationBar setRightButtonWithStandardTitle:@"下一步"];
            
            NSString* filePath = [[NSBundle mainBundle] pathForResource:@"channel" ofType:@"txt"];
            NSString* content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            textView.text = content;
        }
           
            break;
        case DFAgreementStyleGetNoCheckCode:
        {
            self.title = @"没有收到短信验证码";
            textView.text = [self receiveNoCheckedCodeText];
        }
            break;
            
        case DFAgreementStyleTeacher:
        {
            self.title = @"老师认证";
            [self addBottomBar];
            [self.customNavigationBar setRightButtonWithStandardTitle:@"下一步"];
            
            NSString* filePath = [[NSBundle mainBundle] pathForResource:@"teacher" ofType:@"txt"];
            NSString* content = [[NSString alloc] initWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
            textView.text = content;
        }
            break;
            
        case DFAgreementStyleMyIncoming:
        {
            self.title = @"说明";
            textView.text = @"\n\n      在韩通培训，你可以通过成为代理或者授课老师来获得收入。报名参加课程的学员将自动获得韩通培训的课程代理资格，您可以向朋友/同事/同学推荐我们的培训课程来获得收入，每推荐成功一位，将能获得不低于50元的代理奖励金。 \n\n      您可以随时查询您的收入明细，由于银行结算的问题，可能会存在收入延迟到账问题。 \n\n      感谢您对韩通培训的贡献，如果您对收入明细有任何疑问，请随时联系我们的工作人员。\n\n      联系电话：612-058-22";
        }
            break;
            
        default:
            break;
    }
    
    CGSize navigationSize = self.customNavigationBar.frame.size;
    CGSize size = self.view.frame.size;
    CGRect textFrame = CGRectMake(0, navigationSize.height, size.width, size.height - navigationSize.height - self.agreeBottomBar.frame.size.height);
    textView.frame = textFrame;
}

- (NSString *) receiveNoCheckedCodeText
{
    NSMutableString* string = [[NSMutableString alloc] initWithString:@"如果长时间收不到手机校验码，可能是由于以下原因：\n\n"];
    
    [string appendString:@"1.请检查您的手机号码输入是否正确；\n解决方法：正确输入手机号码\n"];
    [string appendString:@"2.查看百度手机助手、360手机卫士等产品的拦截短信；\n解决方法：到您现用的手机助手拦截短信处查看\n"];
    [string appendString:@"3.手机通讯服务商网关异常\n解决方法：换时间段再申请。\n"];
    [string appendString:@"4.节假日手机通讯服务商短信发送拥堵\n解决方法：换时间段再申请。\n"];
    [string appendString:@"5.不支持的手机号段\n解决方法：由于手机通讯服务商网关的限制，目前暂支持以下号段手机:\n移动：134,135,136,137,138,139,147,150,151,152,157,158, 159,182,187,188\n联通：130,131,132,155,156,183,185,186\n电信：133,153,180,189\n"];
    [string appendString:@"6.周围的人可以正常使用，但自己始终收不到\n解决方法：可能是手机本身的原因，建议将手机卡换到别人的手机上再次进行尝试。\n"];
    [string appendString:@"7.如果您遇到页面提示“ 验证码错误 ”，建议您确认验证码输入是否有误，如果获取了多条验证码，请输入最后收到的验证码。"];
    
    return string;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) rightButtonClicked:(id)sender
{
    switch (self.agreementStyle) {
        case DFAgreementStyleTeacher:
        {
            DFBaseInfoForApplyTeacherViewController* controller = [[DFBaseInfoForApplyTeacherViewController alloc] initWithNibName:@"DFBaseInfoForApplyTeacherViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case DFAgreementStyleChannel:
        {
            DFCreateChannelViewController* controller = [[DFCreateChannelViewController alloc] initWithNibName:@"DFCreateChannelViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
        case DFAgreementStyleUser:
        {
            [[DFPreference sharedPreference] agreeAgreement];
            [self dismissViewControllerAnimated:YES completion:^{}];
        }
            break;
        default:
            break;
    }
}

#define kBottomBarHeight 54.f
#define kAgreeButtonWidth 210.f
#define kAgreeButtonHeight 35.f


- (void) addBottomBar
{
    CGSize size = self.view.frame.size;
    
    self.agreeBottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, size.height - kBottomBarHeight, size.width, kBottomBarHeight)];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:self.agreeBottomBar.bounds];
    bkgView.image = [[UIImage imageNamed:@"agreement_bottombar_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 20, 20) resizingMode:UIImageResizingModeStretch];
    [self.agreeBottomBar addSubview:bkgView];
    
    UIButton* agreeButton = [[UIButton alloc] initWithFrame:CGRectMake((size.width - kAgreeButtonWidth) / 2, (kBottomBarHeight - kAgreeButtonHeight) / 2, kAgreeButtonWidth, kAgreeButtonHeight)];
    agreeButton.backgroundColor = [UIColor clearColor];
    [agreeButton setBackgroundImage:[UIImage imageNamed:@"agreement_agree_bkg.png"] forState:UIControlStateSelected];
    [agreeButton setBackgroundImage:[UIImage imageNamed:@"agreement_agree_disable_bkg.png"] forState:UIControlStateNormal];
    [agreeButton setImage:[UIImage imageNamed:@"agreement_checked.png"] forState:UIControlStateSelected];
    [agreeButton setImage:[UIImage imageNamed:@"agreement_unchecked.png"] forState:UIControlStateNormal];
    [agreeButton setTitle:@"我同意以上协议" forState:UIControlStateNormal];
    agreeButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 8);
    agreeButton.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
    agreeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.f];
    [agreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    agreeButton.selected = YES;
    [agreeButton addTarget:self action:@selector(agreeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.agreeBottomBar addSubview:agreeButton];
    
    [self.view addSubview:self.agreeBottomBar];
}

- (void) agreeButtonClicked:(UIButton *)sender
{
    sender.selected = !sender.selected;
    
    self.customNavigationBar.rightButton.hidden = !sender.selected;
}

@end
