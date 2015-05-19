//
//  DeviceInfo.h
//  TTPod
//
//  Created by hushaohua on 13-9-5.
//
//

#import <Foundation/Foundation.h>


@interface SYDeviceDescription : NSObject

@property(nonatomic, readonly) NSInteger mainSystemVersion;
@property(nonatomic, readonly) BOOL isLongScreen;
@property(nonatomic, readonly) BOOL isRetainScreen;
@property(nonatomic, readonly) NSString *UUID;
@property(nonatomic, readonly) BOOL isPad;
@property(nonatomic, readonly) NSString* vendorID;

//- (BOOL) isLowerThaniOS7;

+ (SYDeviceDescription *) sharedDeviceDescription;

@end
