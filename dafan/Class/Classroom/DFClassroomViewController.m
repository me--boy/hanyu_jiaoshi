//
//  DFClassroomViewController.m
//  dafan
//
//  Created by iMac on 14-8-13.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFPreference.h"
#import "DFUserProfile.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "SYScrolledTabBar.h"
#import "SYPrompt.h"
#import "SYConstDefine.h"
#import "DFCalendarEvent.h"
#import "DFColorDefine.h"
#import "DFChatMemberViewController.h"
#import "DFChatViewController.h"
#import "SYPopoverMenu.h"
#import "DFCalendarView.h"
#import "DFUserMemberItem.h"
#import "DFChapterSectionViewController.h"
#import "DFSectionVoiceTableViewCell.h"
#import "DFCalendarView.h"
#import "UIAlertView+SYExtension.h"
#import "DFClassroomViewController.h"
#import "SYContextMenu.h"
#import "DFImportChatSubjectViewController.h"
#import "DFCourseSettingsViewController.h"
#import "DFChapterItem.h"

#define kAlertViewTagLeft 1028
#define kAlertViewTagListen 1029
#define kAlertViewTagFreeTrialOut 1030

@interface DFClassroomViewController ()<UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, SYScrolledTabBarDelegate, SYPopoverMenuDelegate, DFChatViewControllerDelegate, DFChatMemberViewControllerDelegate, SYContextMenuDelegate>

@property(nonatomic, strong) UIView* higherContainerView;
@property(nonatomic, strong) UITableView* courseContentTableView;
@property(nonatomic, strong) UILabel* noSubjectTipsLabel;
@property(nonatomic, strong) UIButton* previousButton;
@property(nonatomic, strong) UIButton* nextButton;
@property(nonatomic, strong) UILabel* sectionLabel;
@property(nonatomic, strong) UILabel* classTimeLabel;
@property(nonatomic, strong) NSTimer* classTimer;
@property(nonatomic) NSInteger currentSeconds;
@property(nonatomic) NSInteger maxLeftSeconds;
//@property(nonatomic) BOOL refreshTimeLabel;

@property(nonatomic, strong) DFChapterItem* chapter;
@property(nonatomic) NSInteger currentSection;

//members
@property(nonatomic, strong) NSMutableArray* members;

@property(nonatomic, strong) UIView* lowerContainerView;
@property(nonatomic, strong) SYScrolledTabBar* lowerTabBar;

@property(nonatomic, strong) DFChatMemberViewController* memberViewController;
@property(nonatomic, strong) DFChatViewController* chatViewController;
@property(nonatomic, strong) DFCalendarView* hoursView;

@property(nonatomic, strong) NSString* voiceChannelId;
@property(nonatomic, strong) NSString* textChatUrl;
@property(nonatomic) NSInteger courseId;
@property(nonatomic) NSInteger teacherUserId;

@property(nonatomic) NSInteger courseHourRateId;
@property(nonatomic) NSInteger courseHourRate;

@property(nonatomic) NSInteger currentChapterId;
@property(nonatomic) NSInteger currentSectionId;

@property(nonatomic) DFClassroomStatus classStatus;
@property(nonatomic) BOOL previewed;

@end

@implementation DFClassroomViewController

- (void) dealloc
{
    NSLog(@"Classroom dealloc %@", self);
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithCourseId:(NSInteger)courseId
{
    self = [super init];
    if (self)
    {
        self.courseId = courseId;
        _currentSection = -1;
    }
    return self;
}

- (void) registerObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationdidEnterForegound:) name:UIApplicationWillEnterForegroundNotification object:[UIApplication sharedApplication]];
}

- (void) applicationdidEnterForegound:(UIApplication *)application
{
    [self requestCourseClassInfo:YES];
}

- (void) requestCourseClassInfo:(BOOL)reload
{
    [self showProgress];
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCourseClassInfo] postValues:@{@"id" : [NSString stringWithFormat:@"%d", self.courseId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
//        NSInteger code = [[resultInfo objectForKey:@"code"] integerValue];
        if (success)
        {
            [bself.noSubjectTipsLabel removeFromSuperview];
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            [bself reloadSubviewsWithContent:info];
            
            if (!reload)
            {
                [bself requestMembers:YES];
            }
        }
        else
        {
//            if (code == kRequestCodeBeKicked)
//            {
//                [self showKickAlerView];
//            }
//            else
            {
                [bself hideProgress];
                [UIAlertView showNOPWithText:errorMsg];
            }
        }
    }];
    [self.requests addObject:request];
}

