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
#import <QuartzCore/QuartzCore.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <sys/utsname.h>

#import <HockeySDK/HockeySDK.h>
#import <Tapjoy/Tapjoy.h>

#import "NSData+Base64.h"
#import "NSString+Base64.h"
#import "NSString+DataTypes.h"

#import "AFNetworking.h"
#import "BlowfishAlgorithm.h"
#import "MBProgressHUD.h"
#import "KeenClient.h"
#import "KeychainItemWrapper.h"
#import "KikAPI.h"
#import "PicoSticker.h"
#import "Reachability.h"
#import "TSTapstream.h"
#import "UIImageView+AFNetworking.h"

#import "HONAppDelegate.h"
#import "HONStoreTransactionObserver.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONInsetOverlayView.h"
#import "HONTabBarController.h"
#import "HONInviteContactsViewController.h"
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
#import "HONCreateClubViewController.h"
#import "HONSuspendedViewController.h"
#import "HONSelfieCameraViewController.h"

typedef NS_OPTIONS(NSUInteger, HONAppDelegateBitTesting) {
	HONAppDelegateBitTesting0	= 0 << 0,
	HONAppDelegateBitTesting1	= 1 << 0,
	HONAppDelegateBitTesting2	= 1 << 0,
	HONAppDelegateBitTesting3	= 1 << 0,
	HONAppDelegateBitTesting4	= 1 << 0,
};

#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
NSString * const kConfigURL = @"http://volley-api.selfieclubapp.com";
NSString * const kConfigJSON = @"boot_moji_100.json";
NSString * const kAPIHost = @"data_api";
#else
NSString * const kConfigURL = @"http://volley-api.devint.selfieclubapp.com";
NSString * const kConfigJSON = @"boot_moji_100.json";
NSString * const kAPIHost = @"data_api-stage";
#endif

NSString * const kBlowfishKey = @"KJkljP9898kljbm675865blkjghoiubdrsw3ye4jifgnRDVER8JND997";
NSString * const kBlowfishIV = @"„7ì”~ís";


NSString * const kFacebookAppID = @"600550136636754";
NSString * const kHockeyAppToken = @"a2f42fed0f269018231f6922af0d8ad3";
NSString * const kTapStreamSecretKey = @"xJCRiJCqSMWFVF6QmWdp8g";
NSString * const kChartboostAppID = @"";
NSString * const kChartboostAppSignature = @"";
NSString * const kTapjoyAppID = @"13b84737-f359-4bf1-b6a0-079e515da029";
NSString * const kTapjoyAppSecretKey = @"llSjQBKKaGBsqsnJZlxE";


NSString * const kKeenIOProductID = @"540e27cd383144486e40a51b";
NSString * const kKeenIOMasterKey = @"A7163C89CB09500B80D14C8FF9904A4D";
NSString * const kKeenIOReadKey = @"58db4a590b4e929f8aac96ea14d5c945b92cdbd0e86d8d522c16c534507dc824dc7e50ccd81d6811facc8fabdf75c086d73022807d75f618b7b538111b92389b0d88a039a5bf06bfbf5edaca2f47f3cd17a567eb0b6137fc4e5b7f4b933f1d5e2b5bea9d1e31eab229178376410a6acf ";
NSString * const kKeenIOWriteKey = @"278b8733c5c2a4e186d6efe472b5f88eb5a62c631a151902f30e749e852fe3ec37eddc06bfba56301743b3c9bd02ce9f0f8b1f79e316f470db611fe52649e41a281af50eb3aefa5faa6e1e1ed39de54d81be6c01d9fc51c5ccb10e0794e40d560d21ee678c5fd6a9296dc2422f8a6888";



// view heights
const CGFloat kNavHeaderHeight = 64.0; //64.0
const CGFloat kSearchHeaderHeight = 43.0f;
const CGFloat kOrthodoxTableHeaderHeight = 24.0f;
const CGFloat kOrthodoxTableCellHeight = 64.0f;
const CGFloat kDetailsHeroImageHeight = 324.0;

// ui
const CGSize kTabSize = {80.0, 34.0}; //80, 34
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
@interface HONAppDelegate() <BITHockeyManagerDelegate>
#else
@interface HONAppDelegate()
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
@property (nonatomic, strong) HONInsetOverlayView *insetOverlayView;
@end


@implementation HONAppDelegate
@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;



+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSString *)customerServiceURLForKey:(NSString *)key {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"support_urls"] objectForKey:key]);
}

