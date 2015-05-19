//
//  RegisterViewController.h
//  MY
//
//  Created by 胡少华 on 14-3-24.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SYBaseContentViewController.h"

typedef NS_ENUM(NSInteger, PasswordSetType)
{
    PasswordSetTypeFind,
    PasswordSetTypeReset
};

//仅用于找回密码，修改密码

@interface DFPasswordViewController : SYBaseContentViewController

@property(nonatomic) PasswordSetType passwordSetType;

@end
