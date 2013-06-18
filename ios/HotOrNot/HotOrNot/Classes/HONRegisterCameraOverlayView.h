//
//  HONRegisterCameraOverlayView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.03.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONBaseCameraOverlayView.h"

@protocol HONAvatarOverlayViewDelegate;
@interface HONRegisterCameraOverlayView : HONBaseCameraOverlayView
@property(nonatomic, assign) id <HONCameraOverlayViewDelegate> createCameraOverlayDelegate;
@property(nonatomic, assign) id <HONAvatarOverlayViewDelegate> avatarOverlayDelegate;
@property (nonatomic, strong) NSString *username;

- (void)showPreviewNormal:(UIImage *)image;
- (void)showPreviewFlipped:(UIImage *)image;
- (void)hidePreview;
@end

@protocol HONAvatarOverlayViewDelegate
- (void)avatarOverlayViewSubmitWithUsername:(HONRegisterCameraOverlayView *)avatarOverlayView username:(NSString *)username;
@optional
@end
