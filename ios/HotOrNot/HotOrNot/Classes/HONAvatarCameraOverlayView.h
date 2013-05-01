//
//  HONAvatarCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 04.30.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONAvatarCameraOverlayViewDelegate;
@interface HONAvatarCameraOverlayView : UIView
- (void)showPreviewNormal:(UIImage *)image;
- (void)showPreviewFlipped:(UIImage *)image;
- (void)hidePreview;

@property(nonatomic, assign) id <HONAvatarCameraOverlayViewDelegate> delegate;
@end

@protocol HONAvatarCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCancelCamera:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSubmit:(HONAvatarCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONAvatarCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONAvatarCameraOverlayView *)cameraOverlayView;
@end