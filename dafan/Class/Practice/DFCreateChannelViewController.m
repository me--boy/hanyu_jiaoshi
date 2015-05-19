//
//  DFCreateChannelViewController.m
//  dafan
//
//  Created by iMac on 14-8-20.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCreateChannelViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYPhotoPicker.h"
#import "SYPrompt.h"
#import "UIAlertView+SYExtension.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFColorDefine.h"
#import "SYDeviceDescription.h"
#import "SYBaseContentViewController+Keyboard.h"

@interface DFCreateChannelViewController () <UITextViewDelegate, UITextFieldDelegate, SYPhtoPickerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *qqField;
@property (weak, nonatomic) IBOutlet UITextField *phoneNoField;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIImageView *noteBackgroundImageView;
@property (weak, nonatomic) IBOutlet UITextView *noteTextView;
@property (weak, nonatomic) IBOutlet UIButton *addPictureButton;
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;

@property(nonatomic, strong) SYPhotoPicker* photoPicker;
@property(nonatomic, strong) NSData* pickedImageData;
@property(nonatomic, strong) UIImage* pickedImage;
@property(nonatomic, strong) NSString* imageUrl;

@property(nonatomic) CGFloat keyboardHeight;

@property(nonatomic) BOOL textViewWasEdit;

@end

@implementation DFCreateChannelViewController

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

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self registerKeyboardObservers];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self unregisterKeyboardObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configCustomNavigationBar
{
    self.title = @"创建频道";
    
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交申请"];
}

- (void) configSubviews
{
    CGSize customNavigationBarSize = self.customNavigationBar.frame.size;
    
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = customNavigationBarSize.height;
    scrollFrame.size.height -= customNavigationBarSize.height;
    self.scrollView.frame = scrollFrame;
    
    UIImage* image = [[UIImage imageNamed:@"channel_input_container.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10) resizingMode:UIImageResizingModeStretch];;
    self.noteBackgroundImageView.image = image;
    
    self.noteTextView.delegate = self;
    self.nameField.delegate = self;
    self.phoneNoField.delegate = self;
    self.qqField.delegate = self;
    
    self.previewImageView.hidden = YES;
    [self.addPictureButton addTarget:self action:@selector(addPictureButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, 500.f);
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView:)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];
}

- (void) tapOnScrollView:(id)gesture
{
    [self.view endEditing:YES];
}

- (BOOL) valiteData
{
    if (self.nameField.text.length == 0)
    {
        [UIAlertView showNOPWithText:@"频道名称不能为空"];
        return NO;
    }
    
    NSString* mobileText = self.phoneNoField.text;
    if (mobileText.length != 11 || ![mobileText hasPrefix:@"1"]) {
        [UIAlertView showNOPWithText:@"电话号码格式不对，请重新输入"];
        [self.phoneNoField becomeFirstResponder];
        return NO;
    }
    
    NSString* qqText = self.qqField.text;
    if (qqText.length > 0 && qqText.length < 4) {
        [UIAlertView showNOPWithText:@"电话号码格式不对，请重新输入"];
        [self.phoneNoField becomeFirstResponder];
        return NO;
    }

    if (self.noteTextView.text.length < 10)
    {
        [UIAlertView showNOPWithText:@"频道说明至少填写10个字"];
        [self.noteTextView becomeFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void) rightButtonClicked:(id)sender
{
    if (![self valiteData])
    {
        return;
    }
    
    [self showProgress];
    
    [self postData];
}

- (void) postData
{
    typeof(self) __weak bself = self;
    
    if (self.pickedImageData != nil)
    {
        SYHttpRequestUploadFileParameter* param = [[SYHttpRequestUploadFileParameter alloc] init];
        param.data = self.pickedImageData;
        param.filename = @"avatar.jpg";
        param.contentType = @"image/jpeg";
        
        SYHttpRequest* uploadRequest = [SYHttpRequest uploadFile:[DFUrlDefine urlForUploadFile] parameter:param finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
            if (succeed)
            {
                self.pickedImageData = nil;
                
                bself.imageUrl = [[resultInfo objectForKey:@"info"] objectForKey:@"url"];
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
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.nameField.text forKey:@"name"];
    [dict setObject:self.phoneNoField.text forKey:@"mobileno"];
    [dict setObject:self.noteTextView.text forKey:@"notice"];
    if (self.qqField.text.length > 0)
    {
        [dict setObject:self.qqField.text forKey:@"qq"];
    }
    if (self.imageUrl.length > 0)
    {
        [dict setObject:self.imageUrl forKey:@"img"];
    }
    
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCreateChannel] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success)
        {
            [bself leftButtonClicked:nil];
            [SYPrompt showWithText:@"频道创建成功～"];
            
            [bself.navigationController dismissViewControllerAnimated:YES completion:^{}];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
        
        [bself hideProgress];
    }];
    [self.requests addObject:request];
}

#pragma mark - picture pick

- (void) addPictureButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if (self.photoPicker == nil)
    {
        self.photoPicker = [SYPhotoPicker photoPickerInNavigationViewController:self.navigationController];
        self.photoPicker.delegate = self;
    }
}

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
    self.pickedImage = image;
    self.pickedImageData = data;
    
//    self.addPictureButton.hidden = YES;
    self.previewImageView.hidden = NO;
    self.previewImageView.image = image;
    
    self.photoPicker = nil;
}

#pragma mark - textfield delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.keyboardHeight > 0)
    {
        [self setScrollViewContentOffsetForQQField];
    }
}

#pragma mark -  textview delegate

#define kDefaultNote @"您在教育、工会管理或其它社区的经验，某些方面的个人号召力，以及大致的频道管理计划，最好要有真相，我们需要确保，您有足够的时间、热情、能力来管理一个频道。"

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if (!self.textViewWasEdit)
    {
        self.noteTextView.text = @"";
        self.textViewWasEdit = YES;
    }
    
    if (self.keyboardHeight > 0)
    {
        [self setScrollViewContentOffsetForNoteTextView];
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (self.noteTextView.text.length == 0)
    {
        self.textViewWasEdit = NO;
        self.noteTextView.text = kDefaultNote;
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (self.noteTextView.text.length == 0)
    {
        self.textViewWasEdit = NO;
        self.noteTextView.text = kDefaultNote;
    }
}

#pragma mark - keyboard observers

- (void) setScrollViewContentOffsetForNoteTextView
{
    //keyboard.height + textview.y - contentoffset.y + textview.height == scrollframe.height
    
    CGRect supplementFrame = self.noteTextView.superview.frame;
    [self.scrollView setContentOffset:CGPointMake(0, self.keyboardHeight + supplementFrame.origin.y + supplementFrame.size.height - self.scrollView.frame.size.height) animated:YES];
}

- (void) setScrollViewContentOffsetForQQField
{
    CGRect carrerFrame = self.qqField.superview.frame;
    CGFloat offsetY = self.keyboardHeight + carrerFrame.origin.y + carrerFrame.size.height - self.scrollView.frame.size.height;
    if (offsetY > 0)
    {
        [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = frame.size.height;
    
    if (self.noteTextView.isFirstResponder)
    {
        [self setScrollViewContentOffsetForNoteTextView];
    }
    else if (self.qqField.isFirstResponder)
    {
        [self setScrollViewContentOffsetForQQField];
    }
}

- (void) keyboardWithFrame:(CGRect)frame willHideInDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = 0;
    
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

- (void) keyboardWillChangeFrame:(CGRect)frame inDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = frame.size.height;
}

@end
