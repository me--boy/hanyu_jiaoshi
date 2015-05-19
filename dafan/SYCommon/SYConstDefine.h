//
//  SYConstDefine.h
//  SYBase
//
//  Created by iMac on 14-8-11.
//  Copyright (c) 2014年 com. All rights reserved.
//

#ifndef SYBase_SYConstDefine_h
#define SYBase_SYConstDefine_h




//macro

#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
} \

//color
#define RGBCOLOR(a, b, c) (([UIColor colorWithRed:((CGFloat)a)/255 green:((CGFloat)b)/255 blue:((CGFloat)c)/255 alpha:1]))
#define ALPHARGBCOLOR(a, b, c, d) (([UIColor colorWithRed:((CGFloat)a)/255 green:((CGFloat)b)/255 blue:((CGFloat)c)/255 alpha:d]))



#define kPageTitleColor [UIColor blackColor]

#endif
