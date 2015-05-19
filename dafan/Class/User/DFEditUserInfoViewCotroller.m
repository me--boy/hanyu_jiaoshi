//
//  MYProfileBaseInfoViewCotroller.m
//  MY
//
//  Created by iMac on 14-4-18.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "DFEditUserInfoViewCotroller.h"
#import "UIView+SYShape.h"
#import "UIImageView+WebCache.h"
#import "DFUrlDefine.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "SYHttpRequest.h"
#import "UIImage+SYExtension.h"
#import "SYConstDefine.h"
#import "DFCommonImages.h"
#import "UIAlertView+SYExtension.h"
#import "SYCityPickedViewController.h"
#import "NSDate+SYExtension.h"
#import "DFPreference.h"
#import "DFUserProfile.h"
#import "DFUrlDefine.h"
#import "DFColorDefine.h"
#import "SYPhotoPicker.h"
#import "DFNotificationDefines.h"
#import "DFUserProfile.h"
#import "SYTextViewInputController.h"

#define kActionSheetTagDiscardModification 1024
#define kActionSheetTagAvatarPicker 1025

#pragma mark - 

//@interface DFGenderPicker : UIView
//
//@property(nonatomic, strong) UIButton* maleButton;
//@property(nonatomic, strong) UIButton* femaleButton;
//
//@property(nonatomic) SYGenderType gender;
//
//@end
//
//@implementation DFGenderPicker
//
//- (id) initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        [self initSubviews];
//         [self setBorderColor:self.layer color:RGBCOLOR(199, 199, 205)];
//    }
//    return self;
//}
//
//- (void) setGender:(SYGenderType)gender
//{
//    _gender = gender;
//    switch (gender) {
//        case SYGenderTypeFemale:
//            self.maleButton.selected = NO;
//            self.femaleButton.selected = YES;
//            break;
//        case SYGenderTypeMale:
//            self.maleButton.selected = YES;
//            self.femaleButton.selected = NO;
//            break;
//            
//        default:
//            break;
//    }
//}
//
//- (void) initSubviews
//{
//    CGSize size = self.frame.size;
//    CGFloat halfWidth = size.width / 2;
//    
//    UIView* hLineView = [[UIView alloc] initWithFrame:CGRectMake(halfWidth, 0, 1, size.height)];
//    hLineView.backgroundColor = RGBCOLOR(199, 199, 205);
//    [self addSubview:hLineView];
//    
//    self.maleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, halfWidth, size.height)];
//    self.maleButton.backgroundColor = [UIColor clearColor];
//    [self.maleButton setTitleColor:RGBCOLOR(145, 145, 145) forState:UIControlStateNormal];
//    [self.maleButton setTitleColor:kMainDarkColor forState:UIControlStateSelected];
//    self.maleButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.maleButton addTarget:self action:@selector(maleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [self.maleButton setTitle:@"男" forState:UIControlStateNormal];
//    [self addSubview:self.maleButton];
//    
//    self.femaleButton = [[UIButton alloc] initWithFrame:CGRectMake(halfWidth, 0, halfWidth, size.height)];
//    self.femaleButton.backgroundColor = [UIColor clearColor];
//    [self.femaleButton setTitleColor:RGBCOLOR(145, 145, 145) forState:UIControlStateNormal];
//    [self.femaleButton setTitleColor:kMainDarkColor forState:UIControlStateSelected];
//    [self.femaleButton addTarget:self action:@selector(femaleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    self.femaleButton.titleLabel.font = [UIFont systemFontOfSize:14];
//    [self.femaleButton setTitle:@"女" forState:UIControlStateNormal];
//    [self addSubview:self.femaleButton];
//}
//
//- (void) maleButtonClicked:(id)sender
//{
//    self.gender = SYGenderTypeMale;
//}
//
//- (void) femaleButtonClicked:(id)sender
//{
//    self.gender = SYGenderTypeFemale;
//}
//
//@end

#pragma mark -

@interface DFEditUserInfoViewCotroller ()<UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, SYPhtoPickerDelegate, SYTextViewInputControllerDelegate>

@property(nonatomic, strong) UIImageView* avatarImageView;
@property(nonatomic, strong) UILabel* nicknameLabel;
@property(nonatomic, strong) UILabel* cityLabel;
@property(nonatomic, strong) UILabel* genderLabel;

@property(nonatomic, strong) UIView* pickerFrameView;

@property(nonatomic, strong) SYPhotoPicker* photoPicker;

@property(nonatomic, strong) NSString* pickedCity;
@property(nonatomic) NSInteger pickedProvincedId;
@property(nonatomic) NSInteger pickedCityId;
@property(nonatomic) SYGenderType pickedGender;
@property(nonatomic) SYGenderType prepareGender;

@property(nonatomic, strong) NSString* editingNickname;

