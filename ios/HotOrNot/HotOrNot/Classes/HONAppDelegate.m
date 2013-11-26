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
#import <AWSiOSSDK/S3/AmazonS3Client.h>
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
#import "UIImageView+AFNetworking.h"

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
#import "HONImagingDepictor.h"
#import "HONChallengeDetailsViewController.h"
#import "HONAddContactsViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSettingsViewController.h"
#import "HONSuspendedViewController.h"


#if __DEV_BUILD___ == 0
NSString * const kConfigURL = @"http://api.letsvolley.com";
NSString * const kConfigJSON = @"boot_sc0001.json";
NSString * const kAPIHost = @"data_api";
NSString * const kMixPanelToken = @"7de852844068f082ddfeaf43d96e998e"; // Volley 1.2.3/4
#else
NSString * const kConfigURL = @"http://api-stage.letsvolley.com";
NSString * const kConfigJSON = @"boot_matt.json";
NSString * const kAPIHost = @"data_api-dev";
NSString * const kMixPanelToken = @"c7bf64584c01bca092e204d95414985f"; // Dev
#endif


//NSString * const kMixPanelToken = @"d93069ad5b368c367c3adc020cce8021"; // Focus Group I
//NSString * const kMixPanelToken = @"8ae70817a3d885455f940ff261657ec7"; // Soft Launch I
//NSString * const kMixPanelToken = @"de3e67b68e6b8bf0344ca58573733ee5"; // Soft Launch II
NSString * const kFacebookAppID = @"600550136636754";
NSString * const kTestFlightAppToken = @"68bcb8c2-c40e-4e3b-afdc-5d14a89eb4a0";
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
NSString * const kAPICreateChallenge = @"challenges/create";
NSString * const kAPIJoinChallenge = @"challenges/join";
NSString * const kAPIGetVerifyList = @"challenges/getVerifyList";
NSString * const kAPIMissingImage = @"challenges/missingimage";
NSString * const kAPIProcessChallengeImage = @"challenges/processimage";
NSString * const kAPIProcessUserImage = @"users/processimage";
NSString * const kAPISuspendedAccount = @"users/suspendedaccount";
NSString * const kAPIPurgeUser = @"users/purge";
NSString * const kAPIPurgeContent = @"users/purgecontent";


// view heights
const CGFloat kNavBarHeaderHeight = 77.0f;
const CGFloat kSearchHeaderHeight = 49.0f;
const CGFloat kOrthodoxTableHeaderHeight = 31.0f;
const CGFloat kOrthodoxTableCellHeight = 63.0f;

// snap params
const CGFloat kMinLuminosity = 0.00;
const CGFloat kSnapRatio = 1.33333333f;
const CGFloat kSnapJPEGCompress = 0.400f;

//const CGFloat kSnapLumThreshold = 0.297f;
//const CGFloat kSnapDarkBrightness = 1.720f;
//const CGFloat kSnapDarkContrast = 1.288f;
//const CGFloat kSnapDarkSaturation = 1.38f;
//const CGFloat kSnapLightBrightness = 1.288f;
//const CGFloat kSnapLightContrast = 1.030f;
//const CGFloat kSnapLightSaturation = 1.012f;

// animation params
const CGFloat kHUDTime = 0.5f;
const CGFloat kHUDErrorTime = 1.5f;
const CGFloat kProfileTime = 0.25f;

// image sizes
const CGSize kSnapThumbSize = {80.0f, 80.0f};
const CGSize kSnapTabSize = {320.0f, 480.0f};
const CGSize kSnapMediumSize = {160.0f, 160.0f};
const CGSize kSnapLargeSize = {320.0f, 568.0f};
const CGFloat kAvatarDim = 200.0f;

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
@interface HONAppDelegate() <AmazonServiceRequestDelegate, BITHockeyManagerDelegate, BITUpdateManagerDelegate, BITCrashManagerDelegate>
#else
@interface HONAppDelegate() <AmazonServiceRequestDelegate>
#endif
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) NSTimer *userTimer;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic) int challengeID;
@property (nonatomic) BOOL awsUploadCounter;
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
	    [data appendString:[HONAppDelegate advertisingIdentifierWithoutSeperators:NO]];
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
 

