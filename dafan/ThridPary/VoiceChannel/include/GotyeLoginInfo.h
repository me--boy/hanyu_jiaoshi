//
//  GotyeLoginInfo.h
//  VoiChannelAPI
//
//  Created by ouyang on 14/12/12.
//
//

#import <Foundation/Foundation.h>

/**
 *  登录信息
 */
@interface GotyeLoginInfo : NSObject
/**
 *  用户ID (唯一)
 */
@property(copy, nonatomic) NSString *userId;
/**
 *  用户昵称
 */
@property(copy, nonatomic) NSString *nickname;
/**
 *  用户密码
 */
@property(copy, nonatomic) NSString *password;

/**
 *  初始化登录信息
 *
 *  @param userid    用户唯一id
 *  @param password  用户密码。无需密码传nil。
 *  @param name      用户昵称
 *
 *  @return        实例化对象
 */
- (id)initWithUserId:(NSString*)userid password:(NSString *)password nickname:(NSString*)name;

@end
