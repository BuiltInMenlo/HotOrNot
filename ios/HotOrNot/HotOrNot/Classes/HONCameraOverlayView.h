//
//  HONCameraOverlayView.h
//  HotOrNot
//
//  Created by BIM  on 9/26/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@class HONCameraOverlayView;
@protocol HONCameraOverlayViewDelegate <NSObject>
- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewTakePhoto:(HONCameraOverlayView *)cameraOverlayView includeFilter:(BOOL)isFiltered;
@optional
- (void)cameraOverlayViewChangeFlash:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView;
@end

@interface HONCameraOverlayView : UIView
@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> delegate;
@end
