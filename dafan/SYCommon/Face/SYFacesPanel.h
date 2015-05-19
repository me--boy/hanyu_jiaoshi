//
//  MYFacesPanel.h
//  MY
//
//  Created by 胡少华 on 14-4-11.
//  表情按钮点击后的展示的表情视图

#import <UIKit/UIKit.h>


@class SYFacesPanel;
@protocol SYFacesPanelDelegate <NSObject>

- (void) face:(NSInteger)faceID clickedAtFacePanel:(SYFacesPanel *)facePanel;

- (void) delButtonClickedAtFacePanel:(SYFacesPanel *)panel;

@end

@interface SYFacesPanel : UIView

@property(nonatomic, weak) id<SYFacesPanelDelegate> delegate;

@end
