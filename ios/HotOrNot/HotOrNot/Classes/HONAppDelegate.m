//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDKv2/AWSCore.h>
#import <CommonCrypto/CommonHMAC.h>

#import <AddressBook/AddressBook.h>
#import <AdSupport/AdSupport.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <StoreKit/StoreKit.h>
#import <sys/utsname.h>
#import </usr/include/objc/objc-class.h>

#import <HockeySDK/HockeySDK.h>
//#import <Tapjoy/Tapjoy.h>
#import "Flurry.h"

#import "NSCharacterSet+AdditionalSets.h"
#import "NSData+Base64.h"
#import "NSDate+Operations.h"
#import "NSString+Base64.h"
#import "NSString+DataTypes.h"
#import "NSUserDefaults+Replacements.h"

#import "AFNetworking.h"
#import "BlowfishAlgorithm.h"
//#import "Crittercism.h"
//#import "CrittercismDelegate.h"
#import "MBProgressHUD.h"
#import "KeenClient.h"
#import "KeychainItemWrapper.h"
#import "NHThreadThis.h"
#import "PicoSticker.h"
//#import "Reachability.h"
#import "TSTapstream.h"
#import "UIImageView+AFNetworking.h"

#import "HONAppDelegate.h"
#import "HONStoreTransactionObserver.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONHomeViewController.h"
#import "HONActivityViewController.h"
#import "HONSettingsViewController.h"
#import "HONComposeViewController.h"


#if __DEV_BUILD__ == 0 || __APPSTORE_BUILD__ == 1
NSString * const kConfigURL = @"https://volley-api.selfieclubapp.com";
//NSString * const kConfigJSON = @"boot_sc0007.json";
NSString * const kConfigJSON = @"boot_sc0009.json";
NSString * const kAPIHost = @"data_api";
#else
NSString * const kConfigURL = @"https://volley-api.devint.selfieclubapp.com";
//NSString * const kConfigJSON = @"boot_ios.json";
NSString * const kConfigJSON = @"boot_yunder.json";
NSString * const kAPIHost = @"data_api-stage";
#endif

NSString * const kBlowfishKey = @"KJkljP9898kljbm675865blkjghoiubdrsw3ye4jifgnRDVER8JND997";
NSString * const kBlowfishIV = @"„7ì”~ís";

#if __APPSTORE_BUILD__ == 1
NSString * const kKeenIOProductID = @"547280787d8cb91037ffa14f";
NSString * const kKeenIOMasterKey = @"DEBAFD13136BB67D6DA2782D5B892D71";
NSString * const kKeenIOReadKey = @"a5974f32089efc21bf3b6c4deffd3d75505d43759b85b421aaff1d5effcc8d64e42a582291432c7405fb25561c66dbf5a0b8977994b337cbeae601257b13ea67e4c535ad7c47f608be64962e5c750b361b338d3eb553ac824463d3ea9afefe0c49ba280510b7e6661918df88e24c5f0b";
NSString * const kKeenIOWriteKey = @"6721421761b2ce2cbd58bc80cd0529d237339923613734d6e549f9e079f007793958d1da054d6f539a8768476e2f4779ff2828050a354a63f38a5e6d0ec22854fcd2136834f34fbf76d11bafc845a35171282f40c6e310c824664a269c7589ab41cb100429c5f8e22b5ccb8bfda89204";
#else
NSString * const kKeenIOProductID = @"5472803f7d8cb91037ffa14e";
NSString * const kKeenIOMasterKey = @"6FF7CA039003552C410EC16300F3634E";
NSString * const kKeenIOReadKey = @"e9657f3cdd1e1c1be9b55933f6d0ff17b124aedd055f9527bf3a9795d948dfb3c43e67d875306eb092bb00dd12bdbfbbba0b5e8851e6a1c91adc1e7a5f673b36e6e52039a6af2981fe44689f67a192324e57de2fe5747a76c55ef2b9f414a306844837739484ab54d85f6c561b10e5b0";
NSString * const kKeenIOWriteKey = @"b1cdd775a884281f24e673401727f75c05985ae671db08bc85aa5f642673e0f5714552c5edec79607df590391a891d08a194ab93f7064607f91e858c80d3368c1b2964dab554f2006679f10200b6732e5ea3d2892f084212c297b32b06e8d131feda4bb0a732f0236d519f3d2bb29047";
#endif


NSString * const kFacebookAppID = @"600550136636754";
NSString * const kHockeyAppToken = @"a2f42fed0f269018231f6922af0d8ad3";
NSString * const kTapStreamSecretKey = @"8Q6fJ5eKTbSOHxzGGrX8pA";
NSString * const kTapjoyAppID = @"13b84737-f359-4bf1-b6a0-079e515da029";
NSString * const kTapjoyAppSecretKey = @"llSjQBKKaGBsqsnJZlxE";
NSString * const kFlurryAPIKey = @"XH2STY3SYCJ37QMTKYHZ";

