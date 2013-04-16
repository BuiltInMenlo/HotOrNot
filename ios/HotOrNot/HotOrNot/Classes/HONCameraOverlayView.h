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

- (void)hidePreview;
- (void)showPreviewImage:(UIImage *)image withUsername:(NSString *)username;
- (void)showPreviewImageFlipped:(UIImage *)image withUsername:(NSString *)username;

@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> delegate;
@property (nonatomic, weak) NSString *subjectName;

@end

@protocol HONCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSubmitChallenge:(HONCameraOverlayView *)cameraOverlayView username:(NSString *)username;
- (void)cameraOverlayViewChangeSubject:(HONCameraOverlayView *)cameraOverlayView subject:(NSString *)subjectName;
- (void)cameraOverlayViewPickFBFriends:(HONCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView;
@end
