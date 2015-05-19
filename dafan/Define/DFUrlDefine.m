//
//  DFUrlDefine.m
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFUrlDefine.h"
#import "DFVersionRelease.h"


#ifdef TestWifi
#define kMYBaseURL @"http://m.1hanyu.net/?action=%@"
#else
#define kMYBaseURL @"http://m.1hanyu.net/?action=%@"
#endif

@implementation DFUrlDefine

+ (NSString *) urlForStartup
{
    return [NSString stringWithFormat:kMYBaseURL, @"startup"];
}

+ (NSString *) urlForAliPay
{
    return [NSString stringWithFormat:kMYBaseURL, @"alipayquick"];
}

+ (NSString *) urlForMemberAliPayTradeNo
{
    return [NSString stringWithFormat:kMYBaseURL, @"alipayquick&pay_type=1"];
}

+ (NSString *) urlForFreeRegister
{
    return [NSString stringWithFormat:kMYBaseURL, @"ordersigncourse"];
}

+ (NSString *) urlForAliPayResult
{
    return [NSString stringWithFormat:kMYBaseURL, @"aliresult"];
}

+ (NSString *) urlForMyCourseAndBanner
{
    return [NSString stringWithFormat:kMYBaseURL, @"main"];
}

+ (NSString *) urlForOtherTeacherCourses
{
    return [NSString stringWithFormat:kMYBaseURL,  @"teacherlist"];
}

+ (NSString *) urlForDoingClassrooms
{
    return [NSString stringWithFormat:kMYBaseURL, @"classcourse"];
}

+ (NSString *) urlForRegisterableTeachers
{
    return [NSString stringWithFormat:kMYBaseURL, @"cansigncourse"];
}

+ (NSString *) urlForCheckUpdate
{
    return [NSString stringWithFormat:kMYBaseURL,  @"update"];
}

+ (NSString *) urlForTeacheInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"teacherinfo"];
}

+ (NSString *) urlForDailyScenes
{
    return [NSString stringWithFormat:kMYBaseURL, @"studylist"];
}

+ (NSString *) urlForFilmClips
{
    return [NSString stringWithFormat:kMYBaseURL, @"videolist"];
}

#pragma mark - user login & register

+ (NSString *) urlForUserInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"getuserinfo"];
}

+ (NSString *) urlForLogin
{
    return [NSString stringWithFormat:kMYBaseURL, @"login"];
}

+ (NSString *) urlForLoginBySns
{
    return [NSString stringWithFormat:kMYBaseURL, @"loginbysns"];;
}

+ (NSString *) urlForUpdatePassword
{
    return [NSString stringWithFormat:kMYBaseURL, @"changepassword"];
}

+ (NSString *) urlForFindPassword
{
    return [NSString stringWithFormat:kMYBaseURL, @"subnewpassword"];
}

+ (NSString *) urlForSendCheckCode
{
    return [NSString stringWithFormat:kMYBaseURL, @"getauthcode"];
}

+ (NSString *) urlForUserRegister
{
    return [NSString stringWithFormat:kMYBaseURL, @"register"];
}

+ (NSString *) urlForGetRandNickname
{
    return [NSString stringWithFormat:kMYBaseURL, @"randnickname"];
}

#pragma mark - class course

+ (NSString *) urlForCourseClassInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"courseinfo"];
}

+ (NSString *) urlForCourseStudents
{
    return [NSString stringWithFormat:kMYBaseURL, @"courseuserlist"];
}

+ (NSString *) urlforCourseHours
{
    return [NSString stringWithFormat:kMYBaseURL, @"coursehours"];
}

+ (NSString *) urlForCourseChapterSections
{
    return [NSString stringWithFormat:kMYBaseURL, @"coursechaptersection"];
}

//#define kMYBasePrefixURL @"http://m.dafanpx.com/?action="

+ (NSString *) urlforChapterSentencesWithSectionId:(NSInteger)sectionId
{
    return [NSString stringWithFormat:kMYBaseURL, [NSString stringWithFormat:@"getchaptersections&section_id=%d", sectionId]];
}

+ (NSString *) urlForMyCourses
{
    return [NSString stringWithFormat:kMYBaseURL, @"usercourse"];
}

+ (NSString *) urlForInverseFocused
{
    return [NSString stringWithFormat:kMYBaseURL, @"switchfav"];
}

+ (NSString *) urlForKickoutFromClassroom
{
    return [NSString stringWithFormat:kMYBaseURL, @"kickuser"];
}

+ (NSString *) urlForInverseClassroomTextChatEnabled
{
    return [NSString stringWithFormat:kMYBaseURL, @"bancourseuser&ban_type=0"];
}

+ (NSString *) urlForInverseClassroomVoiceChatEnabled
{
    return [NSString stringWithFormat:kMYBaseURL, @"bancourseuser&ban_type=1"];
}

+ (NSString *) urlForStartClass
{
    return [NSString stringWithFormat:kMYBaseURL, @"changeclass"];
}

+ (NSString *) urlforSetCurrentChapterSection
{
    return [NSString stringWithFormat:kMYBaseURL, @"setcoursesection"];
}

+ (NSString *) urlForRatingTeacherCourse
{
    return [NSString stringWithFormat:kMYBaseURL, @"rateteacher"];
}

+ (NSString *) urlForChannels
{
    return [NSString stringWithFormat:kMYBaseURL,  @"channellist"];
}

+ (NSString *) urlForChannelInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"channelinfo"];
}

+ (NSString *) urlForAvailableCourses
{
    return [NSString stringWithFormat:kMYBaseURL, @"coursecreateinfo"];
}