// view heights
const CGFloat kNavHeaderHeight = 64.0;
const CGFloat kSearchHeaderHeight = 43.0f;
const CGFloat kDetailsHeroImageHeight = 324.0;

// ui
const CGSize kTabSize = {80.0, 50.0};

// animation params
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

const NSURLRequestCachePolicy kOrthodoxURLCachePolicy = NSURLRequestReturnCacheDataElseLoad;
//const NSURLRequestCachePolicy kOrthodoxURLCachePolicy = NSURLRequestReloadIgnoringCacheData;
NSString * const kTwilioSMS = @"6475577873";


#if __APPSTORE_BUILD__ == 0
@interface HONAppDelegate() <BITHockeyManagerDelegate, PicoStickerDelegate>
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
@property (nonatomic) int clubID;
@property (nonatomic) int userID;
@property (nonatomic) BOOL awsUploadCounter;
@property (nonatomic, copy) NSString *currentConversationID;
@end


@implementation HONAppDelegate
@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;


void Swizzle(Class c, SEL orig, SEL new)
{
	Method origMethod = class_getInstanceMethod(c, orig);
	Method newMethod = class_getInstanceMethod(c, new);
	
	if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
		class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	
	else
		method_exchangeImplementations(origMethod, newMethod);
}


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

+ (NSDictionary *)orthodoxClubVO {
	NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{@"id"	: [[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"owner_id"]}];
	[dict setValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] forKey:@"id"];
	
	return ([dict copy]);
}

+ (NSDictionary *)contentForInsetOverlay:(HONInsetOverlayViewType)insetType {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:(insetType == HONInsetOverlayViewTypeAppReview) ? @"review" : (insetType == HONInsetOverlayViewTypeSuggestions) ? @"contacts" : @"unlock"]);
}

+ (NSTimeInterval)timeoutInterval {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"timeout_interval"] doubleValue]);
}

+ (NSString *)shareMessageForType:(HONShareMessageType)messageType {
	if (messageType == HONShareMessageTypeClipboard) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"clipboard"]);
	
	} else if (messageType == HONShareMessageTypeEmail) {
		return ([NSString stringWithFormat:@"%@|%@", [[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"email"] objectForKey:@"subject"], [[[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"email"] objectForKey:@"body"]]);
	
	} else if (messageType == HONShareMessageTypeFacebook) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"facebook"]);
		
	} else if (messageType == HONShareMessageTypeInstagram) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"instagram"]);
		
	} else if (messageType == HONShareMessageTypeSMS) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"sms"]);
		
	} else if (messageType == HONShareMessageTypeTwitter) {
		return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"twitter"]);
	}
	
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_formats"] objectForKey:@"default"]);
}

+ (int)clubInvitesThreshold {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"invite_threshold"] intValue]);
}

+ (CGFloat)minSnapLuminosity {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"min_luminosity"] floatValue]);
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


+ (NSString *)kikCardURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"kik_card"]);
}

+ (void)writeUserInfo:(NSDictionary *)userInfo {
	[[NSUserDefaults standardUserDefaults] replaceObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	NSMutableDictionary *dict = [userInfo mutableCopy];
	[dict setValue:[NSString stringWithFormat:@"%@_%@_%d", [[userInfo objectForKey:@"username"] stringByTrimmingCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] addChars:@"."]], [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:YES], [[NSDate dateFromISO9601FormattedString:[userInfo objectForKey:@"added"]] unixEpochTimestamp]] forKey:@"username"];
	
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
//	NSLog(@"QUEUEING : |]%@]>{%@)_", NSStringFromRange(range), tag);
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) { };
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {};
	
	for (int i=0; i<range.length - range.location; i++) {
//		NSLog(@"s+ArT_l0Ad. --> (#%02d) \"%@\"", (range.location + i), [urls objectAtIndex:i]);
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
		[imageView setTag:range.location + i];
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[urls objectAtIndex:i]
														   cachePolicy:kOrthodoxURLCachePolicy
													   timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];
	}
}