+ (NSString *)advertisingIdentifierWithoutSeperators:(BOOL)noDashes {
	return ((noDashes) ? [[[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""]  : [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString]);
}

+ (NSString *)identifierForVendorWithoutSeperators:(BOOL)noDashes {
	return ((noDashes) ? [[[UIDevice currentDevice].identifierForVendor UUIDString] stringByReplacingOccurrencesOfString:@"-" withString:@""] : [[UIDevice currentDevice].identifierForVendor UUIDString]);
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

+ (NSDictionary *)infoForABTab{
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"verify_AB"] objectAtIndex:(int)[HONAppDelegate switchEnabledForKey:@"verify_tab"]]);
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

+ (NSRange)ageRangeAsSeconds:(BOOL)isInSeconds {	
	return ((isInSeconds) ? NSMakeRange([[[[NSUserDefaults standardUserDefaults] objectForKey:@"age_range"] objectAtIndex:0] intValue] * 31536000, [[[[NSUserDefaults standardUserDefaults] objectForKey:@"age_range"] objectAtIndex:1] intValue] * 31536000) : NSMakeRange([[[[NSUserDefaults standardUserDefaults] objectForKey:@"age_range"] objectAtIndex:0] intValue], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"age_range"] objectAtIndex:1] intValue]));
}

+ (NSString *)s3BucketForType:(NSString *)bucketType {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"s3_buckets"] objectForKey:bucketType]);
}

+ (int)profileSubscribeThreshold {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"profile_subscribe"] intValue]);
}

+ (BOOL)switchEnabledForKey:(NSString *)key {
	return ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"switches"] objectForKey:key] uppercaseString] isEqualToString:@"YES"]);
}

+ (int)incTotalForCounter:(NSString *)key {
	NSString *counterName = [NSString stringWithFormat:@"%@_total", [key lowercaseString]];
	
	int tot = [[[NSUserDefaults standardUserDefaults] objectForKey:counterName] intValue];
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++tot] forKey:counterName];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	counterName = nil;
	return (tot);
}

+ (int)totalForCounter:(NSString *)key {
	NSString *counterName = [NSString stringWithFormat:@"%@_total", [key lowercaseString]];
	int tot = [[[NSUserDefaults standardUserDefaults] objectForKey:counterName] intValue];
	
	counterName = nil;
	return (tot);
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
}

+ (NSDictionary *)stickerForSubject:(NSString *)subject {
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"stickers"]) {
		if ([[dict objectForKey:@"hashtag"] isEqualToString:subject])
			return (dict);
	}
	
	return (nil);
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

+ (void)cacheNextImagesWithRange:(NSRange)range fromURLs:(NSArray *)urls withTag:(NSString *)tag {
	NSLog(@"QUEUEING : |]%@]>{%@)_", NSStringFromRange(range), tag);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { };
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {};
	
	for (int i=0; i<range.length - range.location; i++) {
//		NSLog(@"s+ArT_l0Ad. --> (#%02d) \"%@\"", (range.location + i), [urls objectAtIndex:i]);
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[imageView setTag:range.location + i];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[urls objectAtIndex:i] cachePolicy:(kIsImageCacheEnabled) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:3]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];
	}
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
														  [NSString stringWithFormat:@"%d", 0], @"total_votes",
														  [NSString stringWithFormat:@"%d", 0], @"pokes",
														  [NSString stringWithFormat:@"%d", 0], @"pics",
														  [NSString stringWithFormat:@"%d", 0], @"age",
														  [[dict objectForKey:@"user"] objectForKey:@"username"], @"username",
														  @"", @"fb_id",
														  [[dict objectForKey:@"user"] objectForKey:@"avatar_url"], @"avatar_url", nil]]];
	}
	
	return (@[[friends sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]]]]);
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

+ (BOOL)isFollowedByUser:(int)userID {
	BOOL isFollowed = NO;
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != userID) {
		for (HONUserVO *vo in [HONAppDelegate friendsList]) {
			if (vo.userID == userID) {
				isFollowed = YES;
				break;
			}
		}
	}
	
	return (isFollowed);
}

+ (NSArray *)subscribeeList {
	NSMutableArray *subscribees = [NSMutableArray array];
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"subscribees"]) {
		[subscribees addObject:[HONUserVO userWithDictionary:[NSDictionary dictionaryWithObjectsAndKeys:
														  [NSString stringWithFormat:@"%d", [[[dict objectForKey:@"user"] objectForKey:@"id"] intValue]], @"id",
														  [NSString stringWithFormat:@"%d", 0], @"points",
														  [NSString stringWithFormat:@"%d", 0], @"total_votes",
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

+ (BOOL)isFollowingUser:(int)userID {
	BOOL isFollowing = NO;
	if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] != userID) {
		for (HONUserVO *vo in [HONAppDelegate subscribeeList]) {
			if (vo.userID == userID) {
				isFollowing = YES;
				break;
			}
		}
	}
	
	return (isFollowing);
}


+ (BOOL)isChallengeParticipant:(HONChallengeVO *)challengeVO {
	for (HONOpponentVO *vo in challengeVO.challengers) {
		if (vo.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue])
			return (YES);
	}
	
	return ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == challengeVO.creatorVO.userID);
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

+ (void)setVoteForChallenge:(HONChallengeVO *)challengeVO forParticipant:(HONOpponentVO *)opponentVO {
	NSMutableArray *upvoteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"upvotes"] mutableCopy];
	NSDictionary *dict = @{@"challenge_id"		: [NSString stringWithFormat:@"%d", challengeVO.challengeID],
						   @"participant_id"	: [NSString stringWithFormat:@"%d", opponentVO.userID]};
	
