//
//  DFSectionVoiceViewController.m
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import "DFSectionVoiceViewController.h"
#import "DFSectionVoiceTableViewCell.h"
#import "DFSentenceItem.h"
#import "AFSoundManager.h"
#import "SYDeviceDescription.h"
#import "DFColorDefine.h"
#import "SYHttpRequest.h"
#import "DFUrlDefine.h"
#import "DFFilePath.h"
#import "UIAlertView+SYExtension.h"
#import "DFVoiceAnimationView.h"
#import "SYPrompt.h"
#import "DFRepeatController.h"
#import "DFRepeatPanel.h"
#import "DFUrlDefine.h"
#import "DFChapterItem.h"

typedef NS_ENUM(NSInteger, DFRepeatMode)
{
    DFRepeatModeNone,
    DFRepeatModeOriginalVoice,
    DFRepeatModeMyVoice,
    DFRepeatModeCompare
};

@interface DFSectionVoiceViewController ()<AFSoundManagerDelegate>

//@property(nonatomic, strong) NSMutableArray* sentences;

@property(nonatomic, strong) DFChapterItem* chapterItem;

@property (weak, nonatomic) IBOutlet UIButton *previousButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UILabel *sectionLabel;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UILabel *timeDurationLabel;


@property(nonatomic) AFSoundManagerStatus playStatus;

@property(nonatomic, strong) UIView* playBarView;
@property(nonatomic, strong) DFRepeatPanel* repeatPanel;
@property(nonatomic, strong) DFRepeatController* repeatController;

@property(nonatomic) NSInteger chapterId;
@property(nonatomic) NSInteger currentSentenceIdx;
@property(nonatomic) DFRepeatMode repeatMode;
@property(nonatomic) BOOL playingMyVoice;

@property(nonatomic, strong) UIImageView* backgroundImageView;

@end

@implementation DFSectionVoiceViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithChapterId:(NSInteger)chapterId
{
    self = [super init];
    if (self)
    {
        self.chapterId = chapterId;
    }
    return self;
}

- (void) leftButtonClicked:(id)sender
{
    [[AFSoundManager sharedManager] stop];
    [AFSoundManager sharedManager].delegate = nil;
    [self.repeatController done];
    
    [super leftButtonClicked:nil];
}

- (void) dealloc
{
    NSLog(@"%s", __FUNCTION__);
}

- (void) requestChapterInfo
{
    NSString* filePath = [DFFilePath dailyTextFilPathWithChapterId:self.chapterId];
    if (self.voiceStyle == DFSectionVoiceStyleDaily && [DFFilePath fileExists:filePath])
    {
        NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:filePath];
        [self reloadDataWithInfo:info];
    }
    else
    {
        typeof(self) __weak bself = self;
        
        [self showProgress];
        
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForChapterInfo] postValues:@{@"id": [NSNumber numberWithInt:self.chapterId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            
            [bself hideProgress];
            if (success)
            {
                NSDictionary* info = [resultInfo objectForKey:@"info"];
                [bself reloadDataWithInfo:info];
            }
            else
            {
                [UIAlertView showNOPWithText:errorMsg];
            }
        }];
        [self.requests addObject:request];
    }
}

- (void) reloadDataWithInfo:(NSDictionary *)info
{
    self.chapterItem = [[DFChapterItem alloc] initWithChapterSectionDictionary:info];
    [self reloadViews];
    self.currentSentenceIdx = 0;
}

#define kCellMarginLeftRight 8.f
#define kCellMarginTopBottom 11.f
#define kCellLabelSpace 6.f

- (void) setCurrentSectionIdx:(NSInteger)currentSectionIdx
{
    _currentSectionIdx = currentSectionIdx;
    
    if (self.chapterItem.sections.count <= currentSectionIdx)
    {
        return;
    }
    
    [self reloadViews];
    self.currentSentenceIdx = 0;
}

