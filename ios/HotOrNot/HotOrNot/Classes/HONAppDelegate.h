//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "HONLoginViewController.h"
#import "HONChallengeVO.h"

extern NSString *const HONSessionStateChangedNotification;
extern NSString *const FacebookAppID;

@class SMClient;

@interface HONAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) SMClient *client;


+ (NSString *)apiServerPath;
+ (NSString *)dailySubjectName;
+ (NSDictionary *)s3Credentials;
+ (NSString *)facebookCanvasURL;
+ (NSDictionary *)facebookFriendPosting;
+ (BOOL)isInviteCodeValid:(NSString *)code;
+ (int)createPointMultiplier;
+ (int)votePointMultiplier;
+ (int)pokePointMultiplier;
+ (NSString *)smsInviteFormat;
+ (NSString *)emailInviteFormat;
+ (BOOL)isCharboostEnabled;
+ (BOOL)isKiipEnabled;
+ (BOOL)isTapForTapEnabled;
+ (NSString *)rndDefaultSubject;
+ (BOOL)isLocaleEnabled;
+ (NSArray *)searchSubjects;
+ (NSArray *)searchUsers;

- (BOOL)openSession;
+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;

+ (void)writeFBProfile:(NSDictionary *)userInfo;
+ (NSDictionary *)fbProfileForUser;

+ (void)setAllowsFBPosting:(BOOL)canPost;
+ (BOOL)allowsFBPosting;

+ (int)hasVoted:(int)challengeID;
+ (void)setVote:(int)challengeID forCreator:(BOOL)isCreator;

+ (UIViewController *)appTabBarController;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;
+ (UIImage *)editImage:(UIImage *)image toSize:(CGSize)size thenCrop:(CGRect)rect;

+ (NSArray *)fbPermissions;

+ (BOOL)isRetina5;
+ (BOOL)hasNetwork;
+ (BOOL)canPingAPIServer;
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
+ (UIColor *)honGreyTxtColor;
+ (UIColor *)honGreyInputColor;
+ (UIColor *)honGreyDarkerColor;


#define kChallengesAPI @"Challenges.php"
#define kCommentsAPI @"Comments.php"
#define kDiscoverAPI @"Discover.php"
#define kPopularAPI @"Popular.php"
#define kSearchAPI @"Search.php"
#define kUsersAPI @"Users.php"
#define kVotesAPI @"Votes.php"

#define kThumb1W 38.0
#define kThumb1H 50.0

#define kMediumW 153.0
#define kMediumH 205.0

#define kLargeW 612.0
#define kLargeH 816.0

#define kPhotoRatio 1.333333333

#define kHUDTime 0.5
#define kJPEGCompress 0.5

#define kNavHeaderHeight 45.0
#define kSearchHeaderHeight 44.0
#define kRowHeight 63.0

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) HONLoginViewController *loginViewController;

@end
