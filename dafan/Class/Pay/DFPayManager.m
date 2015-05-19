//
//  DFPayManager.m
//  dafan
//
//  Created by iMac on 14-9-24.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPayManager.h"
#import "AlixPayOrder.h"
#import "DataVerifier.h"
#import "DFColorDefine.h"
#import "AlixPayResult.h"
#import "DFPreference.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFNotificationDefines.h"
#import "PartnerConfig.h"
#import "SYPrompt.h"
//#import "AlixLibService.h"
#import "UIAlertView+SYExtension.h"
#import <AlipaySDK/AlipaySDK.h>
#import "DataSigner.h"

static DFPayManager* sSharedManager = nil;

@interface DFPayManager ()

@property(nonatomic, strong) NSString* tradeNo;
@property(nonatomic) NSInteger courseId;
@property(nonatomic, strong) NSMutableArray* requests;
@end

@implementation DFPayManager

+ (DFPayManager *) sharedPreference
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedManager = [[DFPayManager alloc] init];
    });
    return sSharedManager;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id) allocWithZone:(NSZone *)zone
{
    //    return [[self class] sharedDeviceDescription];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedManager = [super allocWithZone:zone];
    });
    return sSharedManager;
}

- (id) init
{
    self = [super init];
    if (self)
    {

    }
    return self;
}

- (void) payWithTradeNo:(NSString *)tradeNo params:(NSString *)params forCourse:(NSInteger)courseId
{
    if (self.requests == nil)
    {
        self.requests = [NSMutableArray array];
    }
    self.tradeNo = tradeNo;
    self.courseId = courseId;
    
//    [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
//        NSLog(@"reslut = %@",resultDic);
//    }];
//    NSMutableDictionary * parametersDictionary = [NSMutableDictionary dictionary];
//
//    NSArray * queryComponents = [params componentsSeparatedByString:@"&"];
//    
//    for (NSString * queryComponent in queryComponents) {
//        NSString * key = [queryComponent componentsSeparatedByString:@"="].firstObject;
//        NSString * value = [queryComponent substringFromIndex:(key.length + 1)];
//        [parametersDictionary setObject:value forKey:key];
//    }
//    NSLog(@"%@",parametersDictionary);
    //=======================================================//
    /*
    AlixPayOrder *order = [[AlixPayOrder alloc] init];
    
    order.partner = PartnerID;//[parametersDictionary objectForKey:@"partner"];
    order.seller = SellerID;//[parametersDictionary objectForKey:@"seller_id"];
    order.tradeNO = [self generateTradeNO];//@"608";//[parametersDictionary objectForKey:@"out_trade_no"]; //订单ID（由商家自行制定）
    order.productName = @"支付费用";//[parametersDictionary objectForKey:@"subject"]; //商品标题
    order.productDescription = @"支付费用";//[parametersDictionary objectForKey:@"body"]; //商品描述
    order.amount = @"0.01";//[parametersDictionary objectForKey:@"total_fee"]; //商品价格
    
    order.notifyURL =  @"http:www.baidu.com";//[parametersDictionary objectForKey:@"notify_url"];//回调URL
    
    order.serviceName = @"mobile.securitypay.pay";//[parametersDictionary objectForKey:@"service"];
    
    order.paymentType = @"1";
    
    order.inputCharset = @"utf-8";
    
    order.itBPay = @"30m";//[parametersDictionary objectForKey:@"it_b_pay"];
    
//    order.returnUrl = @"m.alipay.com";//[parametersDictionary objectForKey:@"return_url"];;
    
//    order.showUrl = @"m.alipay.com";

    
    //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
    NSString *appScheme = @"hanyujiaoshi";
    
    //将商品信息拼接成字符串
    NSString *orderSpec = [order description];
    NSLog(@"orderSpec = %@",orderSpec);
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    id<DataSigner> signer = CreateRSADataSigner(PartnerPrivKey);
    NSString *signedString = [signer signString:orderSpec];
    
    //将签名成功字符串格式化为订单字符串,请严格按照该格式
    NSString *orderString = nil;

    if (signedString != nil) {
        
        orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                       orderSpec, signedString, @"RSA"];
        
        NSLog(@"orderString--->\n%@",orderString);
        
        [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
            
            NSLog(@"reslut = %@",resultDic);
        }];
    }
     */
    /*  notify_url="http%3A%2F%2Fm.1hanyu.net%2Falipaynotify.php"&partner="2088511354317974"&out_trade_no="623"&subject="支付报名费"&body="支付报名费"&total_fee="498"&service="mobile.securitypay.pay"&_input_charset="utf-8"&return_url="http%3A%2F%2Fm.alipay.com"&payment_type="1"&seller_id="5208176@qq.com"&it_b_pay="1m"&sign="zSt8EuSWXKCUVlsgaLgN5O1lonFU4Okc8s4PBhfqq5VGCt3CJ5j9DX8U7mgpplLB5RyJMdT8o80k44fhHMj%2FL04j1Nx4vDRRypbIS7CjN%2F3Ie1z1tIwL4ZZv7pVCU3U4skbUHoCHh%2FtYfVf0fEJp3luj1%2FwVhFj9VCbHh65AL0Q%3D"&sign_type="RSA"*/
    //=======================================================//
    
//    [AlixLibService payOrder:params AndScheme:@"hanyujiaoshi" seletor:@selector(aliPaymentResult:) target:self];

    __weak typeof(self) bself = self;
    
    [[AlipaySDK defaultService] payOrder:params fromScheme:@"hanyujiaoshi" callback:^(NSDictionary *resultDic) {
        
//        NSLog(@"reslut = %@",resultDic);
//        [bself aliPaymentResult:resultDic];
        [bself aliPaymentResult:params];
        
    }];
}