+ (NSString *)shareURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"share_url"]);
}

+ (NSDictionary *)s3Credentials {
	return ([NSDictionary dictionaryWithObjectsAndKeys:@"AKIAIHUQ42RE7R7CIMEA", @"key", @"XLFSr4XgGptznyEny3rw3BA//CrMWf7IJlqD7gAQ", @"secret", nil]);
}

+ (NSDictionary *)contentForInsetOverlay:(HONInsetOverlayViewType)insetType {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:(insetType == HONInsetOverlayViewTypeAppReview) ? @"review" : (insetType == HONInsetOverlayViewTypeSuggestions) ? @"contacts" : @"unlock"]);
}

+ (NSTimeInterval)timeoutInterval {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout_interval"] doubleValue]);
}

+ (int)clubInvitesThreshold {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_threshold"] intValue]);
}

+ (CGFloat)minSnapLuminosity {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"min_luminosity"] floatValue]);
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


+ (NSString *)defaultShareMessageForIndex:(int)index { //[0]:Details //[1]:Profile
	NSLog(@"sssssssss %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"]);
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"default"] objectAtIndex:index]);
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
	
	[[NSUserDefaults standardUserDefaults] setObject:@(tot) forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	return (tot);
}

+ (int)totalForCounter:(NSString *)key {
	return (([[NSUserDefaults standardUserDefaults] objectForKey:[key stringByAppendingString:@"_total"]] != nil) ? [[[NSUserDefaults standardUserDefaults] objectForKey:[key stringByAppendingString:@"_total"]] intValue] : -1);
}

+ (NSString *)kikCardURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"kik_card"]);
}

+ (NSArray *)subjectFormats {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"subject_formats"]);
}

+ (NSRange)rangeForImageQueue {
	return (NSRangeFromString([[NSUserDefaults standardUserDefaults] objectForKey:@"image_queue"]));;
}


+ (void)writeUserInfo:(NSDictionary *)userInfo {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"user_info"];
	
#if SC_ACCT_BUILD == 0
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
#else
	NSMutableDictionary *dict = [userInfo mutableCopy];
	[dict setObject:@"2394" forKey:@"id"];
	[[NSUserDefaults standardUserDefaults] setObject:[dict copy] forKey:@"user_info"];
#endif
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
						   @"activity_total",
						   @"activityRefresh_total",
						   @"preview_total",
						   @"camera_total",
						   @"join_total",
						   @"like_total",
						   @"messages_total",
						   @"messagesRefresh_total",
						   @"search_total",
						   @"suggested_total",
						   @"details_total",
						   @"profile_total",
						   @"invite_total"];
	
	for (NSString *key in totalKeys) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		
		[[NSUserDefaults standardUserDefaults] setObject:@(-1) forKey:key];
	}
	
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

+ (NSString *)normalizedPhoneNumber:(NSString *)phoneNumber {
	return (([phoneNumber length] > 0) ? [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""] : @"");
	
//	if ([phoneNumber length] > 0) {
//		NSString *formattedNumber = [[phoneNumber componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"+().-  "]] componentsJoinedByString:@""];
//		if (![[formattedNumber substringToIndex:1] isEqualToString:@"1"])
//			formattedNumber = [@"1" stringByAppendingString:formattedNumber];
//		
//		return ([@"+" stringByAppendingString:formattedNumber]);
//		
//	} else
//		return (@"");
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
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"support_urls"] forKey:@"support_urls"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"ts_name"] forKey:@"ts_name"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"default_imgs"] forKey:@"default_imgs"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invalid_chars"] forKey:@"invalid_chars"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"timeout_interval"] forKey:@"timeout_interval"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_templates"] forKey:@"share_templates"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"inset_modals"] forKey:@"inset_modals"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"suggested_covers"] forKey:@"suggested_covers"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"excluded_domains"] forKey:@"excluded_domains"];
		[[NSUserDefaults standardUserDefaults] setObject:NSStringFromRange(NSMakeRange([[[result objectForKey:@"image_queue"] objectAtIndex:0] intValue], [[[result objectForKey:@"image_queue"] objectAtIndex:1] intValue])) forKey:@"image_queue"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"jpeg_compress"] forKey:@"jpeg_compress"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invite_threshold"] forKey:@"invite_threshold"];
		[[NSUserDefaults standardUserDefaults] setObject:[self _colorsFromJSON:[result objectForKey:@"overlay_tint_rbgas"]] forKey:@"overlay_tint_rbgas"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"sandhill_domains"] forKey:@"sandhill_domains"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"pico_candy"] forKey:@"pico_candy"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"subject_formats"] forKey:@"subject_formats"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"switches"] forKey:@"switches"];
		[[NSUserDefaults standardUserDefaults] setObject:@{@"avatars"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"avatars"],
														   @"banners"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"banners"],
														   @"clubs"			: [[result objectForKey:@"s3_buckets"] objectForKey:@"clubs"],
														   @"emoticons"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"emoticons"]} forKey:@"s3_buckets"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@{@"sms"		: [[result objectForKey:@"invite_formats"] objectForKey:@"sms"],
														   @"email"		: [[result objectForKey:@"invite_formats"] objectForKey:@"email"]} forKey:@"invite_formats"];
		
