//
//  NSString+HTMLCoreText.h
//  dafan
//
//  Created by iMac on 14-8-21.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HTMLCoreText)

- (NSString *) replaceFacesWithHtmlFormat;

- (NSString *) replaceUserIdNicknameJsonWithHrefAtDoubleAt;

@end
