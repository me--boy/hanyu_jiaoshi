//
//  DFUrlDefine.h
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFUrlDefine : NSObject

//－－－－－－－－－－－－－－－－支付
//获取支付宝，报名课程的支付信息
+ (NSString *) urlForAliPay;
//获取支付宝转账结果
+ (NSString *) urlForAliPayResult;
//测试接口，不保证正确
+ (NSString *) urlForFreeRegister;
//获取支付宝，购买会员的支付信息
+ (NSString *) urlForMemberAliPayTradeNo;

//main
//启动时调用的接口，用于获取一些常用信息
+ (NSString *) urlForStartup;
//检查更新
+ (NSString *) urlForCheckUpdate;
//绑定用户和设备token，以备推送时使用
+ (NSString *) urlForSetUserDeviceToken;
//发送用户反馈
+ (NSString *) urlForFeedback;
//举报
+ (NSString *) urlforReport;
//上传图片
+ (NSString *) urlForUploadFile; //upload picture
//上传语音
+ (NSString *) urlForUploadVoice; //upload voice

//－－－－－－－－－－－－－课程老师
//课程老师页面
+ (NSString *) urlForMyCourseAndBanner;
//其他老师课程
+ (NSString *) urlForOtherTeacherCourses;
//正在上课的课程
+ (NSString *) urlForDoingClassrooms;
//可报名的老师
+ (NSString *) urlForRegisterableTeachers;
//老师信息
+ (NSString *) urlForTeacheInfo;
// 申请老师，未用
+ (NSString *) urlForApplyForTeacher;

//－－－－－－－－－－－－－－－用户注册/登录
//自有账号登录
+ (NSString *) urlForLogin;
//第三方登录
+ (NSString *) urlForLoginBySns;
//获取用户信息
+ (NSString *) urlForUserInfo;
//修改密码
+ (NSString *) urlForUpdatePassword;
//找回密码
+ (NSString *) urlForFindPassword;
//申请发送验证码到手机
+ (NSString *) urlForSendCheckCode;
//注册
+ (NSString *) urlForUserRegister;
//获取随机的昵称名
+ (NSString *) urlForGetRandNickname;
//转变关注状态，已关注->未关注，未关注->已关注
+ (NSString *) urlForInverseFocused;
//修改用户信息
+ (NSString *) urlForCompleteUserInfo;

+ (NSString *) urlForFocusList;
+ (NSString *) urlForFansList;

//－－－－－－－－－－－－－－－－自学园地
//日常用语，主题章节列表
+ (NSString *) urlForDailyScenes;
//影视片段的列表
+ (NSString *) urlForFilmClips;
//某个影视片段的具体信息
+ (NSString *) urlForFilmClipDetail;
//某个影视片段的评论
+ (NSString *) urlForFilmpClipComments;
//给某个影视片段发送评论
+ (NSString *) urlForSendFilmClipComment;
//给某个影视片段删除评论
+ (NSString *) urlForDeleteFilmClipComment;
//收藏某个影视片段
+ (NSString *) urlForCollectFilmClip;
//取消收藏某个影视片段
+ (NSString *) urlForUncollectFilmClip;
//分享某个影视片段
+ (NSString *) urlForShareFilmClip;

//－－－－－－－－－－－－－－－师友信息
//最近联系人
+ (NSString *) urlForRecentContacts;
//给某个联系人发送私信
+ (NSString *) urlForSendContactMessage;
//清除和某个人的私信
+ (NSString *) urlForClearMessage;
//获取和某个人的最近信息
+ (NSString *) urlForLatestContactMessages; //do

//获取所有班级圈
+ (NSString *) urlForClassCircles;
//获取班级圈信息
+ (NSString *) urlForClassCircleInfo;
//在班级圈中发送信息
+ (NSString *) urlForSendClassCircleMessage;
//获取班级圈中的最近消息
+ (NSString *) urlForLatestClassCircleMessages;
//更新班级圈信息
+ (NSString *) urlForUpdateClasscircle;
//退出班级圈
+ (NSString *) urlForQuitFromClass;

//－－－－－－－－－－－－－－－－
//获取一些未阅读的信息数量
+ (NSString *) urlForNewsCount;
//用户收入
+ (NSString *) urlForIncoming;

//－－－－－－－－－－－－－－－－课堂信息
//课堂信息
+ (NSString *) urlForCourseClassInfo;
//课程成员
+ (NSString *) urlForCourseStudents;
//课程课时信息
+ (NSString *) urlforCourseHours;
//课程 章节 信息
+ (NSString *) urlForCourseChapterSections;
//某节的句子信息
+ (NSString *) urlforChapterSentencesWithSectionId:(NSInteger)sectionId;
//从课堂中剔出某人
+ (NSString *) urlForKickoutFromClassroom;
//发转某人在课堂的文字 禁言文字<->可发文字
+ (NSString *) urlForInverseClassroomTextChatEnabled;
//发转某人在课堂的语音发出属性  禁言语音 <-> 可发语音
+ (NSString *) urlForInverseClassroomVoiceChatEnabled;
//开始或结束上课
+ (NSString *) urlForStartClass;
//设置当前上的章节
+ (NSString *) urlforSetCurrentChapterSection;
//评价某课程
+ (NSString *) urlForRatingTeacherCourse;

//-------------------------用户课程
//某人学习和教授课程
+ (NSString *) urlForMyCourses;
//可创建的课程类型
+ (NSString *) urlForAvailableCourses;
//创建新课程
+ (NSString *) urlForCreateNewCourse;
//课程详情，名称，学费，课时信息
+ (NSString *) urlForCourseDetailInfo;
//修改课程课时信息
+ (NSString *) urlForUpdateCourseHours;
//章节信息
+ (NSString *) urlForChapterInfo;
//课程介绍，海报，推广
+ (NSString *) urlForCourseIntroduction;
//预习
+ (NSString *) urlForCoursePrep;
//预习完某一节
+ (NSString *) urlForPreviewCourse;

//－－－－－－－－－－－－－－－－－联系广场
//聊天室列表
+ (NSString *) urlForChannels;
//聊天室信息
+ (NSString *) urlForChannelInfo;
//聊天室成员列表
+ (NSString *) urlForChannelMembers;
//创建聊天室
+ (NSString *) urlForCreateChannel;
//导入聊天室主题
+ (NSString *) urlForImportChannelTopic;
//修改聊天室配置
+ (NSString *) urlForConfigChannel;
// 禁言文字 <-> 取消禁言文字
+ (NSString *) urlForInverseChatroomTextChatEnabled;
// 禁言语音 <-> 取消禁言语音
+ (NSString *) urlForInverseChatroomVoiceChatEnabled;

@end