+ (CGFloat)compressJPEGPercentage {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"jpeg_compress"] floatValue]);
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
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"expire_threshold"] forKey:@"expire_threshold"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_templates"] forKey:@"share_templates"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_url"] forKey:@"share_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"inset_modals"] forKey:@"inset_modals"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"suggested_covers"] forKey:@"suggested_covers"];
		[[NSUserDefaults standardUserDefaults] setObject:[[[result objectForKey:@"app_schemas"] objectForKey:@"kik"] objectForKey:@"ios"] forKey:@"kik_card"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"jpeg_compress"] forKey:@"jpeg_compress"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"orthodox_club"] forKey:@"orthodox_club"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"location_clubs"] forKey:@"location_clubs"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invite_threshold"] forKey:@"invite_threshold"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"pico_candy"] forKey:@"pico_candy"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"switches"] forKey:@"switches"];
		[[NSUserDefaults standardUserDefaults] setObject:@{@"avatars"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"avatars"],
														   @"banners"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"banners"],
														   @"clubs"			: [[result objectForKey:@"s3_buckets"] objectForKey:@"clubs"],
														   @"emoticons"		: [[result objectForKey:@"s3_buckets"] objectForKey:@"emoticons"]} forKey:@"s3_buckets"];
		
		[[NSUserDefaults standardUserDefaults] setObject:@{@"sms"		: [[result objectForKey:@"invite_formats"] objectForKey:@"sms"],
														   @"email"		: [[result objectForKey:@"invite_formats"] objectForKey:@"email"]} forKey:@"invite_formats"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"share_formats"] objectForKey:@"sheet_title"] forKey:@"share_title"];
		[[NSUserDefaults standardUserDefaults] setObject:@{@"default"	: [[result objectForKey:@"share_formats"] objectForKey:@"default"],
														   @"clipboard"	: [[result objectForKey:@"share_formats"] objectForKey:@"clipboard"],
														   @"instagram"	: [[result objectForKey:@"share_formats"] objectForKey:@"instagram"],
														   @"twitter"	: [[result objectForKey:@"share_formats"] objectForKey:@"twitter"],
														   @"facebook"	: [[result objectForKey:@"share_formats"] objectForKey:@"facebook"],
														   @"sms"		: [[result objectForKey:@"share_formats"] objectForKey:@"sms"],
														   @"email"		: [[result objectForKey:@"share_formats"] objectForKey:@"email"]} forKey:@"share_formats"];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		NSLog(@"API END PT:[%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [HONAppDelegate apiServerPath]);
		
		[self _initThirdPartySDKs];
		if ([[[result objectForKey:@"boot_alert"] objectForKey:@"enabled"] isEqualToString:@"Y"])
			[self _showOKAlert:[[result objectForKey:@"boot_alert"] objectForKey:@"title"] withMessage:[[result objectForKey:@"boot_alert"] objectForKey:@"message"]];
		
		
		[self _writeShareTemplates];
		[[HONImageBroker sharedInstance] writeImageFromWeb:[NSString stringWithFormat:@"%@/defaultAvatar%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], kSnapLargeSuffix] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"default_avatar"];
		[self _registerUser];
		
		if (_isFromBackground) {
			NSString *notificationName = @"";
			switch ([[HONStateMitigator sharedInstance] currentViewStateType]) {
				case HONStateMitigatorViewStateTypeFriends:
					notificationName = @"REFRESH_HOME_TAB";
					break;
					
				case HONStateMitigatorViewStateTypeSettings:
					notificationName = @"REFRESH_SETTINGS_TAB";
					break;
					
				default:
					notificationName = @"REFRESH_ALL_TABS";
					break;
			}
			
			NSLog(@"REFRESHING:[%@]", notificationName);
			[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
			_isFromBackground = NO;
			
		} else {
			//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Launching"
//											 withProperties:@{@"boots"	: [@"" stringFromInt:[[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBoot]]}];
		}
	}];
}

- (void)_registerUser {
	[[HONAPICaller sharedInstance] registerNewUserWithCompletion:^(NSDictionary *result) {
		if ([result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
			[HONAppDelegate writeUserInfo:result];
			
			NSDate *cohortDate = ([[HONAppDelegate infoForUser] objectForKey:@"added"] != nil) ? [NSDate dateFromOrthodoxFormattedString:[[HONAppDelegate infoForUser] objectForKey:@"added"]] : [NSDate utcNowDate];
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - day"
											   withProperties:@{@"day"	: [NSDate utcNowDate]}];
			
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - cohort_date"
											   withProperties:@{@"cohort_date"	: [[[cohortDate formattedISO8601StringUTC] componentsSeparatedByString:@"T"] firstObject]}];
			
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - cohort_week"
											   withProperties:@{@"cohort_week"	: [NSString stringWithFormat:@"%04d-W%02d", [cohortDate year], [cohortDate weekOfYear]]}];
			
			[Flurry setUserID:[[HONAppDelegate infoForUser] objectForKey:@"id"]];
			KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
			if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] == 0) {
				
			}
			
			if ([[result objectForKey:@"email"] length] == 0)
				[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
			
			else
				[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:[result objectForKey:@"email"]];
			
			[[HONImageBroker sharedInstance] writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			
//			[[NSUserDefaults standardUserDefaults] setObject:[HONUserClubVO clubWithDictionary:@{}] forKey:@"crash_me"];
//			[[NSUserDefaults standardUserDefaults] synchronize];
			
//			[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
//				[[HONClubAssistant sharedInstance] writeUserClubs:result];
			
				if (self.window.rootViewController == nil) {
					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONHomeViewController alloc] init]];
					[navigationController setNavigationBarHidden:YES];
					
					self.window.rootViewController = navigationController;
					self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				}