//	[upvoteArray addObject:[NSNumber numberWithInt:(isCreator) ? challengeID : -challengeID]];
//	[[NSUserDefaults standardUserDefaults] setObject:voteArray forKey:@"votes"];
	
	[upvoteArray addObject:dict];
	[[NSUserDefaults standardUserDefaults] setObject:upvoteArray forKey:@"upvotes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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

+ (BOOL)isIOS7 {
	return ([[[[UIDevice currentDevice] systemVersion] substringToIndex:1] isEqualToString:@"7"]);
}

+ (BOOL)hasTakenSelfie {
	return (YES);//[[[NSUserDefaults standardUserDefaults] objectForKey:@"skipped_selfie"] isEqualToString:@"NO"]);
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


+ (UIColor *)honPercentGreyscaleColor:(CGFloat)percent {
	return ([UIColor colorWithWhite:percent alpha:1.0]);
}

+ (UIColor *)honBlueTextColor {
	return ([UIColor colorWithRed:0.141 green:0.271 blue:0.925 alpha:1.0]);
	//return ([UIColor colorWithRed:0.071 green:0.439 blue:1.000 alpha:1.0]);
}

+ (UIColor *)honBlueTextColorHighlighted {
	return ([UIColor colorWithRed:0.580 green:0.729 blue:0.973 alpha:1.0]);
//	return ([UIColor colorWithRed:0.071 green:0.439 blue:1.000 alpha:0.5]);
}

+ (UIColor *)honGreenTextColor {
	return ([UIColor colorWithRed:0.451 green:0.757 blue:0.694 alpha:1.0]);
}

+ (UIColor *)honGreyTextColor {
	return ([UIColor colorWithWhite:0.600 alpha:1.0]);
}

+ (UIColor *)honDarkGreyTextColor {
	return ([UIColor colorWithWhite:0.400 alpha:1.0]);
}

+ (UIColor *)honLightGreyTextColor {
	return ([UIColor colorWithWhite:0.671 alpha:1.0]);
}

+ (UIColor *)honPlaceholderTextColor {
	return ([UIColor colorWithWhite:0.790 alpha:1.0]);
}

+ (UIColor *)honDebugColorByName:(NSString *)colorName atOpacity:(CGFloat)percent {
	return (([[colorName uppercaseString] isEqualToString:@"FUSCHIA"]) ? [UIColor colorWithRed:0.697 green:0.130 blue:0.811 alpha:MIN(MAX(0.33, percent), 1.00)] : [UIColor colorWithRed:((float)[[colorName uppercaseString] isEqualToString:@"RED"]) green:((float)[[colorName uppercaseString] isEqualToString:@"GREEN"]) blue:((float)[[colorName uppercaseString] isEqualToString:@"BLUE"]) alpha:MIN(MAX(0.33, percent), 1.00)]);
}


#pragma mark - Data Calls
- (void)_retrieveConfigJSON {
	NSString *configURLWithTimestamp = [NSString stringWithFormat:@"%@?epoch=%d", kConfigJSON, (int)[[NSDate date] timeIntervalSince1970]];
	VolleyJSONLog(@"\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]\nCONFIG_JSON:[%@/%@]", kConfigURL, kConfigJSON);
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], kConfigURL, configURLWithTimestamp);
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kConfigURL]];
	[httpClient postPath:configURLWithTimestamp parameters:[NSDictionary dictionary] success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		
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
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VOLLEY_JSON_LOG(@"AFNetworking [-] %@ |[:]>> BOOT JSON [:]|>>\n%@", [[self class] description], result);
			
			if ([result isEqual:[NSNull null]]) {
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
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"appstore_id"] forKey:@"appstore_id"];
				[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"endpts"] objectForKey:kAPIHost] forKey:@"server_api"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"service_url"] forKey:@"service_url"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"twilio_sms"] forKey:@"twilio_sms"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"splash_image"] forKey:@"splash_image"];
				[[NSUserDefaults standardUserDefaults] setObject:NSStringFromRange(NSMakeRange([[[result objectForKey:@"image_queue"] objectAtIndex:0] intValue], [[[result objectForKey:@"image_queue"] objectAtIndex:1] intValue])) forKey:@"image_queue"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"verify_msg"] forKey:@"verify_msg"];
				[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[result objectForKey:@"profile_subscribe"] intValue]] forKey:@"profile_subscribe"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"age_range"] forKey:@"age_range"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"filter_vals"] forKey:@"filter_vals"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"compose_emotions"] forKey:@"compose_emotions"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"reply_emotions"] forKey:@"reply_emotions"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"stickers"] forKey:@"stickers"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"search_hashtags"] forKey:@"search_subjects"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"search_users"] forKey:@"search_users"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invite_celebs"] forKey:@"invite_celebs"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"popular_people"] forKey:@"popular_people"];
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"switches"] forKey:@"switches"];
				[[NSUserDefaults standardUserDefaults] setObject:@{@"challenges"	: [[result objectForKey:@"s3_buckets"] objectForKey:@"challenges"],
																   @"avatars"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"avatars"],
																   @"emoticons"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"emoticons"]} forKey:@"s3_buckets"];
				[[NSUserDefaults standardUserDefaults] setObject:@{@"sms"	: [[result objectForKey:@"invite_formats"] objectForKey:@"sms"],
																   @"email"	: [[result objectForKey:@"invite_formats"] objectForKey:@"email"]} forKey:@"invite_formats"];
				[[NSUserDefaults standardUserDefaults] setObject:@{@"instagram"	: [[result objectForKey:@"share_formats"] objectForKey:@"instagram"],
																   @"twitter"	: [[result objectForKey:@"share_formats"] objectForKey:@"twitter"]} forKey:@"share_formats"];
				
				[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"verify_AB"] forKey:@"verify_AB"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"UPDATE_TAB_BAR_AB" object:nil];
				
				if ([[result objectForKey:@"update_app"] isEqualToString:@"Y"]) {
					[self _showOKAlert:@"Update Required"
						   withMessage:[NSString stringWithFormat:@"Please update %@ to the latest version to use the latest features.", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]];
				}
				
				if (!_isFromBackground)
					[self _registerUser];
				
				else {
					_isFromBackground = NO;
					NSString *notificationName = @"";
					switch ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue]) {
						case 0:
							notificationName = @"REFRESH_HOME_TAB";
							break;
							
						case 1:
							notificationName = @"REFRESH_EXPLORE_TAB";
							break;
							
						case 2:
							notificationName = @"REFRESH_VERIFY_TAB";
							break;
						
						default:
							notificationName = @"REFRESH_HOME_TAB";
							break;
					}
					
					if ([HONAppDelegate isRetina4Inch]) {
						NSLog(@"REFRESHING:[%@]", notificationName);
						[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
					}
				}
