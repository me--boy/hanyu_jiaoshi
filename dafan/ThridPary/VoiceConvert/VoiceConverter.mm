//
//  VoiceConverter.m
//  Jeans
//
//  Created by Jeans Huang on 12-7-22.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "VoiceConverter.h"
#import "wav.h"
#import "interf_dec.h"
#import "dec_if.h"
#import "interf_enc.h"
#import "amrFileCodec.h"

@implementation VoiceConverter

+ (int) convertAMR:(NSString *)amrPath toWAV:(NSString *)wavPath{
    
    if (! DecodeAMRFileToWAVEFile([amrPath cStringUsingEncoding:NSASCIIStringEncoding], [wavPath cStringUsingEncoding:NSASCIIStringEncoding]))
        return 0;
    
    return 1;
}

+ (int) convertWAV:(NSString *)wavPath toAMR:(NSString *)amrPath{
    
    if (EncodeWAVEFileToAMRFile([wavPath cStringUsingEncoding:NSASCIIStringEncoding], [amrPath cStringUsingEncoding:NSASCIIStringEncoding], 1, 16))
        return 0;
    
    return 1;
}
    
    
@end
