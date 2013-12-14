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

#import "MBProgressHUD.h"
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"
#import "AFHTTPClient.h"


#define __DEV_BUILD__ 0
/** =+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+= **/
/** =+-+-+-+-+-+-+-+-+-+-+-+--+= **/
#define __FORCE_REGISTER__ 0

#define __FORCE_SUGGEST__ 0
#define __IGNORE_SUSPENDED__ 0
#define __RESET_TOTALS__ 0

/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/
#define __APPSTORE_BUILD__ 1
/** *~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*~~*· **/


typedef enum {
	HONTimelineScrollDirectionDown	= 0,	/** Challenges using same hashtag */
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
	HONPushTriggerChallengeDetailsType =	1,
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
extern NSString * const kAPIChallenges;
extern NSString * const kAPIComments;
extern NSString * const kAPIDiscover;
extern NSString * const kAPIPopular;
extern NSString * const kAPISearch;
extern NSString * const kAPIUsers;
extern NSString * const kAPIVotes;
extern NSString * const kAPIGetFriends;
extern NSString * const kAPIGetSubscribees;
extern NSString * const kAPIAddFriend;
extern NSString * const kAPIRemoveFriend;
extern NSString * const kAPISMSInvites;
extern NSString * const kAPIEmailInvites;
extern NSString * const kAPITumblrLogin;
extern NSString * const kAPIEmailVerify;
extern NSString * const kAPIPhoneVerify;
extern NSString * const kAPIEmailContacts;
extern NSString * const kAPIChallengeObject;
extern NSString * const kAPIGetPublicMessages;
extern NSString * const kAPIGetPrivateMessages;
extern NSString * const kAPICheckNameAndEmail;
extern NSString * const kAPIUsersFirstRunComplete;
extern NSString * const kAPISetUserAgeGroup;
extern NSString * const kAPICreateChallenge;
extern NSString * const kAPIJoinChallenge;
extern NSString * const kAPIGetVerifyList;
extern NSString * const kAPIProcessChallengeImage;
extern NSString * const kAPIProcessUserImage;
extern NSString * const kAPISuspendedAccount;
extern NSString * const kAPIPurgeUser;
extern NSString * const kAPIPurgeContent;
extern NSString * const kAPIGetActivity;
extern NSString * const kAPIDeleteImage;
extern NSString * const kAPIVerifyShoutout;
extern NSString * const kAPIProfileShoutout;


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

+ (NSMutableString *)hmacToken;
+ (NSMutableString *)hmacForKey:(NSString *)key AndData:(NSString *)data;
+ (AFHTTPClient *)getHttpClientWithHMAC;
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

+ (NSArray *)friendsList;
+ (void)addFriendToList:(NSDictionary *)friend;
+ (void)writeFriendsList:(NSArray *)friends;
+ (BOOL)isFollowedByUser:(int)userID;

+ (NSArray *)subscribeeList;
+ (void)addSubscribeeToList:(NSDictionary *)subscribee;
+ (void)writeSubscribeeList:(NSArray *)subscribees;
+ (BOOL)isFollowingUser:(int)userID;

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
+ (NSString *)formattedExpireTime:(int)seconds;
+ (NSString *)cleanImagePrefixURL:(NSString *)imageURL;
+ (NSDictionary *)parseQueryString:(NSString *)queryString;

+ (UIFont *)cartoGothicBold;
+ (UIFont *)cartoGothicBoldItalic;
+ (UIFont *)cartoGothicBook;
+ (UIFont *)cartoGothicItalic;
+ (UIFont *)helveticaNeueFontRegular;
+ (UIFont *)helveticaNeueFontLight;
+ (UIFont *)helveticaNeueFontBold;
+ (UIFont *)helveticaNeueFontBoldItalic;
+ (UIFont *)helveticaNeueFontMedium;

+ (UIColor *)honPercentGreyscaleColor:(CGFloat)percent;

+ (UIColor *)honBlueTextColor;
+ (UIColor *)honBlueTextColorHighlighted;
+ (UIColor *)honGreenTextColor;
+ (UIColor *)honGreyTextColor;
+ (UIColor *)honDarkGreyTextColor;
+ (UIColor *)honLightGreyTextColor;
+ (UIColor *)honPlaceholderTextColor;

+ (UIColor *)honDebugColor;
+ (UIColor *)honDebugColorByName:(NSString *)colorName atOpacity:(CGFloat)percent;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end


