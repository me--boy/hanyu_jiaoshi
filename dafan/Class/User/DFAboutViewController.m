//
//  MYAboutViewController.m
//  MY
//
//  Created by 胡少华 on 14-4-27.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFAboutViewController.h"
#import "SYDeviceDescription.h"
#import "SYConstDefine.h"
#import "DFVersionRelease.h"

@interface DFAboutViewController ()

@end

@implementation DFAboutViewController

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
    
    [self initSubviews];
    
    self.title = @"关于产品";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initSubviews
{
    CGSize size = self.view.frame.size;
    
    CGFloat offset = 0;
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        CGRect navigationBarFrame =  self.customNavigationBar.frame;
        offset += navigationBarFrame.origin.y + navigationBarFrame.size.height;
    }
    
    UIImageView* logoView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_logo.png"]];
    
    UILabel* versionLabel = [self labelForAboutStyle:[NSString stringWithFormat:@"版本:%@", kAppVersion]];
    UILabel* copyRightLable = [self labelForAboutStyle:@"Copyright © 2015"];
    UILabel* companyLabel = [self labelForAboutStyle:@"上海韩通教育信息咨询有限公司"];
    UILabel* websiteLabel = [self labelForAboutStyle:@"http://www.1hanyu.com"];
    UILabel* mailLabel = [self labelForAboutStyle:@"合作邮箱:hanyujiaoshi@1hanyu.com"];
    
    [self.view addSubview:logoView];
    [self.view addSubview:versionLabel];
    [self.view addSubview:copyRightLable];
    [self.view addSubview:companyLabel];
    [self.view addSubview:websiteLabel];
    [self.view addSubview:mailLabel];
    
    offset += 143;
    logoView.frame = CGRectMake((size.width - 52) / 2, offset, 52, 52);
    

    offset += 52 + ([[SYDeviceDescription sharedDeviceDescription] isLongScreen] ? 95 : 40);
    versionLabel.frame = CGRectMake(0, offset, size.width, 14);
    
    offset += 14 + 14;
    copyRightLable.frame = CGRectMake(0, offset, size.width, 14);
    
    offset += 14 + 35;
    companyLabel.frame = CGRectMake(0, offset, size.width, 14);
    
    offset += 14 + 14;
    websiteLabel.frame = CGRectMake(0, offset, size.width, 14);
    
    offset += 14 + 13;
    mailLabel.frame = CGRectMake(0, offset, size.width, 14);
}

- (UILabel *) labelForAboutStyle:(NSString *)text
{
    UILabel* label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor grayColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.text = text;
    
    return label;
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
