//
//  DFIncomingItem.h
//  dafan
//
//  Created by iMac on 14-8-18.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DFIncomingItem : NSObject

@property(nonatomic, strong) NSString* dateText;
@property(nonatomic, strong) NSAttributedString* tuitionText;
@property(nonatomic, strong) NSString* markText;

+ (id) testIncomingItem;

@end