@property(nonatomic, strong) UIImage* pickedAvatarImage;
@property(nonatomic, strong) NSData* pickedImageData;
@property(nonatomic, strong) NSString* pickedAvatarUrl;
/**
 *  这个手势是为了在用户进行性别选择的时候使用的
 */
@property(nonatomic, strong) UITapGestureRecognizer* tapGesture;

@end

@implementation DFEditUserInfoViewCotroller

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
    
    self.prepareGender = SYGenderTypeCount;
    self.pickedGender = [DFPreference sharedPreference].currentUser.gender;
    //导航栏的设置
    [self configCustomNavigationBar];
    //
    [self initSubviews];
    
    [self addTapGesture];
}

- (void) configCustomNavigationBar
{
    self.title = @"个人资料修改";
    [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
}

- (void) leftButtonClicked:(id)sender
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (self.pickedImageData != nil
        || self.editingNickname != nil
        || self.pickedGender != user.gender
        || self.pickedCity != nil)
    {
        [self popupConfirmActionSheet];
        return;
    }
    
    [super leftButtonClicked:sender];
}

- (void) popupConfirmActionSheet
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"放弃修改?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    sheet.tag = kActionSheetTagDiscardModification;
    [sheet showInView:self.view];
}

- (void) rightButtonClicked:(id)sender
{
    [self showProgress];
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
                
                NSString* url = [[resultInfo objectForKey:@"info"] objectForKey:@"url"];
                
                bself.pickedAvatarUrl = url;
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
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    if (self.editingNickname.length > 0)
    {
        user.nickname = self.editingNickname;
        [dict setObject:self.editingNickname forKey:@"nickname"];
    }
    if (self.pickedAvatarUrl.length > 0)
    {
        user.avatarUrl = self.pickedAvatarUrl;
        [dict setObject:self.pickedAvatarUrl forKey:@"avatar"];
    }
    if (self.pickedCity.length > 0)
    {
        user.city = self.pickedCity;
        user.cityId = self.pickedCityId;
        user.provinceId = self.pickedProvincedId;
        
        [dict setObject:[NSNumber numberWithInt:self.pickedProvincedId] forKey:@"prov_id"];
        [dict setObject:[NSNumber numberWithInt:self.pickedCityId] forKey:@"city_id"];
    }
    if (self.pickedGender != SYGenderTypeCount)
    {
        user.gender = self.pickedGender;
        [dict setObject:[NSNumber numberWithInteger:self.pickedGender] forKey:@"gender"];
    }
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCompleteUserInfo] postValues:dict finished:
                              ^(BOOL succeed, NSDictionary* resultInfo, NSString* errorMessage){
                                  
                                  [bself hideProgress];
                                  
                                  if (succeed)
                                  {
                                      [super leftButtonClicked:nil];
                                      [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationUserInfoUpdated object:nil];
                                  }
                                  else
                                  {
                                      [UIAlertView showNOPWithText:errorMessage];
                                  }
                              }];
    [self.requests addObject:request];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#define kAvatarSize 54
#define kMarginLeft 8
#define kTextColor RGBCOLOR(132, 143, 149)

- (void) initSubviews
{
    [self addSection0Views];
    [self addSection1Views];
}

- (UIImage *) sectionBkgImage
{
    return [[UIImage imageNamed:@"agreement_field_bkg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8) resizingMode:UIImageResizingModeStretch];
}

- (void) addSection0Views
{
    CGSize size = self.view.frame.size;
    
    UIView* avatarContainerView = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, self.customNavigationBar.frame.size.height + 17, size.width - 2 * kMarginLeft, 56)];
    
    UIButton* avatarBkgButton = [self buttonWithTitle:@"修改头像" frame:avatarContainerView.bounds titleMarginLeft:72];
    [avatarBkgButton setBackgroundImage:[self sectionBkgImage] forState:UIControlStateNormal];
    [avatarBkgButton addTarget:self action:@selector(showAddPhotoActionSheet) forControlEvents:UIControlEventTouchUpInside];
    [avatarContainerView addSubview:avatarBkgButton];
    
    self.avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 44, 44)];
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:[DFPreference sharedPreference].currentUser.avatarUrl] placeholderImage:[DFCommonImages defaultAvatarImage]];
    [avatarContainerView addSubview:self.avatarImageView];
    
    [avatarContainerView addSubview:[self arrowViewWithBaseY:0]];
    
    [self.view addSubview:avatarContainerView];
}

