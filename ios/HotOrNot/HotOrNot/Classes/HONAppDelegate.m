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
#import <FacebookSDK/FacebookSDK.h>
#import <HockeySDK/HockeySDK.h>
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "MBProgressHUD.h"
#import "KikAPI.h"
#import "Reachability.h"
#import "TSTapstream.h"
#import "UAirship.h"
#import "UAPush.h"

#import "HONAppDelegate.h"
#import "HONTabBarController.h"
#import "HONChallengesViewController.h"
#import "HONTimelineViewController.h"
#import "HONDiscoveryViewController.h"
#import "HONImagePickerViewController.h"
#import "HONProfileViewController.h"
#import "HONChallengeVO.h"
#import "HONUsernameViewController.h"
#import "HONSearchViewController.h"
#import "HONImagingDepictor.h"
#import "HONChallengeDetailsViewController.h"


#if __DEV_BUILD___ == 1
NSString * const kConfigURL = @"http://stage.letsvolley.com/hotornot";//54.221.205.30";
NSString * const kConfigJSON = @"boot.json";
NSString * const kAPIHost = @"data_api-dev";
NSString * const kMixPanelToken = @"c7bf64584c01bca092e204d95414985f"; // Dev
#else
NSString * const kConfigURL = @"http://config.letsvolley.com/hotornot";
NSString * const kConfigJSON = @"boot_124.json";
NSString * const kAPIHost = @"data_api";
NSString * const kMixPanelToken = @"7de852844068f082ddfeaf43d96e998e"; // Volley 1.2.3
#endif


//NSString * const kMixPanelToken = @"d93069ad5b368c367c3adc020cce8021"; // Focus Group I
//NSString * const kMixPanelToken = @"8ae70817a3d885455f940ff261657ec7"; // Soft Launch I
//NSString * const kMixPanelToken = @"de3e67b68e6b8bf0344ca58573733ee5"; // Soft Launch II
NSString * const kFacebookAppID = @"600550136636754";

//api endpts
NSString * const kAPIChallenges = @"Challenges.php";
NSString * const kAPIComments = @"Comments.php";
NSString * const kAPIDiscover = @"Discover.php";
NSString * const kAPIPopular = @"Popular.php";
NSString * const kAPISearch = @"Search.php";
NSString * const kAPIUsers = @"Users.php";
NSString * const kAPIVotes = @"Votes.php";
NSString * const kAPIGetFriends = @"social/getfriends";
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
NSString * const kAPIUsersFirstRunComplete = @"users/firstruncomplete";
NSString * const kAPIJoinChallenge = @"challenges/join";
NSString * const kAPIGetVerifyList = @"challenges/getVerifyList";


// view heights
const CGFloat kNavBarHeaderHeight = 44.0f;
const CGFloat kSearchHeaderHeight = 44.0f;
const CGFloat kOrthodoxTableHeaderHeight = 31.0f;
const CGFloat kOrthodoxTableCellHeight = 63.0f;
const CGSize kTabSize = {80.0, 50.0};


// snap params
const CGFloat kSnapRatio = 1.33333333f;
const CGFloat kSnapJPEGCompress = 0.875f;

// animation params
const CGFloat kHUDTime = 2.33f;
const CGFloat kHUDErrorTime = 1.5f;

// image sizes
const CGFloat kSnapThumbDim = 37.0f;
const CGFloat kSnapMediumDim = 73.0f;
const CGFloat kSnapLargeDim = 221.0f;
const CGFloat kAvatarDim = 200.0f;

const BOOL kIsImageCacheEnabled = YES;
const NSUInteger kRecentOpponentsDisplayTotal = 10;
NSString * const kTwilioSMS = @"6475577873";

@interface HONAppDelegate() <UIAlertViewDelegate, UIDocumentInteractionControllerDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>
//@interface HONAppDelegate() <UIAlertViewDelegate, UIDocumentInteractionControllerDelegate>
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) AVAudioPlayer *mp3Player;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONSearchViewController *searchViewController;
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
	return httpClient;
}
 

