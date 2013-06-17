//
//  HONCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HONImagePickerViewController.h"

@protocol HONCameraOverlayViewDelegate;
@interface HONCameraOverlayView : UIView
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username;
- (void)updateChallengers:(NSArray *)challengers;

@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> delegate;
@end


@protocol HONCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewAddChallengers:(HONCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView;
@end
