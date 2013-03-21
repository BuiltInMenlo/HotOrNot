//
//  HONRegisterCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.03.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONRegisterCameraOverlayViewDelegate;
@interface HONRegisterCameraOverlayView : UIView
@property(nonatomic, assign) id <HONRegisterCameraOverlayViewDelegate> delegate;
@property (nonatomic, strong) NSString *username;

- (void)showPreviewNormal:(UIImage *)image;
- (void)showPreviewFlipped:(UIImage *)image;
- (void)hidePreview;
@end

@protocol HONRegisterCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONRegisterCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCancelCamera:(HONRegisterCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSubmitWithUsername:(HONRegisterCameraOverlayView *)cameraOverlayView username:(NSString *)username;
@optional
- (void)cameraOverlayViewChangeFlash:(HONRegisterCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONRegisterCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONRegisterCameraOverlayView *)cameraOverlayView;
@end
