//
//  GotyeTypeDefine.h
//  VoiChannelAPI
//
//  Created by ouyang on 14/12/12.
//
//

#ifndef VoiChannelAPI_GotyeTypeDefine_h
#define VoiChannelAPI_GotyeTypeDefine_h

/**
 *  发言模式枚举
 */
typedef enum
{
    /**
     *  自由发言模式
     */
    Freedom,
    /**
     *  管理员发言
     */
    AdministratorOnly
}TalkMode;

/**
 *  成员类型枚举
 */
typedef enum
{
    /**
     *  普通成员
     */
    Common,
    /**
     *  管理员
     */
    Administrator,
    /**
     *  会长
     */
    President
}MemberType;

/**
 *  错误类型枚举
 */
typedef enum
{
    /**
     * 网络断开
     */
    ErrorNetworkInvalid,      //网络断开
    
    /**
     * APP不存在
     */
    ErrorAppNotExsit,	//APP不存在
    
    /**
     * 用户不存在
     */
    ErrorUserNotExsit,			//用户不存在
    
    /**
     * 无效的用户ID
     */
    ErrorInvalidUserID,		//无效的用户ID
    
    /**
     * 用户ID已在用
     */
    ErrorUserIDInUse,		//用户ID已在用
    
    /**
     * 频道成员已满
     */
    ErrorChannelIsFull,		//频道成员已满
    
    /**
     * Server中用户数量已达上限
     */
    ErrorServerIsFull,			//Server中用户数量已达上限
    
    /**
     * 权限不够
     */
    ErrorPermissionDenial,		//权限不够
    
    /**
     * 频道不存在
     */
    ErrorChannelIsNotExist,
    
    /**
     * 用户密码错误
     */
    ErrorWrongPassword,
    
    /**
     * 未知的异常
     */
    ErrorUnknown				//未知的异常
}GotyeErrorType;

#endif