//				_userTimer = [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(_retryUser) userInfo:nil repeats:YES];
			
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
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 1]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"], params);
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
			
			if ([userResult objectForKey:@"id"] != [NSNull null] || [userResult count] > 0) {
				[HONAppDelegate writeUserInfo:userResult];
				[HONImagingDepictor writeImageFromWeb:[userResult objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
				
				if ([[[HONAppDelegate infoForUser] objectForKey:@"age"] isEqualToString:@"0000-00-00 00:00:00"])
					[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
			
#if __IGNORE_SUSPENDED__ == 1
				[self _retreiveSubscribees];
#else
				if ((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_suspended"] intValue]) {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuspendedViewController alloc] init]];
					[navigationController setNavigationBarHidden:YES];
					[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
					
				} else
					[self _retreiveSubscribees];
#endif
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

- (void)_retreiveSubscribees {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
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
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			[HONAppDelegate writeSubscribeeList:result];
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

- (void)_enableNotifications:(BOOL)isEnabled {
	NSDictionary *params = @{@"action"			: [NSString stringWithFormat:@"%d", 4],
							 @"userID"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"isNotifications"	: (isEnabled) ? @"Y" : @"N"};
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"], params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
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
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult isEqual:[NSNull null]])
				[HONAppDelegate writeUserInfo:userResult];
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
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
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], challengeResult);
			
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:challengeResult] withBackground:nil]];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChallengeDetailsViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:challengeResult]]];
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

- (void)_updateChallenge:(int)challengeID asSeen:(BOOL)hasSeen {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 6], @"action",
							[NSString stringWithFormat:@"%d",challengeID], @"challengeID",
							(hasSeen) ? @"Y" : @"N", @"hasSeen",
							nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [params objectForKey:@"action"], params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSLog(@"AFNetworking HONChallengesViewController: %@", result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}


#pragma mark - Notifications
- (void)_addViewToWindow:(NSNotification *)notification {
	[self.window addSubview:(UIView *)[notification object]];
}

- (void)_changeTab:(NSNotification *)notification {
	self.tabBarController.selectedIndex = [[notification object] intValue];
}

