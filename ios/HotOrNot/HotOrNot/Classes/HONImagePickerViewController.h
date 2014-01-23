//
//  HONImagePickerViewController.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONMessageVO.h"

@interface HONImagePickerViewController : UIViewController
- (id)initAsNewChallenge;
- (id)initWithJoinChallenge:(HONChallengeVO *)vo;
- (id)initAsMessageToRecipients:(NSArray *)recipients;
- (id)initAsMessageReply:(HONMessageVO *)messageVO;
@end
