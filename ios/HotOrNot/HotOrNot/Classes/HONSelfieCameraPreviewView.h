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
- (void)cameraPreviewViewBackToCamera:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewClose:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewSubmit:(HONSelfieCameraPreviewView *)previewView withSubject:(NSString *)subject;
@end

@interface HONSelfieCameraPreviewView : UIView <UIAlertViewDelegate>
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image asSubmittingType:(HONSelfieCameraSubmitType)selfieSubmitType withSubject:(NSString *)subject withRecipients:(NSArray *)recipients;
- (void)uploadComplete;

@property (nonatomic, assign) id <HONSelfieCameraPreviewViewDelegate> delegate;
@end
