//
//  HONCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONImagePickerViewController.h"
#import "HONCreateChallengePreviewView.h"

@protocol HONSnapCameraOverlayViewDelegate;
@interface HONSnapCameraOverlayView : UIView
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username;
- (void)intro;
- (void)toggleInfoOverlay:(BOOL)isIntro;
- (void)updateChallengers:(NSArray *)challengers asJoining:(BOOL)isJoining;
- (void)takePhoto;
- (void)addPreview:(UIImage *)image;
- (void)addMirroredPreview:(UIImage *)image;
- (void)removePreview;
- (void)updateClock:(int)tick;
- (void)submitStep:(HONCreateChallengePreviewView *)previewView;
@property(nonatomic, assign) id <HONSnapCameraOverlayViewDelegate> delegate;
@end


@protocol HONSnapCameraOverlayViewDelegate
- (void)cameraOverlayViewCameraBack:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONSnapCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONSnapCameraOverlayView *)cameraOverlayView;
@end