//		[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"share_formats"] objectForKey:@"sheet_title"] forKey:@"share_title"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_formats"] forKey:@"share_formats"];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		
		NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
		
		
		if ([[[result objectForKey:@"boot_alert"] objectForKey:@"enabled"] isEqualToString:@"Y"])
			[self _showOKAlert:[[result objectForKey:@"boot_alert"] objectForKey:@"title"] withMessage:[[result objectForKey:@"boot_alert"] objectForKey:@"message"]];
		
		
		[self _writeShareTemplates];
		[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"default_avatar"];
		[self _registerUser];
		
		if (_isFromBackground) {
			NSString *notificationName = @"";
			switch ([(NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:@"current_tab"] intValue]) {
				case 0:
					notificationName = @"REFRESH_CONTACTS_TAB";
					break;
					
				case 1:
					notificationName = @"REFRESH_NEWS_TAB";
					break;
					
				case 2:
					notificationName = @"REFRESH_CLUBS_TAB";
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
				KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
				[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
			
			} else {
				[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:[result objectForKey:@"email"]];
			}
			
//			[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"token"] forKey:@"device_token"];
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			
			[[HONImageBroker sharedInstance] writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			
//			[[HONStickerAssistant sharedInstance] retrievePicoCandyUser];
			
			[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
				[[HONClubAssistant sharedInstance] writeUserClubs:result];
			}];
			
			if ((BOOL)[[[HONAppDelegate infoForUser] objectForKey:@"is_suspended"] intValue]) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSuspendedViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
				
			} else {
				if (self.tabBarController == nil)
					[self _initTabs];
			}
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
													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Instagram", @"Twitter", @"SMS", @"Email", nil];
	[actionSheet setTag:HONAppDelegateAlertTypeExit];
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
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
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
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

}


#import <CommonCrypto/CommonHMAC.h>




#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	//NSLog(@"[:|:] [application:didFinishLaunchingWithOptions] [:|:]");
	[KeenClient disableGeoLocation];
	
//	const char *cKey  = [@"" cStringUsingEncoding:NSASCIIStringEncoding];
//	const char *cData = [[[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:YES] cStringUsingEncoding:NSUTF8StringEncoding];
//	unsigned char cHMAC[CC_MD5_DIGEST_LENGTH];
//	CCHmac(kCCHmacAlgMD5, cKey, strlen(cKey), cData, strlen(cData), cHMAC);
//	
//	NSMutableString *result = [NSMutableString string];
//	for (int i=0; i<sizeof cHMAC; i++) {
//		NSLog(@"MD5-UTF16:[%@]", result);
//		[result appendFormat:@"%c", cHMAC[i]];
//	}
//
//	NSLog(@"ORG:[%@]", [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:YES]);
//	NSLog(@"MD5-ASCII:[%@]", result);
//	NSLog(@"Base64-UTF8:[%@]", [[[[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:YES] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString]);
//	NSLog(@"Base64-UTF16:[%@]", [[[[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:YES] dataUsingEncoding:NSUTF16StringEncoding] base64EncodedString]);
	
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"Emoji_alert"]; //uncomment to reset Alert that tells user to use emoji keyboard
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"broadcast_enabled"] == nil) {
		[[NSUserDefaults standardUserDefaults] setValue:[@"" stringFromBOOL:YES] forKey:@"broadcast_enabled"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	_isFromBackground = NO;
	
#if __FORCE_NEW_USER__ == 1 || __FORCE_REGISTER__ == 1
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
#endif
	
#if __FORCE_NEW_USER__ == 1
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)]; // 1st run
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecValueData)]; // device id
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrService)]; // phone #
	[HONAppDelegate resetTotals];
