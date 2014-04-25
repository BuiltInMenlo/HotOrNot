//
//  HONCameraSubmitViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 07:11 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONProtoChallengeVO.h"

typedef enum {
	HONCSelfieSubmitTypeCreateChallenge = 0,
	HONSelfieSubmitTypeReplyChallenge,
	
	HONSelfieSubmitTypeCreateClub,
	HONSelfieSubmitTypeReplyClub,
	
	HONSelfieSubmitTypeCreateMessage,
	HONSelfieSubmitTypeReplyMessage
} HONSelfieSubmitType;


@interface HONCameraSubmitViewController : UIViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
- (id)initWithChallenge:(HONChallengeVO *)challengeVO;
- (id)initWithProtoChallenge:(HONProtoChallengeVO *)protoChallengeVO;
@end
