//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <sys/utsname.h>

#import <FacebookSDK/FacebookSDK.h>
#import <HockeySDK/HockeySDK.h>
//#import <Tapjoy/Tapjoy.h>

#import "NSString+DataTypes.h"

#import "AFNetworking.h"
#import "Chartboost.h"
#import "MBProgressHUD.h"
#import "KikAPI.h"
#import "Reachability.h"
#import "TSTapstream.h"
//#import "UAConfig.h"
//#import "UAirship.h"
//#import "UAAnalytics.h"
//#import "UAPush.h"
//#import "UATagUtils.h"
#import "UIImageView+AFNetworking.h"

#import "HONAppDelegate.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONTabBarController.h"
#import "HONVerifyViewController.h"
#import "HONTimelineViewController.h"
#import "HONFeedViewController.h"
#import "HONAlertsViewController.h"
#import "HONClubsTimelineViewController.h"
//#import "HONUserClubsViewController.h"
#import "HONChallengeDetailsViewController.h"
#import "HONAddContactsViewController.h"
#import "HONContactsViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSettingsViewController.h"
#import "HONSuspendedViewController.h"
#import "HONAlertsViewController.h"
#import "HONImagePickerViewController.h"


#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
NSString * const kConfigURL = @"http://api.letsvolley.com";
NSString * const kConfigJSON = @"boot_sc0004.json";
NSString * const kAPIHost = @"data_api";
#else
NSString * const kConfigURL = @"http://api-stage.letsvolley.com";
NSString * const kConfigJSON = @"boot_matt.json";
NSString * const kAPIHost = @"data_api-dev";
#endif

#if __APPSTORE_BUILD__ == 1
NSString * const kMixPanelToken = @"7de852844068f082ddfeaf43d96e998e"; // Volley 1.2.3/4
#else
NSString * const kMixPanelToken = @"c7bf64584c01bca092e204d95414985f"; // Dev
#endif


NSString * const kFacebookAppID = @"600550136636754";
NSString * const kHockeyAppToken = @"a2f42fed0f269018231f6922af0d8ad3";
NSString * const kTapStreamSecretKey = @"xJCRiJCqSMWFVF6QmWdp8g";
NSString * const kChartboostAppID = @"";
NSString * const kChartboostAppSignature = @"";
NSString * const kTapjoyAppID = @"13b84737-f359-4bf1-b6a0-079e515da029";
NSString * const kTapjoyAppSecretKey = @"llSjQBKKaGBsqsnJZlxE";


// view heights
const CGFloat kNavHeaderHeight = 64.0;
const CGFloat kSearchHeaderHeight = 43.0f;
const CGFloat kOrthodoxTableHeaderHeight = 24.0f;
const CGFloat kOrthodoxTableCellHeight = 64.0f;
const CGFloat kDetailsHeroImageHeight = 324.0;

// animation params
const CGFloat kHUDTime = 0.5f;
const CGFloat kHUDErrorTime = 1.5f;
const CGFloat kProfileTime = 0.25f;

// image sizes
const CGSize kSnapAvatarSize = {48.0f, 48.0f};
const CGSize kSnapThumbSize = {80.0f, 80.0f};
const CGSize kSnapTabSize = {320.0f, 480.0f};
const CGSize kSnapMediumSize = {160.0f, 160.0f};
const CGSize kSnapLargeSize = {320.0f, 568.0f};

NSString * const kSnapThumbSuffix = @"Small_160x160.jpg";
NSString * const kSnapMediumSuffix = @"Medium_320x320.jpg";
NSString * const kSnapTabSuffix = @"Tab_640x960.jpg";
NSString * const kSnapLargeSuffix = @"Large_640x1136.jpg";

const BOOL kIsImageCacheEnabled = YES;
NSString * const kTwilioSMS = @"6475577873";

// network error descriptions
NSString * const kNetErrorNoConnection = @"The Internet connection appears to be offline.";
NSString * const kNetErrorStatusCode404 = @"Expected status code in (200-299), got 404";


#if __APPSTORE_BUILD__ == 0
//@interface HONAppDelegate() <BITHockeyManagerDelegate, ChartboostDelegate, UAPushNotificationDelegate>
@interface HONAppDelegate() <BITHockeyManagerDelegate, ChartboostDelegate>
#else
//@interface HONAppDelegate() <ChartboostDelegate, UAPushNotificationDelegate>
@interface HONAppDelegate() <ChartboostDelegate>
#endif
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) UIImageView *launchImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic) int challengeID;
@property (nonatomic) int userID;
@property (nonatomic) BOOL awsUploadCounter;
@property (nonatomic, copy) NSString *currentConversationID;
@end


@implementation HONAppDelegate
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;



+ (NSArray *)fpoClubDictionaries {
	return (@[@{@"id"				: @"1110001",
				@"name"				: @"School",
				@"description"		: @"FPO High School",
				@"img"				: @"https://d3j8du2hyvd35p.cloudfront.net/3f3158660d1144a2ba2bb96d8fa79c96_5c7e2f9900fb4d9a930ac11a09b9facb-1389678527Large_640x1136.jpg",
				
				@"owner"			: @{@"id"			: @"62899",
										@"username"		: @"smileyy_syd",
										@"avatar"		: @"https://d3j8du2hyvd35p.cloudfront.net/efdb098b221b41778409e4d6d3d05f83_b12db29b3dce414899da69ad55effb91-1388538981"},
				
				@"members"			: @[@{@"id"				: @"116900",
										   @"username"		: @"dev_jesse",
										   @"avatar"		: @"https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png",
										   @"age"			: @"1970-07-08 00:00:00",
										   @"extern_name"	: @"Jesse Boley",
										   @"mobile_number"	: @"",
										   @"email"			: @"jlboley@gmail.com",
										   @"invited"		: @"2014-03-05 10:41:41"}],
				
				@"pending"			: @[@{@"extern_name"	: @"Ken Shabby",
										  @"mobile_number"	: @"+14153456723",
										  @"email"			: @"ken.shabby@gmail.com",
										  @"invited"		: @"2014-03-25 18:31:15"}],
				
				@"blocked"			: @[],
				
				@"total_members"	: @"2",
				@"added"			: @"2014-03-21 12:43:55"},
			  
			  
			  @{@"id"				: @"1110002",
				@"name"				: @"Katy Perry",
				@"description"		: @"",
				@"img"				: @"https://s3.amazonaws.com/hotornot-challenges/katyPerryLarge_640x1136.jpg",
				
				@"owner"			: @{@"id"		: @"10563",
										@"username"	: @"cheylaureenxo",
										@"avatar"	: @"https://d3j8du2hyvd35p.cloudfront.net/8268d1cb4608e0fce19ddc30d1a47a6d247769bc1301f9d1b99c2c5248ce3148-1379717258"},
				
				@"members"			: @[@{@"id"				: @"99629",
										  @"username"		: @"shane5s",
										  @"avatar"			: @"https://s3.amazonaws.com/hotornot-avatars/defaultAvatar.png",
										  @"age"			: @"1997-02-05 16:00:00",
										  @"extern_name"	: @"Shane Hill",
										  @"mobile_number"	: @"+14152549391",
										  @"email"			: @"",
										  @"invited"		: @"2014-03-15 10:21:41"},
										@{@"id"				: @"131796",
										  @"username"		: @"jess4life",
										  @"avatar"			: @"https://d3j8du2hyvd35p.cloudfront.net/e03d3827b9b547db9c2d64fe02389896_fcc05b136a6d4a9dac3767006f555701-1397110912",
										  @"age"			: @"1990-04-10 06:20:36",
										  @"extern_name"	: @"Jessica Rabbit",
										  @"mobile_number"	: @"+13058531028",
										  @"email"			: @"",
										  @"invited"		: @"2014-04-27 03:11:33"}],
				@"pending"			: @[],
				
				@"blocked"			: @[@{@"id"				: @"52802",
										  @"username"		: @"king Afg",
										  @"avatar"			: @"https://d3j8du2hyvd35p.cloudfront.net/2e1716ac9b1046c788a7bb67b0f38705_24f84f0bc545480aab2fe358025c03a2-1388792086",
										  @"age"			: @"1979-12-27 14:54:37",
										  @"extern_name"	: @"Afghan King",
										  @"mobile_number"	: @"",
										  @"email"			: @"",
										  @"invited"		: @"2014-04-27 09:36:19"}],
				
				@"total_members"	: @"3",
				@"added"			: @"2014-04-20 16:20:00"},
			  
			  @{@"id"				: @"40",
				@"name"				: @"MATT TEST",
				@"description"		: @"",
				@"img"				: @"",
				
				@"owner"			: @{@"id"		: @"131820",
										@"username"	: @"yoloswag1398622768.1535d4a309d08a",
										@"avatar"	: @"https://d3j8du2hyvd35p.cloudfront.net/8268d1cb4608e0fce19ddc30d1a47a6d247769bc1301f9d1b99c2c5248ce3148-1379717258"},
				
				@"members"			: @[],
				@"pending"			: @[],
				@"blocked"			: @[],
				
				@"total_members"	: @"0",
				@"added"			: @"2014-04-28 00:40:03"}]);
}

