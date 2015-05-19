//
//  GotyeChannelnfo.h
//  VoiChannelAPI
//
//  Created by ouyang on 14/12/12.
//
//

#import <Foundation/Foundation.h>

/**
 *  频道信息
 */
@interface GotyeChannelInfo : NSObject
/**
 *  进入频道所需的字符串
 */
@property(copy, nonatomic) NSString *token;
/**
 *  频道名字
 */
@property(copy, nonatomic) NSString *name;
/**
 *  频道密码
 */
@property(copy, nonatomic) NSString *password;


- (id)initWithToken:(NSString *)token password:(NSString *)password;

@end