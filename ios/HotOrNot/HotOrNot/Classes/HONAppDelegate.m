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
#import <Tapjoy/Tapjoy.h>

//#import "NSData+Base64.h"
#import "Base64.h"
#import "NSString+DataTypes.h"

#import "AFNetworking.h"
#import "BlowfishAlgorithm.h"
#import "Chartboost.h"
#import "MBProgressHUD.h"
#import "KeenClient.h"
#import "KeychainItemWrapper.h"
#import "KikAPI.h"
#import "PCCandyStoreSearchController.h"
#import "PicoManager.h"
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
#import "HONTutorialView.h"
#import "HONTabBarController.h"
#import "HONInviteContactsViewController.h"
#import "HONClubPreviewViewController.h"
#import "HONUserClubsViewController.h"
#import "HONVerifyViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONTimelineViewController.h"
#import "HONFeedViewController.h"
#import "HONClubsNewsFeedViewController.h"
#import "HONAddContactsViewController.h"
#import "HONContactsTabViewController.h"
#import "HONUserProfileViewController.h"
#import "HONSettingsViewController.h"
#import "HONSuspendedViewController.h"
#import "HONSelfieCameraViewController.h"

#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
NSString * const kConfigURL = @"http://api.letsvolley.com";
NSString * const kConfigJSON = @"boot_sc0005.json";
NSString * const kAPIHost = @"data_api";
#else
NSString * const kConfigURL = @"http://api-stage.letsvolley.com";
NSString * const kConfigJSON = @"boot_devint.json";
NSString * const kAPIHost = @"data_api-stage";
#endif

NSString * const kBlowfishKey = @"KJkljP9898kljbm675865blkjghoiubdrsw3ye4jifgnRDVER8JND997";
NSString * const kBlowfishIV = @"„7ì”~ís";

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


NSString * const kKeenIOProductID = @"5390d1f705cd660561000003";
NSString * const kKeenIOMasterKey = @"D498C4D601DD4BEE1D65376E9D3D5248";
NSString * const kKeenIOReadKey = @"19c453075e8eaf3d30b11292819aaa5e268c6c0855eaacb86637f25afbcde7774a605636fc6a61f2b09ac3e01833c3ad8cf6b1e469a5f5ba2f4bc9beedfc2376910748d47acadd89e3e18a8bf5ee95b6ed3698aee6f48ede001bf73c8ba31dbace6170ff86bb735eefc67dae6df0b52e";
NSString * const kKeenIOWriteKey = @"7f1b91140d0fcf8aeb5ccde1a22567ea9073838582ee4725fae19a822f22d19ee243e95469f6b3d952007641901eaa8d5b4793af6ff7fe78f3d326e901d9fc14ed758e49f60c15b49cd85de79d7d04eace16ed79f79a7c9c012612c078f2d806b12f5ae060ec2a6f5c482720a4bdb3a8";



// view heights
const CGFloat kNavHeaderHeight = 64.0;
const CGFloat kSearchHeaderHeight = 43.0f;
const CGFloat kOrthodoxTableHeaderHeight = 24.0f;
const CGFloat kOrthodoxTableCellHeight = 64.0f;
const CGFloat kDetailsHeroImageHeight = 324.0;

const UIEdgeInsets kOrthodoxTableViewEdgeInsets = {0.0, 0.0, 48.0, 0.0};

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

const NSURLRequestCachePolicy kURLRequestCachePolicy = NSURLRequestUseProtocolCachePolicy;
NSString * const kTwilioSMS = @"6475577873";

// network error descriptions
NSString * const kNetErrorNoConnection = @"The Internet connection appears to be offline.";
NSString * const kNetErrorStatusCode404 = @"Expected status code in (200-299), got 404";


#if __APPSTORE_BUILD__ == 0
//@interface HONAppDelegate() <BITHockeyManagerDelegate, ChartboostDelegate, UAPushNotificationDelegate>
@interface HONAppDelegate() <BITHockeyManagerDelegate, ChartboostDelegate, HONTutorialViewDelegate, PCCandyStoreSearchControllerDelegate>
#else
//@interface HONAppDelegate() <ChartboostDelegate, UAPushNotificationDelegate>
@interface HONAppDelegate() <ChartboostDelegate, HONTutorialViewDelegate, PCCandyStoreSearchControllerDelegate>
#endif
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic) int challengeID;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic) int userID;
@property (nonatomic) BOOL awsUploadCounter;
@property (nonatomic, copy) NSString *currentConversationID;
@property (nonatomic, strong) HONTutorialView *tutorialView;
@end


@implementation HONAppDelegate
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;



+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSString *)customerServiceURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"support_url"]);
}

