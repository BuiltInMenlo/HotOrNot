//
//  HONImagePickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"

const CGFloat kFocusInterval;

typedef enum {
	HONChallengeSubmitTypeMatch			= 14,	/** Pairs w/ existing or creates new */
	HONChallengeSubmitTypeJoin			= 69	/** Joins an in-progress challenge */
} HONChallengeSubmitType;

@interface HONImagePickerViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIAlertViewDelegate>
- (id)initWithJoinChallenge:(HONChallengeVO *)vo;
@end