+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSString *)customerServiceURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"service_url"]);
}
+ (NSDictionary *)s3Credentials {
	return ([NSDictionary dictionaryWithObjectsAndKeys:@"AKIAJVS6Y36AQCMRWLQQ", @"key", @"48u0XmxUAYpt2KTkBRqiDniJXy+hnLwmZgYqUGNm", @"secret", nil]);
}

+ (NSTimeInterval)timeoutInterval {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout_interval"] doubleValue]);
}

+ (CGFloat)minSnapLuminosity {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"min_luminosity"] floatValue]);
}

+ (NSString *)verifyCopyForKey:(NSString *)key {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"verify_copy"] objectForKey:key]);
}

+ (NSString *)smsInviteFormat {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_formats"] objectForKey:@"sms"]);
}

+ (NSDictionary *)emailInviteFormat {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_formats"] objectForKey:@"email"]);
}

+ (NSString *)instagramShareMessageForIndex:(int)index { //[0]:Details //[1]:Profile
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"instagram"] objectAtIndex:index]);
}

+ (NSString *)twitterShareCommentForIndex:(int)index { //[0]:Details //[1]:Profile
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"twitter"] objectAtIndex:index]);
}

+ (NSString *)facebookShareCommentForIndex:(int)index {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"facebook"] objectAtIndex:index]);
}

+ (NSString *)smsShareCommentForIndex:(int)index {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"sms"] objectAtIndex:index]);
}

+ (NSDictionary *)emailShareCommentForIndex:(int)index {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"email"] objectAtIndex:index]);
}

+ (int)minimumAge {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"min_age"] intValue]);
}

+ (NSString *)s3BucketForType:(HONAmazonS3BucketType)s3BucketType {
	NSString *key = @"";
	
	if (s3BucketType == HONAmazonS3BucketTypeAvatarsSource || s3BucketType == HONAmazonS3BucketTypeAvatarsCloudFront)
		key = @"avatars";
	
	else if (s3BucketType == HONAmazonS3BucketTypeBannersSource || s3BucketType == HONAmazonS3BucketTypeBannersCloudFront)
		key = @"banners";
	
	else if (s3BucketType == HONAmazonS3BucketTypeClubsSource || s3BucketType == HONAmazonS3BucketTypeClubsCloudFront)
		key = @"challenges";
	
	else if (s3BucketType == HONAmazonS3BucketTypeEmotionsSource || s3BucketType == HONAmazonS3BucketTypeEmoticonsCloudFront)
		key = @"emoticons";
	
	
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"s3_buckets"] objectForKey:key] objectAtIndex:(s3BucketType % 2)]);
}

+ (BOOL)switchEnabledForKey:(NSString *)key {
	return ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"switches"] objectForKey:key] uppercaseString] isEqualToString:@"YES"]);
}

+ (int)incTotalForCounter:(NSString *)key {
	key = [[key lowercaseString] stringByAppendingString:@"_total"];
	int tot = ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) ? 0 : [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue] + 1;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tot] forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (tot);
}

+ (int)totalForCounter:(NSString *)key {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:[[key lowercaseString] stringByAppendingString:@"_total"]] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:[[key lowercaseString] stringByAppendingString:@"_total"]] intValue] : -1);
}

+ (NSString *)kikCardURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"kik_card"]);
}

+ (NSString *)shareURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"share_url"]);
}


+ (NSArray *)freeEmotions {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSDictionary *dict in [[[NSUserDefaults standardUserDefaults] objectForKey:@"emotions"] objectAtIndex:0])
		[emotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
	
	return ([emotions copy]);
}

+ (NSArray *)paidEmotions {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSDictionary *dict in [[[NSUserDefaults standardUserDefaults] objectForKey:@"emotions"] objectAtIndex:1])
		[emotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
	
	return ([emotions copy]);
}

+ (NSArray *)subjectFormats {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"subject_formats"]);
}

+ (NSArray *)searchUsers {
	return ([NSMutableArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"search_users"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username"
																																																  ascending:YES
																																																   selector:@selector(localizedCaseInsensitiveCompare:)]]]]);
}

+ (NSRange)rangeForImageQueue {
	return (NSRangeFromString([[NSUserDefaults standardUserDefaults] objectForKey:@"image_queue"]));;
}


+ (void)writeDeviceToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceToken {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]);
}

+ (void)writeUserInfo:(NSDictionary *)userInfo {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_info"];
	
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeUserAvatar:(UIImage *)image {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"avatar_image"];
	
	[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"avatar_image"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)infoForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
}

+ (UIImage *)avatarImage {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"avatar_image"])
		return ([UIImage imageNamed:@"defaultAvatarLarge_640x1136"]);
	
	return ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatar_image"]]);
}

+ (void)resetTotals {
	NSArray *totalKeys = @[@"boot_total",
						   @"background_total",
						   @"contacts_total",
						   @"contactsRefresh_total",
						   @"timeline_total",
						   @"timelineRefresh_total",
						   @"feedItem_total",
						   @"feedItemRefresh_total",
						   @"clubs_total",
						   @"clubsRefresh_total",
						   @"messages_total",
						   @"messagesRefresh_total",
						   @"alerts_total",
						   @"alertsRefresh_total",
						   @"verify_total",
						   @"verifyRefresh_total",
						   @"search_total",
						   @"suggested_total",
						   @"verifyAction_total",
						   @"preview_total",
						   @"details_total",
						   @"camera_total",
						   @"join_total",
						   @"profile_total",
						   @"like_total"];
	
	for (NSString *key in totalKeys) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:key])
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
	}
}

+ (void)cacheNextImagesWithRange:(NSRange)range fromURLs:(NSArray *)urls withTag:(NSString *)tag {
//	NSLog(@"QUEUEING : |]%@]>{%@)_", NSStringFromRange(range), tag);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { };
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {};
	
	for (int i=0; i<range.length - range.location; i++) {
//		NSLog(@"s+ArT_l0Ad. --> (#%02d) \"%@\"", (range.location + i), [urls objectAtIndex:i]);
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[imageView setTag:range.location + i];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[urls objectAtIndex:i] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];
	}
}

+ (int)ageForDate:(NSDate *)date {
	return ([date timeIntervalSinceNow] / -31536000);
}

+ (NSArray *)followersListWithRefresh:(BOOL)isRefresh {
	NSMutableArray *followers = [NSMutableArray array];
	
	if (isRefresh) {
		[[HONAPICaller sharedInstance] retrieveUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
			NSDictionary *userObj = (NSDictionary *)result;
			[HONAppDelegate writeFollowers:[userObj objectForKey:@"friends"]];
		}];
	
	}
	
	for (NSDictionary *dict in [[HONAppDelegate infoForUser] objectForKey:@"friends"]) {
		[followers addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [[dict objectForKey:@"user"] objectForKey:@"id"],
																	@"username"	: [[dict objectForKey:@"user"] objectForKey:@"username"],
																	@"img_url"	: [[dict objectForKey:@"user"] objectForKey:@"avatar_url"]}]];
		
	}
	
	return ([followers sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]);
}

