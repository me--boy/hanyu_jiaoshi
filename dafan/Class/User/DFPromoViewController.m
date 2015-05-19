//
//  DFPromoViewController.m
//  dafan
//
//  Created by iMac on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPromoViewController.h"
#import "SYTriButtonActionSheet.h"
#import "SYPrompt.h"
#import "SYFullShareActionSheet.h"
#import "DFPreference.h"
#import "UMSocialSnsPlatformManager.h"
#import "UMSocialData.h"
#import "UIAlertView+SYExtension.h"
#import "UMSocialDataService.h"

@interface DFPromoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *promoLabel;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIImageView *noPromoImageView;
@property (weak, nonatomic) IBOutlet UILabel *noPromoTipLabel;
@property (weak, nonatomic) IBOutlet UIImageView *noteTipsImageView;
@property (weak, nonatomic) IBOutlet UILabel *noteLabel;

@end

@implementation DFPromoViewController

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
    
    [self configSubview];
}

#define kNoteText @"您可以把它分享给朋友/同事/同学，当他们报名的时候，输入您提供的邀请码，可以减免%d元，同时您将在一星期后可以得到%d元的推荐奖励"

- (void) configSubview
{
    self.title = @"我的邀请码";
    
    DFPreference* pre = [DFPreference sharedPreference];
    if (pre.currentUser.inviteCode.length > 0)
    {
        self.noPromoImageView.hidden = YES;
        self.noPromoTipLabel.hidden = YES;
        self.promoLabel.text = pre.currentUser.inviteCode;
    }
    else
    {
        self.shareButton.hidden = YES;
        self.promoLabel.hidden = YES;
    }
    
    self.noteLabel.text = [NSString stringWithFormat:kNoteText, pre.inviteCodeWorth, pre.agentReward];
    
    UIImage* image = [[UIImage imageNamed:@"promo_note_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    self.noteTipsImageView.image = image;
    
    [self.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) shareButtonClicked:(id)sender
{
//    SYTriButtonActionSheet* actionsheet = [[SYTriButtonActionSheet alloc] initWithTitle:@"分享邀请码"];
//    [actionsheet.leftButton addTarget:self action:@selector(shareToWechatFriend:) forControlEvents:UIControlEventTouchUpInside];
//    [actionsheet.middleButton addTarget:self action:@selector(shareToQQFriend:) forControlEvents:UIControlEventTouchUpInside];
//    [actionsheet.rightButton addTarget:self action:@selector(shareToSMSFriend:) forControlEvents:UIControlEventTouchUpInside];
//    [actionsheet showInView:self.view];
    
    SYFullShareActionSheet* actionSheet = [[SYFullShareActionSheet alloc] initWithTitle:@"分享邀请码"];
    [actionSheet.weiboButton addTarget:self action:@selector(shareToWeibo:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheet.qZoneButton addTarget:self action:@selector(shareToQZone:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheet.wechatFriendsCircleButton addTarget:self action:@selector(shareToWechatFriendCircle:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheet.qqFriendButton addTarget:self action:@selector(shareToQQFriend:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheet.wechatFriendButton addTarget:self action:@selector(shareToWechatFriend:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheet.messageButton addTarget:self action:@selector(shareToSMSFriend:) forControlEvents:UIControlEventTouchUpInside];
    [actionSheet showInView:self.view];
}

//#define kDefaultSharedText @"妈妈再也不担心我听不懂上海话了！上海话速成班邀请码%@, 立省学费"

- (void) shareToTypes:(NSString *)type content:(NSString *)content tips:(NSString *)tips
{
//    [UMSocialData defaultData].extConfig.title = @"学说上海话";
    [self showProgress];
    typeof(self) __weak bself = self;
    
    UIImage* image = [UIImage imageNamed:@"about_logo.png"];
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[type] content:content image:image location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity* response){
        
        [bself hideProgress];
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            [SYPrompt showWithText:tips];
        }
        else
        {
            [UIAlertView showNOPWithText:@"分享不成功，请稍后尝试"];
        }
    }];
}

- (void) shareToWechatFriendCircle:(id)sender
{
    [UMSocialData defaultData].extConfig.wechatTimelineData.wxMessageType = UMSocialWXMessageTypeWeb;
    [UMSocialData defaultData].extConfig.wechatTimelineData.url = @"http://www.1hanyu.com/?s=wexinpyq";
//    [UMSocialData defaultData].extConfig.wechatTimelineData.title = @"学说上海话";
    
    [self shareToTypes:UMShareToWechatTimeline
               content:[NSString stringWithFormat:@"上海话在线学习速成班邀请码%@，立省学费", [DFPreference sharedPreference].currentUser.inviteCode]
                  tips:@"微信分享成功"];
}

- (void) shareToQZone:(id)sender
{
    [UMSocialData defaultData].extConfig.qzoneData.url = @"http://www.dafanpx.com/?s=qqkongjian";
//    [UMSocialData defaultData].extConfig.qzoneData.title = @"学说上海话";
    
    [self shareToTypes:UMShareToQzone
               content:[NSString stringWithFormat:@"妈妈再也不担心我听不懂上海话了！上海话速成班邀请码%@，立省学费~", [DFPreference sharedPreference].currentUser.inviteCode]
                  tips:@"qq空间分享成功"];
}

- (void) shareToWeibo:(id)sender
{
    [self shareToTypes:UMShareToSina
               content:[NSString stringWithFormat:@"妈妈再也不担心我听不懂上海话了！上海话速成班邀请码%@, 立省学费%@",  [DFPreference sharedPreference].currentUser.inviteCode,  @"http://www.dafanpx.com/?s=weibo"]
                  tips:@"微博分享成功"];
}

- (void) shareToWechatFriend:(id)sender
{
    [UMSocialData defaultData].extConfig.wechatSessionData.wxMessageType = UMSocialWXMessageTypeApp;//UMSocialWXMessageTypeApp;
//    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.dafanpx.com/?s=weibo";
    
    [UMSocialData defaultData].extConfig.wechatSessionData.url = @"http://www.1hanyu.com/?s=weibo";
    [UMSocialData defaultData].extConfig.wechatSessionData.title = @"韩通培训";
    
    [self shareToTypes:UMShareToWechatSession
               content:[NSString stringWithFormat:@"上海话在线学习速成班邀请码%@，立省学费", [DFPreference sharedPreference].currentUser.inviteCode]
                  tips:@"微信邀请成功"];
}

- (void) shareToQQFriend:(id)sender
{
    [UMSocialData defaultData].extConfig.qqData.url = @"http://www.dafanpx.com/?s=qqhaoyou";
    [UMSocialData defaultData].extConfig.qqData.title = @"韩通培训";
    
    [self shareToTypes:UMShareToQQ
               content:[NSString stringWithFormat:@"邀请码%@", [DFPreference sharedPreference].currentUser.inviteCode]
                  tips:@"QQ邀请成功"];
}

- (void) shareToSMSFriend:(id)sender
{
//    [UMSocialData defaultData].extConfig.title = @"学说上海话";
    [UMSocialData defaultData].shareImage = [[NSData alloc] init];
    
    [UMSocialData defaultData].extConfig.smsData.urlResource = nil;
    
    [[UMSocialDataService defaultDataService] postSNSWithTypes:@[UMShareToSms] content:[NSString stringWithFormat:@"妈妈再也不担心我听不懂上海话了！上海话速成班邀请码%@, 立省学费%@",  [DFPreference sharedPreference].currentUser.inviteCode,  @"http://www.dafanpx.com/?s=duanxin"] image:[UIImage imageNamed:@""] location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity* response){
        
        if (response.responseCode == UMSResponseCodeSuccess)
        {
            [SYPrompt showWithText:@"短信邀请成功"];
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
