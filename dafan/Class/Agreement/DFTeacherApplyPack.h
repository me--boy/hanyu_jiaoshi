//
//  DFTeacherApplyPack.h
//  dafan
//
//  Created by iMac on 14-9-9.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFTeacherApplyPack : NSObject

@property(nonatomic, strong) NSString* name;

//@property(nonatomic, strong) NSString* currentCity;
@property(nonatomic) NSInteger currentProvinceId;
@property(nonatomic) NSInteger currentCityId;

@property(nonatomic) NSInteger liveYears;

//@property(nonatomic, strong) NSString* birthCity;
@property(nonatomic) NSInteger birthProvinceId;
@property(nonatomic) NSInteger birthCityId;

@property (nonatomic, strong) NSString* carrier;

@property(nonatomic, strong) NSString* baseNote;

@property(nonatomic, strong) NSString* telNo;
@property(nonatomic, strong) NSString* teacherInfo;

@property(nonatomic, strong) NSString* idPhotoUrl;

//@property(nonatomic, strong) NSData* idCardPhotoData;
//@property(nonatomic, strong) UIImage* idCardPhotoImage;

@end
