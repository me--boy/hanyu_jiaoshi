//
//  DeviceInfo.m
//  TTPod
//
//  Created by hushaohua on 13-9-5.
//
//

#import "SYDeviceDescription.h"
#include <sys/param.h>
#include <sys/mount.h>

@interface SYDeviceDescription()
@property(nonatomic, assign) NSInteger mainSystemVersion;
@property(nonatomic, assign) BOOL isLongScreen;
@property(nonatomic, assign) BOOL isRetainScreen;
@property(nonatomic, strong) NSString *UUID;
@property(nonatomic, strong) NSString* vendorID;

@end

static SYDeviceDescription* sSharedDeviceDescription = nil;

@implementation SYDeviceDescription

+ (SYDeviceDescription *) sharedDeviceDescription
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedDeviceDescription = [[SYDeviceDescription alloc] init];
    });
    return sSharedDeviceDescription;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

+ (id) allocWithZone:(NSZone *)zone
{
//    return [[self class] sharedDeviceDescription];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sSharedDeviceDescription = [super allocWithZone:zone];
    });
    return sSharedDeviceDescription;
}

#pragma mark - system version

- (id) init
{
    self = [super init];
    if (self)
    {
        [self initMainSystemVersion];
        [self initIsLongScreen];
        [self initRetainScreen];
        [self initUUID];
        [self initIsPad];
        [self initVerndor];
    }
    return self;
}

- (void) initRetainScreen
{
   self.isRetainScreen = ([UIScreen instancesRespondToSelector:@selector(scale)] ? (2 == [[UIScreen mainScreen] scale]) : NO);
}

- (void) initMainSystemVersion
{
    NSString* versionDescription = [[UIDevice currentDevice] systemVersion];
    NSRange range = [versionDescription rangeOfString:@"."];
    
    self.mainSystemVersion = [[versionDescription substringToIndex:range.location] integerValue];
}

- (void) initIsLongScreen
{
    if ([UIScreen instancesRespondToSelector:@selector(currentMode)])
    {
//        self.isLongScreen = CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size);
        self.isLongScreen = [[UIScreen mainScreen] currentMode].size.height > 1000;
    }
}

- (void) initIsPad
{
    _isPad = ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad);
}

- (void) initUUID
{
    
}

- (void) initVerndor
{
    self.vendorID = [[UIDevice currentDevice].identifierForVendor UUIDString];
}

- (long long) freeDiskSpaceInBytes{
    struct statfs buf;
    long long freespace = -1;
    if(statfs("/var", &buf) >= 0){
        freespace = (long long)(buf.f_bsize * buf.f_bfree);
    }
    return freespace;
}

//- (BOOL) isLowerThaniOS7
//{
//    return self.mainSystemVersion < 7;
//}



@end
