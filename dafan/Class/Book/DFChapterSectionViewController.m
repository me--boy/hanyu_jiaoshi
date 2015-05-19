//
//  DFChapterSectionViewController.m
//  dafan
//
//  Created by iMac on 14-8-29.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFChapterSectionViewController.h"
#import "DFSectionItem.h"
#import "DFChapterItem.h"
#import "SYConstDefine.h"
#import "SYPrompt.h"
#import "SYDownloadQueue.h"
#import "DFColorDefine.h"
#import "DFUserProfile.h"
#import "DFPreference.h"
#import "ZipArchive.h"
#import "NSString+SYExtension.h"
#import "DFSectionVoiceViewController.h"
#import "UIView+SYShape.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "SYBaseContentViewController+EGORefresh.h"
#import "UIAlertView+SYExtension.h"
#import "DFSectionVoiceViewController.h"
#import "DACircularProgressView.h"
#import "DFFilePath.h"

#define kSectionRowReuseId @"SectionRowCell"
#define kChapterHeaderReuseId @"ChapterHeaderView"

#define kCoursePrepHeaderReuseId @"CoursePrepHeaderView"
#define kSectionPrepRowReuseId @"SectionPrepRowCell"

@interface DFChapterHeaderView : UITableViewHeaderFooterView

@property(nonatomic, strong) UIButton* button;
@property(nonatomic, strong) UIButton* audioButton;
@property(nonatomic, strong) UILabel* chapterTitleLabel;
@property(nonatomic, strong) UILabel* sectionCountLabel;
@property(nonatomic, strong) UIView* bottomLine;
@property(nonatomic, strong) UIView* topLine;

@property(nonatomic, strong) UIButton* rightButton;

@property(nonatomic, strong) DACircularProgressView* progressView;

@end

#define kTitleTextColor RGBCOLOR(82.f, 82.f, 82.f)
#define kDetailTextColor RGBCOLOR(153, 153, 153)

#define kSepLineColor RGBCOLOR(171, 187, 200)

#define kProgressCircleSize 30
#define kMarginRight 16

@implementation DFChapterHeaderView

- (void) addTarget:(id)target action:(SEL)action
{
    [self.button removeTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.chapterTitleLabel = [[UILabel alloc] init];
        self.chapterTitleLabel.backgroundColor = [UIColor clearColor];
        self.chapterTitleLabel.font = [UIFont systemFontOfSize:16];
        self.chapterTitleLabel.textColor = kTitleTextColor;
        [self.contentView addSubview:self.chapterTitleLabel];
        
        self.sectionCountLabel = [[UILabel alloc] init];
        self.sectionCountLabel.font = [UIFont systemFontOfSize:14];
        self.sectionCountLabel.backgroundColor = [UIColor clearColor];
        self.sectionCountLabel.textColor = kDetailTextColor;
        [self.contentView addSubview:self.sectionCountLabel];
        
        self.audioButton = [[UIButton alloc] initWithFrame:CGRectMake(20.f, 40.f, 25.f, 14.f)];
        self.audioButton.backgroundColor = [UIColor clearColor];
        self.audioButton.userInteractionEnabled = NO;
        [self.audioButton setTitle:@"音频" forState:UIControlStateNormal];
        self.audioButton.titleLabel.font = [UIFont systemFontOfSize:11.f];
        [self.audioButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.audioButton setBackgroundImage:[UIImage imageNamed:@"daily_audio.png"] forState:UIControlStateNormal];
        [self.contentView addSubview:self.audioButton];
        
        self.button = [[UIButton alloc] init];
        self.button.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.button];
        
        self.rightButton = [[UIButton alloc] init];
        self.rightButton.backgroundColor = [UIColor clearColor];
        self.rightButton.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, kMarginRight);
        self.rightButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [self.contentView addSubview:self.rightButton];
        
        self.progressView = [[DACircularProgressView alloc] init];
        self.progressView.trackTintColor = RGBCOLOR(0xab, 0xbb, 0xc8);
        self.progressView.progressTintColor = RGBCOLOR(0xee, 0x58, 0x59);
        self.progressView.hidden = YES;
        [self.contentView addSubview:self.progressView];
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = kSepLineColor;
        [self.contentView addSubview:self.bottomLine];
        
        self.topLine = [[UIView alloc] init];
        self.topLine.backgroundColor = kSepLineColor;
        [self.contentView addSubview:self.topLine];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
    CGSize size = self.frame.size;
    