+ (void)addFollower:(NSDictionary *)follower {
	NSMutableDictionary *dict = [[HONAppDelegate infoForUser] mutableCopy];
	NSMutableArray *friends = [[dict objectForKey:@"friends"] mutableCopy];
	
	[friends addObject:follower];
	[dict setObject:friends forKey:@"friends"];
	
	[HONAppDelegate writeUserInfo:[dict copy]];
}

+ (void)writeFollowers:(NSArray *)followers {
	NSMutableDictionary *userInfo = [[HONAppDelegate infoForUser] mutableCopy];
	[userInfo setObject:followers forKey:@"friends"];
	[HONAppDelegate writeUserInfo:[userInfo copy]];
}

+ (BOOL)isFollowedByUser:(int)userID {
	BOOL isFollowed = NO;
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != userID) {
		for (HONTrivialUserVO *vo in [HONAppDelegate followersListWithRefresh:NO]) {
			if (vo.userID == userID) {
				isFollowed = YES;
				break;
			}
		}
	}
	
	return (isFollowed);
}

+ (NSArray *)followingListWithRefresh:(BOOL)isRefresh {
	NSMutableArray *following = [NSMutableArray array];
	
	if (isRefresh) {
		[[HONAPICaller sharedInstance] retrieveFollowingUsersForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
			[HONAppDelegate writeFollowingList:(NSArray *)result];
		}];
	}
	
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"following"]) {
		[following addObject:[HONTrivialUserVO userWithDictionary:@{@"id"		: [[dict objectForKey:@"user"] objectForKey:@"id"],
																	@"username"	: [[dict objectForKey:@"user"] objectForKey:@"username"],
																	@"img_url"	: [[dict objectForKey:@"user"] objectForKey:@"avatar_url"]}]];
	}
	
	return ([NSArray arrayWithArray:[following sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]]);
}

+ (void)addFollowingToList:(NSDictionary *)followingUser {
	NSMutableArray *friends = [[[NSUserDefaults standardUserDefaults] objectForKey:@"following"] mutableCopy];
	[friends addObject:followingUser];
	
	[[NSUserDefaults standardUserDefaults] setObject:[friends copy] forKey:@"following"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeFollowingList:(NSArray *)followingUsers {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"following"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"following"];
	
	[[NSUserDefaults standardUserDefaults] setObject:followingUsers forKey:@"following"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isFollowingUser:(int)userID {
	BOOL isFollowing = NO;
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != userID) {
		for (HONTrivialUserVO *vo in [HONAppDelegate followingListWithRefresh:NO]) {
			if (vo.userID == userID) {
				isFollowing = YES;
				break;
			}
		}
	}
	
	return (isFollowing);
}


+ (CGFloat)compressJPEGPercentage {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"jpeg_compress"] floatValue]);
}

+ (NSArray *)colorsForOverlayTints {
	NSMutableArray *overlayTints = [NSMutableArray arrayWithCapacity:[[[NSUserDefaults standardUserDefaults] objectForKey:@"overlay_tint_rbgas"] count]];
	for (NSArray *rgba in [[NSUserDefaults standardUserDefaults] objectForKey:@"overlay_tint_rbgas"])
		[overlayTints addObject:[UIColor colorWithRed:[[rgba objectAtIndex:0] floatValue] green:[[rgba objectAtIndex:1] floatValue] blue:[[rgba objectAtIndex:2] floatValue] alpha:[[rgba objectAtIndex:3] floatValue]]];
	
	return ([overlayTints copy]);
}


+ (UIViewController *)appTabBarController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}

- (void)changeTabToIndex:(NSNumber *)selectedIndex {
	self.tabBarController.selectedIndex = [selectedIndex intValue];
}

+ (BOOL)hasNetwork {
	[[Reachability reachabilityForInternetConnection] startNotifier];
	NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	
	return !(networkStatus == NotReachable);
}

