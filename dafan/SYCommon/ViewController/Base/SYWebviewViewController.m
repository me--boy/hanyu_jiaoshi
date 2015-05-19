//
//  SYWebviewViewController.m
//  dafan
//
//  Created by 胡少华 on 14/10/23.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYWebviewViewController.h"
#import "SYPrompt.h"

@interface SYWebviewViewController () <UIWebViewDelegate>

@property(nonatomic, strong) NSString* url;
@property(nonatomic, strong) UIWebView* webView;

@end

@implementation SYWebviewViewController

- (id) initWithUrl:(NSString *)url
{
    self = [super init];
    if (self)
    {
        self.url = url;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.webTitle;
    [self initWebview];
}

- (void) initWebview
{
    CGFloat headerHeight = self.customNavigationBar.frame.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, headerHeight, self.view.frame.size.width, self.view.frame.size.height - headerHeight)];
    self.webView.allowsInlineMediaPlayback = YES;
    self.webView.mediaPlaybackRequiresUserAction = NO;
    self.webView.delegate = self;
    [self.view addSubview:self.webView];
    
    if (self.url.length == 0)
    {
//        self.url = @"http://www.dafanpx.com";
        self.url = @"http://www.1hanyu.com";
    }
    
    [self showProgress];
    NSURLRequest* request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:self.url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60];
    [self.webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL* url = [request URL];
    if ([[url scheme] isEqualToString:@"itms-appss"])
    {
        return NO;
    }
    return YES;
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    [self hideProgress];
}

- (void) webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [self hideProgress];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
