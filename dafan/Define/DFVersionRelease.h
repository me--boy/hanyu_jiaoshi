//
//  DFVersionRelease.h
//  dafan
//
//  Created by iMac on 14-8-12.
//  Copyright (c) 2014年 com. All rights reserved.
//

#ifndef dafan_DFVersionRelease_h
#define dafan_DFVersionRelease_h

//release

#define kAppstoreRateUrl  @"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=908638679"
#define kAppstoreRateUrl_iOS7  @"itms-apps://itunes.apple.com/app/id908638679"

//#define AlphaVersion

#define kAppVersion @"1.0"

#ifdef AlphaVersion

#define kSource @"shiyoo-test"
//#define TestWifi

#else

#define kSource @"appstore"

#endif

#endif