- (void) aliPaymentResult:(NSString *)resultId
{
    AlixPayResult* result = [[AlixPayResult alloc] initWithString:resultId];
    if (result)
    {
        if (result.statusCode == kAliPaymentSucceedCode)
        {
            [self verifyWithTradeNo];
#warning    暂时不检验
//            id<DataVerifier> verifier = CreateRSADataVerifier(AlipayPubKey);
            
//            if ([verifier verifyString:result.resultString withSign:result.signString])
//            {
//                [self verifyWithTradeNo];
//            }
//            else
//            {
//                [UIAlertView showWithTitle:@"支付宝" message:@"订单校验失败！"];
//            }
        }
        else
        {
            [UIAlertView showWithTitle:@"支付宝" message:[NSString stringWithFormat:@"支付未完成,%@", result.statusMessage]];
        }
    }
    else
    {
        [UIAlertView showWithTitle:@"支付宝" message:@"支付未完成"];
    }
}

- (void) verifyWithTradeNo
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForAliPayResult] postValues:@{@"out_trade_no" : self.tradeNo} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success && [[[resultInfo objectForKey:@"info"] objectForKey:@"issuccess"] integerValue] == 1)
        {
            [DFPreference sharedPreference].currentUser.role = DFUserRoleStudent;
            [DFPreference sharedPreference].currentUser.member = DFMemberTypeVip;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterCourseSucceed object:nil userInfo:@{@"courseId":[NSNumber numberWithInt:bself.courseId]}];
            [SYPrompt showWithText:@"报名成功！"];
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationRegisterCourseFinished object:nil userInfo:@{@"courseId":[NSNumber numberWithInt:bself.courseId]}];
        }
        
    }];
    [self.requests addObject:request];
}

- (void) processAliPayWithURL:(NSURL *)url
{
    NSString* query = [[url query] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    [self aliPaymentResult:query];
}

- (NSString *)generateTradeNO
{
    static int kNumber = 15;
    
    NSString *sourceStr = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    srand(time(0));
    for (int i = 0; i < kNumber; i++)
    {
        unsigned index = rand() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


@end