- (void) setCurrentSectionIndexWithId:(NSInteger)sectionId
{
    NSInteger idx = 0;
    for (DFSectionItem* item in self.chapter.sections)
    {
        if (item.persistentId == sectionId)
        {
            self.currentSection = idx;
            break;
        }
        ++idx;
    }
    if (self.currentSection < 0)
    {
        self.currentSection = 0;
        self.currentSectionId = [[self.chapter.sections firstObject] persistentId];
    }
    self.title = [[self.chapter.sections objectAtIndex:self.currentSection] title];
}

#define kCellMarginLeftRight 8.f
#define kCellMarginTopBottom 11.f
#define kCellLabelSpace 6.f
#define kCellId @"Sentence"

- (void) setCurrentSection:(NSInteger)currentSection
{
    if (currentSection != _currentSection)
    {
        _currentSection = currentSection;
        
    }
    
    if (currentSection >= 0)
    {
        CGSize size = self.view.frame.size;
        
        DFSectionItem* section = [self.chapter.sections objectAtIndex:currentSection];
        for (DFSentenceItem* item in section.sentences)
        {
            if (item.normalCellHeight == 0)
            {
                item.normalDialectSize = [item dialectSizeWithFont:[UIFont systemFontOfSize:14.f] maxSize:CGSizeMake(size.width - kCellMarginLeftRight * 2, 60)];
                item.normalMandarinSize = [item mandarinSizeWithFont:[UIFont systemFontOfSize:12] maxSize:CGSizeMake(size.width - kCellMarginLeftRight * 2, 60)];
                item.normalCellHeight = kCellMarginTopBottom + item.normalDialectSize.height + kCellLabelSpace + item.normalMandarinSize.height + kCellMarginTopBottom;
            }
            
        }
        self.sectionLabel.text = [NSString stringWithFormat:@"第%d节", self.currentSection + 1];
        self.previousButton.enabled = self.currentSection > 0;
        self.nextButton.enabled = self.currentSection < self.chapter.sections.count - 1;
    }
}

- (void) configTeacherInfo:(NSDictionary *)info
{
    if (self.members == nil)
    {
        self.members = [NSMutableArray array];
    }
    [self.members removeAllObjects];
    
    DFUserMemberItem* teacher = [[DFUserMemberItem alloc] init];
    teacher.userId = [[info objectForKey:@"userid"] integerValue];
    teacher.nickname = [info objectForKey:@"nickname"];
    teacher.avatarUrl = [info objectForKey:@"avatar"];
    teacher.provinceCity = [info objectForKey:@"city"];
    teacher.positionText = @"掌门";
    teacher.userRole = DFUserRoleTeacher;
    teacher.member = [[info objectForKey:@"vip_type"] integerValue];
    teacher.inClassroom = [[info objectForKey:@"online"] integerValue];
    [self.members addObject:teacher];
    
    
}

- (void) reloadSubviewsWithContent:(NSDictionary *)info
{
    self.classStatus = [[info objectForKey:@"isclass"] integerValue];
    self.maxLeftSeconds = [[info objectForKey:@"remain_classtime"] integerValue];
    self.currentSeconds = [[info objectForKey:@"hasclass_time"] integerValue];
    self.teacherUserId = [[info objectForKey:@"teacher_userid"] integerValue];
    
    switch (self.classStatus) {
        case DFClassroomStatusReady:
            [self startPrepareClassTimer];
            break;
            
        case DFClassroomStatusDoing:
            [self startClassingTimer];
            break;

            //本节课已经结束，请到自学园地自学或到广场实战练习。
        case DFClassroomStatusDone:
            if ([DFPreference sharedPreference].currentUser.persistentId != self.teacherUserId)
            {
                [self showLeftClassroomAlertView:@"现在已不在上课时间，请稍候再来！"];
                return;
            }
            
        default:
            break;
    }

    [self resetClassTimeLabel];
    
    [self configTeacherInfo:[info objectForKey:@"teacherinfo"]];
    self.previewed = [[info objectForKey:@"ispreview"] integerValue];
    
    [DFPreference sharedPreference].currentUser.freeTrialCount = [[info objectForKey:@"lasttrycount"] integerValue];
    
    self.chapter = nil;
    self.chapter = [[DFChapterItem alloc] initWithClassroomDictionary:info];
    
    self.voiceChannelId = [info objectForKey:@"room_id"];
    self.textChatUrl = [info objectForKey:@"chat_url"];
    
    if ([DFPreference sharedPreference].currentUser.persistentId == self.teacherUserId)
    {
        [self.customNavigationBar setRightButtonWithStandardTitle:@"课件"];
        self.previousButton.hidden = NO;
        self.nextButton.hidden = NO;
    }
    else
    {
        [self.customNavigationBar setRightButtonWithStandardTitle:@"举报"];
    }
    
    self.courseHourRateId = [[info objectForKey:@"course_hour_id"] integerValue];
    self.courseHourRate = [[info objectForKey:@"course_hour_rate"] integerValue];
    
    self.currentChapterId = [[info objectForKey:@"chapter_id"] integerValue];
    self.currentSectionId = [[info objectForKey:@"section_id"] integerValue];
    [self setCurrentSectionIndexWithId:self.currentSectionId];
    [self.courseContentTableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initHigherViews];
    [self initLowerViews];
    
    if ([self checkListenTrial])
    {
        [self requestCourseClassInfo:NO];
    }
}

