//
//  DFCommonImages.h
//  dafan
//
//  Created by iMac on 14-8-15.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SYEnum.h"

@interface DFCommonImages : NSObject

+ (UIImage *) defaultAvatarImage;

+ (UIImage *) imageForGender:(SYGenderType)gender;

@end