+ (BOOL)canPingAPIServer {
	return (!([[Reachability reachabilityWithHostName:[[[HONAppDelegate apiServerPath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus] == NotReachable));
}


+ (BOOL)canPingConfigServer {
	//	struct sockaddr_in address;
	//	address.sin_len = sizeof(address);
	//	address.sin_family = AF_INET;
	//	address.sin_port = htons(80);
	//	address.sin_addr.s_addr = inet_addr(kConfigURL);
	//
	//	Reachability *reachability = [Reachability reachabilityWithAddress:&address];
	
	//return (!([[Reachability reachabilityWithAddress:kConfigURL] currentReachabilityStatus] == NotReachable));
	return (YES);
}

+ (BOOL)isValidEmail:(NSString *)checkString {
	BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	
	NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";
	NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", (stricterFilter) ? stricterFilterString : laxString];
	
	return ([emailTest evaluateWithObject:checkString]);
}


+ (NSString *)timeSinceDate:(NSDate *)date {
	NSString *timeSince = @"";
	
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	int secs = [[utcDate dateByAddingTimeInterval:0] timeIntervalSinceDate:date];
	int mins = secs / 60;
	int hours = mins / 60;
	int days = hours / 24;
	
	//NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
	//NSLog(@"[%d][%d][%d][%d]", days, hours, mins, secs);
	
	if (days > 0) {
		//timeSince = [NSString stringWithFormat:@"%d day", days];
		timeSince = [[[@"" stringFromInt:days] stringByAppendingString:@" day"] stringByAppendingString:(days != 1) ? @"s" : @""];
		
	} else {
		if (hours > 0)
			timeSince = [[[@"" stringFromInt:hours] stringByAppendingString:@" hr"] stringByAppendingString:(hours != 1) ? @"s" : @""];
		
		else {
			if (mins > 0)
				timeSince = [[[@"" stringFromInt:mins] stringByAppendingString:@" min"] stringByAppendingString:(mins != 1) ? @"s" : @""];
			
			else
				timeSince = [[[@"" stringFromInt:secs] stringByAppendingString:@" sec"] stringByAppendingString:(secs != 1) ? @"s" : @""];
		}
	}
	
	timeSince = [timeSince stringByAppendingString:@" ago"];
	
	//NSLog(@"UTC:[%@] TIME SINCE:[%@]VAL:[%@] SECS:[%d]", [utcFormatter stringFromDate:utcDate], timeSince, [timeSince substringToIndex:[timeSince length] - 1], secs);
	if ([[timeSince substringToIndex:[timeSince length] - 1] intValue] <= 0)
		timeSince = @"just now";
	
	return (timeSince);
}


+ (NSString *)cleanImagePrefixURL:(NSString *)imageURL {
	NSMutableString *imagePrefix = [imageURL mutableCopy];
	
	[imagePrefix replaceOccurrencesOfString:[kSnapThumbSuffix substringToIndex:[kSnapThumbSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:[kSnapMediumSuffix substringToIndex:[kSnapMediumSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:[kSnapLargeSuffix substringToIndex:[kSnapLargeSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:@"_o" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:@".jpg" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	[imagePrefix replaceOccurrencesOfString:@".png" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
	
	return ([imagePrefix copy]);
}

+ (NSDictionary *)parseQueryString:(NSString *)queryString {
	NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
	for (NSString *pair in [queryString componentsSeparatedByString:@"&"]) {
		NSArray *kv = [pair componentsSeparatedByString:@"="];
		NSString *val = [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		params[kv[0]] = val;
	}
	
	return (params);
}


#pragma mark - Data Calls
- (void)_retrieveConfigJSON {
	[[HONAPICaller sharedInstance] retreiveBootConfigWithEpoch:(int)[[NSDate date] timeIntervalSince1970] completion:^(NSObject *result) {
		NSDictionary *dict = (NSDictionary *)result;
		
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"appstore_id"] forKey:@"appstore_id"];
		[[NSUserDefaults standardUserDefaults] setObject:[[dict objectForKey:@"endpts"] objectForKey:kAPIHost] forKey:@"server_api"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"service_url"] forKey:@"service_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"timeout_interval"] forKey:@"timeout_interval"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"twilio_sms"] forKey:@"twilio_sms"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"splash_image"] forKey:@"splash_image"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"share_templates"] forKey:@"share_templates"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"kik_card"] forKey:@"kik_card"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"verify_copy"] forKey:@"verify_copy"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"share_url"] forKey:@"share_url"];
		[[NSUserDefaults standardUserDefaults] setObject:NSStringFromRange(NSMakeRange([[[dict objectForKey:@"image_queue"] objectAtIndex:0] intValue], [[[dict objectForKey:@"image_queue"] objectAtIndex:1] intValue])) forKey:@"image_queue"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"min_age"] forKey:@"min_age"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"min_luminosity"] forKey:@"min_luminosity"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"jpeg_compress"] forKey:@"jpeg_compress"];
		[[NSUserDefaults standardUserDefaults] setObject:[self _colorsFromJSON:[dict objectForKey:@"overlay_tint_rbgas"]] forKey:@"overlay_tint_rbgas"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"filter_vals"] forKey:@"filter_vals"];
		[[NSUserDefaults standardUserDefaults] setObject:@[[dict objectForKey:@"free_emotions"],
														   [dict objectForKey:@"paid_emotions"]] forKey:@"emotions"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"stickers"] forKey:@"stickers"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"subject_formats"] forKey:@"subject_formats"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"search_users"] forKey:@"search_users"];
		[[NSUserDefaults standardUserDefaults] setObject:[dict objectForKey:@"switches"] forKey:@"switches"];
		[[NSUserDefaults standardUserDefaults] setObject:@{@"avatars"		: [[dict objectForKey:@"s3_buckets"] objectForKey:@"avatars"],
														   @"banners"		: [[dict objectForKey:@"s3_buckets"] objectForKey:@"banners"],
														   @"challenges"	: [[dict objectForKey:@"s3_buckets"] objectForKey:@"challenges"],
														   @"emoticons"		: [[dict objectForKey:@"s3_buckets"] objectForKey:@"emoticons"]} forKey:@"s3_buckets"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[[dict objectForKey:@"share_formats"] objectForKey:@"sheet_title"] forKey:@"share_title"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@{@"sms"		: [[dict objectForKey:@"invite_formats"] objectForKey:@"sms"],
														   @"email"		: [[dict objectForKey:@"invite_formats"] objectForKey:@"email"]} forKey:@"invite_formats"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@{@"instagram"	: [[dict objectForKey:@"share_formats"] objectForKey:@"instagram"],
														   @"twitter"	: [[dict objectForKey:@"share_formats"] objectForKey:@"twitter"],
														   @"facebook"	: [[dict objectForKey:@"share_formats"] objectForKey:@"facebook"],
														   @"sms"		: [[dict objectForKey:@"share_formats"] objectForKey:@"sms"],
														   @"email"		: [[dict objectForKey:@"share_formats"] objectForKey:@"email"]} forKey:@"share_formats"];
		
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		
		NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
		
		
		if ([[[dict objectForKey:@"boot_alert"] objectForKey:@"enabled"] isEqualToString:@"Y"])
			[self _showOKAlert:[[dict objectForKey:@"boot_alert"] objectForKey:@"title"] withMessage:[[dict objectForKey:@"boot_alert"] objectForKey:@"message"]];
		
		
		[self _writeShareTemplates];
		[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsCloudFront], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"default_avatar"];
		[self _registerUser];
		
		if (_isFromBackground) {
			NSString *notificationName = @"";
			switch ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue]) {
				case 0:
					notificationName = @"REFRESH_CONTACTS_TAB";
					break;
					
				case 1:
					notificationName = @"REFRESH_CLUBS_TAB";
					break;
					
//				case 2:
//					notificationName = @"REFRESH_ALERTS_TAB";
//					break;
					
				case 2:
					notificationName = @"REFRESH_VERIFY_TAB";
					break;
					
				default:
					notificationName = @"REFRESH_ALL_TABS";
					break;
			}
			
			NSLog(@"REFRESHING:[%@]", notificationName);
			[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
			_isFromBackground = NO;
		}
	}];
}

- (void)_registerUser {
	[[HONAPICaller sharedInstance] registerNewUserWithCompletion:^(NSObject *result){
		if ([(NSDictionary *)result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			[HONImagingDepictor writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			
			[self _enableNotifications:(![[HONAppDelegate deviceToken] isEqualToString:[[NSString stringWithFormat:@"%064d", 0] stringByReplacingOccurrencesOfString:@"0" withString:@"F"]])];
			
#if __IGNORE_SUSPENDED__ == 1
			[[HONAPICaller sharedInstance] retrieveFollowingUsersForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
				[HONAppDelegate writeFollowingList:(NSArray *)result];
				
				if (self.tabBarController == nil)
					[self _initTabs];
			}];
#else
			if ((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_suspended"] intValue]) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuspendedViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
				
			} else {
				[[HONAPICaller sharedInstance] retrieveFollowingUsersForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
					[HONAppDelegate writeFollowingList:(NSArray *)result];
					
					if (self.tabBarController == nil)
						[self _initTabs];
				}];
			}
#endif
		}
	}];
}

- (void)_enableNotifications:(BOOL)isEnabled {
	[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] areEnabled:isEnabled completion:^(NSObject *result) {
		if (![result isEqual:[NSNull null]])
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
	}];
}

- (void)_challengeObjectFromPush:(int)challengeID cancelNextPushes:(BOOL)isCancel {
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:challengeID igoringNextPushes:isCancel completion:^(NSObject *result){
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:(NSDictionary *)result]]];
		[navigationController setNavigationBarHidden:YES];
		[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
	}];
}

- (BOOL)handleKikAPIData:(KikAPIData *)data {
	if (data == nil)
		return (NO);
	
	if (data.type == KikAPIDataTypeNotKik)
		return (NO);
	
	if (data.type == KikAPIDataTypePick)
		_currentConversationID = data.conversationID;
	
	else {
//		[self.viewController loadFromURI:data.message.fileUrl];
		_currentConversationID = data.conversationID;
	}
	
	return (YES);
}


#pragma mark - Notifications
- (void)_showShareShelf:(NSNotification *)notification {
	_shareInfo = [notification object];
	
	NSLog(@"_showShareShelf:[%@]", _shareInfo);
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"share_title"]
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Kik", @"Instagram", @"Twitter", @"Facebook", @"SMS", @"Email", @"Copy link", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:((UIViewController *)[_shareInfo objectForKey:@"view_controller"]).view];
}

- (void)_playOverlayAnimation:(NSNotification *)notification {
	UIImageView *animationImageView = [notification object];
	animationImageView.frame = CGRectOffset(animationImageView.frame, ([UIScreen mainScreen].bounds.size.width - animationImageView.frame.size.width) * 0.5, ([UIScreen mainScreen].bounds.size.height - animationImageView.frame.size.height) * 0.5);
	[self.window addSubview:animationImageView];
	
//	animationImageView.layer.shadowColor = [[UIColor whiteColor] CGColor];
//	animationImageView.layer.shadowRadius = 4.0f;
//	animationImageView.layer.shadowOpacity = 0.9;
//	animationImageView.layer.shadowOffset = CGSizeZero;
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		animationImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[animationImageView removeFromSuperview];
	}];
}

//- (void)_toggleStatusBarTint:(NSNotification *)notification {
//	BOOL willFadeIn = ([[notification object] isEqualToString:@"YES"]);
//	
//	[UIView animateWithDuration:0.33
//					 animations:^(void) {_statusBarOverlayView.alpha = (int)willFadeIn;}
//					 completion:^(BOOL finished) {}];
//}