+ (NSString *) urlForCreateNewCourse
{
    return [NSString stringWithFormat:kMYBaseURL, @"addcourse"];
}

+ (NSString *) urlForCourseDetailInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"coursedetail"];
}

+ (NSString *) urlForUpdateCourseHours
{
    return [NSString stringWithFormat:kMYBaseURL,  @"batchupdatehour"];
}

+ (NSString *) urlForApplyForTeacher
{
    return [NSString stringWithFormat:kMYBaseURL,  @"teachersign"];
}

+ (NSString *) urlForUploadFile
{
    return @"http://up.maiqinqin.com/?action=upload";
}

+ (NSString *) urlForUploadVoice
{
    return @"http://m.maiqinqin.com/uploadfile.php";
}

+ (NSString *) urlForCompleteUserInfo
{
    return [NSString stringWithFormat:kMYBaseURL,  @"full"];
}

+ (NSString *) urlForChannelMembers
{
    return [NSString stringWithFormat:kMYBaseURL,  @"channeluserlist"];
}

+ (NSString *) urlForCreateChannel
{
    return [NSString stringWithFormat:kMYBaseURL, @"signchannel"];
}

+ (NSString *) urlForImportChannelTopic
{
    return [NSString stringWithFormat:kMYBaseURL, @"setchannelnotice"];
}

+ (NSString *) urlForInverseChatroomTextChatEnabled
{
    return [NSString stringWithFormat:kMYBaseURL, @"banchanneluser&ban_type=0"];
}

+ (NSString *) urlForInverseChatroomVoiceChatEnabled
{
    return [NSString stringWithFormat:kMYBaseURL, @"banchanneluser&ban_type=1"];
}

+ (NSString *) urlForConfigChannel
{
    return [NSString stringWithFormat:kMYBaseURL, @"setchannel"];
}

+ (NSString *) urlForFeedback
{
    return [NSString stringWithFormat:kMYBaseURL, @"feedback"];
}

+ (NSString *) urlforReport
{
    return [NSString stringWithFormat:kMYBaseURL, @"report"];
}

+ (NSString *) urlForFilmClipDetail
{
    return [NSString stringWithFormat:kMYBaseURL, @"videoinfo"];
}

+ (NSString *) urlForFilmpClipComments
{
    return [NSString stringWithFormat:kMYBaseURL, @"videocommentlist"];
}

+ (NSString *) urlForSendFilmClipComment
{
    return [NSString stringWithFormat:kMYBaseURL, @"commentvideo"];
}

+ (NSString *) urlForDeleteFilmClipComment
{
    return [NSString stringWithFormat:kMYBaseURL,  @"delvideocomment"];
}

+ (NSString *) urlForChapterInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"chapterinfo"];
}

+ (NSString *) urlForCollectFilmClip
{
    return [NSString stringWithFormat:kMYBaseURL, @"favvideo"];
}

+ (NSString *) urlForUncollectFilmClip
{
    return [NSString stringWithFormat:kMYBaseURL, @"unfavvideo"];
}

+ (NSString *) urlForShareFilmClip
{
    return [NSString stringWithFormat:kMYBaseURL, @"sharevideo"];
}

+ (NSString *) urlForFocusList
{
    return [NSString stringWithFormat:kMYBaseURL, @"focuslist&type=1"];
}

+ (NSString *) urlForFansList
{
    return [NSString stringWithFormat:kMYBaseURL, @"focuslist&type=2"];
}

+ (NSString *) urlForRecentContacts
{
    return [NSString stringWithFormat:kMYBaseURL, @"getmessage"];
}

+ (NSString *) urlForClassCircles
{
    return [NSString stringWithFormat:kMYBaseURL, @"userclass"];
}

+ (NSString *) urlForClassCircleInfo
{
    return [NSString stringWithFormat:kMYBaseURL, @"classinfo"];
}

+ (NSString *) urlForSendClassCircleMessage
{
    return [NSString stringWithFormat:kMYBaseURL, @"classsendmsg"];
}

+ (NSString *) urlForLatestClassCircleMessages
{
    return [NSString stringWithFormat:kMYBaseURL, @"classgetmsg"];
}

+ (NSString *) urlForLatestContactMessages
{
    return [NSString stringWithFormat:kMYBaseURL, @"getlastmessage"];
}

+ (NSString *) urlForSendContactMessage
{
    return [NSString stringWithFormat:kMYBaseURL, @"sendmessage"];
}

+ (NSString *) urlForClearMessage
{
    return [NSString stringWithFormat:kMYBaseURL, @"clearmessage"];
}
+ (NSString *) urlForNewsCount
{
    return [NSString stringWithFormat:kMYBaseURL, @"newinfo"];
}

+ (NSString *) urlForIncoming
{
    return [NSString stringWithFormat:kMYBaseURL, @"userbalance"];
}

+ (NSString *) urlForSetUserDeviceToken
{
    return [NSString stringWithFormat:kMYBaseURL, @"setcid"];
}

+ (NSString *) urlForCourseIntroduction
{
    return [NSString stringWithFormat:kMYBaseURL, @"coursedesc"];
}

+ (NSString *) urlForCoursePrep
{
    return [NSString stringWithFormat:kMYBaseURL, @"coursepreview"];
}

+ (NSString *) urlForPreviewCourse
{
    return [NSString stringWithFormat:kMYBaseURL, @"previewsection"];
}

+ (NSString *) urlForUpdateClasscircle
{
    return [NSString stringWithFormat:kMYBaseURL, @"classsetting"];
}

+ (NSString *) urlForQuitFromClass
{
    return [NSString stringWithFormat:kMYBaseURL, @"quitclass"];
}

@end
