//
//  HONAppDelegate.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import <FacebookSDK/FacebookSDK.h>
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
+ (int)createPointMultiplier;
+ (int)votePointMultiplier;
+ (int)pokePointMultiplier;
+ (NSString *)ctaForChallenge:(HONChallengeVO *)vo;
+ (BOOL)isCharboostEnabled;
+ (BOOL)isKiipEnabled;
+ (BOOL)isTapForTapEnabled;
+ (NSString *)rndDefaultSubject;

- (BOOL)openSession;
+ (void)writeDeviceToken:(NSString *)token;
+ (NSString *)deviceToken;

+ (void)writeUserInfo:(NSDictionary *)userInfo;
+ (NSDictionary *)infoForUser;

+ (void)writeFBProfile:(NSDictionary *)userInfo;
+ (NSDictionary *)fbProfileForUser;

+ (void)setAllowsFBPosting:(BOOL)canPost;
+ (BOOL)allowsFBPosting;

+ (BOOL)hasVoted:(int)challengeID;
+ (void)setVote:(int)challengeID;

+ (UIViewController *)appTabBarController;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;

+ (NSArray *)fbPermissions;

+ (BOOL)isRetina5;
+ (BOOL)hasNetwork;
+ (BOOL)canPingServers;
+ (BOOL)canPingAPIServer;
+ (BOOL)canPingParseServer;

+ (void)toggleViewPushed:(BOOL)isPushed;

+ (UIFont *)honHelveticaNeueFontBold;
+ (UIFont *)honHelveticaNeueFontMedium;

+ (UIFont *)freightSansBlack;

+ (UIFont *)qualcommBold;
+ (UIFont *)qualcommLight;
+ (UIFont *)qualcommRegular;
+ (UIFont *)qualcommSemibold;

+ (UIColor *)honBlueTxtColor;
+ (UIColor *)honGreyTxtColor;


#define kUsersAPI @"Users.php"
#define kChallengesAPI @"Challenges.php"
#define kPopularAPI @"Popular.php"
#define kVotesAPI @"Votes.php"

#define kThumb1W 50.0
#define kThumb1H 67.0

#define kMediumW 153.0
#define kMediumH 205.0

#define kLargeW 612.0
#define kLargeH 816.0

#define kPhotoRatio 1.333333333

#define kHUDTime 0.5
#define kJPEGCompress 0.33

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (strong, nonatomic) HONLoginViewController *loginViewController;

@end
