//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"


#define __DEV_CFG_JSON___ 1
#define __ALWAYS_REGISTER__ 0


// api endpts
extern NSString * const kConfigURL;
extern NSString * const kAPIChallenges;
extern NSString * const kAPIComments;
extern NSString * const kAPIDiscover;
extern NSString * const kAPIPopular;
extern NSString * const kAPISearch;
extern NSString * const kAPIUsers;
extern NSString * const kAPIVotes;

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

// image sizes
const CGFloat kSnapThumbDim;
const CGFloat kSnapMediumDim;
const CGFloat kSnapLargeDim;
const CGFloat kAvatarDim;


const BOOL kIsImageCacheEnabled;
const NSUInteger kFollowingUsersDisplayTotal;

@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

+ (NSString *)apiServerPath;
+ (NSString *)customerServiceURL;
+ (NSDictionary *)s3Credentials;
+ (BOOL)isInviteCodeValid:(NSString *)code;
+ (BOOL)isLocaleEnabled;

+ (int)createPointMultiplier;
+ (int)votePointMultiplier;
+ (int)pokePointMultiplier;

+ (NSString *)tutorialImageForPage:(int)page;
+ (NSString *)promoteInviteImageForType:(int)type;
+ (NSString *)timelineBannerURL;
+ (BOOL)isFUEInviteEnabled;

+ (NSString *)smsInviteFormat;
+ (NSString *)emailInviteFormat;
+ (NSString *)instagramShareComment;

+ (NSString *)rndDefaultSubject;

+ (NSArray *)searchSubjects;
+ (NSArray *)searchUsers;
+ (NSArray *)inviteCelebs;
+ (NSArray *)defaultFollowing;

+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;
+ (UIImage *)avatarImage;

+ (void)setAllowsFBPosting:(BOOL)canPost;
+ (BOOL)allowsFBPosting;

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

+ (NSString *)timeSinceDate:(NSDate *)date;


+ (UIFont *)helveticaNeueFontRegular;
+ (UIFont *)helveticaNeueFontLight;
+ (UIFont *)helveticaNeueFontBold;
+ (UIFont *)helveticaNeueFontBoldItalic;
+ (UIFont *)helveticaNeueFontMedium;

+ (UIFont *)cartoGothicBold;
+ (UIFont *)cartoGothicBoldItalic;
+ (UIFont *)cartoGothicBook;
+ (UIFont *)cartoGothicItalic;

+ (UIColor *)honGrey710Color;
+ (UIColor *)honGrey635Color;
+ (UIColor *)honGrey518Color;
+ (UIColor *)honGrey455Color;
+ (UIColor *)honGrey245Color;
+ (UIColor *)honOffGreyLightColor;
+ (UIColor *)honProfileStatsTextColor;
+ (UIColor *)honOrthodoxGreenColor;
+ (UIColor *)honDarkGreenColor;

+ (UIColor *)honBlueTextColor;
+ (UIColor *)honGreenTextColor;

+(UIColor *)honDebugRedColor;
+(UIColor *)honDebugGreenColor;
+(UIColor *)honDebugBlueColor;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
