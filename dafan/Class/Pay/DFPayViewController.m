//
//  DFPayViewController.m
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPayViewController.h"
//#import "AlixLibService.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "SYPrompt.h"
#import "AlixPayOrder.h"
#import "DataVerifier.h"
#import "DFColorDefine.h"
#import "AlixPayResult.h"
#import "PartnerConfig.h"
#import "DFPreference.h"
#import "DFNotificationDefines.h"
#import "UIAlertView+SYExtension.h"

@interface DFPayViewController ()


@end

@implementation DFPayViewController

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
    UIButton* payButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 160, self.view.frame.size.width, 100)];
    payButton.backgroundColor = kMainDarkColor;
    [payButton setTitle:@"支付398元" forState:UIControlStateNormal];
    [payButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [payButton addTarget:self action:@selector(payButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:payButton];
}

- (void) payButtonClicked:(id)sender
{
    [self showProgress];
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAliPay] postValues:@{@"money": @"0.01"} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [bself hideProgress];
            
            [SYPrompt showWithText:@"call back from our servers"];
//            NSString* params = [[resultInfo objectForKey:@"info"] objectForKey:@"params"];
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
//                [SYPrompt showWithText:@"verify succeed for ali"];
//            }
//            else
//            {
//                [SYPrompt showWithText:@"verify failed for ali"];
//            }
//        }
//        else
//        {
//            [SYPrompt showWithText:@"pay failed"];
//        }
//    }
//    else
//    {
//        [SYPrompt showWithText:@"pay completed failed"];
//    }
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
