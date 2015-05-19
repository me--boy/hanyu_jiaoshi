//
//  NSString+SYFace.h
//  dafan
//
//  Created by iMac on 14-8-21.
//  Copyright (c) 2014年 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SYFace)

+ (NSString *)faceTextForID:(NSInteger)faceId;
- (NSString *) faceDescriptionSuffix;
- (NSString *) replaceFacesIDWithFaceDescriptions;

@end
