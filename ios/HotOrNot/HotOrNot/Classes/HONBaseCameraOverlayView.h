//
//  HONBaseCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.17.13 @ 18:23 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol HONCameraOverlayViewDelegate;
@interface HONBaseCameraOverlayView : UIView

@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *changeCameraButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *submitButton;

@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> delegate;
@end

@protocol HONCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONBaseCameraOverlayView *)previewView;
- (void)cameraOverlayViewCloseCamera:(HONBaseCameraOverlayView *)previewView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONBaseCameraOverlayView *)previewView;
- (void)cameraOverlayViewChangeCamera:(HONBaseCameraOverlayView *)previewView;
- (void)cameraOverlayViewShowCameraRoll:(HONBaseCameraOverlayView *)previewView;
@end
