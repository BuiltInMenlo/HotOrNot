//
//  HONChallengeCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONMessageVO.h"

typedef enum {
	HONSelfieSubmitTypeCreateChallenge = 0,
	HONSelfieSubmitTypeReplyChallenge,
	HONSelfieSubmitTypeCreateMessage,
	HONSelfieSubmitTypeReplyMessage
} HONSelfieSubmitType;


@interface HONChallengeCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initAsNewChallenge;
- (id)initAsJoinChallenge:(HONChallengeVO *)challengeVO;
- (id)initAsNewMessageWithRecipients:(NSString *)recipients;
- (id)initAsMessageReply:(HONMessageVO *)messageVO;
@end