#define kMaxListenCount 10

- (BOOL) checkListenTrial
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (user.member == DFMemberTypeVip || user.role != DFUserRoleNormal || [user hasListenCourse:self.courseId]) //vip,交费学生，老师
    {
        return YES;
    }
    
    if (user.freeTrialCount <= 0)
    {
        [self showLeftClassroomAlertView:@"您的试听次数已经用完，报名后可继续～"];
    }
    else
    {
        NSString* message = nil;
        if (user.freeTrialCount >= kMaxListenCount)
        {
            message = [NSString stringWithFormat:@"您有%d次免费试听的机会，试听本课将用去一次机会。是否试听？（进入同一堂课只计一次）", user.freeTrialCount];
        }
        else
        {
            message = [NSString stringWithFormat:@"您还有%d次免费试听的机会，试听本课将用去一次机会。是否试听？（进入同一堂课只计一次）", user.freeTrialCount];
        }
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:self cancelButtonTitle:@"不试听" otherButtonTitles:@"试听", nil];
        alertView.tag = kAlertViewTagListen;
        [alertView show];
    }
    
    return NO;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
//    [self.chatViewController joinChannel];
    [self.chatViewController.faceTextInputPanel registerKeyboardObservers];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
//    [self.chatViewController exitChannel];
    [self.chatViewController.faceTextInputPanel unregisterKeyboardObservers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - constom navigationbar


- (void) leftButtonClicked:(id)sender
{
//    if (self.teacherUserId == [DFPreference sharedPreference].currentUser.persistentId && self.chatViewController.classroomStatus == DFClassroomStatusDoing)
//    {
//        [self popupLeave];
//    }
//    else
    {
        [self gooutFromClassroom];
    }
}

- (void) gooutFromClassroom
{
    [self stopClassTimer];
    [self.chatViewController exit];
    
    [super leftButtonClicked:nil];
}

- (void) popupLeave
{
    NSMutableArray* items = [NSMutableArray array];
    
    SYContextMenuItem* pauseClass = [SYContextMenuItem contextMenuItemWithID:0 title:@"暂时离开"];
    SYContextMenuItem* stopClass = [SYContextMenuItem contextMenuItemWithID:1 title:@"下课"];
    
    [items addObject:pauseClass];
    [items addObject:stopClass];
    
    SYContextMenu* menu = [[SYContextMenu alloc] initWithTitle:@"" menuItems:items];
    menu.delegate = self;
    [menu showInView:self.parentViewController.view];
}

- (void) contextMenuDidDismiss:(SYContextMenu *)contextMenu
{
    
}

- (void) contextMenu:(SYContextMenu *)menu selectItem:(SYContextMenuItem *)item
{
    switch (item.menuId) {
        case 0:
            [self gooutFromClassroom];
            break;
        case 1:
            [self sendStopClassRequest];
            
            break;
            
        default:
            break;
    }
}

- (void) sendStopClassRequest
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForStartClass] postValues:@{@"course_id": [NSNumber numberWithInt:self.courseId], @"isclass" : @"0"} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [bself gooutFromClassroom];
        }
        else
        {
            [UIAlertView showWithTitle:@"下课" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}


- (void) reportSomeone
{
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforReport] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [SYPrompt showWithText:@"您已举报成功，一经核实会进行处理!"];
        }
        else
        {
            [UIAlertView showWithTitle:@"举报" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) rightButtonClicked:(id)sender
{
    if ([DFPreference sharedPreference].currentUser.persistentId == self.teacherUserId)
    {
        [self gotoChapterPickController];
        
//        SYPopoverMenuItem* importSubjectItem = [[SYPopoverMenuItem alloc] init];
//        importSubjectItem.title = @"章节设置";
//        importSubjectItem.image = [UIImage imageNamed:@"menu_sections.png"];
//        
//        SYPopoverMenu* menu = [[SYPopoverMenu alloc] initWithMenuItems:@[importSubjectItem]];
//        menu.delegate = self;
//        [menu showFromView:self.customNavigationBar.rightButton];
    }
    else
    {
        [self reportSomeone];
    }
}

- (void) gotoChapterPickController
{
    typeof(self) __weak bself = self;
    DFChapterSectionViewController * controller = [[DFChapterSectionViewController alloc] initWithChapterSectionStyle:DFChapterSectionStyleCourse];
    controller.courseId = self.courseId;
    controller.selectedChapterId = self.currentChapterId;
    controller.selectedSectionId = self.currentSectionId;
    controller.pickedBlock = ^(NSInteger chapterId, NSInteger sectionId){
        
        [bself setRemoteCurrentChapterSection:sectionId promptWhenSuccess:YES];
    };
    [self.navigationController pushViewController:controller animated:YES];
}

- (void) popoverMenu:(SYPopoverMenu *)menu select:(NSInteger)menuId
{
    switch (menuId) {
        case 0:
        {
            [self gotoChapterPickController];
        }
            break;
            
        case 1:
        {
            DFCourseSettingsViewController* controller = [[DFCourseSettingsViewController alloc] initWithNibName:@"DFCourseSettingsViewController" bundle:[NSBundle mainBundle]];
            [self.navigationController pushViewController:controller animated:YES];
        }
            break;
            
        default:
            break;
    }
}


- (void) nextButtonClicked:(id)sender
{
    NSInteger newSectionId = [[self.chapter.sections objectAtIndex:self.currentSection + 1] persistentId];
    [self setRemoteCurrentChapterSection:newSectionId promptWhenSuccess:NO];
}

- (void) previousButtonClicked:(id)sender
{
    NSInteger newSectionId = [[self.chapter.sections objectAtIndex:self.currentSection - 1] persistentId];
    [self setRemoteCurrentChapterSection:newSectionId promptWhenSuccess:NO];
}

- (void) setRemoteCurrentChapterSection:(NSInteger)section promptWhenSuccess:(BOOL)show
{
    [self showProgress];
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforSetCurrentChapterSection] postValues:@{@"course_id": [NSNumber numberWithInteger:self.courseId], @"section_id" : [NSNumber numberWithInteger:section]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [self hideProgress];
        
        if (success)
        {
            if (show)
            {
                [SYPrompt showWithText:@"课件调整成功"];
            }
        }
        else
        {
            [UIAlertView showWithTitle:@"章节设置" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) requestChapterSection
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforChapterSentencesWithSectionId:self.currentSectionId] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            [bself.chapter updateSectionsWithDictionaries:[[resultInfo objectForKey:@"info"] objectForKey:@"list"]];
            [bself setCurrentSectionIndexWithId:self.currentSectionId];
            [bself.courseContentTableView reloadData];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

#pragma mark - higher part

#define kHigherPartHeight 204.f
#define kHighBarHeight 32.f
#define kHighBarLabelWidth 90.f
#define kHighBarLabelMargin 10.f

#define kPreviousNextButtonMargin 92.f
#define kClassTimeMarginRight 12.f
#define kClassTimeWidth 70.f

- (void) initHigherViews
{
    CGSize navigationSize = self.customNavigationBar.frame.size;
    
    self.higherContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, navigationSize.height, navigationSize.width, kHigherPartHeight)];
    [self.view addSubview:self.higherContainerView];
    
    UIImageView* bkgImageView = [[UIImageView alloc] initWithFrame:self.higherContainerView.bounds];
//    bkgImageView.image = [UIImage imageNamed:@"user_profile_bkg.png"];
    bkgImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_blackboard.png"]];
//    [self.higherContainerView addSubview:bkgImageView];
    
    self.courseContentTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, navigationSize.width, kHigherPartHeight - kHighBarHeight) style:UITableViewStylePlain];
    self.courseContentTableView.backgroundColor = [UIColor clearColor];
    self.courseContentTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.courseContentTableView.backgroundView = bkgImageView;
    self.courseContentTableView.delegate = self;
    self.courseContentTableView.dataSource = self;
    [self.higherContainerView addSubview:self.courseContentTableView];
    
    [self.courseContentTableView registerNib:[UINib nibWithNibName:@"DFSectionVoiceTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kCellId];
    
    self.noSubjectTipsLabel = [[UILabel alloc] initWithFrame:self.courseContentTableView.frame];
    self.noSubjectTipsLabel.textColor = [UIColor whiteColor];
    self.noSubjectTipsLabel.backgroundColor = [UIColor clearColor];
    self.noSubjectTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.noSubjectTipsLabel.font = [UIFont systemFontOfSize:20];
    self.noSubjectTipsLabel.text = @"～话题～";
    [self.higherContainerView addSubview:self.noSubjectTipsLabel];
    
    UIView* barView = [[UIView alloc] initWithFrame:CGRectMake(0, kHigherPartHeight - kHighBarHeight, navigationSize.width, kHighBarHeight)];
    barView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    [self.higherContainerView addSubview:barView];
    
    self.sectionLabel = [[UILabel alloc] initWithFrame:barView.bounds];
    self.sectionLabel.backgroundColor = [UIColor clearColor];
    self.sectionLabel.textAlignment = NSTextAlignmentCenter;
    self.sectionLabel.font = [UIFont systemFontOfSize:15];
    self.sectionLabel.textColor = [UIColor whiteColor];
    [barView addSubview:self.sectionLabel];
    
    self.previousButton = [[UIButton alloc] initWithFrame:CGRectMake(kPreviousNextButtonMargin, 0, kHighBarHeight, kHighBarHeight)];
    self.previousButton.backgroundColor = [UIColor clearColor];
    [self.previousButton setImage:[UIImage imageNamed:@"course_previous_class.png"] forState:UIControlStateNormal];
    [self.previousButton addTarget:self action:@selector(previousButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.previousButton.hidden = YES;
    [barView addSubview:self.previousButton];
    
    self.nextButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kHighBarHeight - kPreviousNextButtonMargin, 0, kHighBarHeight, kHighBarHeight)];
    self.nextButton.backgroundColor = [UIColor clearColor];
    [self.nextButton setImage:[UIImage imageNamed:@"course_next_class.png"] forState:UIControlStateNormal];
    [self.nextButton addTarget:self action:@selector(nextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.nextButton.hidden = YES;
    [barView addSubview:self.nextButton];
    
    self.classTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width - kClassTimeWidth - kClassTimeMarginRight, 0, kClassTimeWidth, kHighBarHeight)];
    self.classTimeLabel.textColor = [UIColor whiteColor];
    self.classTimeLabel.backgroundColor = [UIColor clearColor];
    self.classTimeLabel.font = [UIFont systemFontOfSize:13];
    self.classTimeLabel.textAlignment = NSTextAlignmentRight;
    self.classTimeLabel.text = @"00:00";
    [barView addSubview:self.classTimeLabel];
}

- (void) startClassingTimer
{
    [self stopClassTimer];
    
    self.classTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(classTimeScheduled:) userInfo:nil repeats:YES];
}