- (void) addSection1Views
{
    
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    CGSize size = self.view.frame.size;
    
    //all
    UIView* containerView = [[UIView alloc] initWithFrame:CGRectMake(kMarginLeft, self.customNavigationBar.frame.size.height + 80, size.width - 2 * kMarginLeft, 160)];
    
    UIImageView* bkgView = [[UIImageView alloc] initWithFrame:containerView.bounds];
    bkgView.image = [self sectionBkgImage];
    [containerView addSubview:bkgView];
    
    //nickname
    UIButton* nicknameButton = [self buttonWithTitle:@"昵称" frame:CGRectMake(0, 0, containerView.frame.size.width, 53) titleMarginLeft:20];
    [nicknameButton addTarget:self action:@selector(pushNicknameViewController) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:nicknameButton];
    
    self.nicknameLabel = [self labelWithTitle:@"" frame:CGRectMake(62, 0, 203, 53)];
    self.nicknameLabel.textAlignment = NSTextAlignmentRight;
    self.nicknameLabel.text = user.nickname;
    self.nicknameLabel.font = [UIFont boldSystemFontOfSize:15];
    [containerView addSubview:self.nicknameLabel];
    
    [containerView addSubview:[self arrowViewWithBaseY:0]];
    
    //gender
    UIButton* genderButton = [self buttonWithTitle:@"性别" frame:CGRectMake(0, 53, containerView.frame.size.width, 53) titleMarginLeft:20];
    [genderButton addTarget:self action:@selector(genderButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:genderButton];
    
    self.genderLabel = [self labelWithTitle:@"" frame:CGRectMake(62, 53, 203, 53)];
    self.genderLabel.textAlignment = NSTextAlignmentRight;
    self.genderLabel.text = (user.gender == SYGenderTypeMale ? @"男" : @"女");
    self.genderLabel.font = [UIFont boldSystemFontOfSize:15];
    [containerView addSubview:self.genderLabel];
    
    [containerView addSubview:[self arrowViewWithBaseY:53]];
    
    //city
    UIButton* cityPickerButton = [self buttonWithTitle:@"所在地" frame:CGRectMake(0, 106, containerView.frame.size.width, 53) titleMarginLeft:20];
    [cityPickerButton addTarget:self action:@selector(pushCityPickedController) forControlEvents:UIControlEventTouchUpInside];
    [containerView addSubview:cityPickerButton];
    
    self.cityLabel = [self labelWithTitle:@"" frame:CGRectMake(62, 106, 203, 53)];
    self.cityLabel.textAlignment = NSTextAlignmentRight;
    self.cityLabel.text = user.city;
    self.cityLabel.font = [UIFont boldSystemFontOfSize:15];
    [containerView addSubview:self.cityLabel];
    
    [containerView addSubview:[self arrowViewWithBaseY:106]];
    
    //line
    UIView* vLine0 = [self lineViewWithOriginY:53];
    [containerView addSubview:vLine0];
    
    UIView* vLine1 = [self lineViewWithOriginY:106];
    [containerView addSubview:vLine1];
    
    [self.view addSubview:containerView];
}

- (UIView *) arrowViewWithBaseY:(CGFloat)baseY
{
    UIImageView* arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default_arrow.png"]];
    arrowImageView.frame = CGRectMake(self.view.frame.size.width - 2 * kMarginLeft - 30 , baseY + (56 - 14) / 2, 8, 14);
    return arrowImageView;
}

- (UIView *) lineViewWithOriginY:(CGFloat)offsetY
{
    UIView* view = [[UIView alloc] initWithFrame:CGRectMake(4, offsetY, self.view.frame.size.width - 2 * kMarginLeft - 8, 1)];
    view.backgroundColor = RGBCOLOR(220, 220, 220);
    return view;
}

- (UILabel *) labelWithTitle:(NSString *)title frame:(CGRect)frame
{
    UILabel* label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kTextColor;
    label.font = [UIFont systemFontOfSize:15];
    label.text = title;
    return label;
}

- (UIButton *) buttonWithTitle:(NSString *)title frame:(CGRect)frame titleMarginLeft:(CGFloat)titleMarginLeft
{
    UIButton* button = [[UIButton alloc] initWithFrame:frame];
    button.backgroundColor = [UIColor clearColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:kTextColor forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    button.titleEdgeInsets = UIEdgeInsetsMake(0, titleMarginLeft, 0, 0);
    return button;
}



#define kTextViewNicknameTag 1023
#define kTextViewSignTag 1024
#define kTextViewAgeTag 1025

- (void) genderButtonClicked:(id)sender
{
    [self showGenderPicker];
}

- (void) pushNicknameViewController
{
    SYTextViewInputController* nicknameControlelr = [[SYTextViewInputController alloc] init];
    nicknameControlelr.tag = kTextViewNicknameTag;
    nicknameControlelr.maxTextCount = 12;
    nicknameControlelr.numberOfLines = 1;
    nicknameControlelr.defaultText = self.editingNickname.length > 0 ? self.editingNickname : [DFPreference sharedPreference].currentUser.nickname;
    nicknameControlelr.titleText = @"昵称";
    nicknameControlelr.delegate = self;
    [self.navigationController pushViewController:nicknameControlelr animated:YES];
}

- (void) pushCityPickedController
{
    typeof(self) __weak bself = self;
    SYCityPickedViewController* controller = [[SYCityPickedViewController alloc] init];
    controller.pickedCityId = self.pickedCityId;
    controller.pickedProvinceId = self.pickedProvincedId;
    //选中地址回调
    controller.citySelectedBlock = ^(NSInteger provincedId, NSInteger cityId, NSString* cityName){
        bself.pickedProvincedId = provincedId;
        bself.pickedCityId = cityId;
        bself.pickedCity = cityName;
        bself.cityLabel.text = cityName;
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) textViewInputController:(SYTextViewInputController *)textViewController inputText:(NSString *)text
{
    if (textViewController.tag == kTextViewNicknameTag)
    {
        self.nicknameLabel.text = text;
        self.editingNickname = text;
    }
}

- (void) showAddPhotoActionSheet
{
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
    self.pickedAvatarImage = image;
    self.pickedImageData = data;
    
    self.avatarImageView.image = image;
    
    self.photoPicker = nil;
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == kActionSheetTagDiscardModification)
    {
        if (buttonIndex == 0)
        {
            [super leftButtonClicked:nil];
        }
    }
}

#pragma mark - gender picker

#define kTopButtonHeight 36
#define kTopButtonWidth 80
#define kTopButtonMarginHori 8
#define kTopButtonMarginVer 2

#define kDatePickerViewHeight 126

#define kDatePickerFrameViewHeight (kTopButtonHeight + kDatePickerViewHeight)

- (void) showGenderPicker
{
    CGSize size = self.view.frame.size;
    
    self.pickerFrameView = [[UIView alloc] initWithFrame:CGRectMake(0, size.height, size.width, kDatePickerFrameViewHeight)];
    self.pickerFrameView.backgroundColor = [UIColor whiteColor];
    
    UIButton* cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(kTopButtonMarginHori, kTopButtonMarginVer, kTopButtonWidth, kTopButtonHeight)];
    cancelButton.backgroundColor = [UIColor clearColor];
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    cancelButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [cancelButton addTarget:self action:@selector(pickerCancelButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerFrameView addSubview:cancelButton];
    
    UIButton* okButton = [[UIButton alloc] initWithFrame:CGRectMake(size.width - kTopButtonMarginHori - kTopButtonWidth, kTopButtonMarginVer, kTopButtonWidth, kTopButtonHeight)];
    //    okButton.tag = isBeginDate ? kBeginDatePicker : kEndDatePicker;
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [okButton addTarget:self action:@selector(pickerOKButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerFrameView addSubview:okButton];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopButtonHeight - 1, size.width, 1)];
    lineView.backgroundColor = RGBCOLOR(241, 241, 241);
    [self.pickerFrameView addSubview:lineView];
    
    UIPickerView* picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, kTopButtonHeight, size.width, kDatePickerViewHeight)];
    picker.delegate = self;
    
    picker.backgroundColor = [UIColor whiteColor];
    [self.pickerFrameView addSubview:picker];
    
    [self.view addSubview:self.pickerFrameView];
    
    self.tapGesture.enabled = YES;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        self.pickerFrameView.frame = CGRectMake(0, size.height - kDatePickerFrameViewHeight, size.width, kDatePickerFrameViewHeight);
        [picker selectRow:self.pickedGender inComponent:0 animated:NO];
    }];
}


