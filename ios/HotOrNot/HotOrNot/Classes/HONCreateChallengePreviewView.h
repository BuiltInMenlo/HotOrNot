//
//  HONCreateChallengePreviewView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeCameraViewController.h"
#import "HONUserVO.h"

@class HONChallengeCameraViewController;

@protocol HONCreateChallengePreviewViewDelegate;
@interface HONCreateChallengePreviewView : UIView <UIActionSheetDelegate, UIAlertViewDelegate, UITextFieldDelegate>
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image asSubmittingType:(HONSelfieSubmitType)selfieSubmitType withSubject:(NSString *)subject withRecipients:(NSArray *)recipients;
- (void)uploadComplete;

@property (nonatomic, assign) id <HONCreateChallengePreviewViewDelegate> delegate;
@end

@protocol HONCreateChallengePreviewViewDelegate <NSObject>
- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView;
- (void)previewView:(HONCreateChallengePreviewView *)previewView changeSubject:(NSString *)subject;
- (void)previewViewClose:(HONCreateChallengePreviewView *)previewView;
- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView;
@end