#endif
	
#if __FORCE_REGISTER__ == 1
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)]; // 1st run
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
	
//	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	
#ifdef FONTS
	[self _showFonts];
#endif
//	[[SKPaymentQueue defaultQueue] addTransactionObserver:[[HONStoreTransactionObserver alloc] init]];
//	[self performSelector:@selector(_picoCandyTest) withObject:nil afterDelay:4.0];
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationWillResignActive] [:|:]");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationDidEnterBackground] [:|:]");
	
	[HONAppDelegate incTotalForCounter:@"background"];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Entering Background"
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
	
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	NSString *passedRegistration = [keychain objectForKey:CFBridgingRelease(kSecAttrAccount)];
	
	if ([passedRegistration length] == 0 && [[NSUserDefaults standardUserDefaults] objectForKey:@"local_reg"] == nil) {
		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
		localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:180];
		localNotification.timeZone = [NSTimeZone systemTimeZone];
		localNotification.alertAction = @"View";
		localNotification.alertBody = NSLocalizedString(@"alert_register_m", nil);
		localNotification.soundName = @"selfie_notification.caf";
		localNotification.userInfo = @{};
		
		[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
		
		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"local_reg"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"[:|:] [applicationWillEnterForeground] [:|:]");
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"active_date"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate new]] forKey:@"active_date"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Returning From Background"
									 withProperties:@{@"duration"	: ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil) ? [[HONDateTimeAlloter sharedInstance] elapsedTimeSinceDate:[[HONDateTimeAlloter sharedInstance] dateFromOrthodoxFormattedString:[[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"]]] : @"00:00:00",
													  @"total"		: [@"" stringFromInt:[HONAppDelegate totalForCounter:@"background"]]}];
	
	
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationDidBecomeActive] [:|:]");
	
	[KeenClient sharedClientWithProjectId:kKeenIOProductID
							  andWriteKey:kKeenIOWriteKey
							   andReadKey:kKeenIOReadKey];
	[KeenClient disableGeoLocation];
	
#if KEENIO_LOG == 1
	[KeenClient enableLogging];
#endif
	
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"active_date"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"active_date"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[[HONDateTimeAlloter sharedInstance] orthodoxFormattedStringFromDate:[NSDate new]] forKey:@"active_date"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (_isFromBackground) {
		if ([HONAppDelegate hasNetwork]) {
//			if ([[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] objectForKey:CFBridgingRelease(kSecAttrAccount)] length] > 0) {
//				if ([HONAppDelegate totalForCounter:@"background"] == 3) {
//					if (_insetOverlayView == nil) {
//						_insetOverlayView = [[HONInsetOverlayView alloc] initAsType:HONInsetOverlayViewTypeAppReview];
//						_insetOverlayView.delegate = self;
//						
//						[[HONScreenManager sharedInstance] appWindowAdoptsView:_insetOverlayView];
//						[_insetOverlayView introWithCompletion:nil];
//					}
//				}
//			}
			
			if (![HONAppDelegate canPingConfigServer]) {
				[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
					   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
				
			} else
				[self _retrieveConfigJSON];
		}
	
	} else {
		[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Launching"
										 withProperties:@{@"boots"	: [@"" stringFromInt:[HONAppDelegate totalForCounter:@"boot"]]}];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationWillTerminate] [:|:]");
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_TERMINATING" object:nil];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Terminating"
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
		NSArray *path = [[[[[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString] substringFromIndex:range.location + range.length] componentsSeparatedByString:@"/"];
		NSLog(@"PATH:[%@]", path);
		
		if ([path count] == 2) {
			NSString *username = [[path firstObject] lowercaseString];
			NSString *clubName = [[path lastObject] lowercaseString];
			
			// already a member
			if ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) {
				for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"]) {
					if ([[[dict objectForKey:@"owner"] objectForKey:@"id"] intValue] == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) {
						NSLog(@"OWNER_ID:[%d]", [[[dict objectForKey:@"owner"] objectForKey:@"id"] intValue]);
						_selectedClubVO = [HONUserClubVO clubWithDictionary:dict];
						break;
					}
				}
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_member", @"You are already a member of"), _selectedClubVO.clubName]
																	message:NSLocalizedString(@"alert_enterClub", @"Want to go there now?")
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
				[alertView setTag:HONAppDelegateAlertTypeEnterClub];
				[alertView show];
				
			} else { // search for this user
				[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSArray *result) {
					int userID = 0;
					if ([result count] == 0) {
						[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"hud_usernameNotFound", @"Username Not Found!")
													message:@""
												   delegate:nil
										  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
										  otherButtonTitles:nil] show];
						
					} else { // user found
						for (NSDictionary *user in result) {
							if ([username isEqualToString:[[user objectForKey:@"username"] lowercaseString]]) {
								userID = [[user objectForKey:@"id"] intValue];
								break;
							}
						}
						
						NSLog(@"userID:[%d]", userID);
						if (userID == 0) { // didn't find the user
							[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hud_usernameNotFound", @"Username Not Found!")
														message:@""
													   delegate:nil
											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
											  otherButtonTitles:nil] show];
							
						} else { // found the user
							[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:userID completion:^(NSDictionary *result) {
								int clubID = 0;
								for (NSDictionary *club in [result objectForKey:@"owned"]) {
									if ([[[club objectForKey:@"name"] lowercaseString] isEqualToString:clubName	]) {
										_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
										clubID = [[club objectForKey:@"id"] intValue];
										break;
									}
								}
								
								if (clubID > 0) { // user is the owner, prompt for join
									[[HONAPICaller sharedInstance] retrieveClubByClubID:clubID withOwnerID:userID completion:^(NSDictionary *result) {
										_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
										
										UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																							message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
																						   delegate:self
																				  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
																				  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
										[alertView setTag:HONAppDelegateAlertTypeJoinCLub];
										[alertView show];
									}];
																	
								} else { // user isn't the owner
									_clubName = clubName;
									UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"club_notfound", @"Club Not Found!")
																						message: NSLocalizedString(@"alert_create_it", @"Would you like to create it?")
																					   delegate:self
																			  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
																			  otherButtonTitles:NSLocalizedString(@"alert_no", nil), nil];
									[alertView setTag:HONAppDelegateAlertTypeCreateClub];
									[alertView show];
								}
							}]; // clubs for owner
						} // found club owner
					} // user found
				}]; // username search
			} // two fields
		} // path split
	}
	
	return (YES);
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification {
	[[UIApplication sharedApplication]cancelAllLocalNotifications];
	app.applicationIconBadgeNumber = notification.applicationIconBadgeNumber -1;
	
	notification.soundName = UILocalNotificationDefaultSoundName;
	[HONAppDelegate cafPlaybackWithFilename:@"selfie_notification"];
	
	[self _showOKAlert:notification.alertBody withMessage:@"Local Notification"];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSString *pushToken = [[deviceToken description] substringFromIndex:1];
	pushToken = [pushToken substringToIndex:[pushToken length] - 1];
	pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"\t—//]> [%@ didRegisterForRemoteNotificationsWithDeviceToken] (%@)", self.class, pushToken);
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSLog(@"WRITE PUSH TOKEN");
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
		
		[[NSUserDefaults standardUserDefaults] setObject:pushToken forKey:@"device_token"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
			[self _enableNotifications:YES];
		}];
	});
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:[[HONDeviceIntrinsics sharedInstance] pushToken]
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"\t—//]> [%@ didFailToRegisterForRemoteNotificationsWithError] (%@)", self.class, error);
	
	double delayInSeconds = 2.0;
	dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
	dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
		NSLog(@"WRITE PUSH TOKEN");
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"device_token"];
		
