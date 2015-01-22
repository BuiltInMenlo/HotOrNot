//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

#import "AFHTTPRequestOperation.h"

/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/
#define __DEV_BUILD__ 1
/** =+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+= **/
/** =+-+-+-+-+-+-+-+-+-+-+-+--+= **/

#define __FORCE_REGISTER__ 0
//]=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=[//
#define __FORCE_NEW_USER__ 0
#define __RESET_TOTALS__ 0

/** =+-+-+-+-+-+-+-+-+-+-+-+--+= **/
/** =+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+= **/
#define __APPSTORE_BUILD__ 0
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

// share sheet actions
typedef NS_ENUM(NSUInteger, HONShareSheetActionType) {
	HONShareSheetActionTypeInstagram = 0,
	HONShareSheetActionTypeTwitter,
	HONShareSheetActionTypeSMS,
	HONShareSheetActionTypeEmail,
	HONShareSheetActionTypeClipboard
};

typedef NS_ENUM(NSUInteger, HONShareMessageType) {
	HONShareMessageTypeClipboard = 0,
	HONShareMessageTypeInstagram,
	HONShareMessageTypeSMS,
	HONShareMessageTypeEmail,
	HONShareMessageTypeTwitter,
	HONShareMessageTypeFacebook
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
	HONAppDelegateAlertTypeAllowContactsAccess
};


typedef NS_ENUM(NSUInteger, HONAmazonS3BucketType) {
	HONAmazonS3BucketTypeAvatarsSource = 0,
	HONAmazonS3BucketTypeAvatarsCloudFront,
	
	HONAmazonS3BucketTypeBannersSource,
	HONAmazonS3BucketTypeBannersCloudFront,
	
	HONAmazonS3BucketTypeClubsSource,
	HONAmazonS3BucketTypeClubsCloudFront,
	
	HONAmazonS3BucketTypeEmotionsSource,
	HONAmazonS3BucketTypeEmoticonsCloudFront
};

typedef NS_ENUM(NSUInteger, HONInsetOverlayViewType) {
	HONInsetOverlayViewTypeUnlock = 0,
	HONInsetOverlayViewTypeSuggestions,
	HONInsetOverlayViewTypeAppReview,
	HONInsetOverlayViewTypeInvite
};

typedef NS_OPTIONS(NSUInteger, HONAppDelegateBitTesting) {
	HONAppDelegateBitTesting0	= (0UL << 0),
	HONAppDelegateBitTesting1	= (1UL << 0),
	HONAppDelegateBitTesting2	= (1UL << 1),
	HONAppDelegateBitTesting3	= (1UL << 2),
	HONAppDelegateBitTesting4	= (1UL << 3)
};


// api endpts
extern NSString * const kAPIHost;

extern NSString * const kBlowfishKey;
extern NSString * const kBlowfishBase64IV;


// view heights
extern const CGFloat kNavHeaderHeight;
extern const CGFloat kSearchHeaderHeight;
extern const CGFloat kDetailsHeroImageHeight;

// ui
extern const CGSize kTabSize;

// animation params
extern const CGFloat kProfileTime;
extern const CGFloat kButtonSelectDelay;

// image sizes
extern const CGSize kSnapAvatarSize;
extern const CGSize kSnapThumbSize;
extern const CGSize kSnapTabSize;
extern const CGSize kSnapMediumSize;
extern const CGSize kSnapLargeSize;

// image size suffixes
extern NSString * const kSnapThumbSuffix;
extern NSString * const kSnapMediumSuffix;
extern NSString * const kSnapTabSuffix;
extern NSString * const kSnapLargeSuffix;

extern const NSURLRequestCachePolicy kOrthodoxURLCachePolicy;
extern NSString * const kTwilioSMS;


@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

+ (NSString *)customerServiceURLForKey:(NSString *)key;
+ (NSString *)kikCardURL;
+ (NSString *)shareURL;

+ (NSDictionary *)s3Credentials;
+ (NSTimeInterval)timeoutInterval;

+ (NSString *)s3BucketForType:(HONAmazonS3BucketType)s3BucketType;

+ (NSDictionary *)contentForInsetOverlay:(HONInsetOverlayViewType)insetType;

+ (BOOL)switchEnabledForKey:(NSString *)key;


+ (NSString *)shareMessageForType:(HONShareMessageType)messageType;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;
+ (UIImage *)avatarImage;

+ (CGFloat)compressJPEGPercentage;

void Swizzle(Class c, SEL orig, SEL new);
void uncaughtExceptionHandler(NSException *exception);

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSSet *httpRequestOperations;


@end


