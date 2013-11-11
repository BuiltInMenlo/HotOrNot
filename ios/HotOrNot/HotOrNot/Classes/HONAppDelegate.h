//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MBProgressHUD.h"
#import "HONChallengeVO.h"
#import "HONOpponentVO.h"
#import "AFHTTPClient.h"


#define __DEV_BUILD___ 0
#define __ALWAYS_REGISTER__ 0
#define __IGNORE_SUSPENDED__ 0
#define __RESET_TOTALS__ 0


typedef enum {
	HONTimelineScrollDirectionDown	= 0,	/** Challenges using same hashtag */
	HONTimelineScrollDirectionUp,			/** Challenges of a single user */
} HONTimelineScrollDirection;


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


// view heights
const CGFloat kNavBarHeaderHeight;
const CGFloat kSearchHeaderHeight;
const CGFloat kOrthodoxTableHeaderHeight;
const CGFloat kOrthodoxTableCellHeight;

// snap params
const CGFloat kMinLuminosity;
const CGFloat kSnapRatio;
const CGFloat kSnapJPEGCompress;

//const CGFloat kSnapLumThreshold;
//const CGFloat kSnapDarkBrightness;
//const CGFloat kSnapDarkContrast;
//const CGFloat kSnapDarkSaturation;
//const CGFloat kSnapLightBrightness;
//const CGFloat kSnapLightContrast;
//const CGFloat kSnapLightSaturation;


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


@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>

+ (NSMutableString *)hmacToken;
+ (NSMutableString *)hmacForKey:(NSString *)key AndData:(NSString *)data;
+ (AFHTTPClient *)getHttpClientWithHMAC;
+ (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes;
+ (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes;
+ (NSString *)deviceModel;

+ (NSString *)apiServerPath;
+ (NSString *)customerServiceURL;
+ (NSDictionary *)s3Credentials;
+ (NSString *)twilioSMS;

+ (NSString *)s3BucketForType:(NSString *)bucketType;

+ (NSRange)ageRangeAsSeconds:(BOOL)isInSeconds;

+ (int)profileSubscribeThreshold;

+ (BOOL)switchEnabledForKey:(NSString *)key;
+ (int)incTotalForCounter:(NSString *)key;
+ (int)totalForCounter:(NSString *)key;

+ (NSDictionary *)infoForABTab;
+ (NSString *)smsInviteFormat;
+ (NSDictionary *)emailInviteFormat;
+ (NSString *)instagramShareMessageForIndex:(int)index;
+ (NSString *)twitterShareCommentForIndex:(int)index;;

+ (NSArray *)composeEmotions;
+ (NSArray *)replyEmotions;

+ (NSArray *)searchSubjects;
+ (NSArray *)searchUsers;
+ (NSArray *)inviteCelebs;
+ (NSArray *)popularPeople;

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

+ (UIViewController *)appTabBarController;

+ (BOOL)isPhoneType5s;
+ (BOOL)isRetina4Inch;
+ (BOOL)isIOS7;
+ (BOOL)hasTakenSelfie;
+ (BOOL)hasNetwork;
+ (BOOL)canPingAPIServer;
+ (BOOL)canPingConfigServer;
+ (NSString *)deviceLocale;

+ (BOOL)isValidEmail:(NSString *)checkString;
+ (NSString *)timeSinceDate:(NSDate *)date;
+ (NSString *)formattedExpireTime:(int)seconds;
+ (NSString *)cleanImagePrefixURL:(NSString *)imageURL;

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

+ (UIColor *)honDebugColorByName:(NSString *)colorName atOpacity:(CGFloat)percent;


@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end


