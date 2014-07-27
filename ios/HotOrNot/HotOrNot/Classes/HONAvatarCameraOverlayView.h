//
//  HONAvatarCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.19.13 @ 09:23 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@class HONAvatarCameraOverlayView;
@protocol HONAvatarCameraOverlayDelegate <NSObject>
- (void)cameraOverlayViewTakePicture:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewRetake:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSubmit:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONAvatarCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONAvatarCameraOverlayView *)previewView;
- (void)cameraOverlayViewChangeCamera:(HONAvatarCameraOverlayView *)previewView;
- (void)cameraOverlayViewShowCameraRoll:(HONAvatarCameraOverlayView *)previewView;
@end

@interface HONAvatarCameraOverlayView : UIView <UIAlertViewDelegate>
- (void)addPreview:(UIImage *)image;
- (void)addPreviewAsFlipped:(UIImage *)image;
- (void)removePreview;
- (void)uploadComplete;
- (void)animateAccept;
- (void)resetControls;

@property (nonatomic, assign) id <HONAvatarCameraOverlayDelegate> delegate;
@end
