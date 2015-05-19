//
//  DFIDInfoForApplyTeacherViewController.m
//  dafan
//
//  Created by 胡少华 on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFIDInfoForApplyTeacherViewController.h"
#import "SYStandardNavigationBar.h"
#import "SYPhotoPicker.h"
#import "UIAlertView+SYExtension.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFTeacherApplyPack.h"
#import "SYDeviceDescription.h"
#import "SYBaseContentViewController+Keyboard.h"

@interface DFIDInfoForApplyTeacherViewController ()<UITextFieldDelegate, UITextViewDelegate, SYPhtoPickerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *idPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UITextField *phoneNoField;
@property (weak, nonatomic) IBOutlet UITextView *teacherInfoTextView;
@property (weak, nonatomic) IBOutlet UIImageView *teacherInfobackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *phoneNoBackgroundView;

@property(nonatomic) BOOL textViewWasEdit;

@property(nonatomic, strong) SYPhotoPicker* photoPicker;

@property(nonatomic) CGFloat keyboardHeight;

@property(nonatomic, strong) NSData* pickedIdCardImageData;


@end

@implementation DFIDInfoForApplyTeacherViewController

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


- (void) configCustomNavigationBar
{
    self.title = @"老师认证";
    
    [self.customNavigationBar setRightButtonWithStandardTitle:@"完成"];
}

- (BOOL) validateInput
{
    NSString* mobileNo = [self validateMobileText];
    if (mobileNo.length == 0)
    {
        return NO;
    }
    self.applyPack.telNo = mobileNo;
    
    if (self.pickedIdCardImageData == nil)
    {
        [UIAlertView showWithTitle:@"提示" message:@"身份证照片必须要提供！"];
        return NO;
    }
    
    self.applyPack.teacherInfo = self.teacherInfoTextView.text;
    
    return YES;
}

- (void) rightButtonClicked:(id)sender
{
    if ([self validateInput])
    {
        [self requestApplyForTeacher];
    }
}

- (void) requestApplyForTeacher
{
    [self showProgress];
    typeof(self) __weak bself = self;
    
    if (self.pickedIdCardImageData != nil)
    {
        SYHttpRequestUploadFileParameter* param = [[SYHttpRequestUploadFileParameter alloc] init];
        param.data = self.pickedIdCardImageData;
        param.filename = @"avatar.jpg";
        param.contentType = @"image/jpeg";
        
        SYHttpRequest* uploadRequest = [SYHttpRequest uploadFile:[DFUrlDefine urlForUploadFile] parameter:param finished:^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
            if (succeed)
            {
                self.pickedIdCardImageData = nil;
                
                NSString* url = [[resultInfo objectForKey:@"info"] objectForKey:@"url"];
                
                bself.applyPack.idPhotoUrl = url;
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

    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:self.applyPack.name forKey:@"name"];
    [dict setObject:self.applyPack.telNo forKey:@"mobileno"];
    [dict setObject:[NSNumber numberWithInt:self.applyPack.birthCityId] forKey:@"residence_city_id"];
    [dict setObject:[NSNumber numberWithInt:self.applyPack.birthProvinceId] forKey:@"residence_prov_id"];
    [dict setObject:[NSNumber numberWithInt:self.applyPack.currentCityId] forKey:@"local_city_id"];
    [dict setObject:[NSNumber numberWithInt:self.applyPack.currentProvinceId] forKey:@"local_prov_id"];
    [dict setObject:[NSNumber numberWithInt:self.applyPack.liveYears] forKey:@"residence_time"];
    [dict setObject:self.applyPack.carrier forKey:@"job"];
    if (self.applyPack.baseNote.length > 0)
    {
        [dict setObject:self.applyPack.baseNote forKey:@"description"];
    }
    [dict setObject:self.applyPack.idPhotoUrl forKey:@"img"];
    if (self.applyPack.teacherInfo.length > 0)
    {
        [dict setObject:self.applyPack.teacherInfo forKey:@"auth_desc"];
    }
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForApplyForTeacher] postValues:dict finished:
                              ^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
                                  if (succeed)
                                  {
                                      [bself popToMain];
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                                  
                                  [bself hideProgress];
                              }];
    [self.requests addObject:request];
}

