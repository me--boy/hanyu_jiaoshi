//
//  DFImportChatSubjectViewController.m
//  dafan
//
//  Created by iMac on 14-8-26.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "UIAlertView+SYExtension.h"
#import "SYPrompt.h"
#import "DFImportChatSubjectViewController.h"

@interface DFImportChatSubjectViewController ()

@end

@implementation DFImportChatSubjectViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) init
{
    self = [super initWithInputStyle:SYTextInputStyleCommit];
    if (self)
    {
        self.titleText = @"导入话题";
        
        self.placeHolder = @"输入公告区话题内容";
        self.maxTextCount = 1000;
        self.numberOfLines = 5;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.textView.scrollEnabled = YES;
    self.textView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    [self.customNavigationBar.titleButton addTarget:self action:@selector(titleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void) titleButtonClicked:(id)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) rightButtonClicked:(id)sender
{
    [self showProgress];
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForImportChannelTopic] postValues:@{@"channel_id": [NSNumber numberWithInt:self.channelId], @"notice" : self.textView.text} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            [SYPrompt showWithText:@"导入成功"];
            [bself leftButtonClicked:nil];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
        
    }];
    [self.requests addObject:request];
}

@end
