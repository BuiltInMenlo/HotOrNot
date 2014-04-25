//
//  HONCreateChallengePreviewView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeCameraViewController.h"
#import "HONUserVO.h"

@class HONCreateChallengePreviewView;
@protocol HONCreateChallengePreviewViewDelegate <NSObject>
- (void)previewViewBackToCamera:(HONCreateChallengePreviewView *)previewView;
- (void)previewViewClose:(HONCreateChallengePreviewView *)previewView;
- (void)previewViewSubmit:(HONCreateChallengePreviewView *)previewView withSubject:(NSString *)subject;
@end

@interface HONCreateChallengePreviewView : UIView <UIAlertViewDelegate>
- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image asSubmittingType:(HONCameraSubmitType)selfieSubmitType withSubject:(NSString *)subject withRecipients:(NSArray *)recipients;
- (void)uploadComplete;

@property (nonatomic, assign) id <HONCreateChallengePreviewViewDelegate> delegate;
@end