//		[[NSUserDefaults standardUserDefaults] setObject:[[NSString stringWithFormat:@"%064d", 0] stringByReplacingOccurrencesOfString:@"0" withString:@"F"] forKey:@"device_token"];
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"device_token"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
			[self _enableNotifications:NO];
		}];
	});
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:@"didFailToRegisterForRemoteNotificationsWithError"
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"\t—//]> [%@ didReceiveRemoteNotification] (%@)", self.class, userInfo);
	[HONAppDelegate cafPlaybackWithFilename:@"selfie_notification"];
	
	application.applicationIconBadgeNumber = 0;
	
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:[[HONDeviceIntrinsics sharedInstance] pushToken]
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}

#pragma mark - Startup Operations
- (void)_initTabs {
	NSLog(@"[|/._initTabs|/:_");
		
	NSArray *navigationControllers = @[[[UINavigationController alloc] initWithRootViewController:[[HONContactsTabViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONClubsNewsFeedViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]]];
	
	
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
//	for (NSString *key in userDefaults) {
//		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil)
//			[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
//		
//		[[NSUserDefaults standardUserDefaults] setObject:[userDefaults objectForKey:key] forKey:key];
//	}
	
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
//}

- (void)_initThirdPartySDKs {
#if __APPSTORE_BUILD__ == 0
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppToken delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];
#endif
	
	//[Mixpanel sharedInstanceWithToken:kMixPanelToken];
	
//	[[HONStickerAssistant sharedInstance] registerStickerStore];
//	for (NSString *contentGroupID in [[[NSUserDefaults standardUserDefaults] objectForKey:@"sticker_paks"] objectForKey:kFreeStickerPak]) {
//		[[HONStickerAssistant sharedInstance] retrieveContentsForContentGroup:contentGroupID completion:nil];
//	}
	
	TSConfig *config = [TSConfig configWithDefaults];
	config.collectWifiMac = NO;
//	config.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
	config.idfa = [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO];
//	config.odin1 = @"<ODIN-1 value goes here>";
	//config.openUdid = @"<OpenUDID value goes here>";
	//config.secureUdid = @"<SecureUDID value goes here>";
	NSLog(@"****** TS_NAME:[%@] ******", [[NSUserDefaults standardUserDefaults] objectForKey:@"ts_name"]);
	[TSTapstream createWithAccountName:[[NSUserDefaults standardUserDefaults] objectForKey:@"ts_name"]
					   developerSecret:kTapStreamSecretKey
								config:config];
	
	[Tapjoy requestTapjoyConnect:kTapjoyAppID
					   secretKey:kTapjoyAppSecretKey
						 options:@{TJC_OPTION_ENABLE_LOGGING	: @(YES)}];
	
//	[KikAPIClient registerAsKikPluginWithAppID:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".kik"]
//							   withHomepageURI:@"http://www.builtinmenlo.com"
//								  addAppButton:YES];
}

- (void)_writeShareTemplates {
//	return;
	
	for (NSDictionary *dict in [[NSUserDefaults standardUserDefaults] objectForKey:@"share_templates"]) {
		for (NSString *key in [dict keyEnumerator])
			[[HONImageBroker sharedInstance] writeImageFromWeb:[dict objectForKey:key] withUserDefaultsKey:[@"share_template-" stringByAppendingString:key]];
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
												  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
		[alertView setTag:HONAppDelegateAlertTypeVerifiedNotification];
		[alertView show];
	
	} else {
		if ([notification objectForKey:@"user"] != nil) {
			_userID = [[notification objectForKey:@"user"] intValue];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[[notification objectForKey:@"aps"] objectForKey:@"alert"]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
			[alertView setTag:HONAppDelegateAlertTypeRemoteNotification];
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
												  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
		[alertView setTag:1];
		[alertView show];
		
	} else {
		if ([notification objectForKey:@"user"] != nil) {
			_userID = [[notification objectForKey:@"user"] intValue];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																message:[[notification objectForKey:@"aps"] objectForKey:@"alert"]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
			[alertView setTag:HONAppDelegateAlertTypeRemoteNotification];
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
												  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
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
												  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
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


#pragma mark - InsetOverlay Delegates
//- (void)insetOverlayViewDidClose:(HONInsetOverlayView *)view {
//	NSLog(@"[*:*] insetOverlayViewDidReview");
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Review Overlay Close"];
//	
//	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
//		[_insetOverlayView removeFromSuperview];
//		_insetOverlayView = nil;
//	}];
//}
//
//- (void)insetOverlayViewDidReview:(HONInsetOverlayView *)view {
//	NSLog(@"[*:*] insetOverlayViewDidReview");
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Review Overlay Acknowledge"];
//	
//	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
//		[_insetOverlayView removeFromSuperview];
//		_insetOverlayView = nil;
//		
//		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
//	}];
//}
//
//- (void)insetOverlayViewDidInvite:(HONInsetOverlayView *)view {
//	NSLog(@"[*:*] insetOverlayViewDidReview");
//	[[HONAnalyticsParams sharedInstance] trackEvent:@"App - Invite Overlay Acknowledge"];
//	
//	[_insetOverlayView outroWithCompletion:^(BOOL finished) {
//		[_insetOverlayView removeFromSuperview];
//		_insetOverlayView = nil;
//		
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] userSignupClub] viewControllerPushed:NO]];
//		[navigationController setNavigationBarHidden:YES];
//		[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
//	}];
//}


#pragma mark - AlertView delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"BUTTON:[%d]", buttonIndex);
	
	if (alertView.tag == HONAppDelegateAlertTypeExit)
		NSLog(@"EXIT APP");//exit(0);
	
	else if (alertView.tag == HONAppDelegateAlertTypeVerifiedNotification) {
		//[[HONAnalyticsParams sharedInstance] trackEvent:[@"App - Notification Verified Invite " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
//			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"]], [NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], [[HONAppDelegate infoForUser] objectForKey:@"username"], [NSString stringWithFormat:@"https://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]],
//																									@"image"			: [HONAppDelegate avatarImage],
//																									@"url"				: @"",
//																									@"mp_event"			: @"App Root",
//																									@"view_controller"	: self.tabBarController}];
		}
	}
	
	else if (alertView.tag == HONAppDelegateAlertTypeReviewApp) {
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
		
	} else if (alertView.tag == HONAppDelegateAlertTypeInviteFriends) {
		//[[HONAnalyticsParams sharedInstance] trackEvent:[@"App - Invite Friends " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == HONAppDelegateAlertTypeShare) {
		//[[HONAnalyticsParams sharedInstance] trackEvent:[@"App - Share " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
				
		if (buttonIndex == 1) {
			__block NSString *emojis = @"";
			[((HONClubPhotoVO *)[[[HONClubAssistant sharedInstance] userSignupClub].submissions firstObject]).subjectNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				emojis = [emojis stringByAppendingString:(NSString *)obj];
			}];
			
			NSString *defaultCaption = [NSString stringWithFormat:[HONAppDelegate defaultShareMessageForIndex:1], emojis];
			NSString *igCaption = [NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], emojis];
			NSString *twCaption = defaultCaption;//[NSString stringWithFormat:[HONAppDelegate twitterShareCommentForIndex:1], emojis];
