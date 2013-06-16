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
- (void)showPreviewImage:(UIImage *)image asMirrored:(BOOL)isMirrored;
- (void)hidePreview;
- (void)enablePreview;

@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> delegate;
@end


@protocol HONCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView;
//- (void)cameraOverlayViewSubmitChallenge:(HONCameraOverlayView *)cameraOverlayView;
//- (void)cameraOverlayViewChangeSubject:(HONCameraOverlayView *)cameraOverlayView subject:(NSString *)subjectName;
@optional
- (void)cameraOverlayViewAddChallengers:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeFlash:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView;
//- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView;
@end
