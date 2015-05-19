//
//  DFSectionVoiceViewController.h
//  dafan
//
//  Created by iMac on 14-8-22.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "SYTableViewController.h"
#import "DFDailySceneItem.h"

typedef NS_ENUM(NSInteger, DFSectionVoiceStyle)
{
    DFSectionVoiceStyleDaily,
    DFSectionVoiceStylePreivew,
};

//预习
//日常用语
    //自动播放
    //手动

typedef void(^voicePlayCompleted)(NSInteger sectionId);

@interface DFSectionVoiceViewController : SYTableViewController
{
    AVAudioRecorder* _record;
}

- (id) initWithChapterId:(NSInteger)chapterId;

@property(nonatomic) DFSectionVoiceStyle voiceStyle;
@property(nonatomic) NSInteger currentSectionIdx;

//@property(nonatomic) BOOL playSingle; //只播放当前一首
@property(nonatomic, copy) voicePlayCompleted completedBlock;

@end