+ (NSString *)advertisingIdentifier {
	return ([[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
}

+ (NSString *)identifierForVendor {
	return ([[UIDevice currentDevice].identifierForVendor UUIDString]);
}


+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSString *)customerServiceURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"service_url"]);
}
+ (NSDictionary *)s3Credentials {
	return ([NSDictionary dictionaryWithObjectsAndKeys:@"AKIAJVS6Y36AQCMRWLQQ", @"key",
			 @"48u0XmxUAYpt2KTkBRqiDniJXy+hnLwmZgYqUGNm", @"secret", nil]);
	
	//return ([[NSUserDefaults standardUserDefaults] objectForKey:@"s3_creds"]);
}

+ (NSString *)twilioSMS {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"twilio_sms"]);
}

+ (BOOL)isInviteCodeValid:(NSString *)code {
	
	for (NSString *validCode in [[NSUserDefaults standardUserDefaults] objectForKey:@"invite_codes"]) {
		if ([code isEqualToString:validCode])
			return (YES);
	}
	
	return (NO);
}

+ (NSString *)smsInviteFormat {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_sms"] objectForKey:[HONAppDelegate deviceLocale]]);
}
+ (NSString *)emailInviteFormat {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_email"] objectForKey:[HONAppDelegate deviceLocale]]);
}

+ (NSString *)instagramShareComment {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"insta_profile"] objectForKey:[HONAppDelegate deviceLocale]]);
}

+ (int)createPointMultiplier {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"point_mult"] objectAtIndex:2] intValue]);
}
+ (int)votePointMultiplier {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"point_mult"] objectAtIndex:0] intValue]);
}
+ (int)pokePointMultiplier {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"point_mult"] objectAtIndex:1] intValue]);
}

+ (NSString *)tutorialImageForPage:(int)page {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"tutorial_images"] objectAtIndex:page]);
}

+ (NSString *)promoteInviteImageForType:(int)type {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"promote_images"] objectAtIndex:type]);
}


+ (NSString *)bannerForSection:(int)section {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"section_banners"] objectAtIndex:section]);
}

+ (NSString *)timelineBannerType {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_banner"] objectForKey:@"type"]);
}

+ (NSString *)timelineBannerURL {
	if ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_banner"] objectForKey:@"type"] lowercaseString] isEqualToString:@"none"])
		return (@"");
	
	else
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeline_banner"] objectForKey:@"url"]);
}


+ (NSString *)rndDefaultSubject {
	NSArray *subjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_subjects"];
	return ([subjects objectAtIndex:(arc4random() % [subjects count])]);
}

+ (void)offsetSubviewsForIOS7:(UIView *)view {
	//view.frame = ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]) ? CGRectMake(view.frame.origin.x, 20.0, view.frame.size.width, view.frame.size.height - 20.0) : CGRectOffset(view.frame, 0.0, 0.0);
	
	if ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]) {
		for (UIView *subview in [view subviews])
			subview.frame = CGRectOffset(subview.frame, 0.0, 20.0);
	}
}

