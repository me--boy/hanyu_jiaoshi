//
//  VoiChannelAPIDelegate.h
//  VoiChannelAPI
//
//  Created by ouyang on 14/12/12.
//
//

#import <Foundation/Foundation.h>
#import "GotyeTypeDefine.h"

@class GotyeChannelInfo;

/**
 *  API消息回调
 */
@protocol VoiChannelAPIDelegate <NSObject>

@optional

/**
 *  错误异常
 *
 *  @param errorType  错误消息类型
 */
- (void)onError:(GotyeErrorType)errorType;

/**
 *  退出登录
 *
 *  @param success  YES 成功 NO 失败
 */
- (void)onExit:(BOOL)success;

/**
 *  加入频道
 *
 * @param success  YES 成功 NO 失败
 */
- (void)onJoinChannel:(BOOL)success;

/**
 *  退出频道
 *
 *  @param success  YES 成功 NO 失败
 */
- (void)onExitChannel:(BOOL)success;

/**
 *  所在频道被删除时收到的通知
 */
- (void)onChannelRemoved;

/**
 *  获取到用户昵称的回调
 *
 *  @param userMap   用户昵称的key-value对，key值为用户id，value值为用户昵称
 */
- (void)onGetUserNickname:(NSDictionary *)userMap;

/**
 *  获取到频道其他成员
 *
 *  @param userId  进入频道的用户id
 */
- (void)onGetChannelMember:(NSString *)userId;

/**
 *  其他成员退出频道通知
 *
 *  @param userId  退出频道用户id
 */
- (void)onRemoveChannelMember:(NSString *)userId;

/**
 *  频道中有人开始说话(包含自己)
 *
 *  @param userId  开始说话用户id
 */
- (void)onStartTalking:(NSString *)userId;

/**
 *  频道中有人停止说话(包含自己)
 *
 *  @param userId  停止说话用户id
 */
- (void)onStopTalking:(NSString *)userId;

/**
 *  自己禁言|静音状态发生改变
 *
 *  @param muted  YES 自己禁言｜静音  NO 自己取消禁言｜静音
 */
- (void)onMuteStateChanged:(BOOL)muted;

/**
 *  频道中有人被管理员 禁言/取消禁言(包括自己)
 *
 *  @param silenced YES 用户被禁言/静音  NO 用户禁言/静音被取消
 *  @param userId   被禁言/取消禁言用户id
 */
- (void)onSilencedStateChanged:(BOOL)silenced with:(NSString *)userId;

/**
 *  通知：获取到频道发言模式
 *
 *  @param TalkMode  频道发言模式枚举值
 */
- (void)notifyChannelTalkMode:(TalkMode)talkMode;

/**
 *  通知：获取到频道成员类型表
 *
 *  @param typeList  频道成员列表。key为成员userId，value为封装了MemberType的NSNumber类型; 字典中包含发生身份发生变化的成员，不在此字典中的成员身份不变.
 */
- (void)notifyChannelMemberTypes:(NSDictionary *)typeList;

/**
 *  获取到频道详情
 *
 *  @param info  频道的详情。（名字等）
 */
- (void)onGetChannelDetail:(GotyeChannelInfo *)info;

@end