+ (NSDictionary *)s3Credentials {
	return ([NSDictionary dictionaryWithObjectsAndKeys:@"AKIAIHUQ42RE7R7CIMEA", @"key", @"XLFSr4XgGptznyEny3rw3BA//CrMWf7IJlqD7gAQ", @"secret", nil]);
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
		key = @"clubs";
	
	else if (s3BucketType == HONAmazonS3BucketTypeEmotionsSource || s3BucketType == HONAmazonS3BucketTypeEmoticonsCloudFront)
		key = @"emoticons";
	
	
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"s3_buckets"] objectForKey:key] objectAtIndex:(s3BucketType % 2)]);
}

+ (BOOL)switchEnabledForKey:(NSString *)key {
	return ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"switches"] objectForKey:key] uppercaseString] isEqualToString:@"YES"]);
}

+ (int)incTotalForCounter:(NSString *)key {
	key = [key stringByAppendingString:@"_total"];
	int tot = ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil) ? 0 : [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue] + 1;
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tot] forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (tot);
}

+ (int)totalForCounter:(NSString *)key {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:[key stringByAppendingString:@"_total"]] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:[key stringByAppendingString:@"_total"]] intValue] : -1);
}

+ (NSString *)kikCardURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"kik_card"]);
}

+ (NSString *)shareURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"share_url"]);
}


+ (NSArray *)orthodoxEmojis {
	NSMutableArray *emojis = [NSMutableArray array];
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"emotions"])
		[emojis addObject:[HONEmotionVO emotionWithDictionary:dict]];
	
	return ([emojis copy]);
}

+ (NSArray *)picoCandyStickers {
	NSMutableArray *picoCandy = [NSMutableArray array];
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"])
		[picoCandy addObject:[HONEmotionVO emotionWithDictionary:dict]];
	
	return ([picoCandy copy]);
}

+ (NSArray *)subjectFormats {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"subject_formats"]);
}

+ (NSArray *)excludedClubDomains {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"excluded_domains"]);
}

+ (NSArray *)searchUsers {
	return ([NSMutableArray arrayWithArray:[[[NSUserDefaults standardUserDefaults] objectForKey:@"search_users"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"username"
																																																  ascending:YES
																																																   selector:@selector(localizedCaseInsensitiveCompare:)]]]]);
}

+ (NSRange)rangeForImageQueue {
	return (NSRangeFromString([[NSUserDefaults standardUserDefaults] objectForKey:@"image_queue"]));;
}


+ (void)writePhoneNumber:(NSString *)phoneNumber {
	NSLog(@"AppDelegate writePhoneNumber:[%@]", phoneNumber);
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"phone_number"];
	