- (void) startPrepareClassTimer
{
    [self stopClassTimer];
    
    self.classTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(prepareClassTimeScheduled:) userInfo:nil repeats:YES];
}

- (void) stopClassTimer
{
    [self.classTimer invalidate];
    self.classTimer = nil;
}

- (void) prepareClassTimeScheduled:(id)timer
{
    if (self.maxLeftSeconds <= 0)
    {
        [self stopClassTimer];
        [self showLeftClassroomAlertView:@"本节课已经结束，请到自学园地自学或到广场实战练习。"];
    }
    else
    {
        --self.maxLeftSeconds;
    }
}

- (void) classTimeScheduled:(id)timer
{
    [self resetClassTimeLabel];
    
    if (self.maxLeftSeconds <= 0)
    {
        [self stopClassTimer];
        [self showLeftClassroomAlertView:@"本节课已经结束，请到自学园地自学或到广场实战练习。"];
    }
    else
    {
        --self.maxLeftSeconds;
        ++self.currentSeconds;
    }
}

- (void) resetClassTimeLabel
{
    self.classTimeLabel.text = [NSString stringWithFormat:@"%d:%02d:%02d", self.currentSeconds / 3600, (self.currentSeconds % 3600) / 60, self.currentSeconds % 60];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.chapter.sections objectAtIndex:self.currentSection] sentences] count];
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFSectionVoiceTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    
    DFSentenceItem* sentence = [[[self.chapter.sections objectAtIndex:self.currentSection] sentences] objectAtIndex:indexPath.row];
    
    cell.dialectLabel.text = sentence.dialect;
    cell.mandarinLabel.text = sentence.mandarin;
    
    cell.contentInsets = UIEdgeInsetsMake(kCellMarginTopBottom, kCellMarginLeftRight, kCellMarginTopBottom, kCellMarginLeftRight);
    cell.dialectSize = sentence.normalDialectSize;
    cell.mandarinSize = sentence.normalMandarinSize;
    cell.labelSpace = kCellLabelSpace;
    
    return cell;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [[[[self.chapter.sections objectAtIndex:self.currentSection] sentences] objectAtIndex:indexPath.row] normalCellHeight];
}

