//
//  DFCommonImages.m
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "DFCommonImages.h"

@implementation DFCommonImages

+ (UIImage *) defaultAvatarImage
{
    return [UIImage imageNamed:@"avatar_default.png"];
}

+ (UIImage *) imageForGender:(SYGenderType)gender
{
    return [UIImage imageNamed:(gender == SYGenderTypeFemale ? @"user_female.png" : @"user_male.png")];
}

@end
