//
//  HONCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONImagePickerViewController.h"

@protocol HONSnapCameraOverlayViewDelegate;
@interface HONSnapCameraOverlayView : UIView
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username;
- (void)updateChallengers:(NSArray *)challengers;
- (void)addPreview:(UIImage *)image;
- (void)addMirroredPreview:(UIImage *)image;
- (void)removePreview;
@property(nonatomic, assign) id <HONSnapCameraOverlayViewDelegate> delegate;
@end


@protocol HONSnapCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCameraBack:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewAddChallengers:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewMakeChallengeNonExpire:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayView:(HONSnapCameraOverlayView *)cameraOverlayView challengeIsPublic:(BOOL)isPublic;
- (void)cameraOverlayViewExpires10Minutes:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewExpires24Hours:(HONSnapCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONSnapCameraOverlayView *)cameraOverlayView;
@end