#pragma mark - UI Presentation
- (void)_showOKAlert:(NSString *)title withMessage:(NSString *)message {
	[[[UIAlertView alloc] initWithTitle:title
								message:message
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_styleUIAppearance {
	/*NSShadow *shadow = [[HONMainScreenOverseer sharedInstance] orthodoxUIShadowAttribute];//[NSShadow new];*/
//	[shadow setShadowColor:[UIColor clearColor]];
//	[shadow setShadowOffset:CGSizeZero];
	
	/*
	if ([[HONDeviceIntrinsics sharedInstance] isIOS7])
		[[UINavigationBar appearance] setBarTintColor:[[HONColorAuthority sharedInstance] honBlueTextColor]];

	else
		[[UINavigationBar appearance] setTintColor:[[HONColorAuthority sharedInstance] honBlueTextColor]];
	*/
//	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header_modal"] forBarMetrics:UIBarMetricsDefault];
//	[[UINavigationBar appearance] setBackgroundColor:[UIColor colorWithRed:0.008 green:0.373 blue:0.914 alpha:1.0]];
//	[[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	
	/*
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName		: [UIColor whiteColor],
														NSShadowAttributeName				: shadow,
														NSFontAttributeName				: [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:22]}];
	
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName	: [UIColor whiteColor],
														NSShadowAttributeName			: shadow,
														   NSFontAttributeName				: [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17]} forState:UIControlStateNormal];
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName	: [UIColor whiteColor],
														   NSShadowAttributeName			: shadow,
														   NSFontAttributeName				: [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17]} forState:UIControlStateHighlighted];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButton_nonActive"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButton_Active"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];

	if ([[HONDeviceIntrinsics sharedInstance] isIOS7])
		[[UITabBar appearance] setBarTintColor:[UIColor clearColor]];
	
	else
		[[UITabBar appearance] setTintColor:[UIColor clearColor]];
	 */
	
//	[[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
	/*[[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabMenuBackground"]];*/
	/*
	if ([[HONDeviceIntrinsics sharedInstance] isIOS7])
		[[UIToolbar appearance] setBarTintColor:[UIColor clearColor]];
	
	else
		[[UIToolbar appearance] setTintColor:[UIColor clearColor]];
	
	[[UIToolbar appearance] setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
	[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"toolbarBG"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[[UIToolbar appearance] setBarStyle:UIBarStyleDefault];
	*/
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_isFromBackground = NO;
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	if (launchOptions) {
		NSLog(@"\t—//]> [%@ didFinishLaunchingWithOptions] (%@)", self.class, launchOptions);
		[[HONMainScreenOverseer sharedInstance] promptWithAlertView:[[UIAlertView alloc] initWithTitle:@"¡Message Recieved!"
																							   message:[[NSString string] stringFromDictionary:launchOptions]
																							  delegate:nil
																					 cancelButtonTitle:@"OK"
																					 otherButtonTitles:nil]];
	}
	
	
#if __FORCE_REGISTER__ == 1
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
	[[NSUserDefaults standardUserDefaults] synchronize];
#endif
	
	[self _styleUIAppearance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showShareShelf:) name:@"SHOW_SHARE_SHELF" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playOverlayAnimation:) name:@"PLAY_OVERLAY_ANIMATION" object:nil];
	

	[self _establishUserDefaults];
	
	if ([HONAppDelegate hasNetwork]) {
		if (![HONAppDelegate canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		}
		
		[HONAppDelegate incTotalForCounter:@"boot"];
		
		[self _initThirdPartySDKs];
		
//		int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"]] / 86400;
//		if ([HONAppDelegate totalForCounter:@"boot"] == 5) {
//			UIAlertView *alertView = [[UIAlertView alloc]
//									  initWithTitle:[NSString stringWithFormat:@"Rate %@", [HONAppDelegate brandedAppName]]
//									  message:[NSString stringWithFormat:@"Why not rate %@ in the app store!", [HONAppDelegate brandedAppName]]
//									  delegate:self
//									  cancelButtonTitle:nil
//									  otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
//			[alertView setTag:2];
//			[alertView show];
//		}
		
		[[HONAnalyticsParams sharedInstance] trackEvent:@"App Boot"
										 withProperties:@{@"boots"	: [@"" stringFromInt:[HONAppDelegate totalForCounter:@"boot"]]}];
		
		self.launchImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		self.launchImageView.image = [UIImage imageNamed:@"mainBG"];
		[self.window addSubview:self.launchImageView];
		[self.window makeKeyAndVisible];
		
//		[self _initUrbanAirship];
		[self _retrieveConfigJSON];
		
		
//		NSLog(@"ADID:[%@]\nVID:[%@]", [[HONDeviceTraits sharedInstance] advertisingIdentifierWithoutSeperators:YES], [HONAppDelegate identifierForVendorWithoutSeperators:YES]);
		
	} else {
		[self _showOKAlert:@"No Network Connection"
			   withMessage:@"This app requires a network connection to work."];
	}
	
#ifdef FONTS
	[self _showFonts];
#endif
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[HONAppDelegate incTotalForCounter:@"background"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
	
	NSString *duration = @"00:00:00";
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
		
		int secs = [[[NSDate new] dateByAddingTimeInterval:0] timeIntervalSinceDate:[dateFormatter dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]]];
		int mins = secs / 60;
		int hours = mins / 60;
		
		duration = [NSString stringWithFormat:@"%2f:%2f:%2f", (float)hours, (float)mins, (float)secs];
	}
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App Entering Background"
									 withProperties:@{@"duration"	: duration}];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBAppEvents activateApp];
	//[[UAPush shared] resetBadge];
	
//	Chartboost *chartboost = [Chartboost sharedChartboost];
//    chartboost.appId = kChartboostAppID;
//    chartboost.appSignature = kChartboostAppSignature;
//    chartboost.delegate = self;
//	
//    [chartboost startSession];
//    [chartboost showInterstitial];
	
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"active_date"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[dateFormatter stringFromDate:[NSDate new]] forKey:@"active_date"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (_isFromBackground) {
		if ([HONAppDelegate hasNetwork]) {
			[[HONAnalyticsParams sharedInstance] trackEvent:@"App Leaving Background"];
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
				if ([HONAppDelegate totalForCounter:@"background"] == 2 && [HONAppDelegate switchEnabledForKey:@"background_invite"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Invite friends?"
																		message:@"Get more followers now, tap OK."
																	   delegate:self
															  cancelButtonTitle:@"No"
															  otherButtonTitles:@"OK", nil];
					[alertView setTag:3];
					[alertView show];
				}
				
				if ([HONAppDelegate totalForCounter:@"background"] == 4 && [HONAppDelegate switchEnabledForKey:@"background_share"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Share Selfieclub?"
																		message:@""
																	   delegate:self
															  cancelButtonTitle:@"Cancel"
															  otherButtonTitles:@"OK", nil];
					[alertView setTag:4];
					[alertView show];
				}
			}
			
			
			if (![HONAppDelegate canPingConfigServer]) {
				[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
					   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
				
			} else
				[self _retrieveConfigJSON];
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[FBSession.activeSession close];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_TERMINATING" object:nil];
	
	NSString *duration = @"00:00:00";
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
		
		int secs = [[[NSDate new] dateByAddingTimeInterval:0] timeIntervalSinceDate:[dateFormatter dateFromString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]]];
		int mins = secs / 60;
		int hours = mins / 60;
		
		duration = [NSString stringWithFormat:@"%2f:%2f:%2f", (float)hours, (float)mins, (float)secs];
	}
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App Terminating"
									 withProperties:@{@"duration"	: duration}];
	
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"application:openURL:[%@]", [url absoluteString]);
	
	if (!url)
		return (NO);
	
	NSString *protocol = [[url absoluteString] substringToIndex:[[url absoluteString] rangeOfString:@"://"].location];
	if ([protocol isEqualToString:@"selfieclub"]) {
		NSRange range = [[url absoluteString] rangeOfString:@"://"];
		NSArray *path = [[[url absoluteString] substringFromIndex:range.location + range.length] componentsSeparatedByString:@"/"];
		NSLog(@"PATH:[%@]", path);
		
		if ([[path objectAtIndex:0] isEqualToString:@"profile"]) {
			dispatch_time_t dispatchTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
			dispatch_after(dispatchTime, dispatch_get_main_queue(), ^(void){
				[self.window.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:[[path objectAtIndex:1] intValue]]] animated:YES completion:nil];
			});
		
		} else if ([[path objectAtIndex:0] isEqualToString:@"invite"]) {
			[self.window.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]] animated:YES completion:nil];
		
		} else if ([[path objectAtIndex:0] isEqualToString:@"create"]) {
			if ([[path objectAtIndex:1] isEqualToString:@"selfie"])
				[self.window.rootViewController presentViewController:[[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initAsNewChallenge]] animated:YES completion:nil];
		}
		
		return (YES);
	
	} else {
		return ([self handleKikAPIData:[KikAPIClient handleOpenURL:url sourceApplication:sourceApplication annotation:annotation]]);
		return ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication]);
	}
}



- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"\t—//]> [%@ didRegisterForRemoteNotificationsWithDeviceToken] (%@)", self.class, deviceID);//[deviceToken description]);
	[HONAppDelegate writeDeviceToken:deviceID];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
	NSLog(@"\t—//]> [%@ didFailToRegisterForRemoteNotificationsWithError] (%@)", self.class, error);
	
	[HONAppDelegate writeDeviceToken:[[NSString stringWithFormat:@"%064d", 0] stringByReplacingOccurrencesOfString:@"0" withString:@"F"]];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"\t—//]> [%@ didReceiveRemoteNotification] (%@)", self.class, userInfo);
	
	application.applicationIconBadgeNumber = 0;
	
	
	[[HONMainScreenOverseer sharedInstance] promptWithAlertView:[[UIAlertView alloc] initWithTitle:@"¡Message Recieved!"
																						   message:[@"" stringFromDictionary:userInfo]
																						  delegate:nil
																				 cancelButtonTitle:@"OK"
																						otherButtonTitles:nil]];
}




/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[UAPush shared] registerDeviceToken:deviceToken];
	
	Mixpanel *mixpanel = [Mixpanel sharedInstance];
	[mixpanel identify:[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:NO]];
	[mixpanel.people addPushDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	
//	if ([HONAppDelegate apiServerPath] != nil && [HONAppDelegate infoForUser] != nil)// && [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"N"])
//		[self _enableNotifications:YES];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", error.description);
	
	NSString *holderToken = [[NSString stringWithFormat:@"%064d", 0] stringByReplacingOccurrencesOfString:@"0" withString:@"F"];
	
	Mixpanel *mixpanel = [Mixpanel sharedInstance];
	[mixpanel identify:[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:NO]];
	[mixpanel.people addPushDeviceToken:[holderToken dataUsingEncoding:NSUTF8StringEncoding]];
	
	[HONAppDelegate writeDeviceToken:holderToken];
	
//	if ([HONAppDelegate apiServerPath] != nil && [HONAppDelegate infoForUser] != nil)// && [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"])
//		[self _enableNotifications:NO];
}
 
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UALOG(@"Received remote notification: %@", userInfo);
	
	[[UAPush shared] handleNotification:userInfo applicationState:application.applicationState];
	
	if (application.applicationState != UIApplicationStateBackground)
		[[UAPush shared] resetBadge]; // zero badge after push received
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
	
    // Reset the badge after a push is received in a active or inactive state
	if (application.applicationState != UIApplicationStateBackground)
		[[UAPush shared] resetBadge];
	
	completionHandler(UIBackgroundFetchResultNoData);
}
*/


#pragma mark - Startup Operations
- (void)_initTabs {
	NSLog(@"[|/._initTabs|/:_");
	NSArray *navigationControllers = @[[[UINavigationController alloc] initWithRootViewController:[[HONContactsViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONClubsTimelineViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] init]]];
	
	
	for (UINavigationController *navigationController in navigationControllers) {
		[navigationController setNavigationBarHidden:YES animated:NO];
		
		if ([navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)])
			[navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
	}
	
	
	self.tabBarController = [[HONTabBarController alloc] init];
	self.tabBarController.viewControllers = navigationControllers;
	self.tabBarController.delegate = self;
	
	self.window.rootViewController = self.tabBarController;
	self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	self.window.backgroundColor = [UIColor blackColor];
}

- (void)_establishUserDefaults {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"is_deactivated"])
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"is_deactivated"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"votes"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"])
		[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"local_challenges"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"upvotes"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"upvotes"];
	
	[HONAppDelegate resetTotals];
	
	for (int i=-2; i<=0; i++)
		[[NSUserDefaults standardUserDefaults] setObject:[[HONChallengeAssistant sharedInstance] emptyChallengeDictionaryWithID:i] forKey:[NSString stringWithFormat:@"empty_challenge_%d", i]];
		
#if __FORCE_REGISTER__ == 1
	[HONAppDelegate resetTotals];
	
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"upvotes"];
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
#endif
	
#if __RESET_TOTALS__ == 1
	[HONAppDelegate resetTotals];
#endif
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

//- (void)_initUrbanAirship {
//	/** This prevents the UA Library from registering with UIApplication by default. This will allow
//	 ** you to prompt your users at a later time. This gives your app the opportunity to explain the
//	 ** benefits of push or allows users to turn it on explicitly in a settings screen.
//	 **
//	 ** If you just want everyone to immediately be prompted for push, you can leave this line out.
//	 **/
////	[UAPush setDefaultPushEnabledValue:NO];
//	
//	/** Set log level for debugging config loading (optional) - it will be set to the value in the loaded config upon takeOff **/
//	[UAirship setLogLevel:UALogLevelNone];
//	
//	/** Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com or set runtime properties here. **/
//	UAConfig *config = [UAConfig defaultConfig];
//	
//	/** You can then programatically override the plist values, etc.: **/
////	config.developmentAppKey = @"YourKey";
//	
//	/** Call takeOff (which creates the UAirship singleton) **/
//	[UAirship takeOff:config];
//	
//	/** Print out the application configuration for debugging (optional) **/
//	UA_LDEBUG(@"Config:\n%@", [config description]);
//	
//	/** Set the icon badge to zero on startup (optional) **/
//	[[UAPush shared] resetBadge];
//	
//	/** Set the notification types required for the app (optional).
//	 ** With the default value of push set to no,
//	 ** UAPush will record the desired remote notification types, but not register for
//	 ** push notifications as mentioned above. When push is enabled at a later time, the registration
//	 ** will occur normally. This value defaults to badge, alert and sound, so it's only necessary to
//	 ** set it if you want to add or remove types.
//	 **/
//	[UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
//	[UAPush shared].pushNotificationDelegate = self;
//	
//	NSMutableArray *tags = [NSMutableArray arrayWithArray:[UATagUtils createTags:(UATagTypeTimeZone | UATagTypeLanguage | UATagTypeCountry)]];
//	[tags addObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
//	[tags addObject:[[HONDeviceIntrinsics sharedInstance] modelName]];
//	[tags addObject:[[UIDevice currentDevice] systemVersion]];
//	
//	[UAPush shared].tags = [NSArray arrayWithArray:tags];
//	[[UAPush shared] updateRegistration];
//	
//	[HONAppDelegate writeDeviceToken:@""];
//}

- (void)_initThirdPartySDKs {
#if __APPSTORE_BUILD__ == 0
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppToken delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];
#endif
	
	[Mixpanel sharedInstanceWithToken:kMixPanelToken];
	
	
	TSConfig *config = [TSConfig configWithDefaults];
	config.collectWifiMac = NO;
	config.idfa = [[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:NO];
	//config.odin1 = @"<ODIN-1 value goes here>";
	//config.openUdid = @"<OpenUDID value goes here>";
	//config.secureUdid = @"<SecureUDID value goes here>";
	[TSTapstream createWithAccountName:@"volley"
					   developerSecret:kTapStreamSecretKey
								config:config];
	
	//TSTapstream *tapstream = [TSTapstream instance];
	
//	[Tapjoy requestTapjoyConnect:kTapjoyAppID
//					   secretKey:kTapjoyAppSecretKey
//						 options:@{TJC_OPTION_ENABLE_LOGGING	: @(YES)}];
	
//	[KikAPIClient registerAsKikPluginWithAppID:@"com.builtinmenlo.selfieclub.kik"
//							   withHomepageURI:@"http://www.builtinmenlo.com"
//								  addAppButton:YES];
}

