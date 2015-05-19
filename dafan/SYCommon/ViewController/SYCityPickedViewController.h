//
//  MYCityPickedViewController.h
//  MY
//
//  Created by iMac on 14-7-15.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import "SYTableViewController.h"

typedef void(^CityPicked)(NSInteger provinceId, NSInteger cityId, NSString* cityName);

@interface SYCityPickedViewController : SYTableViewController

@property(nonatomic) NSInteger pickedProvinceId;
@property(nonatomic) NSInteger pickedCityId;

@property(nonatomic, copy) CityPicked citySelectedBlock;

@end