//			}];
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


#pragma mark - Notifications
- (void)_showShareShelf:(NSNotification *)notification {
	_shareInfo = [notification object];
	
	NSLog(@"_showShareShelf:[%@]", _shareInfo);
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:([[[NSUserDefaults standardUserDefaults] objectForKey:@"share_title"] length] > 0) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"share_title"] : nil
															 delegate:self
													cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
											   destructiveButtonTitle:nil
													otherButtonTitles:@"Instagram", @"Twitter", @"SMS", @"Email", @"Copy to clipboard", nil];
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
	
	// 귀하의 게시물 이 만료. + Your post has expired.
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
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	NSLog(@"[:|:] [application:didFinishLaunchingWithOptions] [:|:]");
	
	[KeenClient disableGeoLocation];
	
	[Flurry setCrashReportingEnabled:YES];
	[Flurry setShowErrorInLogEnabled:YES];
	[Flurry setLogLevel:FlurryLogLevelCriticalOnly];
	[Flurry startSession:kFlurryAPIKey];
	[Flurry logEvent:@"launch"];
	
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
	[[HONStateMitigator sharedInstance] updateAppEntryTimestamp:[NSDate date]];
	[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
	
//	NSLog(@"PAD:%@", [NSString stringWithFormat:@"%0*d", 8, [@"1F604" length]]);
	
	[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeBoot];
	[[HONStateMitigator sharedInstance] updateCurrentViewState:HONStateMitigatorViewStateTypeNotAvailable];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"clubs"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clubs"];
	
	
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
	
	
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	self.window.backgroundColor = [UIColor whiteColor];
	[self.window addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appBG"]]];
	_isFromBackground = NO;
	
	
#if __FORCE_NEW_USER__ == 1 || __FORCE_REGISTER__ == 1
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
#endif
	
#if __FORCE_NEW_USER__ == 1
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)]; // 1st run
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecValueData)]; // device id
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrService)]; // phone #
//	[HONAppDelegate resetTotals];
	[[HONStateMitigator sharedInstance] resetAllTotalCounters];
#endif
	
#if __FORCE_REGISTER__ == 1
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)]; // 1st run
#endif
	
	
	[self _styleUIAppearance];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showShareShelf:) name:@"SHOW_SHARE_SHELF" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_playOverlayAnimation:) name:@"PLAY_OVERLAY_ANIMATION" object:nil];
	

#if __APPSTORE_BUILD__ == 0
	[[BITHockeyManager sharedHockeyManager] configureWithIdentifier:kHockeyAppToken delegate:self];
	[[BITHockeyManager sharedHockeyManager] startManager];
#endif

	
	[self _establishUserDefaults];
	
	if ([[HONAPICaller sharedInstance] hasNetwork]) {
		if (![[HONAPICaller sharedInstance] canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		}
		
		[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeBoot];
		
		[self.window makeKeyAndVisible];
		
		[self _retrieveConfigJSON];
		
	} else {
		[self _showOKAlert:@"No Network Connection"
			   withMessage:@"This app requires a network connection to work."];
	}
	
//	NSLog(@"NSUserDefaults:[%@]", [[NSUserDefaults standardUserDefaults] objectDictionary]);
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Launching"
//									 withProperties:@{@"boots"	: [@"" stringFromInt:[[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBoot]]}];
	
	//[[SKPaymentQueue defaultQueue] addTransactionObserver:[[HONStoreTransactionObserver alloc] init]];
//	[self performSelector:@selector(_picoCandyTest) withObject:nil afterDelay:4.0];
	
#ifdef FONTS
	[self _showFonts];
#endif
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationWillResignActive] [:|:]");
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"[:|:] [applicationDidEnterBackground] [:|:]");
	
	
//	[HONAppDelegate incTotalForCounter:@"background"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeBackground];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Entering Background"
//									 withProperties:@{@"total"		: [@"" stringFromInt:[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeBackground]],
//													  @"duration"	: @([NSDate elapsedSecondsSinceDate:[[HONStateMitigator sharedInstance] appEntryTimestamp]])}];
	
	[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	
	UIBackgroundTaskIdentifier taskId = [application beginBackgroundTaskWithExpirationHandler:^(void) {
		NSLog(@"Background task is being expired.");
	}];
	
	[[KeenClient sharedClient] uploadWithFinishedBlock:^(void) {
		[application endBackgroundTask:taskId];
	}];
	
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	NSString *passedRegistration = [keychain objectForKey:CFBridgingRelease(kSecAttrAccount)];
	
	if ([passedRegistration length] == 0 && [[NSUserDefaults standardUserDefaults] objectForKey:@"local_reg"] == nil) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Backgrounding First Run"];
		
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
	
	[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeSpringboard];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Leaving Background"
//									 withProperties:@{@"duration"	: @([NSDate elapsedSecondsSinceDate:[[HONStateMitigator sharedInstance] appExitTimestamp]]),
//													  @"total"		: [@"" stringFromInt:[[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBackground]]}];
	
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"[:|:] [applicationDidBecomeActive] [:|:]");
	
