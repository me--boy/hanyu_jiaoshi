//
//  DFBaseInfoForApplyTeacherViewController.m
//  dafan
//
//  Created by 胡少华 on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFBaseInfoForApplyTeacherViewController.h"
#import "SYStandardNavigationBar.h"
#import "DFIDInfoForApplyTeacherViewController.h"
#import "SYCityPickedViewController.h"
#import "SYDeviceDescription.h"
#import "UIAlertView+SYExtension.h"
#import "DFTeacherApplyPack.h"
#import "SYBaseContentViewController+Keyboard.h"

@interface DFBaseInfoForApplyTeacherViewController ()<UITextFieldDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIImageView *requiredInfoBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *optionalInfoBackgroundView;
@property (weak, nonatomic) IBOutlet UITextView *supplementTextView;
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UIButton *currentCityButton;
@property (weak, nonatomic) IBOutlet UITextField *liveLifeField;
@property (weak, nonatomic) IBOutlet UIButton *domicileButton;
@property (weak, nonatomic) IBOutlet UITextField *carrerField;

@property(nonatomic) BOOL textViewWasEdit;
@property(nonatomic) CGFloat keyboardHeight;

@property(nonatomic, strong) DFTeacherApplyPack* applyPack;

@end

//#define kDefaultKeyboardHeight 216

@implementation DFBaseInfoForApplyTeacherViewController

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
    
    self.applyPack = [[DFTeacherApplyPack alloc] init];
    
    [self configSubviews];
    
    [self configCustomNavigationBar];
}

