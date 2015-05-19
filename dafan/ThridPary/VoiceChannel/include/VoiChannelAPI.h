//
//  VoiChannelAPI.h
//  VoiChannelAPI
//
//  Created by hash on 14-2-18.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "GotyeChannelnfo.h"
#import "GotyeLoginInfo.h"
#import "VoiChannelAPIDelegate.h"
#import "GotyeTypeDefine.h"










#define APIInstance     [VoiChannelAPI defaultAPI]

@interface VoiChannelAPI : NSObject

/**
 *  获取API的单实例
 *
 *  @return VoiChannelAPI   默认实例化对象
 */
+ (VoiChannelAPI*)defaultAPI;

/**
 *  设定appKey初始化API
 *
 *  @param appKey  指定appkey
 */
- (void)setAppKey: (NSString *)appKey;

/**
 *  设置主机地址和端口
 *
 *  @param host      主机地址
 *  @param httpPort  http端口
 *  @param httpsPort https端口
 */
- (void)setHost:(NSString *)host andHttpPort:(NSUInteger)httpPort httpsPort:(NSUInteger)httpsPort;

/**
 *  设置用户的登录信息
 *
 *  @param loginInfo 用户的登录信息
 */
- (void)setLoginInfo:(GotyeLoginInfo *)loginInfo;

/**
 *  获取用户昵称
 *
 *  @param userIdArray 需要获取昵称的用户id数组
 */
- (void)requestUserNickname:(NSArray *)userIdArray;

/**
 *  获取频道详情
 *
 *  @param info 需要获取详情的频道
 */
- (void)reqChannelDetail:(GotyeChannelInfo *)info;

/**
 *  退出登录
 *
 */
- (void)exit;

/**
 *  请求加入语音频道
 *
 *  @param channelInfo  加入频道的频道信息
 */
- (void)joinChannel:(GotyeChannelInfo *)channelInfo;

/**
 *  请求退出当前所在语音频道
 *
 */
- (void)exitChannel;

/**
 *  提出某用户
 *
 *  @param userID 被提出用户的ID
 */
- (void)kickMember:(NSString *)userID;

/**
 *  请求开始说话
 *
 */
- (void)startTalking;

/**
 *  请求结束说话
 *
 */
- (void)stopTalking;

/**
 *  获取当前已发送的语音流量。在调用startTalking时开始统计(计数清零)，调用stopTalking时结束统计。
 *
 *  @return 已发送的语音流量，单位byte
 */
- (NSUInteger)getCurrentVoiceTrafficSend;

/**
 *  使自己处于静音禁言状态
 *
 */
- (void)mute;

/**
 *  恢复接收语音和说话状态
 *
 */
- (void)restore;

/**
 *  请求禁言指定用户
 *
 *  @param userId  指定禁言用户id
 */
- (void)silence: (NSString*)userId;

/**
 *  请求恢复指定用户
 *
 *  @param userId  恢复指定用户id
 */
- (void)unsilence: (NSString*)userId;

/**
 *  请求提升指定用户为管理员
 *
 *  @param userId  指定提升管理员的用户id
 */
- (void)elevate:(NSString*)userId;

/**
 *  请求将指定用户降为普通成员
 *
 *  @param userId  指定降为普通成员的用户id
 */
- (void)demote:(NSString*)userId;

/**
 *  请求设置频道发言模式
 *
 *  @param TalkMode 频道发言模式枚举值
 */
- (void)setChannelTalkMode:(TalkMode)talkMode;

/**
 *  设置是否通过扬声器播放
 *
 *  @param useSpeaker YES使用扬声器，NO使用听筒。默认情况下使用扬声器
 */
- (void)setUseSpeaker:(BOOL)useSpeaker;

/**
 *  移除所有API回调
 *
 */
- (void)removeAllListeners;

/**
 *  注册API回调
 *
 *  @param listener 回调通知的对象(需要继承VoiChannelAPIDelegate)
 */
- (void)addListener:(id<VoiChannelAPIDelegate>)listener;

/**
 *  移除API回调
 *
 *  @param listener 回调通知的对象
 */
- (void)removeListener:(id<VoiChannelAPIDelegate>)listener;

@end
