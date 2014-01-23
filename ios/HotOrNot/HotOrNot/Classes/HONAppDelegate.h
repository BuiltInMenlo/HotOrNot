//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMessageComposeViewController.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONOpponentVO.h"


#define __DEV_BUILD__ 1
/** =+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+= **/
/** =+-+-+-+-+-+-+-+-+-+-+-+--+= **/
#define __FORCE_REGISTER__ 0

#define __FORCE_SUGGEST__ 0
#define __IGNORE_SUSPENDED__ 0
#define __RESET_TOTALS__ 0

/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/
#define __APPSTORE_BUILD__ 0
/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/


typedef enum {
	HONTimelineScrollDirectionDown = 0,	/** Challenges using same hashtag */
	HONTimelineScrollDirectionUp,			/** Challenges of a single user */
} HONTimelineScrollDirection;

typedef enum {
	HONPushTypeShowChallengeDetails	= 1,			/** Brings up the challenge details modal **/
	HONPushTypeUserVerified,						/** Shows alert **/
	HONPushTypeShowUserProfile,						/** Brings up a user's profile **/
	HONPushTypeShowAddContacts,						/** Brings up the invite contacts modal **/
	HONPushTypeShowSettings,						/** Brings up the settings modal **/
	HONPushTypeShowChallengeDetailsIgnoringPushes	/** Brings up the challenge details modal, ignoring next pushes **/
} HONPushType;


// Push types
typedef enum {
	HONPushTriggerChallengeDetailsType = 1,
	HONPushTriggerVerifyAlertDetailsType,
	HONPushTriggerUserProfileType,
	HONPushTriggerAddContactsType
} HONPushTriggerType;


// share sheet actions
typedef enum {
	HONShareSheetActionTypeKik = 0,
	HONShareSheetActionTypeInstagram,
	HONShareSheetActionTypeTwitter,
	HONShareSheetActionTypeFacebook,
	HONShareSheetActionTypeSMS,
	HONShareSheetActionTypeEmail,
	HONShareSheetActionTypeClipboard
} HONShareSheetActionType;


// api endpts
extern NSString * const kConfigURL;
extern NSString * const kConfigJSON;
extern NSString * const kAPIHost;


// view heights
const CGFloat kNavBarHeaderHeight;
const CGFloat kSearchHeaderHeight;
const CGFloat kOrthodoxTableHeaderHeight;
const CGFloat kOrthodoxTableCellHeight;
const CGFloat kDetailsHeroImageHeight;

// animation params
const CGFloat kHUDTime;
const CGFloat kHUDErrorTime;
const CGFloat kProfileTime;

// image sizes
const CGSize kSnapThumbSize;
const CGSize kSnapTabSize;
const CGSize kSnapMediumSize;
const CGSize kSnapLargeSize;
const CGFloat kAvatarDim;


extern NSString * const kSnapThumbSuffix;
extern NSString * const kSnapMediumSuffix;
extern NSString * const kSnapTabSuffix;
extern NSString * const kSnapLargeSuffix;

const BOOL kIsImageCacheEnabled;
extern NSString * const kTwilioSMS;

// network error descriptions
extern NSString * const kNetErrorNoConnection;
extern NSString * const kNetErrorStatusCode404;


@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

+ (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes;
+ (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes;
+ (NSString *)deviceModel;
+ (BOOL)isPhoneType5s;
+ (BOOL)isRetina4Inch;
+ (BOOL)isIOS7;
+ (NSString *)deviceLocale;

+ (NSString *)apiServerPath;
+ (NSString *)customerServiceURL;
+ (NSDictionary *)s3Credentials;
+ (NSTimeInterval)timeoutInterval;

+ (NSString *)s3BucketForType:(NSString *)bucketType;

+ (int)minimumAge;
+ (NSRange)ageRangeAsSeconds:(BOOL)isInSeconds;

+ (int)profileSubscribeThreshold;

+ (BOOL)switchEnabledForKey:(NSString *)key;
+ (int)incTotalForCounter:(NSString *)key;
+ (int)totalForCounter:(NSString *)key;

+ (CGFloat)minSnapLuminosity;
+ (NSDictionary *)infoForABTab;

+ (NSString *)smsInviteFormat;
+ (NSDictionary *)emailInviteFormat;
+ (NSString *)instagramShareMessageForIndex:(int)index;
+ (NSString *)twitterShareCommentForIndex:(int)index;
+ (NSString *)facebookShareCommentForIndex:(int)index;
+ (NSString *)smsShareCommentForIndex:(int)index;
+ (NSDictionary *)emailShareCommentForIndex:(int)index;

+ (NSArray *)composeEmotions;
+ (NSArray *)replyEmotions;

+ (NSDictionary *)stickerForSubject:(NSString *)subject;
+ (NSString *)kikCardURL;
+ (NSString *)shareURL;

+ (NSString *)brandedAppName;
+ (NSArray *)searchSubjects;
+ (NSArray *)searchUsers;
+ (NSArray *)inviteCelebs;
+ (NSArray *)popularPeople;
+ (NSArray *)specialSubjects;

+ (NSRange)rangeForImageQueue;

+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;
+ (UIImage *)avatarImage;
+ (void)cacheNextImagesWithRange:(NSRange)range fromURLs:(NSArray *)urls withTag:(NSString *)tag;
+ (int)ageForDate:(NSDate *)date;

+ (NSArray *)followersListWithRefresh:(BOOL)isRefresh;
+ (void)addFollower:(NSDictionary *)follower;
+ (void)writeFollowers:(NSArray *)followers;
+ (BOOL)isFollowedByUser:(int)userID;

+ (NSArray *)followingListWithRefresh:(BOOL)isRefresh;
+ (void)addFollowingToList:(NSDictionary *)followingUser;
+ (void)writeFollowingList:(NSArray *)followingUsers;
+ (BOOL)isFollowingUser:(int)userID;

+ (HONOpponentVO *)mostRecentOpponentInChallenge:(HONChallengeVO *)challengeVO byUserID:(int)userID;
+ (HONEmotionVO *)mostRecentEmotionForOpponent:(HONOpponentVO *)opponentVO;
+ (int)hasVoted:(int)challengeID;
+ (BOOL)isChallengeParticipant:(HONChallengeVO *)challengeVO;
+ (void)setVoteForChallenge:(HONChallengeVO *)challengeVO forParticipant:(HONOpponentVO *)opponentVO;

+ (NSDictionary *)emptyChallengeDictionaryWithID:(int)challengeID;

+ (UIViewController *)appTabBarController;

+ (BOOL)hasTakenSelfie;
+ (BOOL)hasNetwork;
+ (BOOL)canPingAPIServer;
+ (BOOL)canPingConfigServer;

+ (CGFloat)compressJPEGPercentage;
+ (NSArray *)colorsForOverlayTints;

+ (BOOL)isValidEmail:(NSString *)checkString;
+ (NSString *)timeSinceDate:(NSDate *)date;
+ (NSString *)cleanImagePrefixURL:(NSString *)imageURL;
+ (NSDictionary *)parseQueryString:(NSString *)queryString;

//+ (UIFont *)cartoGothicBold;
//+ (UIFont *)cartoGothicBoldItalic;
//+ (UIFont *)cartoGothicBook;
//+ (UIFont *)cartoGothicItalic;
//+ (UIFont *)helveticaNeueFontRegular;
//+ (UIFont *)helveticaNeueFontLight;
//+ (UIFont *)helveticaNeueFontBold;
//+ (UIFont *)helveticaNeueFontBoldItalic;
//+ (UIFont *)helveticaNeueFontMedium;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end


