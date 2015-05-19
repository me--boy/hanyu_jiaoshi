//
//  MYTextViewController.m
//  MY
//
//  Created by iMac on 14-4-18.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTextViewInputController.h"
#import "SYPrompt.h"
#import "SYDeviceDescription.h"

@interface SYTextViewInputController ()<UITextViewDelegate, UIActionSheetDelegate>

@property(nonatomic, strong) UITextView* textView;
@property(nonatomic, strong) UILabel* leftCountLabel;

@property(nonatomic) SYTextInputStyle textInputStyle;

@end

@implementation SYTextViewInputController
@synthesize textView = _textView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (id) initWithInputStyle:(SYTextInputStyle)style
{
    self = [super init];
    if (self)
    {
        self.textInputStyle = style;
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initSubviews];
    [self configCustomNavigationBar];
    
    [self.textView becomeFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configCustomNavigationBar
{
    self.title = self.titleText;
    
    switch (self.textInputStyle) {
        case SYTextInputStyleCommit:
            [self.customNavigationBar setRightButtonWithStandardTitle:@"提交"];
            break;
        case SYTextInputStyleEdit:
            [self.customNavigationBar setRightButtonWithStandardTitle:@"确定"];
            break;
            
        default:
            break;
    }
}

- (void) leftButtonClicked:(id)sender
{
    if (self.textInputStyle == SYTextInputStyleEdit && !(self.defaultText.length == 0 && self.textView.text.length == 0) && ![self.defaultText isEqualToString:self.textView.text])
    {
        [self popupConfirmActionSheet];
        return;
    }
    [super leftButtonClicked:sender];
}

- (void) rightButtonClicked:(id)sender
{
    if (self.textView.text.length > self.maxTextCount || self.textView.text.length == 0)
    {
        [SYPrompt showWithText:@"字数不对"];
        return;
    }
    [self.delegate textViewInputController:self inputText:self.textView.text];
    
    [super leftButtonClicked:nil];
}

- (void) popupConfirmActionSheet
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle:@"放弃修改?" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles: nil];
    [sheet showInView:self.view];
}

#pragma mark - action sheet delegate

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [super leftButtonClicked:nil];
    }
}

#define kLeftTextCountHeight 20
#define kLeftTextCountWidth 36
#define kTextClearSize 20
#define kClearCountSpace 4

#define kTextViewMarginLeft 8
#define kTextViewMarginTop 8

#define kTextLineHeight 12

#define kTextSingleLineHeight 48
#define kTextMultiLineHeight 160

- (void) initSubviews
{
    CGSize size = self.view.frame.size;
    
    CGFloat inputFrameHeight = 0;
    CGFloat inputFrameWidth = 0;
    CGFloat textViewHeight = 0;
    CGFloat textViewWidth = 0;
    CGFloat offsetY = kTextViewMarginTop + 44;
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        offsetY += 20;
    }
    CGFloat clearButtonCountLabelOffsetY = 0;
    
    CGFloat fontSize = 0;
    if (self.numberOfLines > 1)
    {
        
        inputFrameHeight = kTextMultiLineHeight;
        textViewHeight = kTextMultiLineHeight - kTextClearSize - 4;
        
        clearButtonCountLabelOffsetY = offsetY + textViewHeight + 4;
        
        inputFrameWidth = textViewWidth = size.width - 2 * kTextViewMarginLeft;
        
        fontSize = 16;
    }
    else
    {
        clearButtonCountLabelOffsetY = offsetY + 4;
        
        inputFrameHeight =  kTextSingleLineHeight;
        textViewHeight = inputFrameHeight - 2;
        
        inputFrameWidth = size.width - 2 * kTextViewMarginLeft;
        textViewWidth = inputFrameWidth - kLeftTextCountWidth - kTextClearSize - kClearCountSpace;
        
        fontSize = 12;
    }
    
    UIImageView* inputBkgView = [[UIImageView alloc] initWithFrame:CGRectMake(kTextViewMarginLeft, offsetY, inputFrameWidth, inputFrameHeight)];
