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
- (void)showPreview:(UIImage *)image;
- (void)showPreviewFlipped:(UIImage *)image;
- (void)artistName:(NSString *)artist songName:(NSString *)songName artworkURL:(NSString *)artwork storeURL:(NSString *)itunesURL;
- (void)endBuffering;

@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> delegate;
@property (nonatomic, weak) NSString *subjectName;

@end

@protocol HONCameraOverlayViewDelegate
- (void)cameraOverlayViewTakePicture:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewCloseCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewClosePreview:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSubmitChallenge:(HONCameraOverlayView *)cameraOverlayView username:(NSString *)username comments:(NSString *)comments;
- (void)cameraOverlayViewRandomSubject:(HONCameraOverlayView *)cameraOverlayView subject:(NSString *)subjectName;
@optional
- (void)cameraOverlayViewChangeFlash:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewPreviewBack:(HONCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewPlayTrack:(HONCameraOverlayView *)cameraOverlayView audioURL:(NSString *)url;
@end
