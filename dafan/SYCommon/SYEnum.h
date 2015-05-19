//
//  SYEnum.h
//  dafan
//
//  Created by iMac on 14-8-14.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYEnum : NSObject

typedef NS_ENUM(NSInteger, SYFocusState)
{
    SYFocusStateUnfocused,
    SYFocusStateFocused,
    SYFocusStateMutalfcoused,
    SYFocusStateUnknown,  //need to reset
    SYFocusStateCount
};

typedef NS_ENUM(NSInteger, SYGenderType)
{
    SYGenderTypeFemale,
    SYGenderTypeMale,
    SYGenderTypeCount
};

typedef NS_ENUM(NSInteger, DFMessageStyle)
{
    DFMessageStyleContact,
    DFMessageStyleGroup
};

@end
