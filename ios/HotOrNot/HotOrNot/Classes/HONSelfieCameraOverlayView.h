//
//  HONSelfieCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSelfieCameraPreviewView.h"

//typedef NS_ENUM(NSInteger, HONCameraSubmitType) {
//	HONCameraSubmitTypeCreateChallenge = 0,
//	HONCameraSubmitTypeReplyChallenge,
//	
//	HONSelfieCameraSubmitTypeCreateClub,
//	HONSelfieCameraSubmitTypeReplyClub,
//	
//	HONSelfieCameraSubmitTypeCreateVerify,
//	HONSelfieCameraSubmitTypeReplyVerify,
//	
//	HONSelfieCameraSubmitTypeCreateShoutout,
//	HONSelfieCameraSubmitTypeReplyShoutout,
//	
//	HONSelfieCameraSubmitTypeCreateMessage,
//	HONSelfieCameraSubmitTypeReplyMessage
//};


@class HONSelfieCameraOverlayView;
@protocol HONSelfieCameraOverlayViewDelegate <NSObject>
- (void)cameraOverlayViewCloseCamera:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewSkipCamera:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewTakePhoto:(HONSelfieCameraOverlayView *)cameraOverlayView;
@optional
- (void)cameraOverlayViewChangeFlash:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewChangeCamera:(HONSelfieCameraOverlayView *)cameraOverlayView;
- (void)cameraOverlayViewShowCameraRoll:(HONSelfieCameraOverlayView *)cameraOverlayView;
@end

@interface HONSelfieCameraOverlayView : UIView
- (id)initWithFrame:(CGRect)frame;
- (void)submitStep:(HONSelfieCameraPreviewView *)previewView;
@property(nonatomic, assign) id <HONSelfieCameraOverlayViewDelegate> delegate;
@end
