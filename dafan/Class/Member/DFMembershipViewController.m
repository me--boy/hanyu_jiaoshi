//
//  DFMembershipViewController.m
//  dafan
//
//  Created by 胡少华 on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFMembershipViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFAppDelegate.h"
#import "AlixPayOrder.h"
#import "DataVerifier.h"
#import "DFColorDefine.h"
//#import "AlixLibService.h"
#import "AlixPayResult.h"
#import "PartnerConfig.h"
#import "DFPreference.h"
#import "SYPrompt.h"
#import "UIAlertView+SYExtension.h"

@interface DFMembershipViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *leftMemebershipDaysButton;
@property (weak, nonatomic) IBOutlet UIImageView *privilegeBackgroundView0;
@property (weak, nonatomic) IBOutlet UIImageView *previlegeBackgroundView1;
@property (weak, nonatomic) IBOutlet UIImageView *commodityBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *previlegeBackgroundView2;

@property(nonatomic) NSInteger buyMonths;

@end

@implementation DFMembershipViewController

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
    
    [self configSubviews];
}

- (void) configCustomNavigationBar
{
    
}

- (void) configSubviews
{
    CGSize navigationSize = self.customNavigationBar.frame.size;
    
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = navigationSize.height;
    scrollFrame.size.height -= navigationSize.height;
    self.scrollView.frame = scrollFrame;
    
    self.scrollView.contentSize = CGSizeMake(navigationSize.width, 568.f);
    
    UIImage* image = [[UIImage imageNamed:@"member_item_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    [self.leftMemebershipDaysButton setBackgroundImage:image forState:UIControlStateNormal];
    self.commodityBackgroundView.image = image;
    self.previlegeBackgroundView1.image = image;
    self.privilegeBackgroundView0.image = image;
    self.previlegeBackgroundView2.image = image;
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    
    if (user.member > 0)
    {
        NSInteger days = [user.memberEndDate timeIntervalSinceDate:[NSDate date]] / (24 * 60 * 60);
        [self.leftMemebershipDaysButton setTitle:[NSString stringWithFormat:@"您还剩余的会员天数:%d", days] forState:UIControlStateNormal];
    }
    else
    {
        [self.leftMemebershipDaysButton setTitle:@"您目前没有购买会员服务" forState:UIControlStateNormal];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)buy1MonthButtonClicked:(id)sender {
    [self showBuyMemberAlertView:1];
}
- (IBAction)buy3MonthsButtonClicked:(id)sender {
    [self showBuyMemberAlertView:3];
}
- (IBAction)buy6MonthsButtonClicked:(id)sender {
    [self showBuyMemberAlertView:6];
}
- (IBAction)buy1YearButtonClicked:(id)sender {
    [self showBuyMemberAlertView:12];
}

- (void) showBuyMemberAlertView:(NSInteger)months
{
    self.buyMonths = months;
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"会员" message:[NSString stringWithFormat:@"确认购买%d月会员", months] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"购买", @"免费获取", nil];
    [alert show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [self payWithMonths:alertView.tag];
    }
    else if (buttonIndex == 2)
    {
        [self freeWithMonths:alertView.tag];
    }
}

- (void) freeWithMonths:(NSInteger)months
{
    [self showProgress];
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAliPay] postValues:@{@"vip_time" : [NSNumber numberWithInt:months]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            [SYPrompt showWithText:@"call back from our servers"];
            [self freeRegister:[info objectForKey:@"out_trade_no"]];
        }
        else
        {
            [UIAlertView showWithTitle:@"pay failed" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) freeRegister:(NSString *)tradeNo
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForFreeRegister] postValues:@{@"out_trade_no": tradeNo} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"会员购买成功！"];
            [bself leftButtonClicked:nil];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) payWithMonths:(NSInteger)months
{
    [self showProgress];
    
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAliPay] postValues:@{@"vip_time" : [NSNumber numberWithInt:months]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"call back from our servers"];
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            NSString* params = [info objectForKey:@"params"];
            
//            ((DFAppDelegate *)[UIApplication sharedApplication].delegate).tradeNo = [info objectForKey:@"out_trade_no"];
#warning 目前这块用不到 暂时先不写  需要时加上支付功能就行
//            [AlixLibService payOrder:params AndScheme:@"com.shiyoo.dafan" seletor:@selector(aliPaymentResult:) target:bself];
        }
        else
        {
            [UIAlertView showWithTitle:@"pay failed" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

//- (void) aliPaymentResult:(NSString *)resultId
//{
//    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultId];
//    if (result)
//    {
//        if (result.statusCode == kAliPaymentSucceedCode)
//        {
//            id<DataVerifier> verifier = CreateRSADataVerifier(AlipayPubKey);
//            if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                [SYPrompt showWithText:@"支付宝，交易成功"];
////                [(DFAppDelegate *)[UIApplication sharedApplication].delegate verifyWithTradeNo];
//            }
//            else
//            {
//                [SYPrompt showWithText:@"支付宝，交易失败 (verify failed)"];
//            }
//        }
//        else
//        {
//            [SYPrompt showWithText:@"支付宝，交易失败 (code error)"];
//        }
//    }
//    else
//    {
//        [SYPrompt showWithText:@"支付宝，交易失败 (result == nil)"];
//    }
//    
//}

@end
