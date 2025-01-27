//
//  HONImagePickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"

@interface HONImagePickerViewController : UIViewController
- (id)initAsNewChallenge;
- (id)initAsNewChallengeForClub:(int)clubID;
- (id)initWithJoinChallenge:(HONChallengeVO *)vo;
@end
