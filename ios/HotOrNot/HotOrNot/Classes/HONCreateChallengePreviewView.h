//
//  HONCreateChallengePreviewView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HONCreateChallengePreviewViewDelegate;
@interface HONCreateChallengePreviewView : UIView
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withMirroredImage:(UIImage *)image;
- (void)uploadComplete;
- (void)setUsernames:(NSArray *)usernameList;
- (void)showKeyboard;

@property (nonatomic) int isPrivate;
@property(nonatomic, assign) id <HONCreateChallengePreviewViewDelegate> delegate;
@end

@protocol HONCreateChallengePreviewViewDelegate
- (void)previewViewAddChallengers:(HONCreateChallengePreviewView *)previewView;
- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView;
- (void)previewView:(HONCreateChallengePreviewView *)cameraOverlayView challengeIsPublic:(BOOL)isPublic;
- (void)previewView:(HONCreateChallengePreviewView *)previewView changeSubject:(NSString *)subject;
- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView;
@end