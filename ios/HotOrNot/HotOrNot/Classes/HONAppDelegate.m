//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AddressBook/AddressBook.h>
#import <AdSupport/AdSupport.h>
#import <AVFoundation/AVFoundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Foundation/Foundation.h>
#import <HockeySDK/HockeySDK.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <sys/utsname.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "MBProgressHUD.h"
#import "KikAPI.h"
#import "Reachability.h"
#import "TSTapstream.h"
#import "UAConfig.h"
#import "UAirship.h"
#import "UAPush.h"
#import "UAAnalytics.h"


#import "HONAppDelegate.h"
#import "HONTabBarController.h"
#import "HONVerifyViewController.h"
#import "HONTimelineViewController.h"
#import "HONExploreViewController.h"
#import "HONImagePickerViewController.h"
#import "HONChallengeVO.h"
#import "HONEmotionVO.h"
#import "HONUserVO.h"
#import "HONUsernameViewController.h"
#import "HONSearchViewController.h"
#import "HONImagingDepictor.h"
#import "HONChallengeDetailsViewController.h"
#import "HONAddContactsViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSettingsViewController.h"
#import "HONSuspendedViewController.h"


#if __DEV_BUILD___ == 1
NSString * const kConfigURL = @"http://stage.letsvolley.com/hotornot";//54.221.205.30";
NSString * const kConfigJSON = @"boot.json";
NSString * const kAPIHost = @"data_api-dev";
NSString * const kMixPanelToken = @"c7bf64584c01bca092e204d95414985f"; // Dev
#else
NSString * const kConfigURL = @"http://config.letsvolley.com/hotornot";
NSString * const kConfigJSON = @"boot_200.json";
NSString * const kAPIHost = @"data_api";
NSString * const kMixPanelToken = @"7de852844068f082ddfeaf43d96e998e"; // Volley 1.2.3/4
#endif


//NSString * const kMixPanelToken = @"d93069ad5b368c367c3adc020cce8021"; // Focus Group I
//NSString * const kMixPanelToken = @"8ae70817a3d885455f940ff261657ec7"; // Soft Launch I
//NSString * const kMixPanelToken = @"de3e67b68e6b8bf0344ca58573733ee5"; // Soft Launch II
NSString * const kFacebookAppID = @"600550136636754";
NSString * const kTestFlightAppToken = @"139f9073-a4d0-4ecd-9bb8-462a10380218";
NSString * const kHockeyAppToken = @"b784de80afa5c65803e0f3d8035cd725";

//api endpts
NSString * const kAPIChallenges = @"Challenges.php";
NSString * const kAPIComments = @"Comments.php";
NSString * const kAPIDiscover = @"Discover.php";
NSString * const kAPIPopular = @"Popular.php";
NSString * const kAPISearch = @"Search.php";
NSString * const kAPIUsers = @"Users.php";
NSString * const kAPIVotes = @"Votes.php";
NSString * const kAPIGetFriends = @"social/getfriends";
NSString * const kAPIGetSubscribees = @"users/getsubscribees";
NSString * const kAPIAddFriend = @"social/addfriend";
NSString * const kAPIRemoveFriend = @"social/removefriend";
NSString * const kAPISMSInvites = @"g/smsinvites";
NSString * const kAPIEmailInvites = @"g/emailinvites";
NSString * const kAPITumblrLogin = @"users/invitetumblr";
NSString * const kAPIEmailVerify = @"users/verifyemail";
NSString * const kAPIPhoneVerify = @"users/verifyphone";
NSString * const kAPIEmailContacts = @"users/ffemail";
NSString * const kAPIChallengeObject = @"challenges/get";
NSString * const kAPIGetPublicMessages = @"challenges/getpublic";
NSString * const kAPIGetPrivateMessages = @"challenges/getprivate";
NSString * const kAPISetUserAgeGroup = @"users/setage";
NSString * const kAPICheckNameAndEmail = @"users/checkNameAndEmail";
NSString * const kAPIUsersFirstRunComplete = @"users/firstruncomplete";
NSString * const kAPIJoinChallenge = @"challenges/join";
NSString * const kAPIGetVerifyList = @"challenges/getVerifyList";
NSString * const kAPIMissingImage = @"challenges/missingimage";
NSString * const kAPIProcessChallengeImage = @"challenges/processimage";
NSString * const kAPIProcessUserImage = @"users/processimage";
NSString * const kAPISuspendedAccount = @"users/suspendedaccount";


// view heights
const CGFloat kNavBarHeaderHeight = 77.0f;
const CGFloat kSearchHeaderHeight = 49.0f;
const CGFloat kOrthodoxTableHeaderHeight = 31.0f;
const CGFloat kOrthodoxTableCellHeight = 63.0f;
const CGFloat kHeroVolleyTableCellHeight = 370.0f;

// snap params
const CGFloat kMinLuminosity = 0.33;
const CGFloat kSnapRatio = 1.33333333f;
const CGFloat kSnapJPEGCompress = 0.400f;

// animation params
const CGFloat kHUDTime = 2.33f;
const CGFloat kHUDErrorTime = 1.5f;
const CGFloat kProfileTime = 0.25f;

// image sizes
const CGSize kSnapThumbSize = {80.0f, 80.0f};
const CGSize kSnapMediumSize = {160.0f, 160.0f};
const CGSize kSnapLargeSize = {320.0f, 568.0f};
const CGFloat kAvatarDim = 200.0f;

const BOOL kIsImageCacheEnabled = YES;
NSString * const kTwilioSMS = @"6475577873";

#if __DEV_BUILD___ == 0
@interface HONAppDelegate()
#else
@interface HONAppDelegate() <BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>
#endif
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) AVAudioPlayer *mp3Player;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONSearchViewController *searchViewController;
@property (nonatomic, strong) UIActivityViewController *activityViewController;
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) NSTimer *userTimer;
@property (nonatomic) int challengeID;
@end

@implementation HONAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;

