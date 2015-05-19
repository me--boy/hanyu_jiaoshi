//
//  DFTeachersViewController.m
//  dafan
//
//  Created by iMac on 14-9-10.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFTeachersViewController.h"
#import "SYHttpRequest.h"
#import "UIAlertView+SYExtension.h"
#import "DFUrlDefine.h"
#import "UIButton+WebCache.h"
#import "DFCommonImages.h"
#import "DFTeacherItem.h"
#import "DFTeacherCoursesViewController.h"
#import "DFCourseTeacherTableViewCell.h"
#import "SYBaseContentViewController+EGORefresh.h"

@interface DFTeachersViewController ()

@property(nonatomic, strong) NSMutableArray* items;
@property(nonatomic) NSInteger offsetId;

@end

#define kTableViewHeight 105.0f

@implementation DFTeachersViewController

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
    
    [self configCustomNavigationBar];
    [self configTableView];
    
    self.items = [NSMutableArray array];
    [self requestData:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) configTableView
{
    self.tableView.rowHeight = kTableViewHeight;
    [self enableRefreshAtHeaderForScrollView:self.tableView];
    [self setClickToFetchMoreTableFooterView];
}

- (void) configCustomNavigationBar
{
    self.title = @"可报名的老师";
}

- (void) requestData:(BOOL)reload
{
    [self showProgress];
    typeof(self) __weak bself = self;
    
    NSDictionary* dict = nil;
    if (!reload)
    {
        dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:self.offsetId] forKey:@"offsetid"];
    }
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForRegisterableTeachers] postValues:dict finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            bself.offsetId = [[[resultInfo objectForKey:@"params"] objectForKey:@"offsetid"] integerValue];
            [bself hideProgress];
            if (!reload)
            {
                [bself.items removeAllObjects];
            }
            NSArray* infos = [resultInfo objectForKey:@"info"];
            for (NSDictionary* info in infos)
            {
                DFTeacherItem* item = [[DFTeacherItem alloc] initWithDictionary:info];
                [bself.items addObject:item];
            }
            [bself.tableView reloadData];
            [bself setTableFooterStauts:bself.offsetId > 0 empty:bself.items.count == 0];
            
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
            [bself setTableFooterStauts:YES empty:NO];
        }
    }];
    [self.requests addObject:request];
}

#define kCourseTeacherCell @"Cell"

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFTeacherItem* teacherItem = [self.items objectAtIndex:indexPath.row];
    
    DFCourseTeacherTableViewCell* cell = (DFCourseTeacherTableViewCell *)[tableView dequeueReusableCellWithIdentifier:kCourseTeacherCell];
    if (cell == nil)
    {
        NSArray* array = [[NSBundle mainBundle] loadNibNamed:@"DFCourseTeacherTableViewCell" owner:self options:nil];
        cell = array.firstObject;
        cell.backgroundColor = [UIColor clearColor];
        cell.avatarButton.userInteractionEnabled = NO;
    }
    cell.starView.pickedStarCount = teacherItem.rate;
    [cell.avatarButton setImageWithURL:[NSURL URLWithString:teacherItem.avatarUrl] forState:UIControlStateNormal placeholderImage:[DFCommonImages defaultAvatarImage]];
    cell.teacherNameLabel.text = teacherItem.nickname;
    cell.teacherBerifMessage.text = teacherItem.teacherDescription;
    cell.studentsLabel.text = [NSString stringWithFormat:@"%d人学习过", teacherItem.studentsCount];
    cell.memberImageView.hidden = teacherItem.member == 0;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DFTeacherItem* teacherItem = [self.items objectAtIndex:indexPath.row];
    
    DFTeacherCoursesViewController* controller = [[DFTeacherCoursesViewController alloc] initWithTeacherId:teacherItem.persistentId];
    controller.defaultTeacherItem = teacherItem;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