#pragma mark - lower part

#define kTabBarHeight 26.f

- (void) initLowerViews
{
    CGRect higherFrame = self.higherContainerView.frame;
    
    self.lowerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, higherFrame.origin.y + higherFrame.size.height, higherFrame.size.width, self.view.frame.size.height - higherFrame.origin.y - higherFrame.size.height)];
    [self.view addSubview:self.lowerContainerView];
    
    [self initScrolledTabBar];
}

- (void) initScrolledTabBar
{
    self.lowerTabBar = [[SYScrolledTabBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kTabBarHeight)];
//    self.lowerTabBar.backgroundImageView.image = [UIImage imageNamed:@"scroll_bar_bg.png"];
    self.lowerTabBar.backgroundColor = RGBCOLOR(237, 237, 237);
    self.lowerTabBar.normalTitleColor = RGBCOLOR(51, 51, 51);
    self.lowerTabBar.selectedTitleColor = RGBCOLOR(51, 51, 51);
    self.lowerTabBar.indicatorColor = kMainDarkColor;
    self.lowerTabBar.delegate = self;
    [self.lowerContainerView addSubview:self.lowerTabBar];
    
    SYTabBarButtonItem* chatTabItem = [[SYTabBarButtonItem alloc] init];
    chatTabItem.title = @"公屏";
    
    SYTabBarButtonItem* memberTabItem = [[SYTabBarButtonItem alloc] init];
    memberTabItem.title = @"成员";
    
    SYTabBarButtonItem* hourItem = [[SYTabBarButtonItem alloc] init];
    hourItem.title = @"课时";
    
    self.lowerTabBar.selectedIndex = 0;
    
    self.lowerTabBar.tabButtonItems = [NSArray arrayWithObjects:chatTabItem, memberTabItem, hourItem, nil];
    
    [self.lowerTabBar reloadData];
    
    UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(0, kTabBarHeight - 0.5, self.view.frame.size.width, 0.5)];
    lineView.backgroundColor = RGBCOLOR(171, 187, 200);
    [self.lowerTabBar addSubview:lineView];
}