+ (NSMutableString *)hmacForKey:(NSString *)key AndData:(NSString *)data{
    const char *cKey  = [key cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cData = [data cStringUsingEncoding:NSASCIIStringEncoding];
    unsigned char cHMAC[CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
    
    NSMutableString *result = [NSMutableString string];
    for (int i = 0; i < sizeof cHMAC ; i++){
        [result appendFormat:@"%02hhx", cHMAC[i]];
    }
    return result;
}

+ (NSMutableString *)hmacToken
{
    NSMutableString *hmac = [NSMutableString stringWithString:@"unknown"];
    NSMutableString *data = [NSMutableString stringWithString:[HONAppDelegate deviceToken]];
	if( data != nil ){
	    [data appendString:@"+"];
	    [data appendString:[HONAppDelegate advertisingIdentifier]];
	    NSString *key = @"YARJSuo6/r47LczzWjUx/T8ioAJpUKdI/ZshlTUP8q4ujEVjC0seEUAAtS6YEE1Veghz+IDbNQ";
	    hmac = [HONAppDelegate hmacForKey:key AndData:data];
	    [hmac appendString:@"+"];
	    [hmac appendString:data];
    }
    return hmac;
}

+ (AFHTTPClient *)getHttpClientWithHMAC {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient setDefaultHeader:@"HMAC" value:[HONAppDelegate hmacToken] ];
	[httpClient setDefaultHeader:@"X-DEVICE" value:[HONAppDelegate deviceModel]];
	return httpClient;
}
 

+ (NSString *)advertisingIdentifier {
	return ([[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
}

+ (NSString *)identifierForVendor {
	return ([[UIDevice currentDevice].identifierForVendor UUIDString]);
}

+ (NSString *)deviceModel {
	struct utsname systemInfo;
	uname(&systemInfo);
	
	return ([NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding]);
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

+ (NSString *)twilioSMS {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"twilio_sms"]);
}

+ (NSString *)smsInviteFormat {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"invite_sms"]);
}

+ (NSString *)emailInviteFormat {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"invite_email"]);
}

+ (NSString *)instagramShareComment {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"instagram_share"]);
}

+ (NSString *)twitterShareComment {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"twitter_share"]);
}

+ (NSRange)ageRange {
	return (NSMakeRange([[[[NSUserDefaults standardUserDefaults] objectForKey:@"age_range"] objectAtIndex:0] intValue] * 31536000, [[[[NSUserDefaults standardUserDefaults] objectForKey:@"age_range"] objectAtIndex:1] intValue] * 31536000));
}

+ (NSString *)s3BucketForType:(NSString *)bucketType {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"s3_buckets"] objectForKey:bucketType]);
}

+ (int)profileSubscribeThreshold {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"profile_subscribe"] intValue]);
}

+ (NSString *)bannerForSection:(int)section {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"section_banners"] objectAtIndex:section]);
}

+ (BOOL)switchEnabledForKey:(NSString *)key {
	return ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"switches"] objectForKey:key] uppercaseString] isEqualToString:@"YES"]);
}

+ (NSArray *)composeEmotions {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"compose_emotions"])
		[emotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
	
	return ([emotions copy]);
//	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"compose_emotions"]);
}

+ (NSArray *)replyEmotions {
	NSMutableArray *emotions = [NSMutableArray array];
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"reply_emotions"])
		[emotions addObject:[HONEmotionVO emotionWithDictionary:dict]];
	
	return ([emotions copy]);
//	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"reply_emotions"]);
}

+ (void)offsetSubviewsForIOS7:(UIView *)view {
	//view.frame = ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]) ? CGRectMake(view.frame.origin.x, 20.0, view.frame.size.width, view.frame.size.height - 20.0) : CGRectOffset(view.frame, 0.0, 0.0);
	
	if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]) {
		for (UIView *subview in [view subviews])
			subview.frame = CGRectOffset(subview.frame, 0.0, 0.0);
	}
}

+ (NSArray *)searchSubjects {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"search_subjects"]);
}

+ (NSArray *)searchUsers {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"search_users"]);
}

+ (NSArray *)inviteCelebs {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"invite_celebs"]);
}

+ (NSArray *)popularPeople {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"popular_people"]);
}


+ (void)writeDeviceToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceToken {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]);
}

+ (void)writeUserInfo:(NSDictionary *)userInfo {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] != nil) {
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_info"];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeUserAvatar:(UIImage *)image {
	[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:@"avatar_image"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)infoForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
}

+ (UIImage *)avatarImage {
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"avatar_image"])
		return ([UIImage imageNamed:@"defaultAvatar"]);
	
	return ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"avatar_image"]]);
}

+ (int)ageForDate:(NSDate *)date {
	return ([date timeIntervalSinceNow] / -31536000);
}

+ (NSArray *)friendsList {
	NSMutableArray *friends = [NSMutableArray array];
	for (NSDictionary *dict in [[HONAppDelegate infoForUser] objectForKey:@"friends"]) {
		[friends addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														  [NSString stringWithFormat:@"%d", [[[dict objectForKey:@"user"] objectForKey:@"id"] intValue]], @"id",
														  [NSString stringWithFormat:@"%d", 0], @"points",
														  [NSString stringWithFormat:@"%d", 0], @"votes",
														  [NSString stringWithFormat:@"%d", 0], @"pokes",
														  [NSString stringWithFormat:@"%d", 0], @"pics",
														  [NSString stringWithFormat:@"%d", 0], @"age",
														  [[dict objectForKey:@"user"] objectForKey:@"username"], @"username",
														  @"", @"fb_id",
														  [[dict objectForKey:@"user"] objectForKey:@"avatar_url"], @"avatar_url", nil]]];
	}
	
	return ([NSArray arrayWithArray:[friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]]);
}

+ (void)addFriendToList:(NSDictionary *)friend {
	NSMutableDictionary *dict = [[HONAppDelegate infoForUser] mutableCopy];
	NSMutableArray *friends = [[dict objectForKey:@"friends"] mutableCopy];
	
	[friends addObject:friend];
	[dict setObject:friends forKey:@"friends"];
	
	[HONAppDelegate writeUserInfo:[dict copy]];
}

+ (void)writeFriendsList:(NSArray *)friends {
	NSMutableDictionary *userInfo = [[HONAppDelegate infoForUser] mutableCopy];
	[userInfo setObject:friends forKey:@"friends"];
	[HONAppDelegate writeUserInfo:[userInfo copy]];
}