- (void)_showShareShelf:(NSNotification *)notification {
	_shareInfo = [notification object];
	
//	NSLog(@"_showShareShelf:[%@]", _shareInfo);
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

- (void)_playOverlayAnimation:(NSNotification *)notification {
	UIImageView *animationImageView = [notification object];
	animationImageView.frame = CGRectOffset(animationImageView.frame, ([UIScreen mainScreen].bounds.size.width - animationImageView.frame.size.width) * 0.5, ([UIScreen mainScreen].bounds.size.height - animationImageView.frame.size.height) * 0.5);
	[self.window addSubview:animationImageView];
	
	[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
		animationImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[animationImageView removeFromSuperview];
	}];
}

- (void)_recreateImageSizes:(NSNotification *)notification {
	NSDictionary *params = @{@"imgURL"	: [HONAppDelegate cleanImagePrefixURL:[notification object]]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage, params);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIProcessUserImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
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
//			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
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

- (void)_updateChallengeAsSeen:(NSNotification *)notification {
	[self _updateChallenge:[[[notification object] objectForKey:@"id"] intValue] asSeen:[[[notification object] objectForKey:@"seen"] isEqualToString:@"Y"]];
}


- (void)_uploadImagesToAWS:(NSNotification *)notification {
	NSLog(@"_uploadImagesToAWS:[%@]", [notification object]);
	
	NSDictionary *dict = [notification object];
	if ([[dict objectForKey:@"url"] length] > 0) {
		_awsUploadCounter = 0;
		
		AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-avatars"]];
		
		@try {
			NSArray *putObjectRequests = [dict objectForKey:@"pors"];
			for (S3PutObjectRequest *por in putObjectRequests) {
				NSString *url = [NSString stringWithFormat:@"%@", por.url];
				
				por.delegate = self;
				por.requestTag = [NSString stringWithFormat:@"%@|%@", por.bucket, ([url rangeOfString:kSnapLargeSuffix].location < [url length]) ? kSnapLargeSuffix : kSnapTabSuffix];
				[s3 putObject:por];
			}
			
		} @catch (AmazonClientException *exception) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:@"avatars"], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		}
	}
}


#pragma mark - UI Presentation
- (void)_showOKAlert:(NSString *)title withMessage:(NSString *)message {
	[[[UIAlertView alloc] initWithTitle:title
								message:message
							   delegate:nil
					  cancelButtonTitle:@"OK"
					  otherButtonTitles:nil] show];
}

- (void)_styleUIAppearance {
	NSShadow *shadow = [NSShadow new];
	[shadow setShadowColor:[UIColor clearColor]];
	[shadow setShadowOffset:CGSizeMake(0.0f, 0.0f)];
	
	//[[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"header"] forBarMetrics:UIBarMetricsDefault];
	
	if ([HONAppDelegate isIOS7])
		[[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.506 green:0.780 blue:0.725 alpha:1.0]];
	
	else
		[[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.506 green:0.780 blue:0.725 alpha:1.0]];
	
	[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName	: [UIColor whiteColor],
														   NSShadowAttributeName			: shadow,
														   NSFontAttributeName				: [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:20]}];
	
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName	: [UIColor whiteColor],
														   NSShadowAttributeName			: shadow,
														   NSFontAttributeName				: [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:17]} forState:UIControlStateNormal];
	[[UIBarButtonItem appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName	: [UIColor whiteColor],
														   NSShadowAttributeName			: shadow,
														   NSFontAttributeName				: [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:17]} forState:UIControlStateHighlighted];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButtonIcon_nonActive"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
	[[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setBackButtonBackgroundImage:[[UIImage imageNamed:@"backButtonIcon_Active"] stretchableImageWithLeftCapWidth:23.0 topCapHeight:0.0] forState:UIControlStateHighlighted barMetrics:UIBarMetricsDefault];
	
	if ([HONAppDelegate isIOS7])
		[[UITabBar appearance] setBarTintColor:[UIColor clearColor]];
	
	else
		[[UITabBar appearance] setTintColor:[UIColor clearColor]];
	
	[[UITabBar appearance] setShadowImage:[[UIImage alloc] init]];
	[[UITabBar appearance] setBackgroundImage:[UIImage imageNamed:@"tabMenuBackground"]];
	
	if ([HONAppDelegate isIOS7])
		[[UIToolbar appearance] setBarTintColor:[UIColor clearColor]];
	
	else
		[[UIToolbar appearance] setTintColor:[UIColor clearColor]];
	
	[[UIToolbar appearance] setShadowImage:[[UIImage alloc] init] forToolbarPosition:UIBarPositionAny];
	[[UIToolbar appearance] setBackgroundImage:[UIImage imageNamed:@"subDetailsFooterBackground"] forToolbarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
	[[UIToolbar appearance] setBarStyle:UIBarStyleBlackTranslucent];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_isFromBackground = NO;
	
	[self _styleUIAppearance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_addViewToWindow:) name:@"ADD_VIEW_TO_WINDOW" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showShareShelf:) name:@"SHOW_SHARE_SHELF" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_initTabBar:) name:@"INIT_TAB_BAR" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeTab:) name:@"CHANGE_TAB" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_recreateImageSizes:) name:@"RECREATE_IMAGE_SIZES" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playOverlayAnimation:) name:@"PLAY_OVERLAY_ANIMATION" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_uploadImagesToAWS:) name:@"UPLOAD_IMAGES_TO_AWS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateChallengeAsSeen:) name:@"UPDATE_CHALLENGE_AS_SEEN" object:nil];
	

