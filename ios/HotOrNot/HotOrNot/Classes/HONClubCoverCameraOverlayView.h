//
//  HONClubCoverCameraOverlayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 03/31/2014 @ 20:52 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@class HONClubCoverCameraOverlayView;
@protocol HONClubCoverCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONClubCoverCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex;
- (void)cameraOverlayViewRetake:(HONClubCoverCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSubmit:(HONClubCoverCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONClubCoverCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONClubCoverCameraOverlayView *)previewView;
- (void)cameraOverlayViewChangeCamera:(HONClubCoverCameraOverlayView *)previewView;
- (void)cameraOverlayViewShowCameraRoll:(HONClubCoverCameraOverlayView *)previewView;
@end

@interface HONClubCoverCameraOverlayView : UIView <UIAlertViewDelegate>
- (void)addPreview:(UIImage *)image;
- (void)addPreviewAsFlipped:(UIImage *)image;
- (void)removePreview;
- (void)uploadComplete;
- (void)animateAccept;
- (void)resetControls;

@property (nonatomic, assign) id <HONClubCoverCameraOverlayViewDelegate> delegate;
@end
