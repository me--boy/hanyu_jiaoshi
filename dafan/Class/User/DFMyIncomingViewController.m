//
//  DFMyIncomingViewController.m
//  dafan
//
//  Created by iMac on 14-8-16.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFMyIncomingViewController.h"
#import "DFMyIncomingTableViewCell.h"
#import "SYConstDefine.h"
#import "DFColorDefine.h"
#import "SYHttpRequest.h"
#import "DFPaymentItem.h"
#import "DFUrlDefine.h"
#import "UIAlertView+SYExtension.h"
#import "NSDate+SYExtension.h"
#import "DFAgreementViewController.h"
#import "SYDeviceDescription.h"

@interface DFMyIncomingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *beginDateButton;
@property (weak, nonatomic) IBOutlet UIButton *endDateButton;
@property (weak, nonatomic) IBOutlet UILabel *totalIncomingLabel;
@property (weak, nonatomic) IBOutlet UIView *headerSepLineView;

@property(nonatomic, strong) NSMutableArray* items;

@property(nonatomic, strong) UIView* pickerFrameView;
@property(nonatomic, strong) NSDate* beginDate;
@property(nonatomic, strong) NSDate* endDate;

@property(nonatomic, strong) NSDate* pickedDate;

@property(nonatomic, strong) UITapGestureRecognizer* tapGesture;

@property(nonatomic) NSInteger pageIdx; //temp for test

@property(nonatomic) NSInteger offsetId;

@end

@implementation DFMyIncomingViewController

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
    
    self.items = [NSMutableArray array];
    [self configTableView];
    [self configCustomNavigationBar];
    
    [self requestData];
}

- (void) configCustomNavigationBar
{
    self.title = @"我的收入";
    [self.customNavigationBar setRightButtonWithStandardTitle:@"说明"];
}

- (void) rightButtonClicked:(id)sender
{
    DFAgreementViewController* controller = [[DFAgreementViewController alloc] init];
    controller.agreementStyle = DFAgreementStyleMyIncoming;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) configTableView
{
    self.tableView.rowHeight = 60;
    
    [self initTableHeaderView];
    
    [self setClickToFetchMoreTableFooterView];
    
    if (![SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    }
}

- (void) initTableHeaderView
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"DFMyIncomingHeaderView" owner:self options:nil];
    
    UIView* tableHeaderView = views.firstObject;
    [self.beginDateButton addTarget:self action:@selector(beginDateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.endDateButton addTarget:self action:@selector(endDateButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.headerSepLineView.backgroundColor = self.tableView.separatorColor;
    CGRect sepLineFrame = self.headerSepLineView.frame;
    sepLineFrame.origin.y = self.headerSepLineView.superview.frame.size.height - 0.5;
    sepLineFrame.size.height = 0.5f;
    self.headerSepLineView.frame = sepLineFrame;
    
    self.endDate = [NSDate date];
    self.beginDate = [NSDate dateWithTimeInterval:-(60 * 60 * 24 * 30) sinceDate:self.endDate];
    
    [self setTitle:[self.beginDate dateString] forButton:self.beginDateButton];
    [self setTitle:[self.endDate dateString] forButton:self.endDateButton];
    
    self.tableView.tableHeaderView = tableHeaderView;
}

- (void) setTitle:(NSString *)title forButton:(UIButton *)button
{
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateSelected];
}

- (void) requestMoreDataForTableFooterClicked
{
    ++self.pageIdx;
    
    [self setTableFooterStauts:self.pageIdx <= 5 empty:NO];
}

- (void) beginDateButtonClicked:(id)sender
{
    self.beginDateButton.selected = YES;
    [self showDatePicker:YES];
}

- (void) endDateButtonClicked:(id)sender
{
    self.endDateButton.selected = YES;
    [self showDatePicker:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)emptyFooterTitle
{
    return @"没有收入";
}

- (NSString *) normalFooterTitle
{
    return @"";
}

- (void) requestData
{
    typeof(self) __weak bself = self;
    
    [self showProgress];
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:[NSNumber numberWithInteger:[self.beginDate timeIntervalSince1970]] forKey:@"starttime"];
    [dict setObject:[NSNumber numberWithInteger:[self.endDate timeIntervalSince1970]] forKey:@"endtime"];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForIncoming] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        
        if (success)
        {
            [bself reloadDataWithInfos:[[resultInfo objectForKey:@"info"] objectForKey:@"userbalance"]];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
        [bself setTableFooterStauts:NO empty:bself.items.count == 0];
    }];
    [self.requests addObject:request];
}