+ (NSArray *)subscribeeList {
	NSMutableArray *subscribees = [NSMutableArray array];
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"subscribees"]) {
		[subscribees addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														  [NSString stringWithFormat:@"%d", [[[dict objectForKey:@"user"] objectForKey:@"id"] intValue]], @"id",
														  [NSString stringWithFormat:@"%d", 0], @"points",
														  [NSString stringWithFormat:@"%d", 0], @"votes",
														  [NSString stringWithFormat:@"%d", 0], @"pokes",
														  [NSString stringWithFormat:@"%d", 0], @"pics",
														  [NSString stringWithFormat:@"%d", 0], @"age",
														  [[dict objectForKey:@"user"] objectForKey:@"username"], @"username",
														  @"", @"fb_id",
														  [[dict objectForKey:@"user"] objectForKey:@"avatar_url"], @"avatar_url", nil]]];
	}
	
	return ([NSArray arrayWithArray:[subscribees sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]]);
}

+ (void)addSubscribeeToList:(NSDictionary *)subscribee {
	NSMutableArray *friends = [[[NSUserDefaults standardUserDefaults] objectForKey:@"subscribees"] mutableCopy];
	[friends addObject:subscribee];
	
	[[NSUserDefaults standardUserDefaults] setObject:[friends copy] forKey:@"subscribees"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)writeSubscribeeList:(NSArray *)subscribees {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"subscribees"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"subscribees"];
	
	[[NSUserDefaults standardUserDefaults] setObject:subscribees forKey:@"subscribees"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


+ (int)hasVoted:(int)challengeID {
	NSArray *voteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"votes"];
	
	for (NSNumber *cID in voteArray) {
		if ([cID intValue] == challengeID || -[cID intValue] == challengeID) {
			return ([cID intValue]);
		}
	}
	
	return (0);
}

+ (void)setVote:(int)challengeID forCreator:(BOOL)isCreator {
	NSMutableArray *voteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] mutableCopy];
	[voteArray addObject:[NSNumber numberWithInt:(isCreator) ? challengeID : -challengeID]];
	
	[[NSUserDefaults standardUserDefaults] setObject:voteArray forKey:@"votes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSArray *)fillDiscoverChallenges:(NSArray *)challenges {
	//NSLog(@"challenges:\n%@[%d]", challenges, [challenges count]);
	
	// fill up all challenges if first time
//	if ([challenges count] >= 12) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:challenges, @"total", challenges, @"remaining", nil] forKey:@"discover_challenges"];
		[[NSUserDefaults standardUserDefaults] synchronize];
//	}
	
	// send back the 1st or next randomized set
	return ([HONAppDelegate refreshDiscoverChallenges]);
}

+ (NSArray *)refreshDiscoverChallenges {
	//	NSLog(@"allChallenges:\n%@", allChallenges);
	//	NSLog(@"remainingChallenges:\n%@", remainingChallenges);
	
	NSArray *allChallenges = [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"total"];
	NSMutableArray *remainingChallenges = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"remaining"] mutableCopy];
	NSMutableArray *newChallenges = [NSMutableArray array];
	
	if ([allChallenges count] < 16) {
		for (int i=0; i<[allChallenges count]; i++) {
			int rnd = arc4random() % [allChallenges count];
			[newChallenges addObject:[allChallenges objectAtIndex:rnd]];
		}
		
		return (newChallenges);
	}
		
	if ([remainingChallenges count] >= 16) {
		// loop for new set
		for (int i=0; i<16; i++) {
			//NSLog(@"POP:[%d][%d]", i, [remainingChallenges count]);
			int rnd = arc4random() % [remainingChallenges count];
			
			// pick a random index and remove from pool
			[newChallenges addObject:[remainingChallenges objectAtIndex:rnd]];
			[remainingChallenges removeObjectAtIndex:rnd];
			
			if ([remainingChallenges count] == 0)
				break;
		}
	}
	
	// no more left, repopulate
	if ([remainingChallenges count] == 0) {
		for (int i=0; i<[allChallenges count]; i++)
			[remainingChallenges addObject:[allChallenges objectAtIndex:arc4random() % [allChallenges count]]];
	}
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:allChallenges, @"total", remainingChallenges, @"remaining", nil] forKey:@"discover_challenges"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (newChallenges);
}

+ (UIViewController *)appTabBarController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}


+ (BOOL)isPhoneType5s {
	return ([[HONAppDelegate deviceModel] rangeOfString:@"iPhone6"].location == 0);
}

+ (BOOL)isRetina4Inch {
	return ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

+ (BOOL)hasTakenSelfie {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"skipped_selfie"] isEqualToString:@"NO"]);
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

+ (NSString *)deviceLocale {
	return ([[NSLocale preferredLanguages] objectAtIndex:0]);
}

+ (NSString *)timeSinceDate:(NSDate *)date {
	NSString *timeSince = @"";
	
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	int secs = [[utcDate dateByAddingTimeInterval:1] timeIntervalSinceDate:date];
	int mins = secs / 60;
	int hours = mins / 60;
	int days = hours / 24;
	
	//NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:date];
	//NSLog(@"[%d][%d][%d][%d]", days, hours, mins, secs);
	
	if (days > 0) {
		timeSince = [NSString stringWithFormat:@"%dd", days];
		
	} else {
		if (hours > 0)
			timeSince = [NSString stringWithFormat:@"%dh", hours];
		
		else {
			if (mins > 0)
				timeSince = [NSString stringWithFormat:@"%dm", mins];
			
			else
				timeSince = [NSString stringWithFormat:@"%ds", secs];
		}
	}
	
	if ([[timeSince substringToIndex:[timeSince length] - 1] intValue] < 0)
		timeSince = @"0s";
	
	return (timeSince);
}

+ (NSString *)formattedExpireTime:(int)seconds {
	
	int mins = seconds / 60;
	int hours = mins / 60;
	
	if (hours > 0)
		return ([NSString stringWithFormat:@"expires in %dh", hours]);
	
	if (mins > 0)
		return ([NSString stringWithFormat:@"expires in %dm", mins]);
	
	
	return ([NSString stringWithFormat:@"expires in %ds", seconds]);
}


+ (UIFont *)helveticaNeueFontRegular {
	return ([UIFont fontWithName:@"HelveticaNeue" size:18.0]);
}

+ (UIFont *)helveticaNeueFontLight {
	return ([UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]);
}

+ (UIFont *)helveticaNeueFontBold {
	return ([UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]);
}

+ (UIFont *)helveticaNeueFontBoldItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0]);
}

+ (UIFont *)helveticaNeueFontMedium {
	return ([UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]);
}