//	NSString *formattedNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""];
//	if (![[formattedNumber substringToIndex:1] isEqualToString:@"1"])
//		formattedNumber = [@"1" stringByAppendingString:formattedNumber];
	
	[[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:@"phone_number"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
	[keychain setObject:phoneNumber forKey:CFBridgingRelease(kSecAttrService)];
}

+ (NSString *)phoneNumber {
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
	[keychain objectForKey:CFBridgingRelease(kSecAttrService)];
	
	NSLog(@"AppDelegate phoneNumber:[%@][%@]", [[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"], [keychain objectForKey:CFBridgingRelease(kSecAttrService)]);
	return (([[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"phone_number"] : [keychain objectForKey:CFBridgingRelease(kSecAttrService)]);
}


+ (void)writeDeviceToken:(NSString *)token {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
	
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
						   @"friendsTab_total",
						   @"friendsTabRefresh_total",
						   @"newsTab_total",
						   @"newsTabRefresh_total",
						   @"clubsTab_total",
						   @"clubsTabRefresh_total",
						   @"verifyAction_total",
						   @"timeline_total",
						   @"timelineRefresh_total",
						   @"feedItem_total",
						   @"feedItemRefresh_total",
						   @"activityView_total",
						   @"activityViewRefresh_total",
						   @"preview_total",
						   @"camera_total",
						   @"join_total",
						   @"like_total",
						   @"messages_total",
						   @"messagesRefresh_total",
						   @"search_total",
						   @"suggested_total",
						   @"details_total",
						   @"profile_total"];
	
	for (NSString *key in totalKeys) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		
		[[NSUserDefaults standardUserDefaults] setObject:@-1 forKey:key];
	}
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activity_total"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activity_total"];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"activity_updated"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"activity_updated"];
	
	[[NSUserDefaults standardUserDefaults] setObject:@0 forKey:@"activity_total"];
	[[NSUserDefaults standardUserDefaults] setObject:@"0000-00-00 00:00:00" forKey:@"activity_updated"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)cacheNextImagesWithRange:(NSRange)range fromURLs:(NSArray *)urls withTag:(NSString *)tag {
//	NSLog(@"QUEUEING : |]%@]>{%@)_", NSStringFromRange(range), tag);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { };
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {};
	
	for (int i=0; i<range.length - range.location; i++) {
//		NSLog(@"s+ArT_l0Ad. --> (#%02d) \"%@\"", (range.location + i), [urls objectAtIndex:i]);
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[imageView setTag:range.location + i];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[urls objectAtIndex:i]
														   cachePolicy:kURLRequestCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];
	}
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

+ (NSString *)cleanImagePrefixURL:(NSString *)imageURL {
//	NSMutableString *imagePrefix = [imageURL mutableCopy];
//	
//	[imagePrefix replaceOccurrencesOfString:[kSnapThumbSuffix substringToIndex:[kSnapThumbSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
//	[imagePrefix replaceOccurrencesOfString:[kSnapMediumSuffix substringToIndex:[kSnapMediumSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
//	[imagePrefix replaceOccurrencesOfString:[kSnapLargeSuffix substringToIndex:[kSnapLargeSuffix length] - 4] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
//	[imagePrefix replaceOccurrencesOfString:@"_o" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
//	[imagePrefix replaceOccurrencesOfString:@".jpg" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
//	[imagePrefix replaceOccurrencesOfString:@".png" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [imagePrefix length])];
//	
//	return ([imagePrefix copy]);
	
	return ([HONImagingDepictor normalizedPrefixForImageURL:imageURL]);
}

+ (NSString *)normalizedPhoneNumber:(NSString *)phoneNumber {
	if ([phoneNumber length] > 0) {
		NSString *formattedNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""];
		if (![[formattedNumber substringToIndex:1] isEqualToString:@"1"])
			formattedNumber = [@"1" stringByAppendingString:formattedNumber];
		
		return ([@"+" stringByAppendingString:formattedNumber]);
		
	} else
		return (@"");
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


+ (void)cafPlaybackWithFilename:(NSString *)filename {
	NSString *filepath = [[NSBundle mainBundle] pathForResource:filename ofType:@"caf"];
	NSURL *url = [NSURL fileURLWithPath:filepath];
	SystemSoundID sound;
	
	AudioServicesCreateSystemSoundID((__bridge_retained CFURLRef)url, &sound);
	AudioServicesPlaySystemSound(sound);
}


#pragma mark - Data Calls
- (void)_retrieveConfigJSON {
	[[HONAPICaller sharedInstance] retreiveBootConfigWithCompletion:^(NSDictionary *result) {
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"appstore_id"] forKey:@"appstore_id"];
		[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"endpts"] objectForKey:kAPIHost] forKey:@"server_api"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"support_url"] forKey:@"support_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"timeout_interval"] forKey:@"timeout_interval"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"twilio_sms"] forKey:@"twilio_sms"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_templates"] forKey:@"share_templates"];
		[[NSUserDefaults standardUserDefaults] setObject:[[[result objectForKey:@"app_schemas"] objectForKey:@"kik"] objectForKey:@"ios"] forKey:@"kik_card"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"verify_copy"] forKey:@"verify_copy"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_url"] forKey:@"share_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"excluded_domains"] forKey:@"excluded_domains"];
		[[NSUserDefaults standardUserDefaults] setObject:NSStringFromRange(NSMakeRange([[[result objectForKey:@"image_queue"] objectAtIndex:0] intValue], [[[result objectForKey:@"image_queue"] objectAtIndex:1] intValue])) forKey:@"image_queue"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"min_age"] forKey:@"min_age"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"min_luminosity"] forKey:@"min_luminosity"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"jpeg_compress"] forKey:@"jpeg_compress"];
		[[NSUserDefaults standardUserDefaults] setObject:[self _colorsFromJSON:[result objectForKey:@"overlay_tint_rbgas"]] forKey:@"overlay_tint_rbgas"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"filter_vals"] forKey:@"filter_vals"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"emotions"] forKey:@"emotions"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"pico_candy"] forKey:@"pico_candy"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"subject_formats"] forKey:@"subject_formats"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"search_users"] forKey:@"search_users"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"switches"] forKey:@"switches"];
		[[NSUserDefaults standardUserDefaults] setObject:@{@"avatars"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"avatars"],
														   @"banners"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"banners"],
														   @"clubs"			: [[result objectForKey:@"s3_buckets"] objectForKey:@"clubs"],
														   @"emoticons"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"emoticons"]} forKey:@"s3_buckets"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"share_formats"] objectForKey:@"sheet_title"] forKey:@"share_title"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@{@"sms"		: [[result objectForKey:@"invite_formats"] objectForKey:@"sms"],
														   @"email"		: [[result objectForKey:@"invite_formats"] objectForKey:@"email"]} forKey:@"invite_formats"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@{@"instagram"	: [[result objectForKey:@"share_formats"] objectForKey:@"instagram"],
														   @"twitter"	: [[result objectForKey:@"share_formats"] objectForKey:@"twitter"],
														   @"facebook"	: [[result objectForKey:@"share_formats"] objectForKey:@"facebook"],
														   @"sms"		: [[result objectForKey:@"share_formats"] objectForKey:@"sms"],
														   @"email"		: [[result objectForKey:@"share_formats"] objectForKey:@"email"]} forKey:@"share_formats"];
		
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		
		NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
		
		
		if ([[[result objectForKey:@"boot_alert"] objectForKey:@"enabled"] isEqualToString:@"Y"])
			[self _showOKAlert:[[result objectForKey:@"boot_alert"] objectForKey:@"title"] withMessage:[[result objectForKey:@"boot_alert"] objectForKey:@"message"]];
		
		
		[self _writeShareTemplates];
		[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"default_avatar"];
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
	[[HONAPICaller sharedInstance] registerNewUserWithCompletion:^(NSDictionary *result) {
		if ([result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
			if ([[result objectForKey:@"email"] length] == 0) {
				KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
				[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
			}
			
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			[HONImagingDepictor writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			[self _enableNotifications:(![[HONAppDelegate deviceToken] isEqualToString:[[NSString stringWithFormat:@"%064d", 0] stringByReplacingOccurrencesOfString:@"0" withString:@"F"]])];
							
#if __IGNORE_SUSPENDED__ == 1
				if (self.tabBarController == nil)
					[self _initTabs];
#else
				if ((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_suspended"] intValue]) {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuspendedViewController alloc] init]];
					[navigationController setNavigationBarHidden:YES];
					[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
					
				} else {
					if (self.tabBarController == nil)
						[self _initTabs];
				}
#endif
		}
	}];
}

- (void)_enableNotifications:(BOOL)isEnabled {
	[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] areEnabled:isEnabled completion:^(NSDictionary *result) {
		if (![result isEqual:[NSNull null]])
			[HONAppDelegate writeUserInfo:result];
	}];
}

- (void)_challengeObjectFromPush:(int)challengeID cancelNextPushes:(BOOL)isCancel {
	[[HONAPICaller sharedInstance] retrieveChallengeForChallengeID:challengeID igoringNextPushes:isCancel completion:^(NSDictionary *result) {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONClubPhotoViewController alloc] initWithChallenge:[HONChallengeVO challengeWithDictionary:result]]];
//		[navigationController setNavigationBarHidden:YES];
//		[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
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
	/*NSShadow *shadow = [[HONColorAuthority sharedInstance] orthodoxUIShadowAttribute];//[NSShadow new];*/
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
	//NSLog(@"[:|:] [application:didFinishLaunchingWithOptions] [:|:]");
	
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_isFromBackground = NO;
	
	char bytes[] = "„7ì”~ís";
	NSString * string = [NSString string];
	string = [[NSString alloc] initWithBytes:bytes length:8 encoding:NSUTF8StringEncoding];
	//NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
	
	//@"YXJ0aHVyLnBld3R5QGdteC5jb20="
//	NSData *data = [NSData dataFromBase64String:string];
//	NSString *decodedString;// = [[NSString alloc] initWithData:data encoding:NSISOLatin1StringEncoding];
	
//	decodedString = @"6787449c";//@"Ñ7Ïî~Ìès";//[NSString stringWithUTF8String:[data bytes]];
//	NSLog(@"BASE64 DECODE(%i):%@\n", [string lengthOfBytesUsingEncoding:NSUTF8StringEncoding], string);
//	
//	BlowfishAlgorithm *blowfishAlgorithm = [BlowfishAlgorithm new];
//	[blowfishAlgorithm setMode:[BlowfishAlgorithm buildModeEnum:@"CBC"]];
//	[blowfishAlgorithm setKey:kBlowfishKey];
//	[blowfishAlgorithm setInitVector:@"„7ì”~ís"];
//	[blowfishAlgorithm setupKey];
//	
//	NSLog(@"ORG:[%@]", [blowfishAlgorithm encrypt:@"+12133009127"]);
//	NSLog(@"ENC:[%@]", [[blowfishAlgorithm encrypt:@"+12133009127"] base64EncodedString]);
//	NSLog(@"DEC:[%@]", [[[blowfishAlgorithm encrypt:@"+12133009127"] base64EncodedString] base64DecodedString]);
//	NSLog(@"ORG:[%@]", [blowfishAlgorithm decrypt:[[[blowfishAlgorithm encrypt:@"+12133009127"] base64EncodedString] base64DecodedString]]);
	
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
//	if (launchOptions) {
//		NSLog(@"\t—//]> [%@ didFinishLaunchingWithOptions] (%@)", self.class, launchOptions);
//		[[[UIAlertView alloc] initWithTitle:@"¡Message Recieved!"
//									message:[[NSString string] stringFromDictionary:launchOptions]
//								   delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
//	}
	
	
#if __FORCE_REGISTER__ == 1
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
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
		
		self.window.backgroundColor = [UIColor whiteColor];
		[self.window makeKeyAndVisible];
		
//		[self _initUrbanAirship];
		[self _retrieveConfigJSON];
		[self _initThirdPartySDKs];
		
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
	//NSLog(@"[:|:] [applicationWillResignActive] [:|:]");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationDidEnterBackground] [:|:]");
	
	[HONAppDelegate incTotalForCounter:@"background"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App Entering Background"
									 withProperties:@{@"total"		: [@"" stringFromInt:[HONAppDelegate incTotalForCounter:@"background"]],
													  @"duration"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) ? [[HONDateTimeAlloter sharedInstance] elapsedTimeSinceDate:[[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]]] : @"00:00:00"}];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"active_date"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate new]] forKey:@"active_date"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	
	UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^(void) {
		NSLog(@"Background task is being expired.");
	}];
	
	[[KeenClient sharedClient] uploadWithFinishedBlock:^(void) {
		[application endBackgroundTask:taskId];
	}];
    
    
    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
    NSString *passedRegistration = [keychain objectForKey:CFBridgingRelease(kSecAttrAccount)];
    
    if ([passedRegistration length] == 0) {
        
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:180];
        localNotification.timeZone = [NSTimeZone systemTimeZone];
        localNotification.alertAction = @"View";
        localNotification.alertBody = @"Create your Selfieclub profile!";
        localNotification.soundName = @"selfie_notification.caf";
        localNotification.userInfo = @{@"user_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];

    }

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationWillEnterForeground] [:|:]");
	
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationDidBecomeActive] [:|:]");
	
	[FBAppEvents activateApp];
	
	[KeenClient disableGeoLocation];
	[KeenClient sharedClientWithProjectId:kKeenIOProductID
                              andWriteKey:kKeenIOWriteKey
							   andReadKey:kKeenIOReadKey];
	
