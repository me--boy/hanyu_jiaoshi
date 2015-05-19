//
//  DFSelfStudyViewController.m
//  dafan
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYStandardNavigationBar.h"
#import "DFSelfStudyViewController.h"
#import "DFClassroomViewController.h"
#import "SYConstDefine.h"
#import "DFChapterSectionViewController.h"
#import "DFFilmClipsViewController.h"
#import "DFFilePath.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "DFColorDefine.h"
#import "DFSectionVoiceViewController.h"

@interface DFSelfStudyViewController ()

@property(nonatomic, strong) DFChapterSectionViewController* dailyViewController;
@property(nonatomic, strong) DFFilmClipsViewController* filmClipsViewController;

@property(nonatomic, strong) UIButton* leftTabButton;
@property(nonatomic, strong) UIButton* rightTabButton;

@end

@implementation DFSelfStudyViewController

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
    //天天韩语
    self.dailyViewController = [[DFChapterSectionViewController alloc] initWithChapterSectionStyle:DFChapterSectionStyleDailySence];
    self.dailyViewController.navigationBarStyle = SYNavigationBarStyleNone;
    [self addChildViewController:self.dailyViewController];
    //玩转台词
    self.filmClipsViewController = [[DFFilmClipsViewController alloc] init];
    self.filmClipsViewController.navigationBarStyle = SYNavigationBarStyleNone;
    [self addChildViewController:self.filmClipsViewController];
    
    [self setDailyViewOn];
}
/**
 *  默认显示  天天韩语
 */
- (void) setDailyViewOn
{
    CGRect frame = self.dailyViewController.view.frame;
    frame.origin.y = self.customNavigationBar.frame.size.height;
    frame.size.height = self.view.frame.size.height - frame.origin.y;
    self.dailyViewController.view.frame = frame;
    
    [self.view addSubview:self.dailyViewController.view];
}

#define kTabButtonWidth 100.f
#define kTabButtonHeight 30.f
#define kTabButtonMarginBottom 8.f

- (void) rightButtonClicked:(id)sender
{
    NSFileManager* mgr = [NSFileManager defaultManager];
    [mgr removeItemAtPath:[DFFilePath dailiesDirectory] error:nil];
    [mgr removeItemAtPath:[DFFilePath sentenceAudiosDirectory] error:nil];
    [mgr removeItemAtPath:[DFFilePath sentenceVoicesDirectory] error:nil];
    
    [DFFilePath ensureDirectory:[DFFilePath dailiesDirectory]];
    [DFFilePath ensureDirectory:[DFFilePath sentenceAudiosDirectory]];
    [DFFilePath ensureDirectory:[DFFilePath sentenceVoicesDirectory]];
    
    [self.dailyViewController reloadDataForRefresh];
}

- (void) configCustomNavigationBar
{
//    [self.customNavigationBar setRightButtonWithStandardTitle:@"XCaches"];
    
    self.customNavigationBar.leftButton.hidden = YES;
    
    CGRect frame = self.customNavigationBar.frame;
    [self.customNavigationBar.titleButton removeFromSuperview];
    
    self.leftTabButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 2 - kTabButtonWidth, frame.size.height - kTabButtonMarginBottom - kTabButtonHeight, kTabButtonWidth, kTabButtonHeight)];
    [self.leftTabButton setBackgroundImage:[UIImage imageNamed:@"top_tab_left_normal.png"] forState:UIControlStateNormal];
    [self.leftTabButton setBackgroundImage:[UIImage imageNamed:@"top_tab_left_selected.png"] forState:UIControlStateSelected];
    [self.leftTabButton setTitleColor:kMainDarkColor forState:UIControlStateSelected];
    [self.leftTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.leftTabButton addTarget:self action:@selector(tabLeftButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftTabButton setTitle:@"天天韩语" forState:UIControlStateNormal];
    self.leftTabButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [self.customNavigationBar addSubview:self.leftTabButton];
    self.leftTabButton.selected = YES;
    
    self.rightTabButton = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width / 2, frame.size.height - kTabButtonMarginBottom - kTabButtonHeight, kTabButtonWidth, kTabButtonHeight)];
    [self.rightTabButton setBackgroundImage:[UIImage imageNamed:@"top_tab_right_normal.png"] forState:UIControlStateNormal];
    [self.rightTabButton setBackgroundImage:[UIImage imageNamed:@"top_tab_right_selected.png"] forState:UIControlStateSelected];
    [self.rightTabButton setTitleColor:kMainDarkColor forState:UIControlStateSelected];
    [self.rightTabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.rightTabButton addTarget:self action:@selector(tabRightButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightTabButton setTitle:@"玩转台词" forState:UIControlStateNormal];
    self.rightTabButton.titleLabel.font = [UIFont systemFontOfSize:15.f];
    [self.customNavigationBar addSubview:self.rightTabButton];
}

- (void) selectLeft
{
    if (self.leftTabButton.selected)
    {
        return;
    }
    self.leftTabButton.selected = YES;
    self.rightTabButton.selected = NO;
    
    if ([self.filmClipsViewController isViewLoaded])
    {
        [self.filmClipsViewController.view removeFromSuperview];
    }
    
    [self.view addSubview:self.dailyViewController.view];
}

- (void) selectRight
{
    if (self.rightTabButton.selected)
    {
        return;
    }
    self.rightTabButton.selected = YES;
    self.leftTabButton.selected = NO;
    
    [self.dailyViewController.view removeFromSuperview];
    
    if ([self.filmClipsViewController isViewLoaded])
    {
        [self.view addSubview:self.filmClipsViewController.view];
    }
    else
    {
        CGRect frame = self.filmClipsViewController.view.frame;
        frame.origin.y = self.customNavigationBar.frame.size.height;
        frame.size.height = self.view.frame.size.height - frame.origin.y;
        self.filmClipsViewController.view.frame = frame;
        
        [self.view addSubview:self.filmClipsViewController.view];
    }
    
    [self.dailyViewController clearSelectedChapterSection];
}

- (void) tabLeftButtonClicked:(UIButton *)sender
{
    [self selectLeft];
}

- (void) tabRightButtonClicked:(UIButton *)sender
{
    [self selectRight];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
