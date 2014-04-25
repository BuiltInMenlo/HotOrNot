//
//  HONChallengeCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONChallengeVO.h"
#import "HONUserClubVO.h"
#import "HONMessageVO.h"

typedef enum {
	HONCameraSubmitTypeCreateChallenge = 0,
	HONCameraSubmitTypeReplyChallenge,
	
	HONCameraSubmitTypeCreateClub,
	HONCameraSubmitTypeReplyClub,
	
	HONCameraSubmitTypeCreateMessage,
	HONCameraSubmitTypeReplyMessage
} HONCameraSubmitType;


@interface HONChallengeCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initAsNewChallenge;
- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO;
- (id)initAsNewMessageWithRecipients:(NSArray *)recipients;
- (id)initAsMessageReply:(HONMessageVO *)messageVO withRecipients:(NSArray *)recipients;
@end
