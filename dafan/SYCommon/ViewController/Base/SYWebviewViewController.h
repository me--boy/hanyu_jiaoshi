//
//  SYWebviewViewController.h
//  dafan
//
//  Created by 胡少华 on 14/10/23.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import "SYBaseContentViewController.h"

@interface SYWebviewViewController : SYBaseContentViewController

- (id) initWithUrl:(NSString *)url;

@property(nonatomic, strong) NSString* webTitle;

@end