+ (UIFont *)cartoGothicBold {
	return ([UIFont fontWithName:@"CartoGothicStd-Bold" size:24.0]);
}

+ (UIFont *)cartoGothicBoldItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-BoldItalic" size:24.0]);
}

+ (UIFont *)cartoGothicBook {
	return ([UIFont fontWithName:@"CartoGothicStd-Book" size:24.0]);
}

+ (UIFont *)cartoGothicItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-Italic" size:24.0]);
}


+ (UIColor *)honOrthodoxGreenColor {
	return ([UIColor colorWithRed:0.451 green:0.757 blue:0.694 alpha:1.0]);
}

+ (UIColor *)honDarkGreenColor {
	return ([UIColor colorWithRed:0.204 green:0.373 blue:0.337 alpha:1.0]);
}

+ (UIColor *)honGrey710Color {
	return ([UIColor colorWithWhite:0.710 alpha:1.0]);
}

+ (UIColor *)honGrey635Color {
	return ([UIColor colorWithWhite:0.635 alpha:1.0]);
}

+ (UIColor *)honGrey608Color {
	return ([UIColor colorWithWhite:0.608 alpha:1.0]); //9b9b9b
}

+ (UIColor *)honGrey518Color {
	return ([UIColor colorWithWhite:0.518 alpha:1.0]);
}

+ (UIColor *)honGrey455Color {
	return ([UIColor colorWithWhite:0.455 alpha:1.0]);
}

+ (UIColor *)honGrey318Color {
	return ([UIColor colorWithWhite:0.318 alpha:1.0]); //515151
}

+ (UIColor *)honBlueTextColor {
	return ([UIColor colorWithRed:0.161 green:0.498 blue:1.0 alpha:1.0]);
}

+ (UIColor *)honGreyTimeColor {
	return ([UIColor colorWithRed:0.549 green:0.565 blue:0.565 alpha:1.0]);
}

+ (UIColor *)honGreenTextColor {
	return ([UIColor colorWithRed:0.451 green:0.757 blue:0.694 alpha:1.0]);
}

+ (UIColor *)honProfileStatsColor {
	return ([UIColor colorWithRed:0.227 green:0.380 blue:0.349 alpha:1.0]);
}


+(UIColor *)honDebugRedColor {
	return ([UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.33]);
}

+(UIColor *)honDebugGreenColor {
	return ([UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:0.33]);
}

+(UIColor *)honDebugBlueColor {
	return ([UIColor colorWithRed:0.0 green:0.0 blue:1.0 alpha:0.33]);
}


#pragma mark - Data Calls
- (void)_challengeObjectFromPush:(int)challengeID cancelNextPushes:(BOOL)isCancel {
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", challengeID], @"challengeID", nil];
	
	if (isCancel)
		[params setObject:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"cancelFor"];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengeResult);
			
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:challengeResult] withBackground:nil]];
			[navigationController setNavigationBarHidden:YES];
			[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

#pragma mark - Notifications
- (void)_addViewToWindow:(NSNotification *)notification {
	[self.window addSubview:(UIView *)[notification object]];
}

- (void)_removeViewFromWindow:(NSNotification *)notification {
	
}

- (void)_showSearchTable:(NSNotification *)notification {
	if (_searchViewController != nil) {
		[_searchViewController.view removeFromSuperview];
		_searchViewController = nil;
	}
	
	_searchViewController = [[HONSearchViewController alloc] init];
	_searchViewController.view.frame = CGRectMake(0.0, 20.0 + kSearchHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - (20.0 + kSearchHeaderHeight));
	[self.window addSubview:_searchViewController.view];
}

- (void)_hideSearchTable:(NSNotification *)notification {
	if (_searchViewController != nil) {
		[_searchViewController.view removeFromSuperview];
		_searchViewController = nil;
	}
}

- (void)_showSubjectSearchTimeline:(NSNotification *)notification {
	[_searchViewController.view removeFromSuperview];
	
	UINavigationController *navigationController = (UINavigationController *)[self.tabBarController selectedViewController];
	[navigationController pushViewController:[[HONTimelineViewController alloc] initWithSubject:[notification object]] animated:YES];
}

- (void)_showUserSearchTimeline:(NSNotification *)notification {
	[_searchViewController.view removeFromSuperview];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"RESIGN_SEARCH_BAR_FOCUS" object:nil];
	
	
	UINavigationController *navigationController = (UINavigationController *)[self.tabBarController selectedViewController];
	[navigationController pushViewController:[[HONTimelineViewController alloc] initWithUsername:[notification object]] animated:YES];
}

- (void)_pokeUser:(NSNotification *)notification {
	HONUserVO *vo = (HONUserVO *)[notification object];
	
	[[Mixpanel sharedInstance] track:@"Timeline - Poke User"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [NSString stringWithFormat:@"%d - %@", vo.userID, vo.username], @"challenger", nil]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"pokerID",
							[NSString stringWithFormat:@"%d", vo.userID], @"pokeeID",
							nil];
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
		
		else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


- (void)_sendToTwitter:(NSNotification *)notification {
	_shareInfo = [notification object];
	
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
			[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ - Share Twitter %@", [_shareInfo objectForKey:@"mp_event"], (result == SLComposeViewControllerResultDone) ? @"Completed" : @"Canceled"]
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
			
			[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
		};
		
		NSLog(@"SHARE INFO:[%@]", _shareInfo);
		[twitterComposeViewController setInitialText:[_shareInfo objectForKey:@"caption"]];
		[twitterComposeViewController addImage:[_shareInfo objectForKey:@"image"]];
//		[twitterComposeViewController addURL:[_shareInfo objectForKey:@"url"]];
		twitterComposeViewController.completionHandler = completionBlock;
		
		[[_shareInfo objectForKey:@"view_controller"] presentViewController:twitterComposeViewController animated:YES completion:nil];
		
	} else {
		[[[UIAlertView alloc] initWithTitle:@""
									message:@"Cannot use Twitter from this device!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (void)_sendToInstagram:(NSNotification *)notification {
	NSString *instaURL = @"instagram://app";
	NSString *instaFormat = @"com.instagram.exclusivegram";
	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_instagram.igo"];
	
	NSDictionary *dict = [notification object];
	UIImage *shareImage = [dict objectForKey:@"image"];
	[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
	
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:instaURL]];
		
		_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
		_documentInteractionController.UTI = instaFormat;
		_documentInteractionController.delegate = self;
		_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[dict objectForKey:@"caption"] forKey:@"InstagramCaption"];
		//[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:[HONAppDelegate appTabBarController].view animated:YES];
		[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.tabBarController.view animated:YES];
		
	} else {
		[self _showOKAlert:NSLocalizedString(@"alert_instagramError_t", nil)
			   withMessage:NSLocalizedString(@"alert_instagramError_m", nil)];
	}
}

