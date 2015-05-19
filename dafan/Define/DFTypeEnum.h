//
//  DFTypeEnum.h
//  dafan
//
//  Created by iMac on 14-8-25.
//  Copyright (c) 2014年 com. All rights reserved.
//

#ifndef dafan_DFTypeEnum_h
#define dafan_DFTypeEnum_h

typedef NS_ENUM(NSInteger, DFChatsUserStyle)
{
    DFChatsUserStyleClassroomTeacher,
    DFChatsUserStyleClassroomStudent,
    DFChatsUserStyleClassroomVisitor,
    DFChatsUserStyleRoomAdministrator,
    DFChatsUserStyleRoomVisitor,
    DFChatsUserStyleCount
};

typedef NS_ENUM(NSInteger, DFChatsPlace)
{
    DFChatsPlaceClassroom,
    DFChatsPlaceChatroom
};

typedef NS_ENUM(NSInteger, DFClassroomStatus) {
    DFClassroomStatusReady = 2,
    DFClassroomStatusDoing = 1,
    DFClassroomStatusDone = 0,
};

#endif
