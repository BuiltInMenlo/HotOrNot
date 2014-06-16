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

typedef NS_ENUM(NSInteger, HONSelfieSubmitType) {
	HONSelfieSubmitTypeCreateChallenge = 0,
	HONSelfieSubmitTypeReplyChallenge,
	
	HONSelfieSubmitTypeCreateClub,
	HONSelfieSubmitTypeReplyClub,
	
	HONSelfieSubmitTypeCreateMessage,
	HONSelfieSubmitTypeReplyMessage
};

@interface HONSelfieCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initWithClub:(HONUserClubVO *)clubVO;


- (id)initAsNewChallenge;
- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO;
- (id)initAsNewMessageWithRecipients:(NSArray *)recipients;
- (id)initAsMessageReply:(HONMessageVO *)messageVO withRecipients:(NSArray *)recipients;
@end