- (void) setCurrentSentenceIdx:(NSInteger)currentSentenceIdx
{
    _currentSentenceIdx = currentSentenceIdx;
    
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    if (section.sentences.count <= currentSentenceIdx)
    {
        return;
    }
    
    if (self.repeatMode > DFRepeatModeNone)
    {
        DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
        DFSentenceItem* item = [section.sentences objectAtIndex:currentSentenceIdx];
        self.repeatController.sentence = item;
        
        switch (self.repeatMode) {
            case DFRepeatModeCompare:
                [self.repeatPanel.voicesComparedButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            case DFRepeatModeMyVoice:
                [self.repeatPanel.myVoicePlayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                break;
            case DFRepeatModeOriginalVoice:
                [self.repeatPanel.originVoicePlayButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                
            default:
                break;
        }
    }
    else
    {
        [self playSentenceVoiceAtIndex:currentSentenceIdx];
    }
    
    self.timeDurationLabel.text = [NSString stringWithFormat:@"第%d句/共%d句", currentSentenceIdx + 1, section.sentences.count];
    [self.tableView reloadData];
    
//    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:currentSentenceIdx inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    NSIndexPath* indexPath = [NSIndexPath indexPathForRow:currentSentenceIdx inSection:0];
    CGRect rect = [self.tableView rectForRowAtIndexPath:indexPath];
    if (rect.origin.y + rect.size.height > self.tableView.contentOffset.y + self.tableView.frame.size.height)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
    else if (rect.origin.y < self.tableView.contentOffset.y)
    {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
//    [self.tableView scrollRectToVisible:rect animated:NO];
}

- (void) reloadViews
{
    self.sectionLabel.text = [NSString stringWithFormat:@"第%d节", self.currentSectionIdx + 1];
    self.previousButton.enabled = self.currentSectionIdx > 0;
    self.nextButton.enabled = self.currentSectionIdx < self.chapterItem.sections.count - 1;
    
    CGSize size = self.view.frame.size;
    
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    self.title = section.title;
    DFSentenceItem* firstSentence = section.sentences.firstObject;
    if (firstSentence.normalCellHeight <= 0)
    {
        for (DFSentenceItem* sentence in section.sentences)
        {
            sentence.normalDialectSize = [sentence dialectSizeWithFont:[UIFont systemFontOfSize:kSectionVoiceTableCellDialectFontSize] maxSize:CGSizeMake(size.width - kCellMarginLeftRight * 2, 60)];
            sentence.selectedDialectSize = [sentence dialectSizeWithFont:[UIFont systemFontOfSize:kSectionVoiceTableCellDialectFontSize + 1] maxSize:CGSizeMake(size.width - kCellMarginLeftRight * 2, 60)];;
            
            sentence.normalMandarinSize = CGSizeZero;
            sentence.selectedMandarinSize = [sentence mandarinSizeWithFont:[UIFont systemFontOfSize:kSectionVoiceTableCellMandarinFontSize + 1] maxSize:CGSizeMake(size.width - kCellMarginLeftRight * 2, 60)];
            
            sentence.normalCellHeight = kCellMarginTopBottom + sentence.normalDialectSize.height + kCellMarginTopBottom;
            sentence.selectedCellHeight = kCellMarginTopBottom + sentence.selectedMandarinSize.height + kCellLabelSpace + sentence.normalDialectSize.height + kCellMarginTopBottom;
        }
    }
    
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    [dict setObject:section.title forKey:MPMediaItemPropertyTitle];
    [dict setObject:@"韩通培训" forKey:MPMediaItemPropertyArtist];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nil];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:dict];
    
//    [self.tableView reloadData];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.playStatus = AFSoundManagerStatusStopped;
    [AFSoundManager sharedManager].delegate = self;
    
    [self initBackgroundImageView];
    [self initFooterView];
    [self configNavigationBar];
    [self configTableView];
    [self requestChapterInfo];
}

- (void) initBackgroundImageView
{
    self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    self.backgroundImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bkg_blackboard.png"]];
    [self.view insertSubview:self.backgroundImageView atIndex:0];
}

- (void) configNavigationBar
{
    if (self.voiceStyle == DFSectionVoiceStyleDaily)
    {
        [self.customNavigationBar setRightButtonWithStandardTitle:@"复读模式"];
        [self.customNavigationBar.rightButton setTitle:@"复读模式" forState:UIControlStateNormal];
        [self.customNavigationBar.rightButton setTitle:@"顺序播放" forState:UIControlStateSelected];
    }
    else
    {
        self.customNavigationBar.rightButton.hidden = YES;
    }
}

- (void) rightButtonClicked:(id)sender
{
    [[AFSoundManager sharedManager] stop];
    
    self.customNavigationBar.rightButton.selected = !self.customNavigationBar.rightButton.selected;
    self.repeatMode = self.customNavigationBar.rightButton.selected ? DFRepeatModeOriginalVoice : DFRepeatModeNone;
    
    if (self.repeatMode > DFRepeatModeNone)
    {
        if (self.repeatPanel == nil)
        {
            NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"DFRepeatPanel" owner:self options:nil];
            self.repeatPanel = views.firstObject;
            
            CGRect frame = self.repeatPanel.frame;
            frame.origin.x = (self.view.frame.size.width - frame.size.width) / 2;
            self.repeatPanel.frame = frame;
            
            [self.repeatPanel.originVoicePlayButton addTarget:self action:@selector(repeatOriginVoiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.repeatPanel.myVoicePlayButton addTarget:self action:@selector(repeatMyVoiceButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.repeatPanel.voicesComparedButton addTarget:self action:@selector(repeatVoicesComparedButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            self.repeatController = [[DFRepeatController alloc] init];
            self.repeatController.repeatPanel = self.repeatPanel;
        }
        
        [self configTableViewForRepeatMode];
        
        [self.repeatPanel startOriginVoice];
    }
    else
    {
        [self configTableViewForNormal];
    }
    
    self.currentSentenceIdx = 0;
}

- (void) configTableViewForRepeatMode
{
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    if ([SYDeviceDescription sharedDeviceDescription].mainSystemVersion > 6)
    {
        self.tableView.separatorInset = UIEdgeInsetsZero;
    }
    
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - tableFrame.origin.y;
    self.tableView.frame = tableFrame;
    
    typeof(self) __weak bself = self;
    [UIView animateWithDuration:0.2 animations:^{
        
        bself.backgroundImageView.alpha = 0;
        
        CGRect playBarFrame = bself.playBarView.frame;
        playBarFrame.origin.y = bself.view.frame.size.height;
        bself.playBarView.frame = playBarFrame;
        
    } completion:^(BOOL finished) {
        
        [bself.playBarView removeFromSuperview];
        
        [bself.backgroundImageView removeFromSuperview];
        
    }];
}

- (void) configTableViewForNormal
{
    if (self.playBarView.superview != self.view)
    {
        [self.view addSubview:self.playBarView];
        [self.view insertSubview:self.backgroundImageView atIndex:0];
        
        typeof(self) __weak bself = self;
        [UIView animateWithDuration:0.2 animations:^{
            
            bself.backgroundImageView.alpha = 1;
            
            CGRect playBarFrame = bself.playBarView.frame;
            playBarFrame.origin.y = bself.view.frame.size.height - bself.playBarView.frame.size.height;
            bself.playBarView.frame = playBarFrame;
            
        } completion:^(BOOL finished) {
            
            CGRect tableFrame = self.tableView.frame;
            tableFrame.size.height = self.view.frame.size.height - self.playBarView.frame.size.height - self.customNavigationBar.frame.size.height;
            self.tableView.frame = tableFrame;
            
        }];
    }
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[AFSoundManager sharedManager] stop];
}

- (void) playSentenceVoiceAtIndex:(NSInteger)index
{
    
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    DFSentenceItem* sentence = [section.sentences objectAtIndex:index];
    
    NSString* audioFilePath = [[DFFilePath sentenceAudiosDirectory] stringByAppendingPathComponent:[NSString stringWithFormat:@"%d.mp3", sentence.persistentId]];
    if ([DFFilePath fileExists:audioFilePath])
    {
        [self playLocalVoice:audioFilePath];
    }
    else
    {
        [self playRemoteVoice:sentence.voiceUrl];
    }
}

- (void) playLocalVoice:(NSString *)filePath
{
    typeof(self) __weak bself = self;
    [[AFSoundManager sharedManager] startPlayingLocalFilePath:filePath andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        if (!error) {
            
//            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//            [formatter setDateFormat:@"mm:ss"];
//            
//            NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
//            NSDate *timeDurationDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining + elapsedTime];
//            bself.timeDurationLabel.text = [NSString stringWithFormat:@"%@/%@", [formatter stringFromDate:elapsedTimeDate], [formatter stringFromDate:timeDurationDate]];
            
            if (bself.repeatMode == DFRepeatModeNone)
            {
                bself.slider.value = percentage * 0.01;
            }
            
            NSLog(@"%i percent played",percentage);
            
        } else {
            
            [SYPrompt showWithText:@"播放错误"];
            [self processWhenPlayFinishd];
            
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
    }];
}

- (void) playRemoteVoice:(NSString *)url
{
    typeof(self) __weak bself = self;
    [[AFSoundManager sharedManager] startStreamingRemoteAudioFromURL:url andBlock:^(int percentage, CGFloat elapsedTime, CGFloat timeRemaining, NSError *error, BOOL finished) {
        
        if (!error) {
            
//            NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
//            [formatter setDateFormat:@"mm:ss"];
//            
//            NSDate *elapsedTimeDate = [NSDate dateWithTimeIntervalSince1970:elapsedTime];
//            NSDate *timeDurationDate = [NSDate dateWithTimeIntervalSince1970:timeRemaining + elapsedTime];
//            bself.timeDurationLabel.text = [NSString stringWithFormat:@"%@/%@", [formatter stringFromDate:elapsedTimeDate], [formatter stringFromDate:timeDurationDate]];
            
            if (bself.repeatMode == DFRepeatModeNone)
            {
                bself.slider.value = percentage * 0.01;
            }
            
            NSLog(@"%i percent played",percentage);
            
        } else {
            
            [SYPrompt showWithText:@"播放错误"];
            [self processWhenPlayFinishd];
            
            NSLog(@"There has been an error playing the remote file: %@", [error description]);
        }
    }];
}

- (void) initFooterView
{
    NSArray* views = [[NSBundle mainBundle] loadNibNamed:@"DFSectionPlayerBar" owner:self options:nil];
    self.playBarView = views.firstObject;
    
    CGRect playBarFrame = self.playBarView.frame;
    playBarFrame.origin.y = self.view.frame.size.height - playBarFrame.size.height;
    self.playBarView.frame = playBarFrame;
    [self.view addSubview:self.playBarView];
    
    self.timeDurationLabel.text = @"第1句/第1节";
    
    [self.slider setMaximumTrackImage:[UIImage imageNamed:@"playbar_progress_normal.png"] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[UIImage imageNamed:@"playbar_progress_track.png"] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"playbar_progress_thumb.png"] forState:UIControlStateNormal];
    self.slider.continuous = NO;
    self.slider.value = 0;
    [self.slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
}

- (IBAction)previousButtonClicked:(id)sender
{
    [[AFSoundManager sharedManager] stop];
    
    self.currentSectionIdx = self.currentSectionIdx - 1;
}

- (IBAction)nextButtonClicked:(id)sender
{
    [[AFSoundManager sharedManager] stop];
    
    self.currentSectionIdx = self.currentSectionIdx + 1;
}

- (IBAction)playPauseButtonClicked:(id)sender
{
    switch (self.playStatus) {
        case AFSoundManagerStatusFinished:
            [[AFSoundManager sharedManager] restart];
            break;
            
        case AFSoundManagerStatusPaused:
            [[AFSoundManager sharedManager] resume];
            break;
            
        case AFSoundManagerStatusPlaying:
        case AFSoundManagerStatusRestarted:
            [[AFSoundManager sharedManager] pause];
            break;
            
        case AFSoundManagerStatusStopped:
//            self.currentSentenceIdx = 0;
            [self playSentenceVoiceAtIndex:self.currentSentenceIdx];
            break;
            
        default:
            break;
    }
}

- (void) sliderValueChanged:(UISlider *)sender
{
    [[AFSoundManager sharedManager] moveToSection:sender.value];
}


#define kCellId @"Sentence"

- (void) configTableView
{
    [self configTableViewForNormal];
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = self.view.frame.size.height - self.playBarView.frame.size.height - self.customNavigationBar.frame.size.height;
    self.tableView.frame = tableFrame;
    
    [self.tableView registerClass:[DFSectionVoiceTableViewCell class] forCellReuseIdentifier:kCellId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    DFSectionItem* sectionItem = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    return sectionItem.sentences.count;
}

- (BOOL) tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.repeatMode > DFRepeatModeNone && indexPath.row == self.currentSentenceIdx)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (void) tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void) tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (NSIndexPath *) tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.repeatMode > DFRepeatModeNone && indexPath.row == self.currentSentenceIdx)
    {
        return nil;
    }
    else
    {
        return indexPath;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFSectionVoiceTableViewCell* cell = [self.tableView dequeueReusableCellWithIdentifier:kCellId forIndexPath:indexPath];
    
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    DFSentenceItem* item = [section.sentences objectAtIndex:indexPath.row];
    
    cell.dialectLabel.text = item.dialect;
    cell.mandarinLabel.text = item.mandarin;
    
    cell.contentInsets = UIEdgeInsetsMake(kCellMarginTopBottom, kCellMarginLeftRight, kCellMarginTopBottom, kCellMarginLeftRight);
    
    cell.labelSpace = kCellLabelSpace;
    
    if (self.repeatMode > DFRepeatModeNone)
    {
        cell.dialectLabel.textColor = [UIColor blackColor];
        cell.mandarinLabel.textColor = RGBCOLOR(114, 114, 114);
        cell.mandarinLabel.hidden = NO;
        
        cell.dialectSize = item.selectedDialectSize;
        cell.mandarinSize = item.selectedMandarinSize;
        
        if (self.currentSentenceIdx == indexPath.row)
        {
            cell.backgroundColor = [UIColor whiteColor];
            
            cell.repeatPanel = self.repeatPanel;
            [cell.contentView addSubview:self.repeatPanel];
            if (cell.repeatPanel.originVoiceAnimating)
            {
                [cell.repeatPanel startOriginVoice];
            }
            else
            {
                [cell.repeatPanel resetOriginVoice];
            }
        }
        else
        {
            cell.repeatPanel = nil;
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    else
    {
        cell.backgroundColor = [UIColor clearColor];
        [self.repeatPanel removeFromSuperview];
        cell.repeatPanel = nil;
        
        if (self.currentSentenceIdx == indexPath.row)
        {
            cell.dialectLabel.textColor = RGBCOLOR(224, 224, 224);
            cell.mandarinLabel.textColor = RGBCOLOR(224, 224, 224);
            cell.mandarinLabel.hidden = NO;
            
            cell.dialectSize = item.selectedDialectSize;
            cell.mandarinSize = item.selectedMandarinSize;
            
            cell.dialectLabel.font = [UIFont systemFontOfSize:kSectionVoiceTableCellDialectFontSize + 1];
            cell.mandarinLabel.font = [UIFont systemFontOfSize:kSectionVoiceTableCellMandarinFontSize + 1];
        }
        else
        {
            cell.dialectLabel.textColor = RGBCOLOR(154, 154, 154);
            cell.mandarinLabel.textColor = RGBCOLOR(154, 154, 154);
            cell.mandarinLabel.hidden = YES;
            
            cell.dialectSize = item.selectedDialectSize;
            cell.mandarinSize = item.normalMandarinSize;
            
            cell.dialectLabel.font = [UIFont systemFontOfSize:kSectionVoiceTableCellDialectFontSize];
            cell.mandarinLabel.font = [UIFont systemFontOfSize:kSectionVoiceTableCellMandarinFontSize];
        }
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.voiceStyle == DFSectionVoiceStylePreivew)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        return;
    }
    
    if (self.repeatMode > DFRepeatModeNone)
    {
        self.repeatMode = DFRepeatModeOriginalVoice;
    }
    self.currentSentenceIdx = indexPath.row;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    if (self.repeatMode > DFRepeatModeNone)
    {
        return [[section.sentences objectAtIndex:indexPath.row] selectedCellHeight] + (self.currentSentenceIdx == indexPath.row ? (self.repeatPanel.frame.size.height + kCellMarginTopBottom) : 0);
    }
    else
    {
        DFSentenceItem* sentence = [section.sentences objectAtIndex:indexPath.row];
        return (self.currentSentenceIdx == indexPath.row ? sentence.selectedCellHeight : sentence.normalCellHeight);
    }
}

- (void) setCurSectionPreviewed
{
    if (self.currentSectionIdx >= 0 && self.currentSectionIdx < self.chapterItem.sections.count)
    {
        DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
        if (self.completedBlock)
        {
            self.completedBlock(section.persistentId);
        }
        SYHttpRequest* request = [SYHttpRequest startAsynchronousRequestWithUrl:[DFUrlDefine urlForPreviewCourse] postValues:@{@"section_id" : [NSNumber numberWithInteger:section.persistentId]} finished:^(BOOL success, NSDictionary *resultInfo, NSString *errorMsg) {
            
        }];
        [self.requests addObject:request];
    }
}

-(void)currentPlayingStatusChanged:(AFSoundManagerStatus)status {
    
    self.playStatus = status;
    switch (status) {
        case AFSoundManagerStatusFinished:

            [self processWhenPlayFinishd];
            
            break;
            
        case AFSoundManagerStatusPaused:
            if (self.repeatMode == DFRepeatModeNone)
            {
                self.playPauseButton.selected = NO;
            }
            
            break;
            
        case AFSoundManagerStatusPlaying:
            //Playing got started or resumed
            if (self.repeatMode == DFRepeatModeNone)
            {
                self.playPauseButton.selected = YES;
            }
            break;
            
        case AFSoundManagerStatusRestarted:
            //Playing got restarted
            if (self.repeatMode == DFRepeatModeNone)
            {
                self.playPauseButton.selected = YES;
            }
            break;
            
        case AFSoundManagerStatusStopped:
            //Playing got stopped
            if (self.repeatMode == DFRepeatModeNone)
            {
                self.playPauseButton.selected = NO;
            }
            break;
            
        default:
            break;
    }
}

- (void) processWhenPlayFinishd
{
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    
    switch (self.repeatMode) {
        case DFRepeatModeNone:
        {
            self.playPauseButton.selected = NO;
            
            if (self.currentSentenceIdx < section.sentences.count - 1 && self.currentSentenceIdx >= 0)
            {
                ++self.currentSentenceIdx;
            }
            else
            {
                if (self.voiceStyle == DFSectionVoiceStylePreivew)
                {
                    [self setCurSectionPreviewed];
                }
                
                [self.nextButton sendActionsForControlEvents:UIControlEventTouchUpInside]; //
            }
        }
            break;
            
        case DFRepeatModeOriginalVoice:
            self.repeatPanel.mikeButton.enabled = YES;
            self.repeatPanel.myVoicePlayButton.enabled = YES;
            self.repeatPanel.voicesComparedButton.enabled = YES;
            [self.repeatPanel resetOriginVoice];
            break;
            
        case DFRepeatModeMyVoice:
            self.repeatPanel.originVoicePlayButton.enabled = YES;
            self.repeatPanel.mikeButton.enabled = YES;
            self.repeatPanel.voicesComparedButton.enabled = YES;
            [self.repeatPanel resetMyVoice];
            break;
            
        case DFRepeatModeCompare:
            if (self.playingMyVoice)
            {
                self.playingMyVoice = NO;
                
                [self.repeatPanel resetMyVoice];
                
                self.repeatPanel.originVoicePlayButton.enabled = YES;
                self.repeatPanel.originVoicePlayButton.userInteractionEnabled = YES;
                self.repeatPanel.myVoicePlayButton.userInteractionEnabled = YES;
                self.repeatPanel.mikeButton.enabled = YES;
            }
            else
            {
                [self.repeatPanel resetOriginVoice];
                self.repeatPanel.originVoicePlayButton.enabled = NO;
                
                self.playingMyVoice = YES;
                [self.repeatPanel startMyVoice];
                [self playCurrentMyVoice];
            }
            break;
            
        default:
            break;
    }
}

- (void) repeatOriginVoiceButtonClicked:(id)sender
{
    self.repeatMode = DFRepeatModeOriginalVoice;
    
    [self.repeatPanel startOriginVoice];
    
    self.repeatPanel.mikeButton.enabled = NO;
    self.repeatPanel.myVoicePlayButton.enabled = NO;
    self.repeatPanel.voicesComparedButton.enabled = NO;
    
    [self playSentenceVoiceAtIndex:self.currentSentenceIdx];
}

- (void) repeatMyVoiceButtonClicked:(id)sender
{
    self.repeatMode = DFRepeatModeMyVoice;
    
    [self.repeatPanel startMyVoice];
    self.repeatPanel.originVoicePlayButton.enabled = NO;
    self.repeatPanel.mikeButton.enabled = NO;
    self.repeatPanel.voicesComparedButton.enabled = NO;
    
    [self playCurrentMyVoice];
}

- (void) repeatVoicesComparedButtonClicked:(id)sender
{
    self.repeatMode = DFRepeatModeCompare;
    
    [self.repeatPanel startOriginVoice];
    self.repeatPanel.originVoicePlayButton.userInteractionEnabled = NO;
    self.repeatPanel.mikeButton.enabled = NO;
    self.repeatPanel.myVoicePlayButton.userInteractionEnabled = NO;
    
    [self playSentenceVoiceAtIndex:self.currentSentenceIdx];
}

- (void) playCurrentMyVoice
{
    DFSectionItem* section = [self.chapterItem.sections objectAtIndex:self.currentSectionIdx];
    DFSentenceItem* sentence = [section.sentences objectAtIndex:self.currentSentenceIdx];
    
    NSString* filePath = [DFFilePath sentenceVoicesWithId:sentence.persistentId];
    
    [self playLocalVoice:filePath];
}

@end
