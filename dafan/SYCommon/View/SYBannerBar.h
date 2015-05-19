//
//  MYBannerBar.h
//  MY
//
//  Created by iMac on 14-6-17.
//  Copyright (c) 2014年 halley. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  模型对象
 */
@interface SYBannerBarItem : NSObject <NSCoding>

@property(nonatomic) NSInteger type;

@property(nonatomic, strong) NSString* imageUrl;

@property(nonatomic) NSInteger optionalId;

@property(nonatomic, strong) NSString* title;

@property(nonatomic, strong) NSString* webViewUrl;

- (id) initWithDictionary:(NSDictionary *)dictionary;

@end

@interface SYBannerBarView : UICollectionReusableView

//@property(nonatomic, strong) UIScrollView* scrollView;

@property(nonatomic, strong) UIPageControl* pageControl;
/**
 *  存放图片的ImageView的数组
 */
@property(nonatomic, strong) NSMutableArray* pageImageViews;
/**
 *  设置处理的事件target对象
 */
@property(nonatomic, weak) id pageImageViewTarget;
/**
 *  点击图片的回调方法
 */
@property(nonatomic) SEL pageImageViewAction;
/**
 *  显示的图片数据源
 */
@property(nonatomic, strong) NSArray* loadingInfos; //dictionary{type, img}

//@property(nonatomic, readonly) UIImageView* pageIndicatorBackgroundImageView;

@end


@interface SYBannerBar : NSObject

@property(nonatomic, strong) SYBannerBarView* bannerView;

- (void) startBannerPlayTimer;
- (void) stopBannerPlayTimer;

@end
