//
//  HONCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONCreateChallengePreviewView.h"

@protocol HONSnapCameraOverlayViewDelegate;
@interface HONSnapCameraOverlayView : UIView
- (id)initWithFrame:(CGRect)frame;
- (void)introWithTutorial:(BOOL)isTutorial;
- (void)submitStep:(HONCreateChallengePreviewView *)previewView;
@property(nonatomic, assign) id <HONSnapCameraOverlayViewDelegate> delegate;
@end


@protocol HONSnapCameraOverlayViewDelegate <NSObject>
- (void)cameraOverlayViewCameraBack:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewTakePhoto:(HONSnapCameraOverlayView *)cameraOverlayView withTintIndex:(int)tintIndex;
@optional
- (void)cameraOverlayViewChangeFlash:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONSnapCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONSnapCameraOverlayView *)cameraOverlayView;
@end
