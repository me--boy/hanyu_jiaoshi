//
//  MYFeedbackViewController.m
//  MY
//
//  Created by 胡少华 on 14-4-27.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFFeedbackViewController.h"
#import "DFUrlDefine.h"
#import "SYPrompt.h"
#import "SYHttpRequest.h"
#import "SYStandardNavigationBar.h"
#import "UIAlertView+SYExtension.h"

@interface DFFeedbackViewController ()

@end

@implementation DFFeedbackViewController

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
    return [super initWithInputStyle:SYTextInputStyleCommit];
}

- (void) loadView
{
    [super loadView];
    
    self.defaultText = @"";
    self.titleText = @"意见反馈";
    self.maxTextCount = 120;
    self.numberOfLines = 7;
    
    [self configCustomNavigationBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configCustomNavigationBar
{
    self.title = @"意见反馈";
    
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
}

- (void) rightButtonClicked:(id)sender
{
    if (_textView.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"请输入反馈内容" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
        [alert show];
        return;
    }
    
    NSDictionary* dict = [NSDictionary dictionaryWithObject:_textView.text forKey:@"content"];
    
    typeof(self) __weak bself = self;
    [self showProgress];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForFeedback] postValues:dict finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
        
        [bself hideProgress];
        if (succeed)
        {
            [SYPrompt showWithText:@"您的反馈我们已经收到，非常感谢"];
            [bself leftButtonClicked:nil];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMessage];
        }
    }];
    
    [self.requests addObject:request];
}

@end
