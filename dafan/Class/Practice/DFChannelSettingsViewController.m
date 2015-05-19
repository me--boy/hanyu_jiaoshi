//
//  DFChannelSettingsViewController.m
//  dafan
//
//  Created by iMac on 14-8-26.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChannelSettingsViewController.h"
#import "SYTextViewInputController.h"
#import "UIImageView+WebCache.h"
#import "DFCommonImages.h"
#import "SYPhotoPicker.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "SYPrompt.h"
#import "UIAlertView+SYExtension.h"


@interface DFChannelSettingsViewController ()<UITextFieldDelegate, SYPhtoPickerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *section0BackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *section1BackgroundImageView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *channelIconButton;
@property (weak, nonatomic) IBOutlet UITextField *channelTitleField;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;

@property (nonatomic, strong) NSString* editChannelTitle;
@property(nonatomic, strong) NSString* editPassword;


@property(nonatomic, strong) SYPhotoPicker* photoPicker;
@property(nonatomic, strong) UIImage* pickedIconImage;
@property(nonatomic, strong) NSData* pickedIconImageData;
@property(nonatomic, strong) NSString* pickedIconUrl;



@end

@implementation DFChannelSettingsViewController

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
    
    [self configCustomNavigationBar];
    [self configSubviews];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -  custom navigationbar

- (void) configCustomNavigationBar
{
    self.title = @"频道设置";
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
}

- (BOOL) valiteData
{
    if (self.channelTitleField.text.length == 0)
    {
        [UIAlertView showNOPWithText:@"频道名称不能为空"];
        [self.channelTitleField becomeFirstResponder];
        return NO;
    }
    
    if (self.passwordField.text.length > 0 && self.passwordField.text.length != 4)
    {
        [UIAlertView showNOPWithText:@"进入密码必须为4位数字"];
        [self.passwordField becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void) rightButtonClicked:(id)sender
{
    self.editChannelTitle = self.channelTitleField.text;
    self.editPassword = self.passwordField.text;
    
    if (![self valiteData])
    {
        return;
    }
    
    [self showProgress];
    typeof(self) __weak bself = self;
    
    if (self.pickedIconImageData != nil)
    {
        SYHttpRequestUploadFileParameter* param = [[SYHttpRequestUploadFileParameter alloc] init];
        param.data = self.pickedIconImageData;
        param.filename = @"avatar.jpg";
        param.contentType = @"image/jpeg";
        
        SYHttpRequest* uploadRequest = [SYHttpRequest uploadFile:[DFUrlDefine urlForUploadFile] parameter:param finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
            if (succeed)
            {
                bself.pickedIconImageData = nil;
                
                NSString* url = [[resultInfo objectForKey:@"info"] objectForKey:@"url"];
                
                bself.pickedIconUrl = url;
            }
            
            [bself postTextData];
        }];
        
        [self.requests addObject:uploadRequest];
    }
    else
    {
        [self postTextData];
    }
}

- (void) postTextData
{
    typeof(self) __weak bself = self;
    
    if (self.editChannelTitle.length == 0 && self.pickedIconUrl.length == 0)
    {
        [self hideProgress];
        return;
    }
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInt:self.channelInfo.persistendId] forKey:@"channel_id"];
    
    self.channelInfo.title = self.editChannelTitle;
    [dict setObject:self.editChannelTitle forKey:@"name"];
    
    if (self.pickedIconUrl.length > 0)
    {
        self.channelInfo.imageUrl = self.pickedIconUrl;
        [dict setObject:self.pickedIconUrl forKey:@"img"];
    }
    else
    {
        [dict setObject:(self.channelInfo.imageUrl.length > 0 ? self.channelInfo.imageUrl : @"") forKey:@"img"];
    }
    
    self.channelInfo.password = self.editPassword;
    [dict setObject:self.editPassword forKey:@"password"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForConfigChannel] postValues:dict finished:
                              ^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
                                  if (succeed)
                                  {
                                      [SYPrompt showWithText:@"设置修改成功"];
                                      [bself leftButtonClicked:nil];
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                                  
                                  [bself hideProgress];
                              }];
    [self.requests addObject:request];
}

#pragma mark - subviews

#define kTextInputTitleTag 1024
#define kTextInputTimeIntervalTag 1025
#define kTextInputDelayedTimeIntervalTag 1026

- (void) configSubviews
{
    UIImage* image = [[UIImage imageNamed:@"chats_item_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    self.section0BackgroundImageView.image = image;
    self.section1BackgroundImageView.image = image;
    
    self.channelTitleField.delegate = self;
    self.passwordField.delegate = self;
    
    self.channelTitleField.text = self.channelInfo.title;
    
    [self.iconImageView setImageWithURL:[NSURL URLWithString:self.channelInfo.imageUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];

    self.passwordField.text = self.channelInfo.password;
    
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = self.customNavigationBar.frame.size.height;
    scrollFrame.size.height = self.view.frame.size.height - scrollFrame.origin.y;
    self.scrollView.frame = scrollFrame;
    
    self.scrollView.contentSize = self.view.frame.size;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView:)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];
}

- (void) tapOnScrollView:(id)gesture
{
    [self.view endEditing:YES];
}

- (IBAction)channelIconButtonClicked:(id)sender {
    if (self.photoPicker == nil)
    {
        self.photoPicker = [SYPhotoPicker photoPickerInNavigationViewController:self.navigationController];
        self.photoPicker.delegate = self;
    }
}

#pragma mark - textview input

- (void) photoPickerCancelled:(SYPhotoPicker *)picker
{
    self.photoPicker = nil;
}

- (void) photoPicker:(SYPhotoPicker *)picker pickImage:(UIImage *)image
{
    self.photoPicker = nil;
}

- (void) photoPicker:(SYPhotoPicker *)picker pickImage:(UIImage *)image imageData:(NSData *)data
{
    self.pickedIconImage = image;
    self.pickedIconImageData = data;
    
    self.iconImageView.image = image;
    
    self.photoPicker = nil;
}

@end