- (void)_writeShareTemplates {
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"share_templates"]) {
		for (NSString *key in [dict keyEnumerator])
			[HONImagingDepictor writeImageFromWeb:[dict objectForKey:key] withUserDefaultsKey:[@"share_template-" stringByAppendingString:key]];
	}
}


#pragma mark - Data Manip
- (NSArray *)_colorsFromJSON:(NSArray *)tintJSON {
//	unsigned int outVal;
//	NSScanner* scanner = [NSScanner scannerWithString:@"0x01FFFFAB"];
//	[scanner scanHexInt:&outVal];
	
	unsigned int rDec;
	unsigned int gDec;
	unsigned int bDec;
	NSScanner *scanner;
	NSMutableArray *colors = [NSMutableArray arrayWithCapacity:[tintJSON count]];
	for (NSDictionary *dict in tintJSON) {
		scanner = [NSScanner scannerWithString:[@"0x" stringByAppendingString:[[[dict objectForKey:@"rgb"] substringFromIndex:1] substringWithRange:NSMakeRange(0, 2)]]];
		[scanner scanHexInt:&rDec];
		
		scanner = [NSScanner scannerWithString:[@"0x" stringByAppendingString:[[[dict objectForKey:@"rgb"] substringFromIndex:1] substringWithRange:NSMakeRange(2, 2)]]];
		[scanner scanHexInt:&gDec];

		scanner = [NSScanner scannerWithString:[@"0x" stringByAppendingString:[[[dict objectForKey:@"rgb"] substringFromIndex:1] substringWithRange:NSMakeRange(4, 2)]]];
		[scanner scanHexInt:&bDec];
		
		[colors addObject:@[[NSNumber numberWithFloat:rDec / 255.0],
							[NSNumber numberWithFloat:gDec / 255.0],
							[NSNumber numberWithFloat:bDec / 255.0],
							[NSNumber numberWithFloat:[[dict objectForKey:@"a"] floatValue]]]];
	}
	return ([colors copy]);
}


#pragma mark - UAPushNotification Delegates
- (void)receivedForegroundNotification:(NSDictionary *)notification {
	NSLog(@"receivedForegroundNotification:[%@]", notification);
	
	if ([[notification objectForKey:@"type"] intValue] == HONPushTypeUserVerified) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:@"Awesome! You have been Selfieclub Verified! Would you like to share Selfieclub with your friends?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
	
	} else {
		if ([notification objectForKey:@"user"] != nil) {
			_userID = [[notification objectForKey:@"user"] intValue];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[[notification objectForKey:@"aps"] objectForKey:@"alert"]
															   delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"OK", nil];
			[alertView setTag:6];
			[alertView show];
			
		} else
			[self _showOKAlert:@"" withMessage:[[notification objectForKey:@"aps"] objectForKey:@"alert"]];
	}
}

- (void)receivedForegroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
	NSLog(@"receivedForegroundNotification:fetchCompletionHandler:[%@]", notification);
	completionHandler(UIBackgroundFetchResultNoData);
	
	if ([[notification objectForKey:@"type"] intValue] == HONPushTypeUserVerified) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:@"Awesome! You have been Selfieclub Verified! Would you like to share Selfieclub with your friends?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
		
	} else {
		if ([notification objectForKey:@"user"] != nil) {
			_userID = [[notification objectForKey:@"user"] intValue];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[[notification objectForKey:@"aps"] objectForKey:@"alert"]
															   delegate:self
													  cancelButtonTitle:@"Cancel"
													  otherButtonTitles:@"OK", nil];
			[alertView setTag:6];
			[alertView show];
			
		} else
			[self _showOKAlert:@"" withMessage:[[notification objectForKey:@"aps"] objectForKey:@"alert"]];
	}
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification {
	NSLog(@"receivedBackgroundNotification:[%@]", notification);
}

- (void)receivedBackgroundNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
	NSLog(@"receivedBackgroundNotification:fetchCompletionHandler:[%@]", notification);
	completionHandler(UIBackgroundFetchResultNoData);
}

- (void)launchedFromNotification:(NSDictionary *)notification {
	NSLog(@"launchedFromNotification:[%@]", notification);
	
	UINavigationController *navigationController;
	
	int pushType = [[notification objectForKey:@"type"] intValue];
	if (pushType == HONPushTypeShowChallengeDetails)
		[self _challengeObjectFromPush:[[notification objectForKey:@"challenge"] intValue] cancelNextPushes:NO];
	
	else if (pushType == HONPushTypeUserVerified) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:@"Awesome! You have been Selfieclub Verified! Would you like to share Selfieclub with your friends?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
		
	} else if (pushType == HONPushTypeShowUserProfile) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:[[notification objectForKey:@"user"] intValue]]];
		
	} else if (pushType == HONPushTypeShowAddContacts) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
		
	} else if (pushType == HONPushTypeShowSettings) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
		
	} else if (pushType == HONPushTypeShowChallengeDetailsIgnoringPushes) {
		[self _challengeObjectFromPush:[[notification objectForKey:@"challenge"] intValue] cancelNextPushes:YES];
	
	} else {
		if ([notification objectForKey:@"user"] != nil)
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:[[notification objectForKey:@"user"] intValue]]];
	}
	
	if (navigationController != nil) {
		[navigationController setNavigationBarHidden:YES];
		if ([[UIApplication sharedApplication] delegate].window.rootViewController.presentedViewController != nil) {
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
				[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
			}];
			
		} else
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
	}
}

- (void)launchedFromNotification:(NSDictionary *)notification fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
	NSLog(@"launchedFromNotification:fetchCompletionHandler:[%@]", notification);
	completionHandler(UIBackgroundFetchResultNoData);
	
	UINavigationController *navigationController;
	
	int pushType = [[notification objectForKey:@"type"] intValue];
	if (pushType == HONPushTypeShowChallengeDetails)
		[self _challengeObjectFromPush:[[notification objectForKey:@"challenge"] intValue] cancelNextPushes:NO];
	
	else if (pushType == HONPushTypeUserVerified) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
															message:@"Awesome! You have been Selfieclub Verified! Would you like to share Selfieclub with your friends?"
														   delegate:self
												  cancelButtonTitle:@"No"
												  otherButtonTitles:@"Yes", nil];
		[alertView setTag:1];
		[alertView show];
		
	} else if (pushType == HONPushTypeShowUserProfile) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:[[notification objectForKey:@"user"] intValue]]];
		
	} else if (pushType == HONPushTypeShowAddContacts) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
		
	} else if (pushType == HONPushTypeShowSettings) {
		navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
		
	} else if (pushType == HONPushTypeShowChallengeDetailsIgnoringPushes) {
		[self _challengeObjectFromPush:[[notification objectForKey:@"challenge"] intValue] cancelNextPushes:YES];
	
	} else {
		if ([notification objectForKey:@"user"] != nil)
			navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:[[notification objectForKey:@"user"] intValue]]];
	}
	
	if (navigationController != nil) {
		[navigationController setNavigationBarHidden:YES];
		if ([[UIApplication sharedApplication] delegate].window.rootViewController.presentedViewController != nil) {
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
				[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
			}];
					
		} else
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
	}
}


#pragma mark - Chartboost Delegates
- (BOOL)shouldRequestInterstitialsInFirstSession {
	return (NO);
}

- (BOOL)shouldRequestInterstitial:(NSString *)location {
	return (YES);
}

- (BOOL)shouldDisplayInterstitial:(NSString *)location {
	return (YES);
}

- (void)didDismissInterstitial:(NSString *)location {
	
}

- (void)didCloseInterstitial:(NSString *)location {
	
}

- (void)didClickInterstitial:(NSString *)location {
	
}

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
	
}


#pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	return (YES);
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//NSLog(@"didSelectViewController:[%@]", viewController);
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}