- (void) hidePickerFrameView
{
    [UIView animateWithDuration:0.15 animations:^{
        
        CGSize size = self.view.frame.size;
        self.pickerFrameView.frame = CGRectMake(0, size.height, size.width, kDatePickerFrameViewHeight);
        
    } completion:^(BOOL finished){
        
        self.tapGesture.enabled = NO;
        
        [self.pickerFrameView removeFromSuperview];
        self.pickerFrameView = nil;
    }];
}

- (void) addTapGesture
{
    self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnView:)];
    self.tapGesture.enabled = NO;
    [self.view addGestureRecognizer:self.tapGesture];
}

- (void) tapOnView:(UIGestureRecognizer *)gesture
{
    if (self.pickerFrameView.superview == self.view)
    {
        [self hidePickerFrameView];
    }
}

- (void) pickerOKButtonClicked:(UIButton *)button
{
    [self hidePickerFrameView];
    
    if (self.prepareGender != SYGenderTypeCount)
    {
        self.pickedGender = self.prepareGender;
        self.genderLabel.text = self.pickedGender == SYGenderTypeMale ? @"男" : @"女";
    }
}

- (void) pickerCancelButtonClicked:(id)sender
{
    [self hidePickerFrameView];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return SYGenderTypeCount;
}

- (NSString *) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (row) {
        case 0:
            return @"女";
        case 1:
            return @"男";
            
        default:
            return @"";
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.prepareGender = row;
}

@end
