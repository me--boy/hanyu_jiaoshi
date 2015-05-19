//
//  DFCourseSettingsViewController.m
//  dafan
//
//  Created by iMac on 14-8-26.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCourseSettingsViewController.h"
#import "SYHttpRequest.h"
#import "UIAlertView+SYExtension.h"
#import "DFUrlDefine.h"
#import "SYTextViewInputController.h"

@implementation DFCourseConfiguration

@end

@interface DFCourseSettingsViewController ()<SYTextViewInputControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *sectionBackgroundView;
@property (weak, nonatomic) IBOutlet UISwitch *textChatSwitch;
@property (weak, nonatomic) IBOutlet UIButton *mikeTimeIntervalButton;
@property (weak, nonatomic) IBOutlet UIButton *mikeDelayedTimeIntervalButton;


@property(nonatomic, strong) NSString* editTimeIntervalText;
@property(nonatomic, strong) NSString* editDelayedTimeIntervalText;
@property(nonatomic) BOOL pickedTextChatEnabled;

@end

@implementation DFCourseSettingsViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setConfiguration:(DFCourseConfiguration *)configuration
{
    if (_configuration != configuration)
    {
        _configuration = configuration;
        
        self.pickedTextChatEnabled = configuration.textChatEnabled;
    }
}

#pragma mark -  custom navigationbar

- (void) configCustomNavigationBar
{
    self.title = @"频道设置";
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
}

- (void) configSubviews
{
    UIImage* image = [[UIImage imageNamed:@"chats_item_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];
    self.sectionBackgroundView.image = image;
    
    self.textChatSwitch.enabled = self.configuration.textChatEnabled;
    [self.mikeTimeIntervalButton setTitle:[NSString stringWithFormat:@"%d秒", self.configuration.timeInterval] forState:UIControlStateNormal];
    
    [self.mikeDelayedTimeIntervalButton setTitle:[NSString stringWithFormat:@"%d秒", self.configuration.delayedTimeInterval] forState:UIControlStateNormal];
}

- (void) rightButtonClicked:(id)sender
{
    [self postTextData];
}

- (void) postTextData
{
    if (!(self.pickedTextChatEnabled ^ self.configuration.textChatEnabled) && self.editTimeIntervalText.length > 0 && self.editDelayedTimeIntervalText.length > 0)
    {
        return;
    }
    
    [self showProgress];
    typeof(self) __weak bself = self;
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if (self.editTimeIntervalText.length > 0)
    {
        [dict setObject:self.editTimeIntervalText forKey:@"time"];
    }
    if (self.editDelayedTimeIntervalText)
    {
        [dict setObject:self.editDelayedTimeIntervalText forKey:@"delay_time"];
    }
    if (self.pickedTextChatEnabled ^ self.configuration.textChatEnabled)
    {
        [dict setObject:(self.pickedTextChatEnabled ? @"1" : @"0") forKey:@"text_chat_enable"];
    }
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCompleteUserInfo] postValues:dict finished:
                              ^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
                                  if (succeed)
                                  {
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

#define kTextInputTimeIntervalTag 1025
#define kTextInputDelayedTimeIntervalTag 1026

- (IBAction)textChatSwitched:(id)sender {
    self.pickedTextChatEnabled = self.textChatSwitch.enabled;
}

- (IBAction)mikeTimeIntervalButtonClicked:(id)sender {
    SYTextViewInputController* controller = [[SYTextViewInputController alloc] initWithInputStyle:SYTextInputStyleEdit];
    controller.tag = kTextInputTimeIntervalTag;
    controller.keyboardType = UIKeyboardTypeNumberPad;
    controller.maxTextCount = 2;
    controller.numberOfLines = 1;
    controller.defaultText = [NSString stringWithFormat:@"%d", self.configuration.timeInterval];
    controller.titleText = @"麦序时间";
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)mikeDelayedTimeIntervalButtonClicked:(id)sender {
    SYTextViewInputController* controller = [[SYTextViewInputController alloc] initWithInputStyle:SYTextInputStyleEdit];
    controller.tag = kTextInputDelayedTimeIntervalTag;
    controller.keyboardType = UIKeyboardTypeNumberPad;
    controller.maxTextCount = 2;
    controller.numberOfLines = 1;
    controller.defaultText = [NSString stringWithFormat:@"%d", self.configuration.delayedTimeInterval];
    controller.titleText = @"麦序过期时间";
    controller.delegate = self;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) textViewInputController:(SYTextViewInputController *)textViewController inputText:(NSString *)text
{
    switch (textViewController.tag) {
        case kTextInputTimeIntervalTag:
            self.editTimeIntervalText = text;
            [self.mikeTimeIntervalButton setTitle:[NSString stringWithFormat:@"%@秒", text] forState:UIControlStateNormal];
            break;
        case kTextInputDelayedTimeIntervalTag:
            self.editDelayedTimeIntervalText = text;
            [self.mikeDelayedTimeIntervalButton setTitle:[NSString stringWithFormat:@"%@秒", text] forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end
