//
//  HONVerifyOverlayView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/16/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

@protocol HONVerifyOverlayViewDelegate;
@interface HONVerifyOverlayView : UIView
- (id)initWithChallenge:(HONChallengeVO *)vo;

@property (nonatomic, assign) id <HONVerifyOverlayViewDelegate> delegate;
@end

@protocol HONVerifyOverlayViewDelegate
- (void)verifyOverlayView:(HONVerifyOverlayView *)cameraOverlayView approve:(BOOL)isApproved forChallenge:(HONChallengeVO *)challengeVO;
- (void)verifyOverlayViewClose:(HONVerifyOverlayView *)verifyOverlayView;
@end


