//
//  HONChallengeCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

typedef enum {
	HONSelfieSubmitTypeCreate	= 0,	/** Creates a new challenge */
	HONSelfieSubmitTypeReply			/** Joins an in-progress challenge */
} HONSelfieSubmitType;


@interface HONChallengeCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initAsNewChallenge;
- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO;
@end