#if __APPSTORE_BUILD__ == 0
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppToken delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];
	
	[TestFlight takeOff:kTestFlightAppToken];
#endif
	
	TSConfig *config = [TSConfig configWithDefaults];
	config.collectWifiMac = NO;
	config.idfa = [HONAppDelegate advertisingIdentifierWithoutSeperators:NO];
	//config.odin1 = @"<ODIN-1 value goes here>";
	//config.openUdid = @"<OpenUDID value goes here>";
	//config.secureUdid = @"<SecureUDID value goes here>";
	[TSTapstream createWithAccountName:@"volley" developerSecret:@"xJCRiJCqSMWFVF6QmWdp8g" config:config];
	[[NSUserDefaults standardUserDefaults] synchronize];

	[self _establishUserDefaults];
	
	if ([HONAppDelegate hasNetwork]) {
		if (![HONAppDelegate canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		}
		
//		[KikAPIClient registerAsKikPluginWithAppID:@"kik-com.builtinmenlo.hotornot"
//								   withHomepageURI:@"http://www.builtinmenlo.com"
//									  addAppButton:YES];
		
		
//		int boot_total = 0;
//		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"])
//			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
//		
//		else {
//			boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
//			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++boot_total] forKey:@"boot_total"];
//		}
		
//		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
//			[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
		
//		int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"]] / 86400;
		
//		if (boot_total == 5) {
//			UIAlertView *alertView = [[UIAlertView alloc]
//									  initWithTitle:[NSString stringWithFormat:@"Rate %@", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]
//									  message:[NSString stringWithFormat:@"Why not rate %@ in the app store!", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]
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
		
		self.window.rootViewController = self.tabBarController;
		self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
		//self.window.rootViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
		self.window.backgroundColor = [UIColor whiteColor];
		[self.window makeKeyAndVisible];
		
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
		[UAPush shared].notificationTypes = (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert);
				
		[HONAppDelegate writeDeviceToken:@""];
		[self _retrieveConfigJSON];
		
//		NSLog(@"ADID:[%@]\nVID:[%@]", [HONAppDelegate advertisingIdentifierWithoutSeperators:YES], [HONAppDelegate identifierForVendorWithoutSeperators:YES]);
		
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
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	[[Mixpanel sharedInstance] track:@"App Entering Background"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
//	if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] isEqualToString:@"YES"])
//		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	
	[HONAppDelegate incTotalForCounter:@"background"];
	
//	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"background_total"] intValue];
//	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"background_total"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
	
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
	
	if (_isFromBackground) {
//		Mixpanel *mixpanel = [Mixpanel sharedInstance];
//		[mixpanel identify:[HONAppDelegate advertisingIdentifierWithoutSeperators:NO]];
//		[mixpanel.people set:@{@"$email"		: [[HONAppDelegate infoForUser] objectForKey:@"email"],
//							   @"$created"		: [[HONAppDelegate infoForUser] objectForKey:@"added"],
//							   @"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
//							   @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
//							   @"deactivated"	: [[NSUserDefaults standardUserDefaults] objectForKey:@"is_deactivated"]}];
		
		if ([HONAppDelegate hasNetwork]) {
			[[Mixpanel sharedInstance] track:@"App Leaving Background"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
			
			
			if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
				if ([HONAppDelegate totalForCounter:@"background"] == 2 && [HONAppDelegate switchEnabledForKey:@"background_invite"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"INVITE FRIENDS?"
																		message:@"Get more followers now, tap OK."
																	   delegate:self
															  cancelButtonTitle:@"No"
															  otherButtonTitles:@"OK", nil];
					[alertView setTag:3];
					[alertView show];
				}
				
				if ([HONAppDelegate totalForCounter:@"background"] == 4 && [HONAppDelegate switchEnabledForKey:@"background_share"]) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"SHARE %@?", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"VOLLEY" : @"SELFIECLUB"]
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
				[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_TABS" object:nil];
				[self _retrieveConfigJSON];
				_isFromBackground = NO;
			}
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
	
	Mixpanel *mixpanel = [Mixpanel sharedInstance];
	[mixpanel identify:[HONAppDelegate advertisingIdentifierWithoutSeperators:NO]];
	[mixpanel.people addPushDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	
	if ([HONAppDelegate apiServerPath] != nil && [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"N"])
		[self _enableNotifications:YES];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", error.description);
	
	NSString *holderToken = ([[HONAppDelegate advertisingIdentifierWithoutSeperators:NO] isEqualToString:@"DAE17C43-B4AD-4039-9DD4-7635420126C0"]) ? [NSString stringWithFormat:@"%064d", 0] : @"";
	
	Mixpanel *mixpanel = [Mixpanel sharedInstance];
	[mixpanel identify:[HONAppDelegate advertisingIdentifierWithoutSeperators:NO]];
	[mixpanel.people addPushDeviceToken:[holderToken dataUsingEncoding:NSUTF8StringEncoding]];
	
	[HONAppDelegate writeDeviceToken:holderToken];
	
	if ([HONAppDelegate apiServerPath] != nil && [[[HONAppDelegate infoForUser] objectForKey:@"notifications"] isEqualToString:@"Y"])
		[self _enableNotifications:NO];
	
//	if ([[HONAppDelegate advertisingIdentifierWithoutSeperators:NO] isEqualToString:@"DAE17C43-B4AD-4039-9DD4-7635420126C0"]) {
//		NSString *deviceID = [NSString stringWithFormat:@"%064d", 0];
//		[HONAppDelegate writeDeviceToken:deviceID];
//	
//	} else
//		[HONAppDelegate writeDeviceToken:@""];
	
//	if ([HONAppDelegate apiServerPath] != nil)
//		[self _enableNotifications:NO];
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
																	message:[NSString stringWithFormat:@"Awesome! You have been %@ Verified! Would you like to share %@ with your friends?", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub", ([HONAppDelegate switchEnabledForKey:@"volley_brand"]) ? @"Volley" : @"Selfieclub"]
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
- (void)_retryUser {
	NSLog(@"---RETRY USER [%d]---", (int)[HONAppDelegate infoForUser]);
	
	if (![HONAppDelegate infoForUser])
		[self _registerUser];
	
	else {
		[_userTimer invalidate];
		_userTimer = nil;
	}
}

- (void)_initTabs {
	NSArray *navigationControllers = @[[[UINavigationController alloc] initWithRootViewController:[[HONTimelineViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONExploreViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONVerifyViewController alloc] init]]];
	
	for (UINavigationController *navigationController in navigationControllers) {
		[navigationController setNavigationBarHidden:YES animated:NO];
		
		if ([navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)])
			[navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
	}
	
	self.tabBarController.view.hidden = NO;
	self.tabBarController.viewControllers = navigationControllers;
	self.window.backgroundColor = [UIColor clearColor];
	
//	if ([HONAppDelegate apiServerPath] != nil)
//		[self _enableNotifications:YES];
}

- (void)_establishUserDefaults {
	NSArray *totalKeys = @[@"boot_total",
						   @"@background_total",
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
						   @"join_total",
						   @"profile_total",
						   @"like_total"];
	
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"is_deactivated"])
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"is_deactivated"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"skipped_selfie"])
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"votes"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"])
		[[NSUserDefaults standardUserDefaults] setValue:[NSArray array] forKey:@"local_challenges"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"upvotes"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"upvotes"];
	
	NSArray *bannerKeys = @[@"home_banner", @"explore_banner", @"verify_banner"];
	for (NSString *key in bannerKeys) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:key])
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:key];
	}
	
	for (NSString *key in totalKeys) {
		if (![[NSUserDefaults standardUserDefaults] objectForKey:key])
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
	}
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
	
	NSDictionary *emptySuggestedChallenge = @{@"id":@"-2",
											  @"added":@"1970-01-01 00:00:00",
											  @"challengers":@[],
											  @"comments":@"0",
											  @"creator":@{@"age":@"1970-01-01 00:00:00",
														   @"avatar":@"",
														   @"id":@"0",
														   @"img":@"",
														   @"score":@"0",
														   @"subject":@"",
														   @"username":@"",
														   @"joined":@"1970-01-01 00:00:00"},
											  @"has_viewed":@"N",
											  @"is_celeb":@"0",
											  @"is_explore":@"1",
											  @"is_verify":@"0",
											  @"started":@"1970-01-01 00:00:00",
											  @"status":@"0",
											  @"subject":@"__#INVITE__",
											  @"updated":@"1970-01-01 00:00:00"};
	
	NSDictionary *emptyInviteChallenge = @{@"id":@"-1",
										   @"added":@"1970-01-01 00:00:00",
										   @"challengers":@[],
										   @"comments":@"0",
										   @"creator":@{@"age":@"1970-01-01 00:00:00",
														@"avatar":@"",
														@"id":@"0",
														@"img":@"",
														@"score":@"0",
														@"subject":@"",
														@"username":@"",
														@"joined":@"1970-01-01 00:00:00"},
										   @"has_viewed":@"N",
										   @"is_celeb":@"0",
										   @"is_explore":@"1",
										   @"is_verify":@"0",
										   @"started":@"1970-01-01 00:00:00",
										   @"status":@"0",
										   @"subject":@"__#INVITE__",
										   @"updated":@"1970-01-01 00:00:00"};
	
	NSDictionary *emptySearchChallenge = @{@"id":@"0",
										   @"added":@"1970-01-01 00:00:00",
										   @"challengers":@[],
										   @"comments":@"0",
										   @"creator":@{@"age":@"1970-01-01 00:00:00",
														@"avatar":@"",
														@"id":@"0",
														@"img":@"",
														@"score":@"0",
														@"subject":@"",
														@"username":@"",
														@"joined":@"1970-01-01 00:00:00"},
										   @"has_viewed":@"N",
										   @"is_celeb":@"0",
										   @"is_explore":@"1",
										   @"is_verify":@"0",
										   @"started":@"1970-01-01 00:00:00",
										   @"status":@"0",
										   @"subject":@"__#SEARCH__",
										   @"updated":@"1970-01-01 00:00:00"};
	
	[[NSUserDefaults standardUserDefaults] setObject:emptySuggestedChallenge forKey:@"empty_challenge_-2"];
	[[NSUserDefaults standardUserDefaults] setObject:emptyInviteChallenge forKey:@"empty_challenge_-1"];
	[[NSUserDefaults standardUserDefaults] setObject:emptySearchChallenge forKey:@"empty_challenge_0"];
	