- (void)_showShareShelf:(NSNotification *)notification {
	_shareInfo = [notification object];
	
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Share on Twitter", @"Share on Instagram", nil];
	[actionSheet setTag:0];
	[actionSheet showInView:((UIViewController *)[_shareInfo objectForKey:@"view_controller"]).view];
}

- (void)_initTabBar:(NSNotification *)notification {
	[self _initTabs];
}


#pragma mark - UI Presentation
- (void)_dropTabs {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
}

- (void)_showOKAlert:(NSString *)title withMessage:(NSString *)message {
	[[[UIAlertView alloc] initWithTitle:title
								message:message
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_showUI {
	self.tabBarController.view.hidden = NO;
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	
//	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
	
//	NSLog(@"ADID:[%@]\nVENDORID:[%@]\nHMAC:[%@]", [HONAppDelegate advertisingIdentifier], [HONAppDelegate identifierForVendor], [HONAppDelegate hmacToken]);
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	
	NSShadow *shadow = [NSShadow new];
	[shadow setShadowColor:[UIColor clearColor]];
	[shadow setShadowOffset:CGSizeMake(0.0f, 0.0f)];
	
	//[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
//	[[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
	[[UINavigationBar appearance] setBarTintColor:[HONAppDelegate honOrthodoxGreenColor]];
	[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
														  [UIColor whiteColor], NSForegroundColorAttributeName,
														  shadow, NSShadowAttributeName,
														  [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:20], NSFontAttributeName, nil]];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButtonIcon_nonActive"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButtonIcon_Active"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
														  [UIColor whiteColor], NSForegroundColorAttributeName,
														  shadow, NSShadowAttributeName,
														  [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:17], NSFontAttributeName, nil] forState:UIControlStateNormal];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
														  [UIColor whiteColor], NSForegroundColorAttributeName,
														  shadow, NSShadowAttributeName,
														  [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:17], NSFontAttributeName, nil] forState:UIControlStateHighlighted];
	
	[[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
//	[[UITabBar appearance] setTintColor:[UIColor blackColor]];
	[[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
	[[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabMenuBackground"]];
	
	[[UIToolbar appearance] setBarTintColor:[UIColor blackColor]];
//	[[UIToolbar appearance] setTintColor:[UIColor blackColor]];
	[[UIToolbar appearance] setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
	[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"subDetailsFooterBackground"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[[UIToolbar appearance] setBarStyle:UIBarStyleBlackTranslucent];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	_isFromBackground = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addViewToWindow:) name:@"ADD_VIEW_TO_WINDOW" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchTable:) name:@"SHOW_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchTable:) name:@"HIDE_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSubjectSearchTimeline:) name:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showUserSearchTimeline:) name:@"SHOW_USER_SEARCH_TIMELINE" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pokeUser:) name:@"POKE_USER" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sendToInstagram:) name:@"SEND_TO_INSTAGRAM" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showShareShelf:) name:@"SHOW_SHARE_SHELF" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_initTabBar:) name:@"INIT_TAB_BAR" object:nil];
	
#ifdef FONTS
	[self _showFonts];
#endif
//	[TestFlight takeOff:kTestFlightAppToken];
	
//	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppToken delegate:self];
//	[[BITHockeyManager sharedHockeyManager] startManager];
	
	TSConfig *config = [TSConfig configWithDefaults];
	config.collectWifiMac = NO;
	config.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	//config.odin1 = @"<ODIN-1 value goes here>";
	//config.openUdid = @"<OpenUDID value goes here>";
	//config.secureUdid = @"<SecureUDID value goes here>";
	[TSTapstream createWithAccountName:@"volley" developerSecret:@"xJCRiJCqSMWFVF6QmWdp8g" config:config];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"skipped_selfie"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"timeline2_banner"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"timeline2_banner"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"discover_banner"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"activity_banner"];
	
	
	NSArray *totals = @[@"background_total",
						@"timeline_total",
						@"explore_total",
						@"exploreRefresh_total",
						@"verify_total",
						@"verifyRefresh_total",
						@"popular_total",
						@"verifyAction_total",
						@"preview_total",
						@"details_total",
						@"camera_total",
						@"profile_total",
						@"like_total"];
	
	for (NSString *key in totals) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:key])
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
#if __ALWAYS_REGISTER__ == 1
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	
	for (NSString *key in totals)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
#endif
	
#if __RESET_TOTALS__ == 1
	for (NSString *key in totals)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
#endif

	
	if ([HONAppDelegate hasNetwork]) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"votes"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"])
			[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"audio_muted"];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"])
			[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"local_challenges"];
		
		
		if (![HONAppDelegate canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		}
		
		[KikAPIClient registerAsKikPluginWithAppID:@"kik-com.builtinmenlo.hotornot"
								   withHomepageURI:@"http://www.builtinmenlo.com"
									  addAppButton:YES];
		
		
		int boot_total = 0;
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
		
		else {
			boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++boot_total] forKey:@"boot_total"];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
		
//		int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"]] / 86400;
		