+ (BOOL)isLocaleEnabled {
	//return (NO);
	
	if ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_locales"] objectAtIndex:0] isEqualToString:@""])
		return (YES);
	
	for (NSString *locale in [[NSUserDefaults standardUserDefaults] objectForKey:@"enabled_locales"]) {
		if ([[[NSLocale preferredLanguages] objectAtIndex:0] isEqualToString:locale]) {
			return (YES);
		}
	}
	
	return (NO);
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
	//return ([[HONAppDelegate infoForUser] objectForKey:@"friends"]);
	
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


+ (void)setAllowsFBPosting:(BOOL)canPost {
	[[NSUserDefaults standardUserDefaults] setObject:(canPost) ? @"YES" : @"NO" forKey:@"fb_posting"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)allowsFBPosting {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"] isEqualToString:@"YES"]);
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
	if ([challenges count] >= 12) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:challenges, @"total", challenges, @"remaining", nil] forKey:@"discover_challenges"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	// send back the 1st or next randomized set
	return ([HONAppDelegate refreshDiscoverChallenges]);
}

+ (NSArray *)refreshDiscoverChallenges {
	//	NSLog(@"allChallenges:\n%@", [discover_challenges objectForKey:@"total"]);
	//	NSLog(@"remainingChallenges:\n%@", [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"remaining"]);
	
	NSArray *allChallenges = [[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"total"];
	NSMutableArray *remainingChallenges = [[[[NSUserDefaults standardUserDefaults] objectForKey:@"discover_challenges"] objectForKey:@"remaining"] mutableCopy];
	NSMutableArray *newChallenges = [NSMutableArray array];
	
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


+ (BOOL)isRetina5 {
	return ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f);
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

+ (BOOL)audioMuted {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"] isEqualToString:@"YES"]);
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

+ (UIColor *)honGrey518Color {
	return ([UIColor colorWithWhite:0.518 alpha:1.0]);
}

+ (UIColor *)honGrey455Color {
	return ([UIColor colorWithWhite:0.455 alpha:1.0]);
}

+ (UIColor *)honGrey365Color {
	return ([UIColor colorWithWhite:0.365 alpha:1.0]);
}

+ (UIColor *)honGrey245Color {
	return ([UIColor colorWithWhite:0.245 alpha:1.0]);
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
- (void)_challengeObjectFromPush:(int)challengeID {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", challengeID], @"challengeID", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallengeObject);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallengeObject parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *challengeResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengeResult);
			
			//UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:challengeResult]]];
			//[navigationController setNavigationBarHidden:YES];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:challengeResult]]];
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
	_searchViewController.view.frame = CGRectMake(0.0, 20.0 + kSearchHeaderHeight, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 188.0);
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
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
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


- (void)_sendToInstagram:(NSNotification *)notification {
	NSString *instaURL = @"instagram://app";
	NSString *instaFormat = @"com.instagram.exclusivegram";
	NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/volley_instagram.igo"];
	
	NSDictionary *dict = [notification object];
	UIImage *shareImage = [dict objectForKey:@"image"];//[UIImage imageNamed:@"instagram_template-0000"];
	[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
	
	
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
		//[[UIApplication sharedApplication] openURL:[NSURL URLWithString:instaURL]];
		
		_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
		_documentInteractionController.UTI = instaFormat;
		_documentInteractionController.delegate = self;
		_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[dict objectForKey:@"caption"] forKey:@"InstagramCaption"];
		[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:[HONAppDelegate appTabBarController].view animated:YES];
		
	} else {
		[self _showOKAlert:NSLocalizedString(@"alert_instagramError_t", nil)
			   withMessage:NSLocalizedString(@"alert_instagramError_m", nil)];
	}
}

#pragma mark - UI Presentation
- (void)_dropTabs {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_TABS" object:nil];
}

- (void)_showOKAlert:(NSString *)title withMessage:(NSString *)message {
	UIAlertView *alertView = [[UIAlertView alloc]
							  initWithTitle:title
							  message:message
							  delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil];
	[alertView show];
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//self.window.backgroundColor = [UIColor whiteColor];
	
	//self.window.backgroundColor = [HONAppDelegate honOrthodoxGreenColor];
	//self.window.frame = CGRectOffset(self.window.frame, 0.0, 20.0);
	
	[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
	[[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
														  [UIColor whiteColor], UITextAttributeTextColor,
														  [UIColor clearColor], UITextAttributeTextShadowColor,
														  [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18], UITextAttributeFont, nil]];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButtonIcon_nonActive"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButtonIcon_Active"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
														  [UIColor whiteColor], UITextAttributeTextColor,
														  [UIColor clearColor], UITextAttributeTextShadowColor,
														  [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17], UITextAttributeFont,nil] forState:UIControlStateNormal];
	[[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
														  [UIColor whiteColor], UITextAttributeTextColor,
														  [UIColor clearColor], UITextAttributeTextShadowColor,
														  [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17], UITextAttributeFont,nil] forState:UIControlStateHighlighted];
	
	_isFromBackground = NO;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addViewToWindow:) name:@"ADD_VIEW_TO_WINDOW" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSearchTable:) name:@"SHOW_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideSearchTable:) name:@"HIDE_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showSubjectSearchTimeline:) name:@"SHOW_SUBJECT_SEARCH_TIMELINE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showUserSearchTimeline:) name:@"SHOW_USER_SEARCH_TIMELINE" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_pokeUser:) name:@"POKE_USER" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_sendToInstagram:) name:@"SEND_TO_INSTAGRAM" object:nil];
	
#ifdef FONTS
	[self _showFonts];
#endif
	
	//	[TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];
	//	[TestFlight takeOff:@"139f9073-a4d0-4ecd-9bb8-462a10380218"];
	
//	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"8ee8d69b4f24d1f5ac975bceb0b6f17f" delegate:self];
//	[[BITHockeyManager sharedHockeyManager] startManager];
	
//	TSConfig *config = [TSConfig configWithDefaults];
//	config.collectWifiMac = NO;
//	config.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//	//config.odin1 = @"<ODIN-1 value goes here>";
//	//config.openUdid = @"<OpenUDID value goes here>";
//	//config.secureUdid = @"<SecureUDID value goes here>";
//	[TSTapstream createWithAccountName:@"volley" developerSecret:@"xJCRiJCqSMWFVF6QmWdp8g" config:config];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"timeline2_banner"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"timeline2_banner"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"discover_banner"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"discover_banner"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"activity_banner"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"activity_banner"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
	if ([HONAppDelegate hasNetwork]) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"votes"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"])
			[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"audio_muted"];
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"])
			[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"local_challenges"];
		
		NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
		[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
		[UAirship takeOff:takeOffOptions];
		[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		
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
		
		if (boot_total == 5) {
			UIAlertView *alertView = [[UIAlertView alloc]
									  initWithTitle:@"Rate Volley"
									  message:@"Why not rate Volley in the app store!"
									  delegate:self
									  cancelButtonTitle:nil
									  otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
			[alertView setTag:2];
			[alertView show];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"])
			[HONAppDelegate setAllowsFBPosting:NO];
		
		//[self _retrieveConfigJSON];
		
		[Mixpanel sharedInstanceWithToken:kMixPanelToken];
		[[Mixpanel sharedInstance] track:@"App Boot"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		
		self.tabBarController = [[HONTabBarController alloc] init];
		//self.tabBarController.view.frame = CGRectOffset(self.tabBarController.view.frame, 0.0, 20.0);
		self.tabBarController.delegate = self;
		
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
		_bgImageView.frame = CGRectMake(0.0, [[UIApplication sharedApplication] statusBarFrame].size.height, 320.0, [UIScreen mainScreen].bounds.size.height);
		[self.tabBarController.view addSubview:_bgImageView];
		
		self.window.rootViewController = self.tabBarController;
		[self.window makeKeyAndVisible];
		
	} else {
		[self _showOKAlert:@"No Network Connection"
			   withMessage:@"This app requires a network connection to work."];
	}
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[Mixpanel sharedInstance] track:@"App Entering Background"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBSettings publishInstall:kFacebookAppID];
	
	//	[FBAppCall handleDidBecomeActive];
	
	if (_isFromBackground && [HONAppDelegate hasNetwork]) {
		[[Mixpanel sharedInstance] track:@"App Leaving Background"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (![HONAppDelegate canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
			
		} else {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
			[self _retrieveConfigJSON];
			//_isFromBackground = NO;
		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[UAirship land];
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
	[self _retrieveConfigJSON];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	
	NSString *deviceID = [NSString stringWithFormat:@"%064d", 0];
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	[self _retrieveConfigJSON];
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
	
	if (!_isFromBackground) {
		// sms sound
		AudioServicesPlaySystemSound(1007);
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:nil];
		
		int type_id = [[userInfo objectForKey:@"type"] intValue];
		switch (type_id) {
				
			// challenge request
			case 1:{
				_challengeID = [[userInfo objectForKey:@"challenge"] intValue];
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Snap Update"
																	message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
																   delegate:self
														  cancelButtonTitle:@"Cancel"
														  otherButtonTitles:@"OK", nil];
				[alertView setTag:3];
				[alertView show];
				break;}
				
				// poke
			case 2:
				[self _showOKAlert:@"Poke"
					   withMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
				break;
				
				// accpeted challenge
			case 3:
				[self _showOKAlert:@"Snap Update"
					   withMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
				break;
				
			default:
				[self _showOKAlert:@""
					   withMessage:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
				break;
		}
		
	} else {
		if ([[userInfo objectForKey:@"type"] intValue] == 1)
			[self _challengeObjectFromPush:[[userInfo objectForKey:@"challenge"] intValue]];
	}
	
//	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//	localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
//	localNotification.alertBody = [NSString stringWithFormat:@"%d", [[userInfo objectForKey:@"type"] intValue]];;
//	localNotification.soundName = UILocalNotificationDefaultSoundName;
//	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
//	return [FBSession.activeSession handleOpenURL:url];
//}


#pragma mark - Startup Operations
- (void)_retrieveConfigJSON {
	VolleyJSONLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCONFIG_JSON:[%@/%@]", kConfigURL, kConfigJSON);
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], kConfigURL, kConfigJSON);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kConfigURL]];
	[httpClient postPath:kConfigJSON parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		
		if (error != nil)
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
		
		else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			
			NSMutableArray *locales = [NSMutableArray array];
			for (NSString *locale in [result objectForKey:@"enabled_locales"])
				[locales addObject:locale];
			
			NSMutableArray *inviteCodes = [NSMutableArray array];
			for (NSString *code in [result objectForKey:@"invite_codes"])
				[inviteCodes addObject:code];
			
			NSMutableArray *tutorialImages = [NSMutableArray array];
			for (NSString *tutorialImage in [result objectForKey:@"tutorial_images"])
				[tutorialImages addObject:tutorialImage];
			
			NSMutableArray *sectionBanners = [NSMutableArray array];
			for (NSString *sectionBanner in [result objectForKey:@"section_banners"])
				[sectionBanners addObject:sectionBanner];
			
			NSMutableArray *promoteImages = [NSMutableArray array];
			for (NSString *promoteImage in [result objectForKey:@"promote_images"])
				[promoteImages addObject:promoteImage];
			
			NSMutableArray *hashtags = [NSMutableArray array];
			for (NSString *hashtag in [result objectForKey:@"default_hashtags"])
				[hashtags addObject:hashtag];
			
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
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:
															  [[result objectForKey:@"point_multipliers"] objectForKey:@"vote"],
															  [[result objectForKey:@"point_multipliers"] objectForKey:@"poke"],
															  [[result objectForKey:@"point_multipliers"] objectForKey:@"create"], nil] forKey:@"point_mult"];
//			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
//															  [[result objectForKey:@"timeline_banner"] objectForKey:@"type"], @"type",
//															  [[result objectForKey:@"timeline_banner"] objectForKey:@"url"], @"url", nil] forKey:@"timeline_banner"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
															  [[result objectForKey:@"invite_sms"] objectForKey:@"en"], @"en",
															  [[result objectForKey:@"invite_sms"] objectForKey:@"id"], @"id",
															  [[result objectForKey:@"invite_sms"] objectForKey:@"ko"], @"ko",
															  [[result objectForKey:@"invite_sms"] objectForKey:@"jp"], @"jp",
															  [[result objectForKey:@"invite_sms"] objectForKey:@"vi"], @"vi",
															  [[result objectForKey:@"invite_sms"] objectForKey:@"zn-Hant"], @"zn-Hant", nil] forKey:@"invite_sms"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
															  [[result objectForKey:@"invite_email"] objectForKey:@"en"], @"en",
															  [[result objectForKey:@"invite_email"] objectForKey:@"id"], @"id",
															  [[result objectForKey:@"invite_email"] objectForKey:@"ko"], @"ko",
															  [[result objectForKey:@"invite_email"] objectForKey:@"jp"], @"jp",
															  [[result objectForKey:@"invite_email"] objectForKey:@"vi"], @"vi",
															  [[result objectForKey:@"invite_email"] objectForKey:@"zn-Hant"], @"zn-Hant", nil] forKey:@"invite_email"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
															  [[result objectForKey:@"insta_profile"] objectForKey:@"en"], @"en",
															  [[result objectForKey:@"insta_profile"] objectForKey:@"id"], @"id",
															  [[result objectForKey:@"insta_profile"] objectForKey:@"ko"], @"ko",
															  [[result objectForKey:@"insta_profile"] objectForKey:@"jp"], @"jp",
															  [[result objectForKey:@"insta_profile"] objectForKey:@"vi"], @"vi",
															  [[result objectForKey:@"insta_profile"] objectForKey:@"zn-Hant"], @"zn-Hant", nil] forKey:@"insta_profile"];
			[[NSUserDefaults standardUserDefaults] setObject:[locales copy] forKey:@"enabled_locales"];
			[[NSUserDefaults standardUserDefaults] setObject:[inviteCodes copy] forKey:@"invite_codes"];
			[[NSUserDefaults standardUserDefaults] setObject:[tutorialImages copy] forKey:@"tutorial_images"];
			[[NSUserDefaults standardUserDefaults] setObject:[sectionBanners copy] forKey:@"section_banners"];
			[[NSUserDefaults standardUserDefaults] setObject:[promoteImages copy] forKey:@"promote_images"];
			[[NSUserDefaults standardUserDefaults] setObject:[hashtags copy] forKey:@"default_subjects"];
			[[NSUserDefaults standardUserDefaults] setObject:[subjects copy] forKey:@"search_subjects"];
			[[NSUserDefaults standardUserDefaults] setObject:[users copy] forKey:@"search_users"];
			[[NSUserDefaults standardUserDefaults] setObject:[celebs copy] forKey:@"invite_celebs"];
			[[NSUserDefaults standardUserDefaults] setObject:[populars copy] forKey:@"popular_people"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
			
			
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
				
				NSLog(@"REFRESHING:[%@]", notificationName);
				[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
			}
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
							[HONAppDelegate deviceToken], @"token",
							nil];
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
			VolleyJSONLog(@"AFNetworking [-] %@: %@ %@", [[self class] description], userResult, httpClient.baseURL);
			
			if ([userResult objectForKey:@"id"] != [NSNull null]) {
				[HONAppDelegate writeUserInfo:userResult];
				[HONImagingDepictor writeImageFromWeb:[userResult objectForKey:@"avatar_url"] withDimensions:CGSizeMake(kAvatarDim, kAvatarDim) withUserDefaultsKey:@"avatar_image"];
			}
			
			[self _initTabs];
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

- (void)_initTabs {
	[_bgImageView removeFromSuperview];
	
	UIViewController *timelineViewController, *discoveryViewController, *challengesViewController, *profileViewController;
	timelineViewController = [[HONTimelineViewController alloc] initWithFriends];
	discoveryViewController = [[HONDiscoveryViewController alloc] init];
	challengesViewController = [[HONChallengesViewController alloc] init];
	//profileViewController = [[HONProfileViewController alloc] init];
	profileViewController = [[HONTimelineViewController alloc] initWithUsername:[[HONAppDelegate infoForUser] objectForKey:@"username"]];
	
	UINavigationController *navigationController1 = [[UINavigationController alloc] initWithRootViewController:timelineViewController];
	UINavigationController *navigationController2 = [[UINavigationController alloc] initWithRootViewController:discoveryViewController];
	UINavigationController *navigationController3 = [[UINavigationController alloc] initWithRootViewController:challengesViewController];
	UINavigationController *navigationController4 = [[UINavigationController alloc] initWithRootViewController:profileViewController];
		
	if ([navigationController1.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController1.navigationBar setShadowImage:[[UIImage alloc] init]];
	
	if ([navigationController2.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController2.navigationBar setShadowImage:[[UIImage alloc] init]];
	
	if ([navigationController3.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController3.navigationBar setShadowImage:[[UIImage alloc] init]];
	
	if ([navigationController4.navigationBar respondsToSelector:@selector(setShadowImage:)])
		[navigationController4.navigationBar setShadowImage:[[UIImage alloc] init]];
		
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:navigationController1, navigationController2, navigationController3, navigationController4, nil];
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
		switch (buttonIndex) {
			case 0:
				break;
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
	if (alertView.tag == 3) {
		switch (buttonIndex) {
			case 1:
				NSLog(@"CHALLENGE:(%d)", _challengeID);
				[self _challengeObjectFromPush:_challengeID];
				break;
		}
	}
}

#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Presenting DocInteraction Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	[[Mixpanel sharedInstance] track:@"Dismissing DocInteraction Shelf"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Launching DocInteraction App"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	[[Mixpanel sharedInstance] track:@"Entering DocInteraction App Foreground"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [controller name], @"controller", nil]];
}


#pragma mark - UpdateManager Delegates
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
#ifndef CONFIGURATION_AppStore
	if ([[UIDevice currentDevice] respondsToSelector:@selector(uniqueIdentifier)])
		return [[UIDevice currentDevice] performSelector:@selector(uniqueIdentifier)];
#endif
	return nil;
}

@end