- (DFChatsUserStyle) userChatStyleWithUserId:(NSInteger)userId
{
    if (userId == ((DFUserMemberItem *)self.members[0]).userId)
    {
        return DFChatsUserStyleClassroomTeacher;
    }
    else
    {
        for (DFUserMemberItem* item in self.members)
        {
            if (item.userId == userId)
            {
                return DFChatsUserStyleClassroomStudent;
            }
        }
        return DFChatsUserStyleClassroomVisitor;
    }
}

- (void) putChatViewControllerOn
{
    if (self.chatViewController == nil)
    {
        DFUserProfile* user = [DFPreference sharedPreference].currentUser;
        self.chatViewController = [[DFChatViewController alloc] initWithChatUserStyle:[self userChatStyleWithUserId:user.persistentId]];
        self.chatViewController.courseHourRateId = self.courseHourRateId;
        self.chatViewController.courseHourRate = self.courseHourRate;
        self.chatViewController.courseId = self.courseId;
        self.chatViewController.navigationBarStyle = SYNavigationBarStyleNone;
        self.chatViewController.classroomStatus = self.classStatus;
        self.chatViewController.controllerDelegate = self;
//        self.chatViewController.me = [self memberItemForMe];
        self.chatViewController.members = self.members;
        [self addChildViewController:self.chatViewController];
    }
    if ([self.memberViewController isViewLoaded] && self.memberViewController.view.superview != nil)
    {
        [self.memberViewController.view removeFromSuperview];
    }
    [self.hoursView removeFromSuperview];
    
    self.chatViewController.view.frame = CGRectMake(0, self.lowerTabBar.frame.size.height, self.lowerTabBar.frame.size.width, self.lowerContainerView.frame.size.height - self.lowerTabBar.frame.size.height);
    [self.lowerContainerView addSubview:self.chatViewController.view];
    [self.chatViewController.faceTextInputPanel registerKeyboardObservers];
}

- (void) putMemberViewControllerOn
{
    if (self.memberViewController == nil)
    {
        DFUserProfile* user = [DFPreference sharedPreference].currentUser;
        self.memberViewController = [[DFChatMemberViewController alloc] initWithChatUserStyle:[self userChatStyleWithUserId:user.persistentId]];
        self.memberViewController.delegate = self;
        self.memberViewController.courseId = self.courseId;
        self.memberViewController.navigationBarStyle = SYNavigationBarStyleNone;
        self.memberViewController.members = self.members;
        [self addChildViewController:self.memberViewController];
    }
    [self.chatViewController.view removeFromSuperview];

    [self.hoursView removeFromSuperview];
    
    self.memberViewController.view.frame = CGRectMake(0, self.lowerTabBar.frame.size.height, self.lowerTabBar.frame.size.width, self.lowerContainerView.frame.size.height - self.lowerTabBar.frame.size.height);
    [self.lowerContainerView addSubview:self.memberViewController.view];
}

