//
//  MYPhotoPicker.m
//  MY
//
//  Created by iMac on 14-8-5.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "SYPhotoPicker.h"
#import "DFAppDelegate.h"
#import "UIImage+SYExtension.h"

@interface SYPhotoPicker () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic) CGSize captureSize;
@property(nonatomic, weak) UINavigationController* navigationController;

@end

@implementation SYPhotoPicker

+ (SYPhotoPicker *) photoPickerInNavigationViewController:(UINavigationController *)navigationController
{
    SYPhotoPicker* picker = [[SYPhotoPicker alloc] init];
    picker.navigationController = navigationController;
    
    UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"请选择照片来源" delegate:picker cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
    [as showInView:navigationController.view];
    
    return picker;
}

+ (SYPhotoPicker *) photoPickerInNavigationViewController:(UINavigationController *)navigationController captureSize:(CGSize)captureSize
{
    SYPhotoPicker* picker = [[SYPhotoPicker alloc] init];
    picker.captureSize = captureSize;
    picker.navigationController = navigationController;
    
    UIActionSheet * as = [[UIActionSheet alloc] initWithTitle:@"请选择照片来源" delegate:picker cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"拍照",@"从相册选取", nil];
    [as showInView:navigationController.view];
    
    return picker;
}

- (void) actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < 2 && buttonIndex >= 0)
    {
        UIImagePickerController * imagepicker=[[UIImagePickerController alloc] init];
        imagepicker.delegate = self;
        imagepicker.allowsEditing=YES;
        if (buttonIndex == 0) {
            [imagepicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            imagepicker.mediaTypes =[NSArray arrayWithObject:(NSString*)kUTTypeImage];
            if (self.captureSize.width > 0 && self.captureSize.height > 0)
            {
                CGRect overlayFrame = imagepicker.cameraOverlayView.frame;
                overlayFrame.size = self.captureSize;
                imagepicker.cameraOverlayView.frame = overlayFrame;
                
            }
        }
        else if(buttonIndex == 1){
            [imagepicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            imagepicker.mediaTypes =[NSArray arrayWithObject:(NSString*)kUTTypeImage];
        }
        [self.navigationController presentViewController:imagepicker animated:YES completion:^{}];
    }
    else
    {
        [self.delegate photoPickerCancelled:self];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:^{}];
    [self.delegate photoPickerCancelled:self];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    UIImage *newImage = nil;
    if (self.captureSize.width > 0 && self.captureSize.height > 0)
    {
        newImage = [image scaleToSize:self.captureSize];
    }
    else
    {
        newImage = [image scaleToSize:CGSizeMake(600, 600)];
    }
    
    [picker dismissModalViewControllerAnimated:YES];
    
    if ([self.delegate respondsToSelector:@selector(photoPicker:pickImage:imageData:)])
    {
        CGFloat compression = 0.8f;
        CGFloat maxCompression = 0.1f;
        int maxFileSize = 250*1024;
        NSData *imageData = UIImagePNGRepresentation(newImage);
        while ([imageData length] > maxFileSize && compression > maxCompression)
        {
            compression -= 0.1;
            imageData = UIImagePNGRepresentation(newImage);
        }
        [self.delegate photoPicker:self pickImage:newImage imageData:imageData];
    }
    else
    {
        [self.delegate photoPicker:self pickImage:newImage];
    }
    
	
}

@end