//	[FBAppEvents activateApp];
	
	[KeenClient sharedClientWithProjectId:kKeenIOProductID
							  andWriteKey:kKeenIOWriteKey
							   andReadKey:kKeenIOReadKey];
	[KeenClient disableGeoLocation];
//	[KeenClient enableLogging];
	
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:HONStateMitigatorTotalTypeTrackingCalls withValue:0];
	[[HONStateMitigator sharedInstance] updateAppEntryTimestamp:[NSDate date]];
	[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Became Active"];
	[Flurry logEvent:@"App_Active"];

	
	if (_isFromBackground) {
		[Flurry logEvent:@"resume"];
		
		if ([[HONAPICaller sharedInstance] hasNetwork]) {
			if ([[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] objectForKey:CFBridgingRelease(kSecAttrAccount)] length] > 0) {
				
			}
			
			if (![[HONAPICaller sharedInstance] canPingConfigServer]) {
				[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
					   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
				
			} else
				[self _retrieveConfigJSON];
		}
	
	} else {
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
	//NSLog(@"[:|:] [applicationWillTerminate] [:|:]");
	
//	[FBSession.activeSession close];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_TERMINATING" object:nil];
	
	[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Terminating"
//									 withProperties:@{@"duration"	: @([NSDate elapsedSecondsSinceDate:[[HONStateMitigator sharedInstance] appEntryTimestamp]])}];
	
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
			
			[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeDeepLink];
			
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
	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
	
	[self _showOKAlert:notification.alertBody withMessage:@"Local Notification"];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSString *pushToken = [[deviceToken description] substringFromIndex:1];
	pushToken = [pushToken substringToIndex:[pushToken length] - 1];
	pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"\t—//]> [%@ didRegisterForRemoteNotificationsWithDeviceToken] (%@)", self.class, pushToken);
	[[HONDeviceIntrinsics sharedInstance] writePushToken:pushToken];
	
	if (![[[HONAppDelegate infoForUser] objectForKey:@"device_token"] isEqualToString:pushToken]) {
		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
			[self _enableNotifications:YES];
		}];
	}
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:[[HONDeviceIntrinsics sharedInstance] pushToken]
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"\t—//]> [%@ didFailToRegisterForRemoteNotificationsWithError] (%@)", self.class, error);
	
	[[HONDeviceIntrinsics sharedInstance] writePushToken:@""];
	if (![[[HONAppDelegate infoForUser] objectForKey:@"device_token"] isEqualToString:@""]) {
		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
			[self _enableNotifications:NO];
		}];
	}
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:@"didFailToRegisterForRemoteNotificationsWithError"
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"\t—//]> [%@ didReceiveRemoteNotification] (%@)", self.class, userInfo);
	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
	
	[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeRemoteNotification];
	
	NSString *typeID = [[userInfo objectForKey:@"aps"] objectForKey:@"type"];
	_clubID = [[[userInfo objectForKey:@"aps"] objectForKey:@"club_id"] intValue];
	_userID = [[[userInfo objectForKey:@"aps"] objectForKey:@"owner_id"] intValue];
	
	if ([[typeID uppercaseString] isEqualToString:@"DEV"]) {
		[self _showOKAlert:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
			   withMessage:[[HONDeviceIntrinsics sharedInstance] pushToken]];
		
	} else if ([[typeID uppercaseString] isEqualToString:@"INVITE"]) {
//		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
//															message:@""
//														   delegate:self
//												  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
//												  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
//		[alertView setTag:HONAppDelegateAlertTypeRemoteNotification];
//		[alertView show];
	
	} else {
		[[HONAPICaller sharedInstance] retrieveClubByClubID:_clubID withOwnerID:_userID completion:^(NSDictionary *result) {
			_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"You have 1 new status update"
																message:@""
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_cancel", nil)
													  otherButtonTitles:NSLocalizedString(@"alert_ok", nil), nil];
			[alertView setTag:HONAppDelegateAlertTypeRemoteNotification];
			[alertView show];
		}];
	}
	
	application.applicationIconBadgeNumber = 0;
}