- (void) rightButtonClicked:(id)sender
{
    if ([self validateInput])
    {
        DFIDInfoForApplyTeacherViewController* controller = [[DFIDInfoForApplyTeacherViewController alloc] initWithNibName:@"DFIDInfoForApplyTeacherViewController" bundle:[NSBundle mainBundle]];
        controller.applyPack = self.applyPack;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (BOOL) validateInput
{
    self.applyPack.name = self.nameField.text;
    if (self.applyPack.name.length == 0)
    {
        [UIAlertView showWithTitle:@"提示" message:@"姓名必须要填！"];
        return NO;
    }
    if (self.applyPack.currentProvinceId == 0)
    {
        [UIAlertView showWithTitle:@"提示" message:@"现在居住地必须要填！"];
        return NO;
    }
    if (self.liveLifeField.text.length == 0)
    {
        [UIAlertView showWithTitle:@"提示" message:@"居住年限须要填！"];
        return NO;
    }
    self.applyPack.liveYears = [self.liveLifeField.text integerValue];
    
    if (self.applyPack.birthProvinceId == 0)
    {
        [UIAlertView showWithTitle:@"提示" message:@"籍贯所在地！"];
        return NO;
    }
    
    self.applyPack.carrier = self.carrerField.text;
    if (self.applyPack.carrier.length == 0)
    {
        [UIAlertView showWithTitle:@"提示" message:@"职业必须要填写！"];
        return NO;
    }
    
    self.applyPack.baseNote = self.supplementTextView.text;
    
    return YES;
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
    
    [self.customNavigationBar setRightButtonWithStandardTitle:@"下一步"];
}

- (void) configSubviews
{
    CGSize navigatonBarSize = self.customNavigationBar.frame.size;
    
    self.scrollView.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
    CGRect scrollFrame = self.scrollView.frame;
    scrollFrame.origin.y = navigatonBarSize.height;
    scrollFrame.size.height = self.view.frame.size.height - navigatonBarSize.height;
    self.scrollView.frame = scrollFrame;
    
    [self.currentCityButton addTarget:self action:@selector(currentCityButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.domicileButton addTarget:self action:@selector(domicileButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nameField.delegate = self;
    self.liveLifeField.delegate = self;
    self.carrerField.delegate = self;
    self.supplementTextView.delegate = self;
    
    UIImage* bkgImage = [[UIImage imageNamed:@"agreement_field_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
    self.requiredInfoBackgroundView.image = bkgImage;
    self.optionalInfoBackgroundView.image = bkgImage;
    
    CGRect bottomViewFrame = self.supplementTextView.superview.frame;
    if (bottomViewFrame.origin.y + bottomViewFrame.size.height > scrollFrame.size.height)
    {
        self.scrollView.contentSize = CGSizeMake(scrollFrame.size.width, bottomViewFrame.origin.y + bottomViewFrame.size.height);
    }
    else
    {
        self.scrollView.contentSize = CGSizeMake(scrollFrame.size.width, scrollFrame.size.height + 32);
    }
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnScrollView:)];
    tap.cancelsTouchesInView = NO;
    [self.scrollView addGestureRecognizer:tap];
}

- (void) tapOnScrollView:(id)gesture
{
    [self.view endEditing:YES];
}

- (void) domicileButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    typeof(self) __weak bself = self;
    SYCityPickedViewController* controller = [[SYCityPickedViewController alloc] init];
    controller.pickedCityId = self.applyPack.birthCityId;
    controller.pickedProvinceId = self.applyPack.birthProvinceId;
    
    controller.citySelectedBlock = ^(NSInteger provincedId, NSInteger cityId, NSString* cityName){
        bself.applyPack.birthProvinceId = provincedId;
        bself.applyPack.birthCityId = cityId;
        bself.customNavigationBar.rightButton.hidden = NO;
        
        [bself.domicileButton setTitle:cityName forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) currentCityButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    
    typeof(self) __weak bself = self;
    SYCityPickedViewController* controller = [[SYCityPickedViewController alloc] init];
    controller.pickedCityId = self.applyPack.currentCityId;
    controller.pickedProvinceId = self.applyPack.currentProvinceId;
    
    controller.citySelectedBlock = ^(NSInteger provincedId, NSInteger cityId, NSString* cityName){
        
        bself.customNavigationBar.rightButton.hidden = NO;
        bself.applyPack.currentProvinceId = provincedId;
        bself.applyPack.currentCityId = cityId;
        
        [bself.currentCityButton setTitle:cityName forState:UIControlStateNormal];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - textfield delegate

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.keyboardHeight > 0)
    {
        [self setScrollViewContentOffsetForCarrerField];
    }
}

#pragma mark -  textview delegate

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    if (!self.textViewWasEdit)
    {
        self.supplementTextView.text = @"";
        self.textViewWasEdit = YES;
    }
    
    if (self.keyboardHeight > 0)
    {
        [self setScrollViewContentOffsetForSupplementTextView];
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (self.supplementTextView.text.length == 0)
    {
        self.textViewWasEdit = NO;
        self.supplementTextView.text = @"如果认证通过，会作为老师简介";
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (self.supplementTextView.text.length == 0)
    {
        self.textViewWasEdit = NO;
        self.supplementTextView.text = @"如果认证通过，会作为老师简介";
    }
}

#pragma mark - keyboard observers

- (void) setScrollViewContentOffsetForSupplementTextView
{
    //keyboard.height + textview.y - contentoffset.y + textview.height == scrollframe.height
    
    CGRect supplementFrame = self.supplementTextView.superview.frame;
    [self.scrollView setContentOffset:CGPointMake(0, self.keyboardHeight + supplementFrame.origin.y + supplementFrame.size.height - self.scrollView.frame.size.height) animated:YES];
}

- (void) setScrollViewContentOffsetForCarrerField
{
    CGRect carrerFrame = self.carrerField.superview.frame;
    CGFloat offsetY = self.keyboardHeight + carrerFrame.origin.y + carrerFrame.size.height - self.scrollView.frame.size.height;
    if (offsetY > 0)
    {
        [self.scrollView setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }
}

- (void) keyboardWithFrame:(CGRect)frame willShowInDuration:(NSTimeInterval)duration
{
    self.keyboardHeight = frame.size.height;
    
    if (self.supplementTextView.isFirstResponder)
    {
        [self setScrollViewContentOffsetForSupplementTextView];
    }
    else if (self.carrerField.isFirstResponder)
    {
        [self setScrollViewContentOffsetForCarrerField];
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
