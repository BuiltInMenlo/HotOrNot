//
//  HONSelfieCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSelfieCameraPreviewView.h"

@class HONSelfieCameraOverlayView;
@protocol HONSelfieCameraOverlayViewDelegate <NSObject>
- (void)cameraOverlayViewCameraBack:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewTakePhoto:(HONSelfieCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex;
@optional
- (void)cameraOverlayViewChangeFlash:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONSelfieCameraOverlayView *)cameraOverlayView;
@end

@interface HONSelfieCameraOverlayView : UIView
- (id)initWithFrame:(CGRect)frame;
- (void)introWithTutorial:(BOOL)isTutorial;
- (void)submitStep:(HONSelfieCameraPreviewView *)previewView;
@property(nonatomic, assign) id <HONSelfieCameraOverlayViewDelegate> delegate;
@end