//    self.contentView.backgroundColor = [UIColor clearColor];
    self.progressView.frame = CGRectMake(size.width - kMarginRight - kProgressCircleSize, (size.height - kProgressCircleSize) / 2, kProgressCircleSize, kProgressCircleSize);
    self.chapterTitleLabel.frame = CGRectMake(20.f, 12.f, 258.f, 17.f);
    self.sectionCountLabel.frame = CGRectMake(60.f, 38.f, 200.f, 17.f);
    self.audioButton.frame = CGRectMake(20.f, 40.f, 25.f, 14.f);
    self.button.frame = self.bounds;
    self.rightButton.frame = CGRectMake(size.width - 80, 0, 80, size.height);
    self.bottomLine.frame = CGRectMake(0, size.height - 0.5, size.width, 0.5);
    self.topLine.frame = CGRectMake(0, 0, size.width, 0.5);
}

@end

#pragma mark - prep course

@interface DFCoursePrepHeaderView : UITableViewHeaderFooterView

@property(nonatomic, strong) UILabel* chapterTitleLabel;

@property(nonatomic, strong) UIView* bottomLine;
//@property(nonatomic, strong) UIView* topLine;

@end

@implementation DFCoursePrepHeaderView

- (id) initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.chapterTitleLabel = [[UILabel alloc] init];
        self.chapterTitleLabel.backgroundColor = [UIColor clearColor];
        self.chapterTitleLabel.font = [UIFont systemFontOfSize:16];
        self.chapterTitleLabel.textColor = kTitleTextColor;
        [self.contentView addSubview:self.chapterTitleLabel];
        
        
        self.bottomLine = [[UIView alloc] init];
        self.bottomLine.backgroundColor = kSepLineColor;
        [self.contentView addSubview:self.bottomLine];
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    //    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.chapterTitleLabel.frame = CGRectMake(20.f, 0, 258.f, self.frame.size.height);
    self.bottomLine.frame = CGRectMake(8, self.frame.size.height - 0.5, self.frame.size.width, 0.5);
}

@end

@interface DFSectionRowCell : UITableViewCell

@end

@implementation DFSectionRowCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.textColor = kTitleTextColor;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:15];
        self.backgroundView.backgroundColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor clearColor];
        
        if ([reuseIdentifier isEqualToString:kSectionPrepRowReuseId])
        {
            UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 53, 22)];
            button.backgroundColor = [UIColor clearColor];
            button.userInteractionEnabled = NO;
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            [button setTitle:@"预习" forState:UIControlStateNormal];
            [button setTitle:@"已预习" forState:UIControlStateSelected];
            [button setBackgroundImage:[UIImage imageNamed:@"course_to_preview.png"] forState:UIControlStateNormal];
            [button setBackgroundImage:[UIImage imageNamed:@"course_previewed.png"] forState:UIControlStateSelected];
            self.accessoryView = button;
        }
        else
        {
            UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chapter_section_selected.png"]];
            imageView.hidden = YES;
            self.accessoryView = imageView;
        }
        
    }
    return self;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.textLabel.frame = CGRectMake(23.f, 0, self.frame.size.width - 23, self.frame.size.height);
    
    if ([self.reuseIdentifier isEqualToString:kSectionPrepRowReuseId])
    {
        self.accessoryView.frame = CGRectMake(self.frame.size.width - 10 - self.accessoryView.frame.size.width, (self.frame.size.height - self.accessoryView.frame.size.height) / 2, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height);
    }
    else
    {
        self.accessoryView.frame = CGRectMake(self.frame.size.width - 23 - self.accessoryView.frame.size.width, (self.frame.size.height - self.accessoryView.frame.size.height) / 2, self.accessoryView.frame.size.width, self.accessoryView.frame.size.height);
    }
}

@end



#define kDownloadMaxProgress 0.96f

@interface DFChapterSectionViewController ()
/**
 *  用来记录选中的section
 */