#if __ALWAYS_REGISTER__ == 1
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"passed_registration"];
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	
	for (NSString *key in totalKeys)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
	
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"upvotes"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
#endif
	
#if __RESET_TOTALS__ == 1
	for (NSString *key in totalKeys)
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:-1] forKey:key];
#endif
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Debug Calls
- (void)_showFonts {
	for (NSString *familyName in [UIFont familyNames]) {
		NSLog(@"Font Family Name = %@", familyName);
		
		NSArray *names = [UIFont fontNamesForFamilyName:familyName];
		NSLog(@"Font Names = %@", names);
	}
}


#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
	NSLog(@"\nAWS didCompleteWithResponse:\n[%@] - %@", tag, request.url);
	
	if ([[tag objectAtIndex:1] isEqualToString:kSnapLargeSuffix]) {
		[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@", request.url] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		
		NSDictionary *params = @{@"imgURL"	: [HONAppDelegate cleanImagePrefixURL:[NSString stringWithFormat:@"%@", request.url]]};
		VolleyJSONLog(@"%@ —/> (%@/%@)\n%@", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage, params);
		AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
		[httpClient postPath:kAPIProcessUserImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
			NSError *error = nil;
			if (error != nil) {
				VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
				
			} else {
				VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error]);
			}
			
		} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
			VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		}];
	}
	
	_awsUploadCounter++;
	if (_awsUploadCounter == 2) {
		if ([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"]) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
		}
		
		_awsUploadCounter = 0;
	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", [error description]);
	NSArray *tag = [request.requestTag componentsSeparatedByString:@"|"];
	
	if ([[tag objectAtIndex:0] isEqualToString:@"hotornot-avatars"]) {
		[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:@"avatars"], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
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
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
																								@"image"			: [HONAppDelegate avatarImage],
																								@"url"				: @"",
																								@"mp_event"			: @"App Root",
																								@"view_controller"	: self.tabBarController}];
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
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"App Backgrounding - Invite Friends %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == 4) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"App Backgrounding - Share %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
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


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ - Share %@", [_shareInfo objectForKey:@"mp_event"], (buttonIndex == 0) ? @"Twitter" : (buttonIndex == 1) ? @"Instagram" : @"Cancel"]
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
				
				[twitterComposeViewController setInitialText:[[_shareInfo objectForKey:@"caption"] objectAtIndex:0]];
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
															  avatarImage:[_shareInfo objectForKey:@"image"]
																 username:[[HONAppDelegate infoForUser] objectForKey:@"username"]];
			[UIImageJPEGRepresentation(shareImage, 1.0f) writeToFile:savePath atomically:YES];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:instaURL]]) {
				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				_documentInteractionController.UTI = instaFormat;
				_documentInteractionController.delegate = self;
				_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[[_shareInfo objectForKey:@"caption"] objectAtIndex:1] forKey:@"InstagramCaption"];
				[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:((UIViewController *)[_shareInfo objectForKey:@"view_controller"]).view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Not Available"
											message:@"This device isn't allowed or doesn't recognize instagram"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
		}
		
		_shareInfo = nil;
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


#if __APPSTORE_BUILD__ == 0
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



// containsSubstring = ([string rangeOfString:@"bla"].location == NSNotFound);