#if KEENIO_LOG == 1
	[KeenClient enableLogging];
#endif
	
	//[[UAPush shared] resetBadge];
	
//	Chartboost *chartboost = [Chartboost sharedChartboost];
//    chartboost.appId = kChartboostAppID;
//    chartboost.appSignature = kChartboostAppSignature;
//    chartboost.delegate = self;
//	
//    [chartboost startSession];
//    [chartboost showInterstitial];
	
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"active_date"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate new]] forKey:@"active_date"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (_isFromBackground) {
		if ([HONAppDelegate hasNetwork]) {
			
			[[HONAnalyticsParams sharedInstance] trackEvent:@"App Leaving Background"
											 withProperties:@{@"duration"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) ? [[HONDateTimeAlloter sharedInstance] elapsedTimeSinceDate:[[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]]] : @"00:00:00",
															  @"total"		: [@"" stringFromInt:[HONAppDelegate totalForCounter:@"background"]]}];
			
			KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"com.builtinmenlo.selfieclub" accessGroup:nil];
			if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] > 0) {
				if ([HONAppDelegate totalForCounter:@"background"] == 3) {
					_tutorialView = [[HONTutorialView alloc] initWithImageURL:@"tutorial_resume"];
					_tutorialView.delegate = self;
					
					[[HONScreenManager sharedInstance] appWindowAdoptsView:_tutorialView];
					[_tutorialView introWithCompletion:nil];
				}
			}
			
			
			if (![HONAppDelegate canPingConfigServer]) {
				[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
					   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
				
			} else
				[self _retrieveConfigJSON];
		}
	
	} else {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"App Boot"
										 withProperties:@{@"boots"	: [@"" stringFromInt:[HONAppDelegate totalForCounter:@"boot"]]}];
				