//		if (boot_total == 5) {
//			UIAlertView *alertView = [[UIAlertView alloc]
//									  initWithTitle:@"Rate Volley"
//									  message:@"Why not rate Volley in the app store!"
//									  delegate:self
//									  cancelButtonTitle:nil
//									  otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
//			[alertView setTag:2];
//			[alertView show];
//		}
		
		[Mixpanel sharedInstanceWithToken:kMixPanelToken];
		[[Mixpanel sharedInstance] track:@"App Boot"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		
		self.tabBarController = [[HONTabBarController alloc] init];
		self.tabBarController.delegate = self;
		self.tabBarController.view.hidden = YES;
		
//		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] == nil) {
//			[self performSelector:@selector(_showUI) withObject:nil afterDelay:3.0];
//		}
		
		self.window.rootViewController = self.tabBarController;
		self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//		self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
		[self.window makeKeyAndVisible];
		
		
		//NSLog(@"DEVICE:[%@]", [UIDevice currentDevice].description);
		
		
		
		// This prevents the UA Library from registering with UIApplication by default. This will allow
		// you to prompt your users at a later time. This gives your app the opportunity to explain the
		// benefits of push or allows users to turn it on explicitly in a settings screen.
		//
		// If you just want everyone to immediately be prompted for push, you can
		// leave this line out.
//		[UAPush setDefaultPushEnabledValue:NO];
		
		// Set log level for debugging config loading (optional)
		// It will be set to the value in the loaded config upon takeOff
		[UAirship setLogLevel:UALogLevelNone];
		
		// Populate AirshipConfig.plist with your app's info from https://go.urbanairship.com
		// or set runtime properties here.
		UAConfig *config = [UAConfig defaultConfig];
		
		// You can then programatically override the plist values:
		// config.developmentAppKey = @"YourKey";
		// etc.
		
		// Call takeOff (which creates the UAirship singleton)
		[UAirship takeOff:config];
		
		// Print out the application configuration for debugging (optional)
		UA_LDEBUG(@"Config:\n%@", [config description]);
		
		// Set the icon badge to zero on startup (optional)
		[[UAPush shared] resetBadge];
		
		// Set the notification types required for the app (optional). With the default value of push set to no,
		// UAPush will record the desired remote notification types, but not register for
		// push notifications as mentioned above. When push is enabled at a later time, the registration
		// will occur normally. This value defaults to badge, alert and sound, so it's only necessary to
		// set it if you want to add or remove types.
		[UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge |
											 UIRemoteNotificationTypeSound |
											 UIRemoteNotificationTypeAlert);
		
		
		
//		NSString *deviceID = [NSString stringWithFormat:@"%064d", 7];
//		NSLog(@"DEVICE TOKEN:[%@]", deviceID);
//		
//		[HONAppDelegate writeDeviceToken:deviceID];
//		[self _retrieveConfigJSON];
		
		[HONAppDelegate writeDeviceToken:@""];
		[self _retrieveConfigJSON];
		
	} else {
		[self _showOKAlert:@"No Network Connection"
			   withMessage:@"This app requires a network connection to work."];
	}
	
	
	NSLog(@"ADID:[%@]", [HONAppDelegate advertisingIdentifier]);
//	[self _showOKAlert:@"" withMessage:[HONAppDelegate advertisingIdentifier]];
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[Mixpanel sharedInstance] track:@"App Entering Background"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"])
//		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	
	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"background_total"] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"background_total"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
//	[FBSettings publishInstall:kFacebookAppID];
	[FBAppEvents activateApp];
	
	// Set the icon badge to zero on resume (optional)
	[[UAPush shared] resetBadge];
	
//	[FBAppCall handleDidBecomeActive];
	
	if (_isFromBackground && [HONAppDelegate hasNetwork]) {
		[[Mixpanel sharedInstance] track:@"App Leaving Background"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
			int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"background_total"] intValue];
			if (total == 1 && [HONAppDelegate switchEnabledForKey:@"background_invite"]) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"INVITE FRIENDS?"
																	message:@"Get more followers now, tap OK."
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"OK", nil];
				[alertView setTag:3];
				[alertView show];
			}
			
			if (total == 3 && [HONAppDelegate switchEnabledForKey:@"background_share"]) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"SHARE VOLLEY?"
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
			
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
			[self _retrieveConfigJSON];
			//_isFromBackground = NO;
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[FBSession.activeSession close];
}


- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication]);
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[UAPush shared] registerDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	
	if ([HONAppDelegate apiServerPath] != nil)
		[self _enableNotifications];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	
	if ([[HONAppDelegate advertisingIdentifier] isEqualToString:@"DAE17C43-B4AD-4039-9DD4-7635420126C0"]) {
		NSString *deviceID = [NSString stringWithFormat:@"%064d", 0];
		NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", deviceID);
		
		[HONAppDelegate writeDeviceToken:deviceID];
	
	} else
		[HONAppDelegate writeDeviceToken:@""];
	
	if ([HONAppDelegate apiServerPath] != nil)
		[self _enableNotifications];
}
 
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	UALOG(@"Received remote notification: %@", userInfo);
	
	// Get application state for iOS4.x+ devices, otherwise assume active
	UIApplicationState appState = UIApplicationStateActive;
	if ([application respondsToSelector:@selector(applicationState)]) {
		appState = application.applicationState;
	}
	
	[[UAPush shared] handleNotification:userInfo applicationState:appState];
	[[UAPush shared] resetBadge]; // zero badge after push received
	
	NSLog(@"alert:(%d)[%@]", [[userInfo objectForKey:@"type"] intValue], [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
	
	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"]) {
		if (!_isFromBackground) {
			// sms sound
//			AudioServicesPlaySystemSound(1007);
//			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
			
			if ([userInfo objectForKey:@"type"] == nil) {
				[self _showOKAlert:@""
					   withMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
			}
			
		} else {
			int pushType = [[userInfo objectForKey:@"type"] intValue];
			
			// somone joined your volley
			if (pushType == 1)
				[self _challengeObjectFromPush:[[userInfo objectForKey:@"challenge"] intValue] cancelNextPushes:NO];
			
			// user verified
			else if (pushType == 2) {
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:@"Awesome! You have been Volley Verified! Would you like to share Volley with your friends?"//[userInfo objectForKey:@"aps"]
																   delegate:self
														  cancelButtonTitle:@"No"
														  otherButtonTitles:@"Yes", nil];
				[alertView setTag:1];
				[alertView show];
			
			// user profile
			} else if (pushType == 3) {
				HONUserProfileViewController *userPofileViewController = [[HONUserProfileViewController alloc] initWithBackground:nil];
				userPofileViewController.userID = [[userInfo objectForKey:@"user"] intValue];
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:userPofileViewController];
				[navigationController setNavigationBarHidden:YES];
				[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
			
			// find friends
			} else if (pushType == 4) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
			
			// settings
			} else if (pushType == 5) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[[HONAppDelegate appTabBarController] presentViewController:navigationController animated:YES completion:nil];
			
			} else if (pushType == 6) {
				[self _challengeObjectFromPush:[[userInfo objectForKey:@"challenge"] intValue] cancelNextPushes:YES];
			}
			
		}
	}
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    UA_LINFO(@"Received remote notification (in appDelegate): %@", userInfo);
	
    // Optionally provide a delegate that will be used to handle notifications received while the app is running
    // [UAPush shared].pushNotificationDelegate = your custom push delegate class conforming to the UAPushNotificationDelegate protocol
	
    // Reset the badge after a push is received in a active or inactive state
    if (application.applicationState != UIApplicationStateBackground) {
        [[UAPush shared] resetBadge];
    }
	
    completionHandler(UIBackgroundFetchResultNoData);
}