#pragma mark - Startup Operations
- (void)_initTabs {
	NSLog(@"[|/._initTabs|/:_");
	
	NSArray *navigationControllers = @[[[UINavigationController alloc] initWithRootViewController:[[HONHomeViewController alloc] init]],
									   [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]]];
	
	
	for (UINavigationController *navigationController in navigationControllers) {
		[navigationController setNavigationBarHidden:YES animated:NO];
		
		if ([navigationController.navigationBar respondsToSelector:@selector(setShadowImage:)])
			[navigationController.navigationBar setShadowImage:[[UIImage alloc] init]];
	}
	
	self.window.rootViewController = [[HONHomeViewController alloc] init];
	self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_TABS" object:@"HIDE"];
}

- (void)_establishUserDefaults {
	NSDictionary *userDefaults = @{@"is_deactivated"	: [@"" stringFromBOOL:NO],
								   @"votes"				: @{},
								   @"purchases"			: @[],
								   @"coords"			: @{@"lat" : @(0.00), @"long" : @(0.00)},
								   @"activity_updated"	: @"0000-00-00 00:00:00"};
	
	for (NSString *key in [userDefaults allKeys]) {
//		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] == nil)
		if (![[NSUserDefaults standardUserDefaults] hasObjectForKey:key])
			[[NSUserDefaults standardUserDefaults] setObject:[userDefaults objectForKey:key] forKey:key];
	}
	
	for (NSString *key in [[[HONStateMitigator sharedInstance] _totalKeyPrefixesForTypes] allKeys]) {
		NSString *keyName = [key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix];
//		if ([[NSUserDefaults standardUserDefaults] objectForKey:keyName] == nil)
		if (![[NSUserDefaults standardUserDefaults] hasObjectForKey:keyName])
			[[HONStateMitigator sharedInstance] resetTotalCounterForType:(HONStateMitigatorTotalType)[[[HONStateMitigator sharedInstance] _totalKeyPrefixesForTypes] objectForKey:keyName] withValue:-1];
	}
	
#if __FORCE_REGISTER__ == 1
	for (NSString *key in [userDefaults allKeys]) {
		if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
		[[NSUserDefaults standardUserDefaults] setObject:[userDefaults objectForKey:key] forKey:key];
	}
	
	[[HONStateMitigator sharedInstance] resetAllTotalCounters];
#endif
	
#if __RESET_TOTALS__ == 1
	[[HONStateMitigator sharedInstance] resetAllTotalCounters];
#endif
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_initThirdPartySDKs {
	TSConfig *config = [TSConfig configWithDefaults];
	config.collectWifiMac = NO;
	config.idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
//	config.idfa = [[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO];
//	config.odin1 = @"<ODIN-1 value goes here>";
	//config.openUdid = @"<OpenUDID value goes here>";
	//config.secureUdid = @"<SecureUDID value goes here>";
	NSLog(@"****** TS_NAME:[%@] ******", [[NSUserDefaults standardUserDefaults] objectForKey:@"ts_name"]);
	[TSTapstream createWithAccountName:[[NSUserDefaults standardUserDefaults] objectForKey:@"ts_name"]
					   developerSecret:kTapStreamSecretKey
								config:config];
	
//	[Tapjoy requestTapjoyConnect:kTapjoyAppID
//					   secretKey:kTapjoyAppSecretKey
//						 options:@{TJC_OPTION_ENABLE_LOGGING	: @(YES)}];

	AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"]
																									 secretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
																		  credentialsProvider:credentialsProvider];
	
	[AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

	
	
//	[Crittercism enableWithAppID:kCritersismAppID
//					 andDelegate:self];
	
//	[KikAPIClient registerAsKikPluginWithAppID:[[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".kik"]
//							   withHomepageURI:@"http://www.builtinmenlo.com"
//								  addAppButton:YES];
}

- (void)_writeShareTemplates {
	NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"share_templates"];
	for (NSString *key in [dict keyEnumerator])
		[[HONImageBroker sharedInstance] writeImageFromWeb:[dict objectForKey:key] withUserDefaultsKey:[@"share_template-" stringByAppendingString:key]];
}


#pragma mark - Crash Handling
void uncaughtExceptionHandler(NSException *exception) {
	NSString *message = [NSString stringWithFormat:@"Device: %@\nOS: %@\nBacktrace:\n%@", [[HONDeviceIntrinsics sharedInstance] modelName], [[HONDeviceIntrinsics sharedInstance] osNameVersion], [exception callStackSymbols]];
	NSLog(@"[INFO] Flurry logged an uncaught error: %@\n%@", exception, message);
	
	[Flurry logError:@"Uncaught"
			 message:message
		   exception:exception];
}


