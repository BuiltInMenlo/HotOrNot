//
//  HONCreateChallengePreviewView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserVO.h"

@class HONSelfieCameraPreviewView;
@protocol HONSelfieCameraPreviewViewDelegate <NSObject>
- (void)cameraPreviewView:(HONSelfieCameraPreviewView *)previewView showCameraFromLargeButton:(BOOL)isLarge;
- (void)cameraPreviewViewCancel:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewShowInviteContacts:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewSubmit:(HONSelfieCameraPreviewView *)previewView withSubjects:(NSArray *)subjects;
@end

@interface HONSelfieCameraPreviewView : UIView
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image;
- (void)updateProcessedImage:(UIImage *)image;
- (void)uploadComplete;

@property (nonatomic, assign) id <HONSelfieCameraPreviewViewDelegate> delegate;
@end