//		if ([HONAppDelegate incTotalForCounter:@"boot"] == 3) {
//			_tutorialView = [[HONTutorialView alloc] initWithBGImage:[UIImage imageNamed:@"tutorial_resume"]];
//			_tutorialView.delegate = self;
//			
//			[[HONScreenManager sharedInstance] appWindowAdoptsView:_tutorialView];
//			[_tutorialView introWithCompletion:nil];
//		}
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationWillTerminate] [:|:]");
	
	[FBSession.activeSession close];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_TERMINATING" object:nil];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App Terminating"
									 withProperties:@{@"duration"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) ? [[HONDateTimeAlloter sharedInstance] elapsedTimeSinceDate:[[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]]] : @"00:00:00"}];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"active_date"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate new]] forKey:@"active_date"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"application:openURL:[%@]", [url absoluteString]);
	
	if (!url)
		return (NO);
	
	NSString *protocol = [[[url absoluteString] lowercaseString] substringToIndex:[[url absoluteString] rangeOfString:@"://"].location];
	if ([protocol isEqualToString:@"selfieclub"]) {
		NSRange range = [[[url absoluteString] lowercaseString] rangeOfString:@"://"];
		NSArray *path = [[[[url absoluteString] lowercaseString] substringFromIndex:range.location + range.length] componentsSeparatedByString:@"/"];
		NSLog(@"PATH:[%@]", path);
		
		if ([path count] == 2) {
			NSString *username = [[path firstObject] lowercaseString];
			NSString *clubname = [[path lastObject] lowercaseString];
			
			[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSArray *result) {
				int userID = 0;
				if ([result count] > 0) {
					
					for (NSDictionary *user in result) {
						if ([username isEqualToString:[[user objectForKey:@"username"] lowercaseString]]) {
							userID = [[user objectForKey:@"id"] intValue];
							break;
						}
					}
					
					NSLog(@"userID:[%d]", userID);
					if (userID > 0) {
						[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:userID completion:^(NSDictionary *result) {
							int clubID = 0;
							for (NSString *key in [[HONClubAssistant sharedInstance] clubTypeKeys]) {
								for (NSDictionary *club in [result objectForKey:key]) {
									if ([[[club objectForKey:@"name"] lowercaseString] isEqualToString:clubname]) {
										clubID = [[club objectForKey:@"id"] intValue];
										break;
									}
								}
							}
							
							NSLog(@"clubID:[%d]", clubID);
							if (clubID > 0) {
								[[HONAPICaller sharedInstance] retrieveClubByClubID:clubID withOwnerID:userID completion:^(NSDictionary *result) {
									HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:result];
									_selectedClubVO = vo;
									
//									NSLog(@"_selectedClubVO.activeMembers:[%@]", _selectedClubVO.activeMembers);
//									NSLog(@"_selectedClubVO.pendingMembers:[%@]", _selectedClubVO.pendingMembers);
									BOOL isMember = ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == _selectedClubVO.ownerID);
									for (HONTrivialUserVO *trivialUserVO in _selectedClubVO.activeMembers) {
										NSLog(@"trivialUserVO:[%d](%d)", trivialUserVO.userID, [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
										if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == trivialUserVO.userID) {
											isMember = YES;
											break;
										}
									}
									
									for (HONTrivialUserVO *trivialUserVO in _selectedClubVO.pendingMembers) {
										NSLog(@"trivialUserVO:[%d](%d)", trivialUserVO.userID, [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
										if ([[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] == trivialUserVO.userID) {
											isMember = YES;
											break;
										}
									}
									
									if (isMember) {
										[self.tabBarController setSelectedIndex:2];
										[self.tabBarController.selectedViewController.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:0] animated:YES];
										
										UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"You are already a member of %@!", _selectedClubVO.clubName]
																							message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
																						   delegate:self
																				  cancelButtonTitle:@"Yes"
																				  otherButtonTitles:@"Not Now", nil];
										
										[alertView setTag:8];
										[alertView show];
									
									} else {
//										UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONClubPreviewViewController alloc] initWithClub:_selectedClubVO]];
//										[navigationController setNavigationBarHidden:YES];
//										[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
										
										
										UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																							message:[NSString stringWithFormat:@"Would you like to join the %@ Selfieclub?", _selectedClubVO.clubName]
																						   delegate:self
																				  cancelButtonTitle:@"OK"
																				  otherButtonTitles:@"Cancel", nil];
										
										[alertView setTag:7];
										[alertView show];
									}
								}];
							
							} else {
								_clubName = clubname;
								UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Club Not Found!"
																					message:@"Would you like to create it?"
																				   delegate:self
																		  cancelButtonTitle:@"Yes"
																		  otherButtonTitles:@"No", nil];
								[alertView setTag:9];
								[alertView show];
							}
						}];
					
					} else {
						[[[UIAlertView alloc] initWithTitle:@"Username Not Found!"
													message:@""
												   delegate:nil
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil] show];
					}
				}
			}];
		}
		
		return (YES);
	
	} else {
		return ([self handleKikAPIData:[KikAPIClient handleOpenURL:url sourceApplication:sourceApplication annotation:annotation]]);
		return ([FBAppCall handleOpenURL:url sourceApplication:sourceApplication]);
	}
}


- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification {
    [[UIApplication sharedApplication]cancelAllLocalNotifications];
    app.applicationIconBadgeNumber = notification.applicationIconBadgeNumber -1;
	
    notification.soundName = UILocalNotificationDefaultSoundName;
    [HONAppDelegate cafPlaybackWithFilename:@"selfie_notification"];
	
    [self _showOKAlert:@"Local Notification" withMessage:[notification.alertBody stringByAppendingFormat:@" %@", notification.userInfo]];
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
    [HONAppDelegate cafPlaybackWithFilename:@"selfie_notification"];
	
	application.applicationIconBadgeNumber = 0;
	
	
//	[[[UIAlertView alloc] initWithTitle:@"¡Message Recieved!"
//								message:[@"" stringFromDictionary:userInfo]
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}





/*
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[UAPush shared] registerDeviceToken:deviceToken];
	
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
	
	NSArray *navigationControllers = @[[[UINavigationController alloc] initWithRootViewController:[[HONContactsTabViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONClubsNewsFeedViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONUserClubsViewController alloc] init]]];
	
	
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
	NSDictionary *userDefaults = @{@"install_date"		: [NSDate new],
								   @"is_deactivated"	: [@"" stringFromBOOL:NO],
								   @"votes"				: @[],
								   @"local_challenges"	: @[],
								   @"upvotes"			: @[],
								   @"activity_total"	: @0,
								   @"activity_updated"	: @"0000-00-00 00:00:00"};
	
	for (NSString *key in userDefaults) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil)
			[[NSUserDefaults standardUserDefaults] setObject:[userDefaults objectForKey:key] forKey:key];
	}
		
#if __FORCE_REGISTER__ == 1
	for (NSString *key in userDefaults) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		
		[[NSUserDefaults standardUserDefaults] setObject:[userDefaults objectForKey:key] forKey:key];
	}
	
	[HONAppDelegate resetTotals];
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
	
	//[Mixpanel sharedInstanceWithToken:kMixPanelToken];
	
	
	PicoManager *picoManager = [PicoManager sharedManager];
	[picoManager registerStoreWithAppId:@"1df5644d9e94"
								 apiKey:@"8Xzg4rCwWpwHfNCPLBvV"];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"picocandy"];
	
	NSLog(@"PICOCANDY:[%@]", [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"free"]);
	
	NSMutableArray *stickers = [NSMutableArray array];
	PCCandyStoreSearchController *candyStoreSearchController = [[PCCandyStoreSearchController alloc] init];
	for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"pico_candy"] objectForKey:@"free"]) {
		[candyStoreSearchController fetchStickerPackInfo:contentGroupID completion:^(BOOL success, PCContentGroup *contentGroup) {
			NSLog(@"///// fetchStickerPackInfo:[%d][%@] /////", success, contentGroup);
			
			[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				PCContent *content = (PCContent *)obj;
				NSLog(@"content.image:[%@][%@][%@] (%@)", content.medium_image, content.medium_image, content.large_image, content.name);
				
				[stickers addObject:@{@"id"		: content.content_id,
									  @"name"	: content.name,
									  @"price"	: @"0",
									  @"img"	: content.large_image}];
				
				[[NSUserDefaults standardUserDefaults] setObject:[stickers copy] forKey:@"picocandy"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}];
		}];
	}
	
		
	TSConfig *config = [TSConfig configWithDefaults];
	config.collectWifiMac = NO;
	config.idfa = [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO];
	config.odin1 = @"<ODIN-1 value goes here>";
	//config.openUdid = @"<OpenUDID value goes here>";
	//config.secureUdid = @"<SecureUDID value goes here>";
	[TSTapstream createWithAccountName:@"selfieclub"
					   developerSecret:kTapStreamSecretKey
								config:config];
	
	[Tapjoy requestTapjoyConnect:kTapjoyAppID
					   secretKey:kTapjoyAppSecretKey
						 options:@{TJC_OPTION_ENABLE_LOGGING	: @(YES)}];
	
//	[KikAPIClient registerAsKikPluginWithAppID:@"com.builtinmenlo.selfieclub.kik"
//							   withHomepageURI:@"http://www.builtinmenlo.com"
//								  addAppButton:YES];
}

- (void)_writeShareTemplates {
	return;
	
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


#pragma mark - CandyStoreSearchController Delegates
- (void)candyStoreSearchController:(id)controller failedToFetchAllContentsForSearchTerms:(NSString *)text {
	NSLog(@"[[*:*]] candyStoreSearchController:failedToFetchAllContentsForSearchTerms");
}

- (void)candyStoreSearchController:(id)controller failedToFetchStickerPacksForSearchTerms:(NSString *)text {
	NSLog(@"[[*:*]] candyStoreSearchController:failedToFetchStickerPacksForSearchTerms");
}

- (void)candyStoreSearchController:(id)controller failedToFetchStickersForCategory:(NSString *)categoryId {
	NSLog(@"[[*:*]] candyStoreSearchController:failedToFetchStickersForCategory");
}

- (void)candyStoreSearchController:(id)controller failedToFetchStickersForSearchTerms:(NSString *)text {
	NSLog(@"[[*:*]] candyStoreSearchController:failedToFetchStickersForSearchTerms");
}

- (void)candyStoreSearchController:(id)controller failedToFetchStickersForSearchType:(kCandyStoreSearchType)searchType {
	NSLog(@"[[*:*]] candyStoreSearchController:failedToFetchStickersForSearchType");
}

- (void)candyStoreSearchController:(id)controller fetchedStickerPacks:(PCCandyStoreSearchResult *)result withSearchTerms:(NSString *)text {
	NSLog(@"[[*:*]] candyStoreSearchController:fetchedStickerPacks:[%@]", result);
	
//	NSMutableArray *stickers = [NSMutableArray array];
//	[result.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//		PCContent *content = (PCContent *)obj;
//		NSLog(@"content.large_image:[%@]", content.large_image);
//		[stickers addObject:@{@"id"		: content.content_id,
//							  @"name"	: content.name,
//							  @"price"	: @"0",
//							  @"img"	: content.large_image}];
//	}];
//	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"] != nil)
//		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"picocandy"];
//	
//	[[NSUserDefaults standardUserDefaults] setObject:[stickers copy] forKey:@"picocandy"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)candyStoreSearchController:(id)controller fetchedAllContents:(PCCandyStoreSearchResult *)result withSearchTerms:(NSString *)text {
	NSLog(@"[[*:*]] candyStoreSearchController:fetchedAllContents:[%@]", result);
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"picocandy"];
	
	NSMutableArray *stickers = [NSMutableArray array];
	[result.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		PCContent *content = (PCContent *)obj;
		NSLog(@"content.large_image:[%@]", content.large_image);
	}];
	
	[[NSUserDefaults standardUserDefaults] setObject:[stickers copy] forKey:@"picocandy"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)candyStoreSearchController:(id)controller fetchedStickers:(PCCandyStoreSearchResult *)result withSearchTerms:(NSString *)text {
	NSLog(@"[[*:*]] candyStoreSearchController:fetchedStickers:withSearchTerms");
}

- (void)candyStoreSearchController:(id)controller fetchedStickers:(PCCandyStoreSearchResult *)result forSearchType:(kCandyStoreSearchType)searchType {
	NSLog(@"[[*:*]] candyStoreSearchController:fetchedStickers:forSearchType:[%d]", searchType);
	
	NSMutableArray *stickers = [NSMutableArray array];
	if (searchType == kCandyStoreSearchNewestStickerPacks) {
		[result.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			PCContentGroup *contentGroup = (PCContentGroup *)obj;
			
			[contentGroup.contents enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				PCContent *content = (PCContent *)obj;
				//NSLog(@"content.large_image:[%@] (%@)", content.large_image, content.name);
				
				[stickers addObject:@{@"id"		: content.content_id,
									  @"name"	: content.name,
									  @"price"	: @"0",
									  @"img"	: content.large_image}];
			}];
		}];
		
	} else {
		[result.results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			PCContent *content = (PCContent *)obj;
			NSLog(@"content.large_image:[%@]", content.large_image);
		}];
	}
	
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"picocandy"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"picocandy"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[stickers copy] forKey:@"picocandy"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)candyStoreSearchController:(id)controller fetchedStickers:(PCCandyStoreSearchResult *)result withCategory:(NSString *)categoryId {
	NSLog(@"[[*:*]] candyStoreSearchController:fetchedStickers:withCategory");
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


#pragma mark - TutorialView Delegates
- (void)tutorialViewClose:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Tutorial Close"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
}

- (void)tutorialViewInvite:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Tutorial Invite"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
		
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:nil viewControllerPushed:NO]];
		[navigationController setNavigationBarHidden:YES];
		[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
	}];
}

- (void)tutorialViewSkip:(HONTutorialView *)tutorialView {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Main Camera - Tutorial Skip"];
	
	[_tutorialView outroWithCompletion:^(BOOL finished) {
		[_tutorialView removeFromSuperview];
		_tutorialView = nil;
	}];
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
	} else if (alertView.tag == 8) {
//	} else if (buttonIndex == 8) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
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
	
	} else if (alertView.tag == 7) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] joinClub:_selectedClubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
				[self.tabBarController setSelectedIndex:2];
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:@"Yes"
														  otherButtonTitles:@"Not Now", nil];
				
				[alertView setTag:8];
				[alertView show];
			}];
		}
	
	} else if (alertView.tag == 9) {
		[[HONAPICaller sharedInstance] createClubWithTitle:_clubName withDescription:@"" withImagePrefix:@"" completion:^(NSDictionary *result) {
			_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[NSString stringWithFormat:@"Want to invite friends to %@?", _selectedClubVO.clubName]
															   delegate:self
													  cancelButtonTitle:@"Yes"
													  otherButtonTitles:@"No", nil];
			
			[alertView setTag:8];
			[alertView show];
		}];
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

