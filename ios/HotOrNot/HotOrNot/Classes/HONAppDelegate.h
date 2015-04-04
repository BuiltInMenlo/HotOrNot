//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/
#define __DEV_BUILD__ 0
/** =+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+= **/
/** =+-+-+-+-+-+-+-+-+-+-+-+--+= **/

#define __FORCE_REGISTER__ 0
//]=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=[//
#define __FORCE_NEW_USER__ 0
#define __RESET_TOTALS__ 0

/** =+-+-+-+-+-+-+-+-+-+-+-+--+= **/
/** =+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+= **/
#define __APPSTORE_BUILD__ 1
/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/


typedef NS_ENUM(NSUInteger, HONTimelineScrollDirection) {
	HONTimelineScrollDirectionDown = 0,	/** Challenges using same hashtag */
	HONTimelineScrollDirectionUp,			/** Challenges of a single user */
};

typedef NS_ENUM(NSUInteger, HONPushType) {
	HONPushTypeShowChallengeDetails	= 1,			/** Brings up the challenge details modal **/
	HONPushTypeUserVerified,						/** Shows alert **/
	HONPushTypeShowUserProfile,						/** Brings up a user's profile **/
	HONPushTypeShowAddContacts,						/** Brings up the invite contacts modal **/
	HONPushTypeShowSettings,						/** Brings up the settings modal **/
	HONPushTypeShowChallengeDetailsIgnoringPushes	/** Brings up the challenge details modal, ignoring next pushes **/
};

typedef NS_ENUM(NSUInteger, HONAppDelegateAlertType) {
	HONAppDelegateAlertTypeExit = 0,
	HONAppDelegateAlertTypeVerifiedNotification,
	HONAppDelegateAlertTypeReviewApp,
	HONAppDelegateAlertTypeInviteFriends,		
	HONAppDelegateAlertTypeShare,
	HONAppDelegateAlertTypeRefreshTabs,
	HONAppDelegateAlertTypeRemoteNotification,
	HONAppDelegateAlertTypeJoinCLub,
	HONAppDelegateAlertTypeInviteContacts,
	HONAppDelegateAlertTypeCreateClub,
	HONAppDelegateAlertTypeEnterClub,
	HONAppDelegateAlertTypeAllowContactsAccess,
	HONAppDelegateAlertTypeCreateChat
};

typedef NS_OPTIONS(NSUInteger, HONAppDelegateBitTesting) {
	HONAppDelegateBitTesting0	= (0UL << 0),
	HONAppDelegateBitTesting1	= (1UL << 0),
	HONAppDelegateBitTesting2	= (1UL << 1),
	HONAppDelegateBitTesting3	= (1UL << 2),
	HONAppDelegateBitTesting4	= (1UL << 3)
};


// view heights
extern const CGFloat kNavHeaderHeight;
extern const CGFloat kSearchHeaderHeight;
extern const CGFloat kDetailsHeroImageHeight;

// animation params
extern const CGFloat kProfileTime;
extern const CGFloat kButtonSelectDelay;

@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>


+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController;
+ (UINavigationController *)rootNavController;
+ (UIViewController *)appNavController;

+ (NSString *)customerServiceURLForKey:(NSString *)key;

+ (BOOL)switchEnabledForKey:(NSString *)key;

void uncaughtExceptionHandler(NSException *exception);

@property (nonatomic, retain) UINavigationController *navController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) UIWindow *window;
@end