#pragma mark - AlertView delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"BUTTON:[%d]", buttonIndex);
	
	if (alertView.tag == 0)
		NSLog(@"EXIT APP");//exit(0);
	
	else if (alertView.tag == 1) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"App Notification - Verified Invite " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																									@"image"			: [HONAppDelegate avatarImage],
																									@"url"				: @"",
																									@"mp_event"			: @"App Root",
																									@"view_controller"	: self.tabBarController}];
		}
	}
	
	else if (alertView.tag == 2) {
		switch(buttonIndex) {
			case 0:
				break;
				
			case 1:
				[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				break;
				
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
				break;
		}
		
	} else if (alertView.tag == 3) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"App Backgrounding - Invite Friends " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == 4) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"App Backgrounding - Share " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
				
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																									@"image"			: [HONAppDelegate avatarImage],
																									@"url"				: @"",
																									@"mp_event"			: @"App Root",
																									@"view_controller"	: self.window.rootViewController}];
		}
		
	} else if (alertView.tag == 5) {
		switch (buttonIndex) {
			case 0:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
				break;
				
			case 1:
				break;
		}
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 6) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"App Notification - " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
				
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUserProfileViewController alloc] initWithUserID:_userID]];
			[navigationController setNavigationBarHidden:YES];
			
			if ([[UIApplication sharedApplication] delegate].window.rootViewController.presentedViewController != nil) {
				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
					[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
				}];
				
			} else
				[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[@" - Share " stringByAppendingString:(buttonIndex == HONShareSheetActionTypeKik) ? @"Kik" : (buttonIndex == HONShareSheetActionTypeInstagram) ? @"Instagram" : (buttonIndex == HONShareSheetActionTypeTwitter) ? @"Twitter" : (buttonIndex == HONShareSheetActionTypeFacebook) ? @"Facebook" : (buttonIndex == HONShareSheetActionTypeSMS) ? @"SMS" : (buttonIndex == HONShareSheetActionTypeEmail) ? @"Email" : (buttonIndex == HONShareSheetActionTypeClipboard) ? @"Link" : @"Cancel"]]];
		
		if (buttonIndex == HONShareSheetActionTypeKik) {
			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[HONAppDelegate kikCardURL]]];
			
		} else if (buttonIndex == HONShareSheetActionTypeInstagram) {
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
			[HONImagingDepictor saveForInstagram:[_shareInfo objectForKey:@"image"]
									withUsername:[[HONAppDelegate infoForUser] objectForKey:@"username"]
										  toPath:savePath];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				_documentInteractionController.UTI = @"com.instagram.exclusivegram";
				_documentInteractionController.delegate = self;
				_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[[_shareInfo objectForKey:@"caption"] objectAtIndex:0] forKey:@"InstagramCaption"];
				[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:((UIViewController *)[_shareInfo objectForKey:@"view_controller"]).view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Not Available"
											message:@"This device isn't allowed or doesn't recognize Instagram!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeTwitter) {
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
				SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
					[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[@" - Share Twitter " stringByAppendingString:(result == SLComposeViewControllerResultDone) ? @"Completed" : @"Canceled"]]];
					
					[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
				};
				
				[twitterComposeViewController setInitialText:[[_shareInfo objectForKey:@"caption"] objectAtIndex:1]];
				[twitterComposeViewController addImage:[_shareInfo objectForKey:@"image"]];
				twitterComposeViewController.completionHandler = completionBlock;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:twitterComposeViewController animated:YES completion:nil];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@""
											message:@"Cannot use Twitter from this device!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeFacebook) {
			NSString *url = ([[_shareInfo objectForKey:@"url"] rangeOfString:@"defaultAvatar"].location == NSNotFound) ? [_shareInfo objectForKey:@"url"] : @"https://s3.amazonaws.com/hotornot-banners/shareTemplate_default.png";
			NSDictionary *params = @{@"name"		: @"Selfieclub",
									 @"caption"		: [[_shareInfo objectForKey:@"caption"] objectAtIndex:2],
									 @"description"	: @"Welcome @Selfieclub members!\nPost your selfie and how you feel. Right now.\nGet \"Selfie famous\" by getting the most shoutouts!",
									 @"link"		: [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]],
									 @"picture"		: url};
			
			[FBWebDialogs presentFeedDialogModallyWithSession:nil parameters:params handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
				NSString *mpAction = @"(UNKNOWN)";
				
				if (error) {
					mpAction = @"Error";
					NSLog(@"Error publishing story.");
					
				} else {
					mpAction = @"Canceled";
					if (result == FBWebDialogResultDialogNotCompleted) {
						NSLog(@"User canceled story publishing.");
						
					} else {
						NSDictionary *urlParams = [HONAppDelegate parseQueryString:[resultURL query]];
						if (![urlParams valueForKey:@"post_id"]) {
							mpAction = @"Canceled";
							NSLog(@"User canceled story publishing.");
							
						} else {
							mpAction = @"Posted";
							NSLog(@"Posted:[%@]", [urlParams valueForKey:@"post_id"]);
							[self _showOKAlert:@"" withMessage:@"Posted to your timeline!"];
						}
					}
				}
				
				[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[NSString stringWithFormat:@" - Share Facebook (%@)", mpAction]]];
			 }];
		
		} else if (buttonIndex == HONShareSheetActionTypeSMS) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [[_shareInfo objectForKey:@"caption"] objectAtIndex:3];
				messageComposeViewController.messageComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeEmail) {
			if ([MFMailComposeViewController canSendMail]) {
				NSRange range = [[[_shareInfo objectForKey:@"caption"] objectAtIndex:4] rangeOfString:@"|"];
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				[mailComposeViewController setSubject:[[[_shareInfo objectForKey:@"caption"] objectAtIndex:4] substringToIndex:range.location]];
				[mailComposeViewController setMessageBody:[[[_shareInfo objectForKey:@"caption"] objectAtIndex:4] substringFromIndex:range.location + 1] isHTML:NO];
				mailComposeViewController.mailComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Email Error"
											message:@"Cannot send email from this device!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeClipboard) {
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [HONAppDelegate shareURL];
			
			[self _showOKAlert:@"Link Copied to Clipboard" withMessage:[HONAppDelegate shareURL]];
		}
		
		_shareInfo = nil;
	}
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Presenting DocInteraction Shelf"
									 withProperties:@{@"controller"		: [controller name]}];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Dismissing DocInteraction Shelf"
									 withProperties:@{@"controller"		: [controller name]}];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Launching DocInteraction App"
									 withProperties:@{@"controller"		: [controller name]}];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Entering DocInteraction App Foreground"
									 withProperties:@{@"controller"		: [controller name]}];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	NSString *mpAction = @"";
	switch (result) {
		case MessageComposeResultCancelled:
			mpAction = @"Canceled";
			break;
			
		case MessageComposeResultSent:
			mpAction = @"Sent";
			break;
			
		case MessageComposeResultFailed:
			mpAction = @"Failed";
			break;
			
		default:
			mpAction = @"Not Sent";
			break;
	}
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[NSString stringWithFormat:@" - Share via SMS (%@)", mpAction]]];
	[controller dismissViewControllerAnimated:YES completion:nil];
	_shareInfo = nil;
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
		
	NSString *mpAction = @"";
	switch (result) {
		case MFMailComposeResultCancelled:
			mpAction = @"Canceled";
			break;
			
		case MFMailComposeResultFailed:
			mpAction = @"Failed";
			break;
			
		case MFMailComposeResultSaved:
			mpAction = @"Saved";
			break;
			
		case MFMailComposeResultSent:
			mpAction = @"Sent";
			break;
			
		default:
			mpAction = @"Not Sent";
			break;
	}
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[NSString stringWithFormat:@" - Share via Email (%@)", mpAction]]];
	[controller dismissViewControllerAnimated:YES completion:nil];
	_shareInfo = nil;
}


#pragma mark - Debug Calls
- (void)_showFonts {
	for (NSString *familyName in [UIFont familyNames]) {
		NSLog(@"Font Family Name = %@", familyName);
		
		NSArray *names = [UIFont fontNamesForFamilyName:familyName];
		NSLog(@"Font Names = %@", names);
	}
}


#if __APPSTORE_BUILD__ == 0
#pragma mark - UpdateManager Delegates
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
//	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
//		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
	return (nil);
}
#endif
@end