- (void) putHoursCalendarViewOn
{
    if (self.hoursView == nil)
    {
        self.hoursView = [[DFCalendarView alloc] initWithFrame:CGRectMake(0, self.lowerTabBar.frame.size.height, self.lowerTabBar.frame.size.width, self.lowerContainerView.frame.size.height - self.lowerTabBar.frame.size.height) mode:DFCalendarModeRead];
        self.hoursView.backgroundColor = [UIColor clearColor];
        
        self.hoursView.contentSize = CGSizeMake(self.hoursView.frame.size.width, self.hoursView.frame.size.width);
    }
    [self.chatViewController.view removeFromSuperview];
    if ([self.memberViewController isViewLoaded])
    {
        [self.memberViewController.view removeFromSuperview];
    }
    
    [self.lowerContainerView addSubview:self.hoursView];
    
    if (self.hoursView.events == nil)
    {
        [self requestCourseHours];
    }
}

- (void) requestMembers:(BOOL)firstRequest
{
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCourseStudents] postValues:@{@"course_id": [NSNumber numberWithInt:self.courseId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [self hideProgress];
        
        if (success)
        {
            [bself.members removeAllObjects];
            
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            NSInteger positionId = -1; //第一个为老师
            NSArray* users = [info objectForKey:@"userlist"];
            NSInteger myPositionId = users.count;
            for (NSDictionary* info in users)
            {
                DFUserMemberItem* member = [[DFUserMemberItem alloc] initWithDictionary:info];
                member.admin = self.teacherUserId == member.userId;
                member.positionId = positionId;
                [bself.members addObject:member];
                ++positionId;
                if ([DFPreference sharedPreference].currentUser.persistentId == member.userId)
                {
                    myPositionId = member.positionId;
                }
            }
            
            DFUserMemberItem* member = self.members.firstObject;
            member.positionText = @"掌门";
            
            if ([DFPreference sharedPreference].currentUser.persistentId == self.teacherUserId)
            {
                for (NSInteger idx = bself.members.count - 1; idx > 0; --idx)
                {
                    DFUserMemberItem* member = [bself.members objectAtIndex:idx];
                    [member setStudentPositionTextWithCount:users.count];
                }
            }
            else
            {
                for (NSInteger idx = bself.members.count - 1; idx > 0; --idx)
                {
                    DFUserMemberItem* member = [bself.members objectAtIndex:idx];
                    [member setPositionTextBaseMyPosition:myPositionId count:users.count];
                }
            }
            
            
            if (firstRequest)
            {
                [bself checkShowNoPreview];
                
                [bself putChatViewControllerOn];
                
                bself.chatViewController.members = bself.members;
                bself.chatViewController.textChatUrl = bself.textChatUrl;
                bself.chatViewController.voiceChannelId = bself.voiceChannelId;
                [bself.chatViewController joinChannel];
                [bself.chatViewController startTextChat];
            }
            bself.memberViewController.members = bself.members;
            bself.memberViewController.classroomVisitorCount = [[info objectForKey:@"visit_count"] integerValue];
            [bself.memberViewController.tableView reloadData];
            
        }
        else
        {
            [UIAlertView showWithTitle:@"获取成员" message:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

#define kNoPreviewSize 126.f

- (BOOL) isStudentForCourse
{
    DFUserProfile* me = [DFPreference sharedPreference].currentUser;
    if (me.role != DFUserRoleStudent)
    {
        return NO;
    }
    
    NSInteger userId = me.persistentId;
    for (DFUserMemberItem* item in self.members)
    {
        if (item.userId == userId)
        {
            return YES;
        }
    }
    return NO;
}

- (void) checkShowNoPreview
{
    DFUserProfile* user = [DFPreference sharedPreference].currentUser;
    if (!self.previewed && ![user hasPunishForNoPreviewCourse:self.courseId] && [self isStudentForCourse])
    {
        [user punishForNoPreviewCourse:self.courseId];
        
        CGSize size = self.view.frame.size;
        
        UIView* maskView = [[UIView alloc] initWithFrame:self.view.bounds];
        maskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.view addSubview:maskView];
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((size.width - kNoPreviewSize) / 2, (size.height - kNoPreviewSize) / 2, kNoPreviewSize, kNoPreviewSize)];
        [maskView addSubview:imageView];
        
        UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, (size.height - kNoPreviewSize) / 2 + kNoPreviewSize + 20, size.width, 20)];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:15];
        label.text = @"下次记得预习哦~";
        [maskView addSubview:label];
        
        NSMutableArray* images = [NSMutableArray array];
        for (NSInteger idx = 0; idx < 9; ++idx)
        {
            [images addObject:[UIImage imageNamed:[NSString stringWithFormat:@"no_preview_%d.png", idx]]];
        }
        imageView.animationImages = images;
        imageView.animationDuration = 0.7;
        imageView.animationRepeatCount = 4;
        [imageView startAnimating];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [maskView removeFromSuperview];
        });
    }
}