#pragma mark - Startup Operations
- (void)_retrieveConfigJSON {
	VolleyJSONLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCONFIG_JSON:[%@/%@]", kConfigURL, kConfigJSON);
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], kConfigURL, kConfigJSON);
//	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kConfigURL]];
	[httpClient postPath:kConfigJSON parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		
		if (error != nil)
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
		
		else {
//			[self _showOKAlert:@"GOT CONFIG" withMessage:@""];
			
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			NSMutableArray *ageRange = [NSMutableArray array];
			for (NSNumber *age in [result objectForKey:@"age_range"])
				[ageRange addObject:age];
			
			NSMutableArray *composeEmotions = [NSMutableArray array];
			for (NSString *emotion in [result objectForKey:@"compose_emotions"])
				[composeEmotions addObject:emotion];
			
			NSMutableArray *replyEmotions = [NSMutableArray array];
			for (NSString *emotion in [result objectForKey:@"reply_emotions"])
				[replyEmotions addObject:emotion];
			
			NSMutableArray *subjects = [NSMutableArray array];
			for (NSString *hashtag in [result objectForKey:@"search_hashtags"])
				[subjects addObject:hashtag];
			
			NSMutableArray *users = [NSMutableArray array];
			for (NSString *user in [result objectForKey:@"search_users"])
				[users addObject:user];
			
			NSMutableArray *celebs = [NSMutableArray array];
			for (NSDictionary *celeb in [result objectForKey:@"invite_celebs"])
				[celebs addObject:celeb];
			
			NSMutableArray *populars = [NSMutableArray array];
			for (NSString *popular in [result objectForKey:@"popular_people"])
				[populars addObject:popular];
			
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"appstore_id"] forKey:@"appstore_id"];
			[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"endpts"] objectForKey:kAPIHost] forKey:@"server_api"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"service_url"] forKey:@"service_url"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"twilio_sms"] forKey:@"twilio_sms"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[result objectForKey:@"profile_subscribe"] intValue]] forKey:@"profile_subscribe"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"sharing_social"] forKey:@"sharing_social"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invite_sms"] forKey:@"invite_sms"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invite_email"] forKey:@"invite_email"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"instagram_share"] forKey:@"instagram_share"];
			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"twitter_share"] forKey:@"twitter_share"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
															  [[result objectForKey:@"switches"] objectForKey:@"splash_camera"], @"splash_camera",
															  [[result objectForKey:@"switches"] objectForKey:@"background_invite"], @"background_invite",
															  [[result objectForKey:@"switches"] objectForKey:@"firstrun_invite"], @"firstrun_invite",
															  [[result objectForKey:@"switches"] objectForKey:@"firstrun_subscribe"], @"firstrun_subscribe",
															  [[result objectForKey:@"switches"] objectForKey:@"profile_invite"], @"profile_invite",
															  [[result objectForKey:@"switches"] objectForKey:@"popular_invite"], @"popular_invite",
															  [[result objectForKey:@"switches"] objectForKey:@"explore_invite"], @"explore_invite",
															  
															  [[result objectForKey:@"switches"] objectForKey:@"background_share"], @"background_share",
															  [[result objectForKey:@"switches"] objectForKey:@"volley_share"], @"volley_share",
															  [[result objectForKey:@"switches"] objectForKey:@"verify_share"], @"verify_share",
															  [[result objectForKey:@"switches"] objectForKey:@"like_share"], @"like_share",
															  [[result objectForKey:@"switches"] objectForKey:@"profile_share"], @"profile_share",
															  
															  [[result objectForKey:@"switches"] objectForKey:@"share_email"], @"share_email",
															  [[result objectForKey:@"switches"] objectForKey:@"share_sms"], @"share_sms",
															  [[result objectForKey:@"switches"] objectForKey:@"share_instagram"], @"share_instagram",
															  [[result objectForKey:@"switches"] objectForKey:@"share_twitter"], @"share_twitter", nil] forKey:@"switches"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
															  [[result objectForKey:@"s3_buckets"] objectForKey:@"challenges"], @"challenges",
															  [[result objectForKey:@"s3_buckets"] objectForKey:@"avatars"], @"avatars",
															  [[result objectForKey:@"s3_buckets"] objectForKey:@"emoticons"], @"emoticons", nil] forKey:@"s3_buckets"];
			[[NSUserDefaults standardUserDefaults] setObject:[ageRange copy] forKey:@"age_range"];
			[[NSUserDefaults standardUserDefaults] setObject:[composeEmotions copy] forKey:@"compose_emotions"];
			[[NSUserDefaults standardUserDefaults] setObject:[replyEmotions copy] forKey:@"reply_emotions"];
			[[NSUserDefaults standardUserDefaults] setObject:[subjects copy] forKey:@"search_subjects"];
			[[NSUserDefaults standardUserDefaults] setObject:[users copy] forKey:@"search_users"];
			[[NSUserDefaults standardUserDefaults] setObject:[celebs copy] forKey:@"invite_celebs"];
			[[NSUserDefaults standardUserDefaults] setObject:[populars copy] forKey:@"popular_people"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
			
//			[self _showOKAlert:@"PARSED CONFIG" withMessage:@""];
			
			if ([[result objectForKey:@"update_app"] isEqualToString:@"Y"]) {
				[self _showOKAlert:@"Update Required"
					   withMessage:@"Please update Volley to the latest version to use the latest features."];
			}
			
			if (!_isFromBackground)
				[self _registerUser];
			
			else {
				_isFromBackground = NO;
				NSString *notificationName;
				switch ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue]) {
					case 0:
						notificationName = @"REFRESH_VOTE_TAB";
						break;
						
					case 1:
						notificationName = @"REFRESH_DISCOVERY_TAB";
						break;
						
					case 2:
						notificationName = @"REFRESH_CHALLENGES_TAB";
						break;
						
					case 3:
						notificationName = @"REFRESH_PROFILE_TAB";
						break;
				}
				
				[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
			}
			