@property(nonatomic) NSInteger pickedChapterIdx;

@property(nonatomic) NSInteger selectedChapterIdx;

@property(nonatomic) NSInteger selectedSectionIndex;

@property(nonatomic) DFChapterSectionStyle style;

@property(nonatomic, strong) NSMutableArray* items;

@end

@implementation DFChapterSectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithChapterSectionStyle:(DFChapterSectionStyle)style
{
    self = [super init];
    if (self)
    {
        self.style = style;
    }
    return self;
}

//- (UITableViewStyle) tableViewStyle
//{
//    return UITableViewStyleGrouped;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = RGBCOLOR(248, 248, 248);
    
    self.pickedChapterIdx = -1;
    self.items = [NSMutableArray array];
    [self configTableView];
    [self configForStyle];
}

- (void) configForStyle
{
    switch (self.style) {
        case DFChapterSectionStyleCourse:
            self.title = @"章节设置";
            [self requestCourseItems:YES];
            break;
        case DFChapterSectionStyleDailySence:
            [self requestDailySceneItems:YES];
            break;
            
        case DFChapterSectionStylePrep:
            self.title = @"课前预习";
            [self requestCoursePrepItems:YES];
            break;
            
        default:
            break;
    }
}

- (void) reloadDataForRefresh
{
    [self configForStyle];
}

- (void) configTableView
{
    self.tableView.rowHeight = 45.f;
    self.tableView.sectionHeaderHeight = 65.f;
    
    self.tableView.separatorColor = kSepLineColor;
    
    [self.tableView registerClass:[DFSectionRowCell class] forCellReuseIdentifier:kSectionRowReuseId];
    [self.tableView registerClass:[DFSectionRowCell class] forCellReuseIdentifier:kSectionPrepRowReuseId];
    [self.tableView registerClass:[DFChapterHeaderView class] forHeaderFooterViewReuseIdentifier:kChapterHeaderReuseId];
    [self.tableView registerClass:[DFCoursePrepHeaderView class] forHeaderFooterViewReuseIdentifier:kCoursePrepHeaderReuseId];
    
    [self enableRefreshAtHeaderForScrollView:self.tableView];
}

- (void) requestCoursePrepItems:(BOOL)reload
{
    typeof(self) __weak bself = self;
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCoursePrep] postValues:@{@"course_id" : [NSNumber numberWithInt:self.courseId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (success)
        {
            if (reload)
            {
                [bself.items removeAllObjects];
            }
            DFChapterItem* chapter = [[DFChapterItem alloc] initWithCoursePrepDictionary:[resultInfo objectForKey:@"info"]];
            [bself.items addObject:chapter];
            
            [bself.tableView reloadData];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
        
    }];
    [self.requests addObject:request];
}

