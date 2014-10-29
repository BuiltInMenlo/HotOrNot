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
#import "HONContactUserVO.h"
#import "HONTrivialUserVO.h"

typedef NS_ENUM(NSInteger, HONSelfieSubmitType) {
	HONSelfieSubmitTypeCreate = 0,
	HONSelfieSubmitTypeReply,
	HONSelfieSubmitTypeSearchUser
};

@class HONSelfieCameraViewController;
@protocol HONSelfieCameraViewControllerDelegate <NSObject>
@optional
- (void)selfieCameraViewControllerDidDismissByInviteOverlay:(HONSelfieCameraViewController *)viewController;
- (void)selfieCameraViewController:(HONSelfieCameraViewController *)viewController didDismissByCanceling:(BOOL)isCanceled;
@end

@interface HONSelfieCameraViewController : HONViewController <UIActionSheetDelegate, UIGestureRecognizerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
- (id)initAsNewStatusUpdate;
- (id)initWithUser:(HONTrivialUserVO *)trivialUserVO;
- (id)initWithContact:(HONContactUserVO *)contactUserVO;
- (id)initWithClub:(HONUserClubVO *)clubVO;

@property (nonatomic, assign) id <HONSelfieCameraViewControllerDelegate> delegate;
@end