#pragma mark - AlertView delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSLog(@"BUTTON:[%ld]", (long)buttonIndex);
	
	if (alertView.tag == HONAppDelegateAlertTypeExit)
		NSLog(@"EXIT APP");//exit(0);
	
	else if (alertView.tag == HONAppDelegateAlertTypeReviewApp) {
		switch(buttonIndex) {
			case 0:
				break;
				
			case 1:
				[[HONStateMitigator sharedInstance] writeAppInstallTimestamp];
				break;
				
			case 2:
				[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"itms://itunes.apple.com/app/id%@?mt=8&uo=4", [[NSUserDefaults standardUserDefaults] objectForKey:@"appstore_id"]]]];
				break;
		}
		
	} else if (alertView.tag == HONAppDelegateAlertTypeInviteFriends) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:[@"App - Invite Friends " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		
		if (buttonIndex == 1) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONAddContactsViewController alloc] init]];
//			[navigationController setNavigationBarHidden:YES];
//			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
		
	} else if (alertView.tag == HONAppDelegateAlertTypeShare) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:[@"App - Share " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
				
		if (buttonIndex == 1) {
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"captions"			: @{@"instagram"	: [NSString stringWithFormat:[HONAppDelegate shareMessageForType:HONShareMessageTypeInstagram], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"twitter"		: [NSString stringWithFormat:[HONAppDelegate shareMessageForType:HONShareMessageTypeTwitter], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"sms"			: [NSString stringWithFormat:[HONAppDelegate shareMessageForType:HONShareMessageTypeSMS], [[HONAppDelegate infoForUser] objectForKey:@"username"]],
																															@"email"		: @{@"subject"	: [[[HONAppDelegate shareMessageForType:HONShareMessageTypeEmail] componentsSeparatedByString:@"|"] firstObject],
																																				@"body"		: [NSString stringWithFormat:[[[HONAppDelegate shareMessageForType:HONShareMessageTypeEmail] componentsSeparatedByString:@"|"] firstObject], [[HONAppDelegate infoForUser] objectForKey:@"username"]]},
																															@"clipboard"	: [NSString stringWithFormat:[HONAppDelegate shareMessageForType:HONShareMessageTypeClipboard], [[HONAppDelegate infoForUser] objectForKey:@"username"]]},
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
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteContactsViewController alloc] initWithClub:_selectedClubVO viewControllerPushed:NO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == HONAppDelegateAlertTypeAllowContactsAccess) {
		NSLog(@"CONTACTS:[%ld]", (long)buttonIndex);
		if (buttonIndex == 1) {
			if (ABAddressBookRequestAccessWithCompletion) {
				ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
				NSLog(@"ABAddressBookGetAuthorizationStatus() = [%@]", (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"kABAuthorizationStatusNotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"kABAuthorizationStatusDenied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"kABAuthorizationStatusAuthorized" : @"OTHER");
				
				if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
					});
					
				} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
					});
					
				} else {
				}
			}
		}
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONAppDelegateAlertTypeRemoteNotification) {
//		[[HONAnalyticsParams sharedInstance] trackEvent:[@"App - Notification " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];
		if (buttonIndex == 1) {
//			[self.window.rootViewController.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:0] animated:YES];
		}
		
	} else if (alertView.tag == HONAppDelegateAlertTypeJoinCLub) {
		if (buttonIndex == 0) {
			[[HONAPICaller sharedInstance] joinClub:_selectedClubVO completion:^(NSObject *result) {
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
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateClubViewController alloc] initWithClubTitle:_clubName]];
//			[navigationController setNavigationBarHidden:YES];
//			[self.window.rootViewController presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == HONAppDelegateAlertTypeEnterClub) {
		if (buttonIndex == 1) {
//			[self.window.rootViewController.navigationController pushViewController:[[HONClubTimelineViewController alloc] initWithClub:_selectedClubVO atPhotoIndex:0] animated:YES];
		}
	}
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		//[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[@" - Share " stringByAppendingString:(buttonIndex == HONShareSheetActionTypeKik) ? @"Kik" : (buttonIndex == HONShareSheetActionTypeInstagram) ? @"Instagram" : (buttonIndex == HONShareSheetActionTypeTwitter) ? @"Twitter" : (buttonIndex == HONShareSheetActionTypeFacebook) ? @"Facebook" : (buttonIndex == HONShareSheetActionTypeSMS) ? @"SMS" : (buttonIndex == HONShareSheetActionTypeEmail) ? @"Email" : (buttonIndex == HONShareSheetActionTypeClipboard) ? @"Link" : @"Cancel"]]];
		
