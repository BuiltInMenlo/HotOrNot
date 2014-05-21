//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>


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


typedef enum {
	HONAmazonS3BucketTypeAvatarsSource = 0,
	HONAmazonS3BucketTypeAvatarsCloudFront,
	
	HONAmazonS3BucketTypeBannersSource,
	HONAmazonS3BucketTypeBannersCloudFront,
	
	HONAmazonS3BucketTypeClubsSource,
	HONAmazonS3BucketTypeClubsCloudFront,
	
	HONAmazonS3BucketTypeEmotionsSource,
	HONAmazonS3BucketTypeEmoticonsCloudFront
} HONAmazonS3BucketType;


// api endpts
extern NSString * const kConfigURL;
extern NSString * const kConfigJSON;
extern NSString * const kAPIHost;

extern NSString * const kBlowfishKey;
extern NSString * const kBlowfishBase64IV;


// view heights
extern const CGFloat kNavHeaderHeight;
extern const CGFloat kSearchHeaderHeight;
extern const CGFloat kOrthodoxTableHeaderHeight;
extern const CGFloat kOrthodoxTableCellHeight;
extern const CGFloat kDetailsHeroImageHeight;

// animation params
extern const CGFloat kHUDTime;
extern const CGFloat kHUDErrorTime;
extern const CGFloat kProfileTime;

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

extern const BOOL kIsImageCacheEnabled;
extern NSString * const kTwilioSMS;

// network error descriptions
extern NSString * const kNetErrorNoConnection;
extern NSString * const kNetErrorStatusCode404;


@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate>

+ (NSString *)apiServerPath;
+ (NSString *)customerServiceURL;
+ (NSString *)kikCardURL;
+ (NSString *)shareURL;

+ (NSDictionary *)s3Credentials;
+ (NSTimeInterval)timeoutInterval;

+ (NSString *)s3BucketForType:(HONAmazonS3BucketType)s3BucketType;

+ (int)minimumAge;


+ (BOOL)switchEnabledForKey:(NSString *)key;
+ (int)incTotalForCounter:(NSString *)key;
+ (int)totalForCounter:(NSString *)key;

+ (CGFloat)minSnapLuminosity;
+ (NSString *)verifyCopyForKey:(NSString *)key;

+ (NSString *)smsInviteFormat;
+ (NSDictionary *)emailInviteFormat;
+ (NSString *)instagramShareMessageForIndex:(int)index;
+ (NSString *)twitterShareCommentForIndex:(int)index;
+ (NSString *)facebookShareCommentForIndex:(int)index;
+ (NSString *)smsShareCommentForIndex:(int)index;
+ (NSDictionary *)emailShareCommentForIndex:(int)index;


+ (NSArray *)freeEmotions;
+ (NSArray *)paidEmotions;
+ (NSArray *)searchUsers;
+ (NSArray *)subjectFormats;

+ (NSRange)rangeForImageQueue;

+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;
+ (UIImage *)avatarImage;
+ (void)cacheNextImagesWithRange:(NSRange)range fromURLs:(NSArray *)urls withTag:(NSString *)tag;
+ (int)ageForDate:(NSDate *)date;

+ (void)resetTotals;


- (void)changeTabToIndex:(NSNumber *)selectedIndex;
+ (UIViewController *)appTabBarController;

+ (BOOL)hasNetwork;
+ (BOOL)canPingAPIServer;
+ (BOOL)canPingConfigServer;

+ (CGFloat)compressJPEGPercentage;
+ (NSArray *)colorsForOverlayTints;

+ (BOOL)isValidEmail:(NSString *)checkString;
+ (NSString *)timeSinceDate:(NSDate *)date;
+ (NSString *)cleanImagePrefixURL:(NSString *)imageURL;
+ (NSDictionary *)parseQueryString:(NSString *)queryString;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end