- (void) requestCourseItems:(BOOL)reload
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForCourseChapterSections] postValues:@{@"course_id" : [NSNumber numberWithInteger:self.courseId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        if (success)
        {
            if (reload)
            {
                [bself.items removeAllObjects];
            }
            NSArray* infos = [[resultInfo objectForKey:@"info"] objectForKey:@"list"];
            [bself reloadWithDictionary:infos daily:NO];
        }
        else
        {
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) requestDailySceneItems:(BOOL)reload
{
    typeof(self) __weak bself = self;
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForDailyScenes] postValues:nil finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        if (reload)
        {
            [bself.items removeAllObjects];
        }
        
        if (success)
        {
            NSArray* infos = [[resultInfo objectForKey:@"info"] objectForKey:@"list"];
            [bself reloadWithDictionary:infos daily:YES];
            if (reload)
            {
                [infos writeToFile:[DFFilePath homeDailiesCacheFilePath] atomically:YES];
            }
        }
        else
        {
            NSArray* infos = [NSArray arrayWithContentsOfFile:[DFFilePath homeDailiesCacheFilePath]];
            [bself reloadWithDictionary:infos daily:YES];
            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) reloadWithDictionary:(NSArray *)chapters daily:(BOOL)daily
{
    NSString* audioDirectory = [DFFilePath dailiesDirectory];
    for (NSDictionary* info in chapters)
    {
        DFChapterItem* chapter = [[DFChapterItem alloc] initWithChapterSectionDictionary:info];
        if (daily)
        {
            NSString* audioPath = [audioDirectory stringByAppendingPathComponent:[chapter.compressedFileUrl encryptionWithMD5]];
            chapter.downloadedStatus = [SYFilePath fileExists:audioPath] ? DFDownloadStatusSucceed : DFDownloadStatusReady;
        }
        
        [self.items addObject:chapter];
    }
    if (self.style == DFChapterSectionStyleCourse)
    {
        [self resetPickedIdx];
    }
    [self.tableView reloadData];
}

- (void) resetPickedIdx
{
    if (self.selectedChapterId > 0 || self.selectedSectionId > 0)
    {
        NSInteger chapterIdx = 0;
        for (DFChapterItem* chapter in self.items)
        {
            if (chapter.persistentId == self.selectedChapterId)
            {
                self.selectedChapterIdx = chapterIdx;
                
                NSInteger sectionIdx = 0;
                for (DFSectionItem* section in chapter.sections)
                {
                    if (section.persistentId == self.selectedSectionId)
                    {
                        self.selectedSectionIndex = sectionIdx;
                        self.selectedChapterIdx = chapterIdx;
                        self.pickedChapterIdx = chapterIdx;
                    }
                    ++sectionIdx;
                }
            }
            ++chapterIdx;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DFChapterItem* chapter = [self.items objectAtIndex:section];
    if (self.style == DFChapterSectionStylePrep)
    {
        return chapter.sections.count;
    }
    else
    {
        if (self.pickedChapterIdx == section)
        {
            return chapter.sections.count;
        }
        else
        {
            return 0;
        }
    }
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (self.style == DFChapterSectionStylePrep)
    {
        DFCoursePrepHeaderView* headerview = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kCoursePrepHeaderReuseId];
        DFChapterItem* chapter = self.items.count > section ? [self.items objectAtIndex:section] : nil;
        headerview.contentView.backgroundColor = [UIColor whiteColor];
        headerview.chapterTitleLabel.text = [NSString stringWithFormat:@"主题: %@", chapter.title];
        return headerview;
    }
    else
    {
        DFChapterHeaderView* headerview = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kChapterHeaderReuseId];
        DFChapterItem* chapter = self.items.count > section ? [self.items objectAtIndex:section] : nil;
        headerview.contentView.backgroundColor = [UIColor whiteColor];
        headerview.chapterTitleLabel.text = [NSString stringWithFormat:@"主题%d: %@", section + 1, chapter.title];
        headerview.sectionCountLabel.text = [NSString stringWithFormat:@"共计%d小节", chapter.sections.count];
        headerview.button.tag = section;
        headerview.rightButton.tag = section;
        headerview.rightButton.selected = (section == self.pickedChapterIdx);
        [headerview addTarget:self action:@selector(headerChapterClicked:)];
        
        headerview.topLine.hidden = (self.pickedChapterIdx < 0 || self.pickedChapterIdx != section - 1);
        
        switch (chapter.downloadedStatus) {
            case DFDownloadStatusReady:
            case DFDownloadStatusFailed://没有下载的
                headerview.rightButton.hidden = NO;
                headerview.progressView.hidden = YES;
                [headerview.rightButton setImage:[UIImage imageNamed:@"audio_download.png"] forState:UIControlStateNormal];
                [headerview.rightButton setImage:nil forState:UIControlStateSelected];
                [headerview.rightButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
                [headerview.rightButton addTarget:self action:@selector(downloadChapterButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
                break;
                
            case DFDownloadStatusDoing:
            case DFDownloadStatusWaiting:
                headerview.progressView.hidden = NO;
                headerview.rightButton.hidden = YES;
                headerview.progressView.progress = chapter.progress > kDownloadMaxProgress ? kDownloadMaxProgress : chapter.progress;
                break;

//            case DFDownloadStatusSucceed:
            default:
                headerview.rightButton.hidden = NO;
                headerview.progressView.hidden = YES;
                [headerview.rightButton setImage:[UIImage imageNamed:@"arrow_city_collapse.png"] forState:UIControlStateNormal];
                [headerview.rightButton setImage:[UIImage imageNamed:@"arrow_city_extend.png"] forState:UIControlStateSelected];
                [headerview.rightButton removeTarget:self action:NULL forControlEvents:UIControlEventTouchUpInside];
                [headerview.rightButton addTarget:self action:@selector(headerChapterClicked:) forControlEvents:UIControlEventTouchUpInside];
                break;
        }
        
        return headerview;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFSectionRowCell* cell = nil;
    
    if (self.style == DFChapterSectionStylePrep)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kSectionPrepRowReuseId forIndexPath:indexPath];
        cell.textLabel.textColor = kDetailTextColor;
    }
    else
    {
        cell = [tableView dequeueReusableCellWithIdentifier:kSectionRowReuseId forIndexPath:indexPath];
    }
    
    DFChapterItem* chapter = [self.items objectAtIndex:indexPath.section];
    DFSectionItem* section = [chapter.sections objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [NSString stringWithFormat:@"第%d节：%@", indexPath.row + 1, section.title];
    
    if (self.style == DFChapterSectionStyleCourse && self.selectedChapterIdx == indexPath.section && self.selectedSectionIndex == indexPath.row)
    {
        cell.accessoryView.hidden = NO;
    }
    else if (self.style == DFChapterSectionStylePrep)
    {
        UIButton* button = (UIButton *)cell.accessoryView;
        button.selected = section.prepviewed;
    }
    else
    {
        cell.accessoryView.hidden = YES;
    }
    
    return cell;
}

- (void) clearSelectedChapterSection
{
    self.pickedChapterIdx = -1;
    [self.tableView reloadData];
}

- (void) headerChapterClicked:(UIButton *)sender
{
    if (self.pickedChapterIdx == sender.tag)
    {
        self.pickedChapterIdx = -1;
    }
    else
    {
        self.pickedChapterIdx = sender.tag;
    }
    [self.tableView reloadData];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedSectionIndex = indexPath.row;
    
    DFSectionRowCell* cell = (DFSectionRowCell *)[tableView cellForRowAtIndexPath:indexPath];
    DFChapterItem* chapter = [self.items objectAtIndex:indexPath.section];
    DFSectionItem* section = [chapter.sections objectAtIndex:indexPath.row];
    
    if (self.pickedBlock)
    {
        cell.accessoryView.hidden = NO;
        self.pickedBlock(chapter.persistentId, section.persistentId);
        
        [self leftButtonClicked:nil];
    }
    else if (self.style == DFChapterSectionStyleDailySence)
    {
        //开始播放音频
        DFSectionVoiceViewController* controller = [[DFSectionVoiceViewController alloc] initWithChapterId:chapter.persistentId];
        controller.currentSectionIdx = indexPath.row;
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (self.style == DFChapterSectionStylePrep)
    {
        DFSectionVoiceViewController* controller = [[DFSectionVoiceViewController alloc] initWithChapterId:chapter.persistentId];
        controller.currentSectionIdx = indexPath.row;
        controller.voiceStyle = DFSectionVoiceStylePreivew;
        controller.completedBlock = ^(NSInteger sectionId)
        {
            for (DFSectionItem* section in chapter.sections)
            {
                if (section.persistentId == sectionId)
                {
                    section.prepviewed = YES;
                    [self.tableView reloadData];
                    break;
                }
            }
        };
        [self.navigationController pushViewController:controller animated:YES];
    }
}

/**
 *  下载教程
 */
- (void) downloadChapterButtonClicked:(UIButton *)sender
{
    if (![[DFPreference sharedPreference] validateLogin:^BOOL{
        return NO;
    }])
    {
        return;
    }
    
    typeof(self) __weak bself = self;
    DFChapterItem* chapter = [self.items objectAtIndex:sender.tag];
    if (chapter.compressedFileUrl.length == 0)
    {
        [SYPrompt showWithText:@"暂无下载地址，请下拉刷新"];
        return;
    }
    
    chapter.downloadedStatus = DFDownloadStatusWaiting;
    
    NSString* unzipDirectory = [DFFilePath sentenceAudiosDirectory];
    NSString* compressedFilePath = [[DFFilePath dailiesDirectory] stringByAppendingPathComponent:[chapter.compressedFileUrl encryptionWithMD5]];
    [SYFilePath ensureDirectory:unzipDirectory];
    
    DFChapterHeaderView* headerView = (DFChapterHeaderView *)[bself.tableView headerViewForSection:sender.tag];
    headerView.progressView.hidden = NO;
    headerView.progressView.progress = 0.01f;
    headerView.rightButton.hidden = YES;
    
    NSLog(@"%s, download begin", __FUNCTION__);
    SYHttpRequest* request = [SYHttpRequest startDownloadFromUrl:chapter.compressedFileUrl toFilePath:compressedFilePath progress:^(CGFloat progress) {
        
        chapter.downloadedStatus = DFDownloadStatusDoing;
        chapter.progress = progress;
        
        DFChapterHeaderView* sectionHeaderView = (DFChapterHeaderView *)[bself.tableView headerViewForSection:sender.tag];
        sectionHeaderView.progressView.progress = progress > kDownloadMaxProgress ? kDownloadMaxProgress : progress;
        
        NSLog(@"%s, download: %f:%f", __FUNCTION__, chapter.progress, sectionHeaderView.progressView.progress);
        
    } finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        NSLog(@"%s, download end", __FUNCTION__);
        if (success)
        {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                ZipArchive* zip = [[ZipArchive alloc] init];
                BOOL completeSuccess = NO;
                NSLog(@"%s, unzip begin", __FUNCTION__);
                if ([zip UnzipOpenFile:compressedFilePath])
                {
                    NSLog(@"%s, unzip open file", __FUNCTION__);
                    
                    if ([zip UnzipFileTo:unzipDirectory overWrite:YES])
                    {
                        completeSuccess = YES;
                        NSLog(@"%s, unzip file", __FUNCTION__);
                        
                        [zip UnzipCloseFile];
                        chapter.progress = 1;
                        chapter.downloadedStatus = DFDownloadStatusSucceed;
                    }
                    else
                    {
                        NSLog(@"%s, unzip file failed", __FUNCTION__);
                        
                        [zip UnzipCloseFile];
                        [bself handleErrorEventWhenDownloadChapter:chapter localFilepath:compressedFilePath];
                        [SYPrompt showWithText:@"文件源损坏，请改天再下载！"];
                    }
                }
                else
                {
                    NSLog(@"%s, unzip open file failed", __FUNCTION__);
                    
                    [bself handleErrorEventWhenDownloadChapter:chapter localFilepath:compressedFilePath];
                    [SYPrompt showWithText:@"文件源损坏，请改天再下载！"];
                }
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completeSuccess)
                    {
                        [bself downloadChapterText:chapter.persistentId];
                    }
                    [bself.tableView reloadData];
                    NSLog(@"%s, unzip end reload", __FUNCTION__);
                });
            });
        }
        else
        {
            [bself handleErrorEventWhenDownloadChapter:chapter localFilepath:compressedFilePath];
            [bself.tableView reloadData];
            [SYPrompt showWithText:@"网络不给力，请稍后下载"];
        }
    }];
    [self.requests addObject:request];
}

- (void) downloadChapterText:(NSInteger)chapterId
{
    typeof(self) __weak bself = self;
    
    [self showProgress];
    
    SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForChapterInfo] postValues:@{@"id": [NSNumber numberWithInt:chapterId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
        
        [bself hideProgress];
        if (success)
        {
            NSDictionary* info = [resultInfo objectForKey:@"info"];
            [info writeToFile:[DFFilePath dailyTextFilPathWithChapterId:chapterId] atomically:YES];
        }
        else
        {
            [SYPrompt showWithText:@"文本下载不成功！"];
//            [UIAlertView showNOPWithText:errorMsg];
        }
    }];
    [self.requests addObject:request];
}

- (void) handleErrorEventWhenDownloadChapter:(DFChapterItem *)chapter localFilepath:(NSString *)compressedFilePath
{
    [[NSFileManager defaultManager] removeItemAtPath:compressedFilePath error:nil];
    chapter.downloadedStatus = DFDownloadStatusFailed;
    chapter.progress = 0;
}

@end