- (void) reloadDataWithInfos:(NSArray *)infos
{
    for (NSDictionary* info in infos)
    {
        DFPaymentItem* item = [[DFPaymentItem alloc] initWithDictionary:info];
        [self.items addObject:item];
    }
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    NSInteger total = 0;
    for (DFPaymentItem* item in self.items)
    {
        item.dateText = [formatter stringFromDate:item.date];
        total += item.value;
    }
    
    self.totalIncomingLabel.text = [NSString stringWithFormat:@"总计：%d元", total];
    
    [self.tableView reloadData];
}

- (IBAction)searchButtonClicked:(id)sender
{
    [self.items removeAllObjects];
    [self requestData];
}

#pragma mark - tableview

#define kIncomingCell @"IncomingCell"

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFMyIncomingTableViewCell* cell = (DFMyIncomingTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kIncomingCell];
    
    if (cell == nil)
    {
        NSArray* cells = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([DFMyIncomingTableViewCell class]) owner:self options:nil];
        cell = cells.firstObject;
    }
    
    DFPaymentItem* item = [self.items objectAtIndex:indexPath.row];
    
    cell.dateTimeLabel.text = item.dateText;
    cell.tuitionLabel.text = [NSString stringWithFormat:@"%d", item.value];
    cell.descriptionLabel.text = item.comment;
    
    return cell;
}

#pragma mark - date picker

#define kBeginDatePicker 1024
#define kEndDatePicker 1025

#define kTopButtonHeight 36
#define kTopButtonWidth 80
#define kTopButtonMarginHori 8
#define kTopButtonMarginVer 2

#define kDatePickerViewHeight 216

#define kDatePickerFrameViewHeight (kTopButtonHeight + kDatePickerViewHeight)

- (void) showDatePicker:(BOOL)isBeginDate
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
    
    [okButton setTitle:@"确定" forState:UIControlStateNormal];
    okButton.backgroundColor = [UIColor clearColor];
    [okButton setTitleColor:kMainDarkColor forState:UIControlStateNormal];
    okButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [okButton addTarget:self action:@selector(pickerOKButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.pickerFrameView addSubview:okButton];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kTopButtonHeight - 1, size.width, 1)];
    lineView.backgroundColor = RGBCOLOR(241, 241, 241);
    [self.pickerFrameView addSubview:lineView];
    
    UIDatePicker* picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, kTopButtonHeight, size.width, kDatePickerViewHeight)];
    picker.backgroundColor = [UIColor whiteColor];
    picker.datePickerMode = UIDatePickerModeDate;
    picker.minimumDate = [NSDate dateWithDateFormattedString:@"2014-01-10"];
    picker.maximumDate = [NSDate date];


    [picker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    [self.pickerFrameView addSubview:picker];
    
    [self.view addSubview:self.pickerFrameView];
    
    if (isBeginDate)
    {
        self.pickerFrameView.tag = kBeginDatePicker;
        okButton.tag = kBeginDatePicker;
        picker.date = self.beginDate;
        self.pickedDate = self.beginDate;
    }
    else
    {
        self.pickerFrameView.tag = kEndDatePicker;
        okButton.tag = kEndDatePicker;
        picker.date = self.endDate;
        self.pickedDate = self.endDate;
    }
    
    self.tapGesture.enabled = YES;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        self.pickerFrameView.frame = CGRectMake(0, size.height - kDatePickerFrameViewHeight, size.width, kDatePickerFrameViewHeight);
        
    }];
}

- (void) dateChanged:(UIDatePicker *)birthdayPicker
{
    self.pickedDate = birthdayPicker.date;
}

- (void) hidePickerFrameView
{
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.15 animations:^{
        
        CGSize size = self.view.frame.size;
        bself.pickerFrameView.frame = CGRectMake(0, size.height, size.width, kDatePickerFrameViewHeight);
        
    } completion:^(BOOL finished){
        
        bself.tapGesture.enabled = NO;
        
        [bself.pickerFrameView removeFromSuperview];
        bself.pickerFrameView = nil;
        
        bself.beginDateButton.selected = NO;
        bself.endDateButton.selected = NO;
        bself.pickedDate = nil;
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
    switch (button.tag) {
        case kBeginDatePicker:
            self.beginDate = self.pickedDate;
            [self setTitle:[self.beginDate dateString] forButton:self.beginDateButton];
            break;
        case kEndDatePicker:
            self.endDate = self.pickedDate;
            [self setTitle:[self.endDate dateString] forButton:self.endDateButton];
            break;
            
        default:
            break;
    }
    
    [self hidePickerFrameView];
    
    if ([self.endDate compare:self.beginDate] ==NSOrderedDescending)
    {
        [self.tableView reloadData];
    }
}

- (void) pickerCancelButtonClicked:(id)sender
{
    [self hidePickerFrameView];
}

@end
