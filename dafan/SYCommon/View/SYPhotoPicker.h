//
//  MYPhotoPicker.h
//  MY
//
//  Created by iMac on 14-8-5.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SYPhotoPicker;
@protocol SYPhtoPickerDelegate <NSObject>

- (void) photoPickerCancelled:(SYPhotoPicker *)picker;
- (void) photoPicker:(SYPhotoPicker *)picker pickImage:(UIImage *)image;
@optional
- (void) photoPicker:(SYPhotoPicker *)picker pickImage:(UIImage *)image imageData:(NSData *)data;

@end

@interface SYPhotoPicker : NSObject

@property(nonatomic, weak) id<SYPhtoPickerDelegate> delegate;

+ (SYPhotoPicker *) photoPickerInNavigationViewController:(UINavigationController *)navigationController;

+ (SYPhotoPicker *) photoPickerInNavigationViewController:(UINavigationController *)navigationController captureSize:(CGSize)captureSize;

@end
