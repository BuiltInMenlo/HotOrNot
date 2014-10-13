//
//  HONCreateChallengePreviewView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <StoreKit/StoreKit.h>

#import "HONStoreProductVO.h"
#import "HONUserVO.h"

@class HONSelfieCameraPreviewView;
@protocol HONSelfieCameraPreviewViewDelegate <NSObject>
- (void)cameraPreviewViewShowCamera:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewCancel:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewShowInviteContacts:(HONSelfieCameraPreviewView *)previewView;
- (void)cameraPreviewViewSubmit:(HONSelfieCameraPreviewView *)previewView withSubjects:(NSArray *)subjects;
@optional
- (void)cameraPreviewViewShowStore:(HONSelfieCameraPreviewView *)previewView;
@end

@interface HONSelfieCameraPreviewView : UIView <SKProductsRequestDelegate>
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image;
- (void)updateProcessedImage:(UIImage *)image;
- (NSArray *)getSubjectNames;
- (void)enableSubmitButton;

@property (nonatomic, assign) id <HONSelfieCameraPreviewViewDelegate> delegate;
@end
