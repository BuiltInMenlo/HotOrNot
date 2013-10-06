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
#import "AFHTTPClient.h"


#define __DEV_BUILD___ 1
#define __ALWAYS_REGISTER__ 0
#define __ALWAYS_VERIFY__ 0


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
extern NSString * const kAPIUsersFirstRunComplete;
extern NSString * const kAPISetUserAgeGroup;
extern NSString * const kAPIJoinChallenge;
extern NSString * const kAPIGetVerifyList;


// view heights
const CGFloat kNavBarHeaderHeight;
const CGFloat kSearchHeaderHeight;
const CGFloat kOrthodoxTableHeaderHeight;
const CGFloat kOrthodoxTableCellHeight;
const CGSize kTabSize;

// snap params
const CGFloat kSnapRatio;
const CGFloat kSnapJPEGCompress;

// animation params
const CGFloat kHUDTime;
const CGFloat kHUDErrorTime;
const CGFloat kProfileTime;

// image sizes
const CGFloat kSnapThumbDim;
const CGFloat kSnapMediumDim;
const CGFloat kSnapLargeDim;
const CGFloat kAvatarDim;


const BOOL kIsImageCacheEnabled;
const NSUInteger kRecentOpponentsDisplayTotal;
extern NSString * const kTwilioSMS;


@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate, UIAlertViewDelegate, UIActionSheetDelegate, UIDocumentInteractionControllerDelegate>

+ (NSMutableString *)hmacToken;
+ (NSMutableString *)hmacForKey:(NSString *)key AndData:(NSString *)data;
+ (AFHTTPClient *)getHttpClientWithHMAC;
+ (NSString *)advertisingIdentifier;
+ (NSString *)identifierForVendor;

+ (NSString *)apiServerPath;
+ (NSString *)customerServiceURL;
+ (NSDictionary *)s3Credentials;
+ (NSString *)twilioSMS;

+ (NSString *)s3BucketForType:(NSString *)bucketType;

+ (int)createPointMultiplier;
+ (int)votePointMultiplier;
+ (int)pokePointMultiplier;

+ (int)profileSubscribeThreshold;

+ (NSString *)bannerForSection:(int)section;

+ (BOOL)switchEnabledForKey:(NSString *)key;

+ (NSString *)socialShareFormat;
+ (NSString *)smsInviteFormat;
+ (NSString *)emailInviteFormat;
+ (NSString *)instagramShareComment;

+ (NSArray *)defaultSubjects;

+ (NSArray *)searchSubjects;
+ (NSArray *)searchUsers;
+ (NSArray *)inviteCelebs;
+ (NSArray *)popularPeople;

+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;
+ (UIImage *)avatarImage;
+ (int)ageForDate:(NSDate *)date;

+ (NSArray *)friendsList;
+ (void)addFriendToList:(NSDictionary *)friend;
+ (void)writeFriendsList:(NSArray *)friends;

+ (NSArray *)subscribeeList;
+ (void)addSubscribeeToList:(NSDictionary *)subscribee;
+ (void)writeSubscribeeList:(NSArray *)subscribees;

+ (int)hasVoted:(int)challengeID;
+ (void)setVote:(int)challengeID forCreator:(BOOL)isCreator;

+ (NSArray *)fillDiscoverChallenges:(NSArray *)challenges;
+ (NSArray *)refreshDiscoverChallenges;

+ (UIViewController *)appTabBarController;

+ (BOOL)isRetina5;
+ (BOOL)hasNetwork;
+ (BOOL)canPingAPIServer;
+ (BOOL)canPingConfigServer;
+ (BOOL)audioMuted;
+ (NSString *)deviceLocale;
+ (void)offsetSubviewsForIOS7:(UIView *)view;

+ (NSString *)timeSinceDate:(NSDate *)date;
+ (NSString *)formattedExpireTime:(int)seconds;

+ (UIFont *)helveticaNeueFontRegular;
+ (UIFont *)helveticaNeueFontLight;
+ (UIFont *)helveticaNeueFontBold;
+ (UIFont *)helveticaNeueFontBoldItalic;
+ (UIFont *)helveticaNeueFontMedium;

+ (UIFont *)cartoGothicBold;
+ (UIFont *)cartoGothicBoldItalic;
+ (UIFont *)cartoGothicBook;
+ (UIFont *)cartoGothicItalic;

+ (UIColor *)honOrthodoxGreenColor;
+ (UIColor *)honDarkGreenColor;

+ (UIColor *)honGrey710Color;
+ (UIColor *)honGrey635Color;
+ (UIColor *)honGrey608Color;
+ (UIColor *)honGrey518Color;
+ (UIColor *)honGrey455Color;
+ (UIColor *)honGrey318Color;

+ (UIColor *)honBlueTextColor;
+ (UIColor *)honGreenTextColor;
+ (UIColor *)honGreyTimeColor;
+ (UIColor *)honProfileStatsColor;

+ (UIColor *)honDebugRedColor;
+ (UIColor *)honDebugGreenColor;
+ (UIColor *)honDebugBlueColor;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
