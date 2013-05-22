//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HONChallengeVO.h"


extern const NSInteger kNavBarHeaderHeight;
extern const NSInteger kSearchHeaderHeight;
extern const NSInteger kDefaultCellHeight;

extern NSString * const kConfigURL;
extern NSString * const kAPIChallenges;
extern NSString * const kAPIComments;
extern NSString * const kAPIDiscover;
extern NSString * const kAPIPopular;
extern NSString * const kAPISearch;
extern NSString * const kAPIUsers;
extern NSString * const kAPIVotes;

const CGSize kTabSize;
const CGSize kSnapThumbSize;
const CGSize kSnapMediumSize;
const CGSize kSnapLargeSize;
const CGSize kAvatarDefaultSize;

static const CGFloat kSnapRatio;
static const CGFloat kSnapJPEGCompress;

static const CGFloat kHUDTime;
static const CGFloat kSnapRatio;


@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

+ (NSString *)apiServerPath;
+ (NSString *)customerServiceURL;
+ (NSDictionary *)s3Credentials;
+ (BOOL)isInviteCodeValid:(NSString *)code;
+ (BOOL)isLocaleEnabled;

+ (int)createPointMultiplier;
+ (int)votePointMultiplier;
+ (int)pokePointMultiplier;

+ (NSString *)timelineBannerURL;

+ (NSString *)smsInviteFormat;
+ (NSString *)emailInviteFormat;
+ (NSString *)instagramShareComment;

+ (NSString *)rndDefaultSubject;

+ (NSArray *)searchSubjects;
+ (NSArray *)searchUsers;

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
//+ (BOOL)canPingParseServer;
+ (BOOL)canPingConfigServer;
+ (BOOL)audioMuted;
+ (NSString *)deviceLocale;

+ (NSString *)timeSinceDate:(NSDate *)date;

+ (UIFont *)helveticaNeueFontBold;
+ (UIFont *)helveticaNeueFontBoldItalic;
+ (UIFont *)helveticaNeueFontMedium;

+ (UIFont *)cartoGothicBold;
+ (UIFont *)cartoGothicBoldItalic;
+ (UIFont *)cartoGothicBook;
+ (UIFont *)cartoGothicItalic;

+ (UIColor *)honBlueTxtColor;
+ (UIColor *)honGrey635Color;
+ (UIColor *)honGrey518Color;
+ (UIColor *)honGrey455Color;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;

@end