//		if (buttonIndex == HONShareSheetActionTypeKik) {
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[HONAppDelegate kikCardURL]]];
//			
//
		if (buttonIndex == HONShareSheetActionTypeInstagram) {
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
			[[HONImageBroker sharedInstance] saveForInstagram:[_shareInfo objectForKey:@"image"]
									withUsername:[[HONAppDelegate infoForUser] objectForKey:@"username"]
										  toPath:savePath];
			
			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
				_documentInteractionController.UTI = @"com.instagram.exclusivegram";
				_documentInteractionController.delegate = self;
				_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[[_shareInfo objectForKey:@"captions"] objectForKey:@"instagram"] forKey:@"InstagramCaption"];
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
					[twitterComposeViewController dismissViewControllerAnimated:YES completion:nil];
				};
				
				[twitterComposeViewController setInitialText:[[_shareInfo objectForKey:@"captions"] objectForKey:@"twitter"]];
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
				messageComposeViewController.body = [[_shareInfo objectForKey:@"captions"] objectForKey:@"sms"];
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
				[mailComposeViewController setSubject:[[[_shareInfo objectForKey:@"captions"] objectForKey:@"email"] objectForKey:@"subject"]];
				[mailComposeViewController setMessageBody:[[[_shareInfo objectForKey:@"captions"] objectForKey:@"email"] objectForKey:@"body"] isHTML:NO];
				mailComposeViewController.mailComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:mailComposeViewController
																		   animated:YES
																		 completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"email_error", @"Email Error")
											message:NSLocalizedString(@"email_errormsg", @"Cannot send email from this device!")
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONShareSheetActionTypeClipboard) {
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = @"Get Yunder - A live photo feed of who is doing what around you. getyunder.com";
			
			[self _showOKAlert:@"Paste anywhere to share!" withMessage:nil];
		}
		
		_shareInfo = nil;
	}
}


#pragma mark - DocumentInteraction Delegates
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - DocInteraction Shelf"
//									 withProperties:@{@"state"		: @"presenting",
//													  @"controller"	: [controller name]}];
}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - DocInteraction Shelf"
//									 withProperties:@{@"state"		: @"dismissing",
//													  @"controller"	: [controller name]}];
	
	_documentInteractionController.delegate = nil;
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller willBeginSendingToApplication:(NSString *)application {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - DocInteraction App"
//									 withProperties:@{@"state"		: @"launching",
//													  @"controller"	: [controller name]}];
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - DocInteraction App Foreground"
//									 withProperties:@{@"state"		: @"entering",
//													  @"controller"	: [controller name]}];
}


#pragma mark - MessageCompose Delegates
- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
//	NSString *mpAction = @"";
//	switch (result) {
//		case MessageComposeResultCancelled:
//			mpAction = @"Canceled";
//			break;
//			
//		case MessageComposeResultSent:
//			mpAction = @"Sent";
//			break;
//			
//		case MessageComposeResultFailed:
//			mpAction = @"Failed";
//			break;
//			
//		default:
//			mpAction = @"Not Sent";
//			break;
//	}
	
//	[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[NSString stringWithFormat:@" - Share via SMS (%@)", mpAction]]];
	[controller dismissViewControllerAnimated:YES completion:nil];
	_shareInfo = nil;
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
		
//	NSString *mpAction = @"";
//	switch (result) {
//		case MFMailComposeResultCancelled:
//			mpAction = @"Canceled";
//			break;
//			
//		case MFMailComposeResultFailed:
//			mpAction = @"Failed";
//			break;
//			
//		case MFMailComposeResultSaved:
//			mpAction = @"Saved";
//			break;
//			
//		case MFMailComposeResultSent:
//			mpAction = @"Sent";
//			break;
//			
//		default:
//			mpAction = @"Not Sent";
//			break;
//	}
//	[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[NSString stringWithFormat:@" - Share via Email (%@)", mpAction]]];
	
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
	return ([[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO]);
	return (nil);
}
#endif

#if __APPSTORE_BUILD__ == 0
- (void)_picoCandyTest {
	NSLog(@"CandyStore:\n%@\n\n", [[HONStickerAssistant sharedInstance] fetchStickerStoreInfo]);
	[[HONStickerAssistant sharedInstance] retrievePicoCandyUser];
	NSLog(@"CandyBox:\n%@\n\n", [[HONStickerAssistant sharedInstance] fetchAllCandyBoxContents]);
	
	[self performSelector:@selector(_picoCandyTest2) withObject:nil afterDelay:4.0];
}

- (void)_picoCandyTest2 {
	__block int idx = 0;
	[[[HONStickerAssistant sharedInstance] fetchAllCandyBoxContents] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		PicoSticker *sticker = (PicoSticker *)obj;
		sticker.frame = CGRectMake((idx % 5) * 60.0, (idx / 5) * 60.0, 50.0, 50.0);
		sticker.backgroundColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
		sticker.userInteractionEnabled = YES;
		sticker.delegate = self;
		[sticker setTag:idx];
		
		idx++;
	}];
}

- (void)picoSticker:(id)sticker tappedWithContentId:(NSString *)contentId {
	NSLog(@"sticker.tag:[%ld] (%@)", (long)((PicoSticker *)sticker).tag, contentId);
}
#endif

@end