//    inputBkgView.backgroundColor = [UIColor grayColor];
    UIImage* image = [[UIImage imageNamed:@"text_input_frame.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20) resizingMode:UIImageResizingModeStretch];
    inputBkgView.image = image;
    [self.view addSubview:inputBkgView];
    
    
    self.textView = [[UITextView alloc] initWithFrame:CGRectMake(kTextViewMarginLeft + 1, offsetY + 1, textViewWidth - 2, textViewHeight)];
    self.textView.keyboardType = self.keyboardType;
    self.textView.textColor = [UIColor blackColor];
    self.textView.font = [UIFont systemFontOfSize:fontSize];
    self.textView.text = self.defaultText;
    self.textView.delegate = self;
    self.textView.scrollEnabled = NO;
    [self.view addSubview:self.textView];
    
    if (self.defaultText.length == 0)
    {
        self.textView.textColor = [UIColor grayColor];
        self.textView.text = self.placeHolder;
    }
    
    if (self.numberOfLines == 1)
    {
        CGSize contentSize = self.textView.frame.size;
        contentSize.height = 18;
        self.textView.contentSize = contentSize;
        
        self.textView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0);
    }
    
    if (self.maxTextCount > 0 && self.numberOfLines > 1)
    {
        
        CGFloat offsetX = self.view.frame.size.width - kTextViewMarginLeft - kTextClearSize;
        
        UIButton* clearTextButton = [[UIButton alloc] initWithFrame:CGRectMake(offsetX, clearButtonCountLabelOffsetY, kTextClearSize, kTextClearSize)];
        [clearTextButton setImage:[UIImage imageNamed:@"text_input_clear.png"] forState:UIControlStateNormal];
        clearTextButton.backgroundColor = [UIColor clearColor];
        [clearTextButton addTarget:self action:@selector(clearTextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:clearTextButton];
        
        offsetX -= kClearCountSpace + kLeftTextCountWidth;
        self.leftCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, clearButtonCountLabelOffsetY, kLeftTextCountWidth, kLeftTextCountHeight)];
        self.leftCountLabel.backgroundColor = [UIColor clearColor];
        self.leftCountLabel.textAlignment = NSTextAlignmentRight;
        self.leftCountLabel.textColor = [UIColor grayColor];
        self.leftCountLabel.font = [UIFont systemFontOfSize:10];
        self.leftCountLabel.text = [NSString stringWithFormat:@"%d", self.maxTextCount - self.defaultText.length];
        [self.view addSubview:self.leftCountLabel];
    }
}

- (void) clearTextButtonClicked:(id)sender
{
    self.textView.text = @"";
    self.leftCountLabel.text = [NSString stringWithFormat:@"%d", self.maxTextCount];
}

- (void) textViewDidBeginEditing:(UITextView *)textView
{
    textView.textColor = [UIColor blackColor];
    if ([textView.text isEqualToString:self.placeHolder])
    {
        textView.text = @"";
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView
{
    if (textView.text.length == 0)
    {
        textView.text = self.placeHolder;
        textView.textColor = [UIColor grayColor];
    }
}

- (void) textViewDidChange:(UITextView *)textView
{
    if (self.textView.markedTextRange == nil)
    {
        if (self.textView.text.length > self.maxTextCount)
        {
            self.textView.text = [self.textView.text substringWithRange:NSMakeRange(0, self.maxTextCount)];
        }
        self.leftCountLabel.text = [NSString stringWithFormat:@"%d", self.maxTextCount - self.textView.text.length];
    }
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (self.textView.markedTextRange == nil)
    {
        if (self.textView.text.length >= self.maxTextCount && ![text isEqualToString:@""])
        {
            return NO;
        }
    }
    if ([text isEqualToString:@"\n"])
    {
        if (self.textView.text.length > self.maxTextCount)
        {
            self.textView.text = [self.textView.text substringToIndex:self.maxTextCount];
        }
        [self.textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
