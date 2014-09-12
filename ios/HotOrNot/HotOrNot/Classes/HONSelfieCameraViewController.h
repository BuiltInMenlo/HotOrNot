//
//  HONChallengeCameraViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 9/6/13 @ 12:01 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
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

@class HONSelfieCameraViewController;
@protocol HONSelfieCameraViewControllerDelegate <NSObject>
@optional
- (void)selfieCameraViewControllerDidDismissByInviteOverlay:(HONSelfieCameraViewController *)viewController;
- (void)selfieCameraViewController:(HONSelfieCameraViewController *)viewController didDismissByCanceling:(BOOL)isCanceled;
@end

@interface HONSelfieCameraViewController : HONViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initAsNewChallenge;
- (id)initWithClub:(HONUserClubVO *)clubVO;

@property (nonatomic, assign) id <HONSelfieCameraViewControllerDelegate> delegate;
@end