- (NSString *) validateMobileText
{
    NSString* mobileText = self.phoneNoField.text;
    if (mobileText.length != 11 || ![mobileText hasPrefix:@"1"]) {
        UIAlertView *alert =[[UIAlertView alloc] initWithTitle:@""
                                                       message:@"电话号码格式不对，请重新输入"
                                                      delegate:self
                                             cancelButtonTitle:@"好的"
                                             otherButtonTitles:nil];
        [alert show];
        [self.phoneNoField becomeFirstResponder];
        return nil;
    }
    return mobileText;
}

- (void) popToMain
{
    [self cancelAllRequest];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [_progressActivity removeFromSuperview];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{}];
}

- (void) configSubviews
{
    CGSize navigatonBarSize = self.customNavigationBar.frame.size;
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = navigatonBarSize.height;
    scrollFrame.size.height = self.view.frame.size.height - navigatonBarSize.height;
    self.scrollView.frame = scrollFrame;
    
    [self.idPhotoButton addTarget:self action:@selector(idPhotoButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.phoneNoField.delegate = self;
    self.teacherInfoTextView.delegate = self;
    
    UIImage* bkgImage = [[UIImage imageNamed:@"agreement_field_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    self.teacherInfobackgroundView.image = bkgImage;
    self.phoneNoBackgroundView.image = bkgImage;
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView:)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];
}

- (void) tapOnScrollView:(id)gesture
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) idPhotoButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    if (self.photoPicker == nil)
    {
        self.photoPicker = [SYPhotoPicker photoPickerInNavigationViewController:self.navigationController captureSize:CGSizeMake(478, 300)];
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
    self.pickedIdCardImageData = data;
    
    [self.idPhotoButton setImage:image forState:UIControlStateNormal];
    
    self.photoPicker = nil;
}

#pragma mark - textfield delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.keyboardHeight > 0)
    {
        [self setScrollViewContentOffsetForPhoneNoField];
    }
}

#pragma mark -  textview delegate

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if (!self.textViewWasEdit)
    {
        self.teacherInfoTextView.text = @"";
        self.textViewWasEdit = YES;
    }
    
    if (self.keyboardHeight > 0)
    {
        [self setScrollViewContentOffsetForTeacherInfoTextView];
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (self.teacherInfoTextView.text.length == 0)
    {
        self.textViewWasEdit = NO;
        self.teacherInfoTextView.text = @"如果认证通过，会作为老师简介";
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (self.teacherInfoTextView.text.length == 0)
    {
        self.textViewWasEdit = NO;
        self.teacherInfoTextView.text = @"如果认证通过，会作为老师简介";
    }
}

#pragma mark - keyboard observers

- (void) setScrollViewContentOffsetForTeacherInfoTextView
{
    //keyboard.height + textview.y - contentoffset.y + textview.height == scrollframe.height
    
    CGRect supplementFrame = self.teacherInfoTextView.superview.frame;
    [self.scrollView setContentOffset:CGPointMake(0, self.keyboardHeight + supplementFrame.origin.y + supplementFrame.size.height - self.scrollView.frame.size.height) animated:YES];
}

- (void) setScrollViewContentOffsetForPhoneNoField
{
    CGRect carrerFrame = self.phoneNoField.superview.frame;
    CGFloat offsetY = self.keyboardHeight + carrerFrame.origin.y + carrerFrame.size.height - self.scrollView.frame.size.height;
    if (offsetY > 0)
    {
        [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = frame.size.height;
    
    if (self.teacherInfoTextView.isFirstResponder)
    {
        [self setScrollViewContentOffsetForTeacherInfoTextView];
    }
    else if (self.phoneNoField.isFirstResponder)
    {
        [self setScrollViewContentOffsetForPhoneNoField];
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
