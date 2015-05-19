//
//  DFTeacherAgreementViewController.h
//  dafan
//
//  Created by 胡少华 on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//  用户协议 试图控制器

#import "SYBaseContentViewController.h"

typedef NS_ENUM(NSInteger, DFAgreementStyle)
{
    DFAgreementStyleTeacher = 0,
    DFAgreementStyleChannel,
    DFAgreementStyleService,
    DFAgreementStyleGetNoCheckCode,
    DFAgreementStyleUser,
    DFAgreementStyleMyIncoming
};

@interface DFAgreementViewController : SYBaseContentViewController

@property(nonatomic) DFAgreementStyle agreementStyle;

@end