//			_userTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(_retryUser) userInfo:nil repeats:YES];
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], kConfigURL, kConfigJSON, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_registerUser {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 1], @"action",
//							[HONAppDelegate deviceToken], @"token",
							nil];
	
//	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null]) {
				[HONAppDelegate writeUserInfo:userResult];
				
//				NSMutableString *avatarURL = [[userResult objectForKey:@"avatar_url"] mutableCopy];
//				[avatarURL replaceOccurrencesOfString:@"Large_640x1136" withString:@"_o" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
//				[avatarURL replaceOccurrencesOfString:@".png" withString:@"_o.png" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
				[HONImagingDepictor writeImageFromWeb:[userResult objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
				
				if ([[[HONAppDelegate infoForUser] objectForKey:@"age"] isEqualToString:@"0000-00-00 00:00:00"]) {
					[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
					[[NSUserDefaults standardUserDefaults] synchronize];
				}
			}
			
			if ([[[HONAppDelegate infoForUser] objectForKey:@"is_suspended"] intValue] == 1) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuspendedViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
						
			} else {
				[self _initTabs];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_enableNotifications {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 4], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							@"Y", @"isNotifications",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


- (void)_retryUser {
	NSLog(@"---RETRY USER [%d]---", (int)[HONAppDelegate infoForUser]);
//	[self _showOKAlert:@"RETRYING USER" withMessage:(![HONAppDelegate infoForUser]) ? @"NEEDED" : @"NOT NEEDED"];
	
	if (![HONAppDelegate infoForUser]) {
		[self _registerUser];
	
	} else {
		[_userTimer invalidate];
		_userTimer = nil;
	}
}

- (void)_initTabs {
	[_bgImageView removeFromSuperview];
	self.tabBarController.view.hidden = NO;
	
	UIViewController *timelineViewController, *discoveryViewController, *challengesViewController;
	timelineViewController = [[HONTimelineViewController alloc] initWithFriends];
	discoveryViewController = [[HONExploreViewController alloc] init];
	challengesViewController = [[HONVerifyViewController alloc] init];
	
	UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
	UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
	UINavigationController *navigationController3 = [[UINavigationController alloc] initWithRootViewController:challengesViewController];
	
	[navigationController1 setNavigationBarHidden:YES animated:NO];
	[navigationController2 setNavigationBarHidden:YES animated:NO];
	[navigationController3 setNavigationBarHidden:YES animated:NO];
		
	if ([navigationController1.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController1.navigationBar setShadowImage:[[UIImage alloc] init]];
	
	if ([navigationController2.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController2.navigationBar setShadowImage:[[UIImage alloc] init]];
	
	if ([navigationController3.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController3.navigationBar setShadowImage:[[UIImage alloc] init]];
	
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:
											 navigationController1,
											 navigationController2,
											 navigationController3, nil];
}


#pragma mark - Debug Calls
- (void)_showFonts {
	for (NSString *familyName in [UIFont familyNames]) {
		NSLog(@"Font Family Name = %@", familyName);
		
		NSArray *names = [UIFont fontNamesForFamilyName:familyName];
		NSLog(@"Font Names = %@", names);
	}
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
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"            : [NSString stringWithFormat:[HONAppDelegate twitterShareComment], @"#profile", [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																								@"image"              : [HONAppDelegate avatarImage],
																								@"url"                : @"",
																								@"mp_event"           : @"App Root",
																								@"view_controller"    : self.tabBarController}];
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
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/us/app/id%@?mt=8", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
				break;
		}
		
	} else if (alertView.tag == 3) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"App Backgrounding - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"App Backgrounding - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"            : [NSString stringWithFormat:[HONAppDelegate twitterShareComment], @"#profile", [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																									@"image"              : [HONAppDelegate avatarImage],
																									@"url"                : @"",
																									@"mp_event"           : @"App Root",
																									@"view_controller"    : self.tabBarController}];
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


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		NSLog(@"SHARE INFO:[%@]", _shareInfo);
		
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ - Share %@", [_shareInfo objectForKey:@"mp_event"], (buttonIndex == 0) ? @"Twitter" : @"Instagram"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 0) {
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
				SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
					[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ - Share Twitter %@", [_shareInfo objectForKey:@"mp_event"], (result == SLComposeViewControllerResultDone) ? @"Completed" : @"Canceled"]
										  properties:[NSDictionary dictionaryWithObjectsAndKeys:
													  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
					
					[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
				};
				
				[twitterComposeViewController setInitialText:[_shareInfo objectForKey:@"caption"]];
				[twitterComposeViewController addImage:[_shareInfo objectForKey:@"image"]];
//				[twitterComposeViewController addURL:[_shareInfo objectForKey:@"url"]];
				twitterComposeViewController.completionHandler = completionBlock;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:twitterComposeViewController animated:YES completion:nil];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@""
											message:@"Cannot use Twitter from this device!"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else if (buttonIndex == 1) {
			NSString *instaURL = @"instagram://app";
			NSString *instaFormat = @"com.instagram.exclusivegram";
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_instagram.igo"];
			UIImage *shareImage = [HONImagingDepictor prepImageForSharing:[UIImage imageNamed:@"share_template"]
															  avatarImage:[HONImagingDepictor cropImage:[HONAppDelegate avatarImage] toRect:CGRectMake(0.0, 141.0, 640.0, 853.0)]
																 username:[[HONAppDelegate infoForUser] objectForKey:@"username"]];
			[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				_documentInteractionController.UTI = instaFormat;
				_documentInteractionController.delegate = self;
				_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:[HONAppDelegate instagramShareComment], @"#profile", [[HONAppDelegate infoForUser] objectForKey:@"username"]] forKey:@"InstagramCaption"];
				[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.tabBarController.view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Not Available"
											message:@"This device isn't allowed or doesn't recognize instagram"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}
	}
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Presenting DocInteraction Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Dismissing DocInteraction Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Launching DocInteraction App"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Entering DocInteraction App Foreground"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user",
									  [controller name], @"controller", nil]];
}


#if __DEV_BUILD___ == 1
#pragma mark - UpdateManager Delegates
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
//	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
//		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
	return nil;
}
#endif
@end