//			NSString *fbCaption = [NSString stringWithFormat:[HONAppDelegate facebookShareCommentForIndex:1], emojis];
			NSString *smsCaption = defaultCaption;//[NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], emojis];
			NSString *emailCaption = [[[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"subject"] stringByAppendingString:@"|"] stringByAppendingString:[NSString stringWithFormat:[[HONAppDelegate emailShareCommentForIndex:1] objectForKey:@"body"], emojis]];
			NSString *clipboardCaption = [NSString stringWithFormat:[HONAppDelegate smsShareCommentForIndex:1], emojis];
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"caption"			: @[igCaption, twCaption, smsCaption, emailCaption, clipboardCaption],
																									@"image"			: [HONAppDelegate avatarImage],
																									@"url"				: @"",
																									@"mp_event"			: @"App Root",
																									@"view_controller"	: self.window.rootViewController}];
		}
		
	} else if (alertView.tag == HONAppDelegateAlertTypeRefreshTabs) {
		switch (buttonIndex) {
			case 0:
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_ALL_TABS" object:nil];
				break;
				
			case 1:
				break;
		}
	} else if (alertView.tag == HONAppDelegateAlertTypeInviteContacts) {
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
	}

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONAppDelegateAlertTypeRemoteNotification) {
		//[[HONAnalyticsParams sharedInstance] trackEvent:[@"App - Notification " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
				
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
	
	} else if (alertView.tag == HONAppDelegateAlertTypeJoinCLub) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] joinClub:_selectedClubVO withMemberID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result) {
				[self.tabBarController setSelectedIndex:2];
				//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUBS_TAB" object:nil];
				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																	message:[NSString stringWithFormat: NSLocalizedString(@"want_invite", nil) , _selectedClubVO.clubName]
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
														  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
				[alertView setTag:HONAppDelegateAlertTypeInviteContacts];
				[alertView show];
			}];
		}
	
	} else if (alertView.tag == HONAppDelegateAlertTypeCreateClub) {
		if (buttonIndex == 0) {
			[self.tabBarController setSelectedIndex:2];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:_clubName]];
			[navigationController setNavigationBarHidden:YES];
			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == HONAppDelegateAlertTypeEnterClub) {
		if (buttonIndex == 1) {
			[self.tabBarController setSelectedIndex:1];
			[self.window.rootViewController.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:0] animated:YES];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"%@ - Share on %@", [_shareInfo objectForKey:@"mp_event"], (buttonIndex == HONShareSheetActionTypeInstagram) ? @"Instagram" : (buttonIndex == HONShareSheetActionTypeTwitter) ? @"Twitter" : (buttonIndex == HONShareSheetActionTypeSMS) ? @"SMS" : (buttonIndex == HONShareSheetActionTypeEmail) ? @"Email" : @"CANCEL"]];
		
		//[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[@" - Share " stringByAppendingString:(buttonIndex == HONShareSheetActionTypeKik) ? @"Kik" : (buttonIndex == HONShareSheetActionTypeInstagram) ? @"Instagram" : (buttonIndex == HONShareSheetActionTypeTwitter) ? @"Twitter" : (buttonIndex == HONShareSheetActionTypeFacebook) ? @"Facebook" : (buttonIndex == HONShareSheetActionTypeSMS) ? @"SMS" : (buttonIndex == HONShareSheetActionTypeEmail) ? @"Email" : (buttonIndex == HONShareSheetActionTypeClipboard) ? @"Link" : @"Cancel"]]];
		