#define kHoursViewMarginTop 4.f
#define kHoursViewMarginBottom 8.f

- (void) requestCourseHours
{
    typeof(self) __weak bself = self;
    
    [self showProgresWithText:@"" inView:self.hoursView];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlforCourseHours] postValues:@{@"course_id": [NSNumber numberWithInt:self.courseId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [self hideProgress];
        
        if (success)
        {
            NSArray* infos = [resultInfo objectForKey:@"info"];
            NSMutableArray* hours = [NSMutableArray arrayWithCapacity:infos.count];
            for (NSDictionary* info in infos)
            {
                DFCalendarEvent* hour = [[DFCalendarEvent alloc] init];
                hour.date = [NSDate dateWithTimeIntervalSince1970:[[info objectForKey:@"course_day"] floatValue]];
                hour.event = [info objectForKey:@"title"];
                [hours addObject:hour];
            }
//            bself.hoursView.beginEventDate = [(DFCalendarEvent *)hours.firstObject date];
            bself.hoursView.events = hours;
            
            CGFloat endY = [bself.hoursView drawDaysFromOriginY:kHoursViewMarginTop];
            bself.hoursView.contentSize = CGSizeMake(bself.view.frame.size.width, endY + 8);
        }
    }];
    [self.requests addObject:request];
}


#pragma mark - scroll tabbar

- (void) scrolledTabBar:(SYScrolledTabBar *)tabbar selectIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            [self putChatViewControllerOn];
            break;
            
        case 1:
            [self putMemberViewControllerOn];
            [self requestMembers:NO];
            break;
            
        case 2:
            [self putHoursCalendarViewOn];
            break;
            
        default:
            break;
    }
    [self.lowerTabBar setIndicatorPositionFactor:index selectTab:YES];
}

#pragma mark - alertview

- (void) showLeftClassroomAlertView:(NSString *)message
{
    UIAlertView* alertView = [UIAlertView showWithTitle:@"提示" message:message];
    alertView.tag = kAlertViewTagLeft;
    alertView.delegate = self;
    [alertView show];
}

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == kAlertViewTagLeft)
    {
        [self gooutFromClassroom];
    }
    else if (alertView.tag == kAlertViewTagListen)
    {
        if (buttonIndex == 0)
        {
            [self gooutFromClassroom];
        }
        else
        {
            [[DFPreference sharedPreference].currentUser listenCourse:self.courseId];
            [self requestCourseClassInfo:NO];
        }
    }
}

#pragma mark - chat view delegate

- (void) facePanel:(SYFaceTextInputPanel *)facePanel beginEditingForChatViewController:(DFChatViewController *)viewController
{
    CGRect lowerFrame = self.lowerContainerView.frame;
    lowerFrame.origin.y = facePanel.inputBarView.frame.origin.y - lowerFrame.size.height + facePanel.inputBarView.frame.size.height;
    self.lowerContainerView.frame = lowerFrame;
}

-(void) facePanel:(SYFaceTextInputPanel *)facePanel endEditingForChatViewController:(DFChatViewController *)viewController
{
    CGRect lowerFrame = self.lowerContainerView.frame;
    lowerFrame.origin.y = facePanel.inputBarView.frame.origin.y - lowerFrame.size.height;
    self.lowerContainerView.frame = lowerFrame;
}

- (void) classroomStatusChanged:(DFClassroomStatus)classStatus
{
    self.classStatus = classStatus;
    switch (classStatus) {
        case DFClassroomStatusDoing:
            [self startClassingTimer];
            break;
            
        default:
            [self stopClassTimer];
            break;
    }
}

- (void) roomMemberStatusChanged
{
    [self.memberViewController.tableView reloadData];
}

//- (void) classroomDidKickedByTeacher
//{
//    [self showKickAlerView];
//}

- (void) classroomDidSetChapter:(NSInteger)chapterId section:(NSInteger)sectionId
{
    if (chapterId != self.currentChapterId)
    {
        self.currentChapterId = chapterId;
        self.currentSectionId = sectionId;
        [self requestChapterSection];
    }
    else
    {
        self.currentSectionId = sectionId;
        [self setCurrentSectionIndexWithId:self.currentSectionId];
        
        [self.courseContentTableView reloadData];
    }
    
}

#pragma mark - chat member delegate

- (void) refreshMemberForChatMemberViewController:(DFChatMemberViewController *)viewController
{
    [self requestMembers:NO];
}

@end
