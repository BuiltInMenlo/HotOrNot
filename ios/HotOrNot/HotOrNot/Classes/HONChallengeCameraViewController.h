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
	HONVolleySubmitTypeCreate	= 0,	/** Creates a new challenge */
	HONVolleySubmitTypeJoin				/** Joins an in-progress challenge */
} HONVolleySubmitType;


@interface HONChallengeCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
- (id)initAsNewChallenge;
- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO;
@end