//		if (buttonIndex == HONShareSheetActionTypeKik) {
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[HONAppDelegate kikCardURL]]];
//			
//
		NSLog(@"_shareInfo:[%@]", [[_shareInfo objectForKey:@"caption"] objectAtIndex:buttonIndex]);
		
		if (buttonIndex == HONShareSheetActionTypeInstagram) {
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/moji_instagram.igo"];
			[[HONImageBroker sharedInstance] saveForInstagram:[_shareInfo objectForKey:@"image"]
												 withCaption:[[_shareInfo objectForKey:@"caption"] objectAtIndex:buttonIndex]
													   toPath:savePath];
			
			__block NSString *emojis = @"";
			HONClubPhotoVO *vo = [[[HONClubAssistant sharedInstance] userSignupClub].submissions firstObject];
			
			[vo.subjectNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				emojis = [emojis stringByAppendingString:(NSString *)obj];
			}];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				_documentInteractionController.UTI = @"com.instagram.exclusivegram";
				_documentInteractionController.delegate = self;
				_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[NSString stringWithFormat:[HONAppDelegate instagramShareMessageForIndex:1], emojis] forKey:@"InstagramCaption"];
				[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:((UIViewController *)[_shareInfo objectForKey:@"view_controller"]).view animated:YES];
				
			} else {
				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"alert_instagramError_t", nil) //@"Not Available"
											message:@"This device isn't allowed or doesn't recognize Instagram!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeTwitter) {
			if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
				SLComposeViewController *twitterComposeViewController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
				SLComposeViewControllerCompletionHandler completionBlock = ^(SLComposeViewControllerResult result) {
					//[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[@" - Share Twitter " stringByAppendingString:(result == SLComposeViewControllerResultDone) ? @"Completed" : @"Canceled"]]];
					
					[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
				};
				
				[twitterComposeViewController setInitialText:[[_shareInfo objectForKey:@"caption"] objectAtIndex:buttonIndex]];
				[twitterComposeViewController addImage:[_shareInfo objectForKey:@"image"]];
				twitterComposeViewController.completionHandler = completionBlock;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:twitterComposeViewController animated:YES completion:nil];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@""
											message:@"Cannot use Twitter from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeSMS) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [[_shareInfo objectForKey:@"caption"] objectAtIndex:buttonIndex];
				messageComposeViewController.messageComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"sms_error", nil) //@"SMS Error"
											message: NSLocalizedString(@"cannot_send", nil)  //@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeEmail) {
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				[mailComposeViewController setSubject:[[[[_shareInfo objectForKey:@"caption"] objectAtIndex:buttonIndex] componentsSeparatedByString:@"|"] firstObject]];
				[mailComposeViewController setMessageBody:[[[[_shareInfo objectForKey:@"caption"] objectAtIndex:buttonIndex] componentsSeparatedByString:@"|"] lastObject] isHTML:NO];
				mailComposeViewController.mailComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email_error", @"Email Error")
											message:NSLocalizedString(@"email_errormsg", @"Cannot send email from this device!")
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeClipboard) {
			[[HONClubAssistant sharedInstance] copyClubToClipBoard:[HONUserClubVO clubWithDictionary:[_shareInfo objectForKey:@"club"]] withAlert:YES];
		}
		
		_shareInfo = nil;
	}
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
	[controller dismissViewControllerAnimated:YES completion:nil];
	_shareInfo = nil;
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
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

- (void)_writeRandomContacts:(int)amt {
	for (int i=0; i<amt; i++) {
		[[HONContactsAssistant sharedInstance] writeTrivialUserToDeviceContacts:nil];
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

