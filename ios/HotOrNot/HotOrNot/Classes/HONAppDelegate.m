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

#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSData+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"

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
#import "UIImageDebugger.h"
#import "UIImageView+AFNetworking.h"

#import "HONAppDelegate.h"
#import "HONStoreTransactionObserver.h"
#import "HONTrivialUserVO.h"
#import "HONHomeViewController.h"
#import "HONActivityViewController.h"
#import "HONSettingsViewController.h"
#import "HONComposeTopicViewController.h"
#import "HONLoadingOverlayView.h"


NSString * const kBlowfishKey = @"KJkljP9898kljbm675865blkjghoiubdrsw3ye4jifgnRDVER8JND997";
NSString * const kBlowfishIV = @"„7ì”~ís";

#if __APPSTORE_BUILD__ == 1
NSString * const kKeenIOProjectID = @"54bb13196f31a230ad1cfef9";
NSString * const kKeenIOMasterKey = @"3DB8C226B5D919804F9A08D6413D4CE2";
NSString * const kKeenIOReadKey = @"683f55a5dff7cef2d6ac81dbf83d2c8ca51e8575f67d6f0d00011b160893026a4bd2641020530cd38472cea9decd9c372ee72b430758167e5875f2bfe35e8a406ae844d79a56c7f2852b71953623c4d52447be7f72478ae25605313828b59a39d9755456f8a932c91d6571f452228ef9";
NSString * const kKeenIOWriteKey = @"d398f1a3a660a1420b6bcd827370458d57249a373393b17ed022aabb8b5f7cf25ffaf34994285c6a0d9d776c4316ffc48cdf514fcc3d4c3e5166b4e2a30ba9b0b029dc536872ca36c50516ae38c396f42b1394244360226e173f6938dc541e6759915a45e5d32f1b72e9aaefbf1c49d2";
#else
NSString * const kKeenIOProjectID = @"54bb1391e0855733be551306";
NSString * const kKeenIOMasterKey = @"D805BE8BA8AF8F65F7C4825CA31C58E1";
NSString * const kKeenIOReadKey = @"984990cfc1ba74d560bc85d2fe78ebb4d3595d9d14169a041ac7a3c80d6710c4a43dbcc1b1556f4361e8097cfd11e62bbdcf43be2c612f296225c52d32e12762864d9c569aa277632c08ee6b82783118a9d5052c0dccdf8d364993e184b23a1367e5de9b742b848a9f4f9ded7e58b186";
NSString * const kKeenIOWriteKey = @"3765f6e50fdb595882038fb5c336dd31cbe55a2977ae03aa25d32fa0ef09b5ef9249a383dc54557c2eafbb539301094b347d97bafd67e948f33ff5df60aa438c02e1be7c06abdeafa468ca8e8cde4dafd54872f82fc21ac1e64d82f4522a86820e20f226253006b2aa713c9ac211ba83";
#endif


NSString * const kFacebookAppID = @"600550136636754";
NSString * const kHockeyAppToken = @"a2f42fed0f269018231f6922af0d8ad3";
NSString * const kTapStreamSecretKey = @"8Q6fJ5eKTbSOHxzGGrX8pA";
NSString * const kTapjoyAppID = @"13b84737-f359-4bf1-b6a0-079e515da029";
NSString * const kTapjoyAppSecretKey = @"llSjQBKKaGBsqsnJZlxE";
NSString * const kFlurryAPIKey = @"R84M6PFVNH2Z5Q8JW88C";

// view heights
const CGFloat kNavHeaderHeight = 64.0;
const CGFloat kSearchHeaderHeight = 43.0f;
const CGFloat kDetailsHeroImageHeight = 324.0;

// animation params
const CGFloat kProfileTime = 0.25f;
const CGFloat kButtonSelectDelay = 0.0625;

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

NSString * const kTwilioSMS = @"6475577873";


#if __APPSTORE_BUILD__ == 0
@interface HONAppDelegate() <BITHockeyManagerDelegate, PicoStickerDelegate, HONLoadingOverlayViewDelegate>
#else
@interface HONAppDelegate() <HONLoadingOverlayView>
#endif
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *noNetworkView;
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic) int challengeID;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic) int clubID;
@property (nonatomic) int userID;
@property (nonatomic) BOOL awsUploadCounter;
@property (nonatomic, copy) NSString *currentConversationID;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@end


@implementation HONAppDelegate
@synthesize window = _window;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize navController = _navController;



+ (NSString *)customerServiceURLForKey:(NSString *)key {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"support_urls"] objectForKey:key]);
}

+ (BOOL)switchEnabledForKey:(NSString *)key {
	return ([[[[[NSUserDefaults standardUserDefaults] objectForKey:@"switches"] objectForKey:key] uppercaseString] isEqualToString:@"YES"]);
}

+ (UIViewController *)appNavController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}

+ (UINavigationController *)rootNavController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController.navigationController);
}

+ (UIViewController *)topViewControllerWithRootViewController:(UIViewController *)rootViewController {
	
	// Handling UITabBarController
	if ([rootViewController isKindOfClass:[UITabBarController class]]) {
		UITabBarController* tabBarController = (UITabBarController*)rootViewController;
		return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
		
	} else if ([rootViewController isKindOfClass:[UINavigationController class]]) { // Handling UINavigationController
		UINavigationController* navigationController = (UINavigationController*)rootViewController;
		return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
		
	} else if (rootViewController.presentedViewController) { // Handling Modal views
		UIViewController* presentedViewController = rootViewController.presentedViewController;
		return [self topViewControllerWithRootViewController:presentedViewController];
		
	} else { // Handling UIViewController's added as subviews to some other views.
		for (UIView *view in [rootViewController.view subviews]) {
			id subViewController = [view nextResponder];    // Key property which most of us are unaware of / rarely use.
			if (subViewController && [subViewController isKindOfClass:[UIViewController class]])
				return [self topViewControllerWithRootViewController:subViewController];
		}
		
		return (rootViewController);
	}
}




#pragma mark - Data Calls
- (void)_retrieveConfigJSON {
	[[HONAPICaller sharedInstance] retreiveBootConfigWithCompletion:^(NSDictionary *result) {
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"appstore_id"] forKey:@"appstore_id"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"server_apis"] forKey:@"server_apis"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"support_urls"] forKey:@"support_urls"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"ts_name"] forKey:@"ts_name"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"default_imgs"] forKey:@"default_imgs"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invalid_chars"] forKey:@"invalid_chars"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"timeout_interval"] forKey:@"timeout_interval"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_templates"] forKey:@"share_templates"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_url"] forKey:@"share_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[[[result objectForKey:@"app_schemas"] objectForKey:@"kik"] objectForKey:@"ios"] forKey:@"kik_card"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"jpeg_compress"] forKey:@"jpeg_compress"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"join_radius"] forKey:@"join_radius"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"global_club"] forKey:@"global_club"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"staff_clubs"] forKey:@"staff_clubs"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"compose_topics"] forKey:@"compose_topics"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"switches"] forKey:@"switches"];
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
		NSLog(@"API BASE PATHS:\nPHP\t\t: [%@]\nPYTHON\t: [%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [[HONAPICaller sharedInstance] phpAPIBasePath], [[HONAPICaller sharedInstance] pythonAPIBasePath]);
		
		if ([[[result objectForKey:@"boot_alert"] objectForKey:@"enabled"] isEqualToString:@"Y"])
			[self _showOKAlert:[[result objectForKey:@"boot_alert"] objectForKey:@"title"] withMessage:[[result objectForKey:@"boot_alert"] objectForKey:@"message"]];
		
		[self _initThirdPartySDKs];
		[self _writeShareTemplates];
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
//											 withProperties:@{@"boots"	: @([[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBoot])}];
		}
	}];
}

- (void)_registerUser {
	[[HONAPICaller sharedInstance] registerNewUserWithCompletion:^(NSDictionary *result) {
		if ([result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
			[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
			
			NSDate *cohortDate = [[HONUserAssistant sharedInstance] activeUserSignupDate];
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - day"
											   withProperties:@{@"day"	: [NSDate utcNowDate]}];
			
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - cohort_date"
											   withProperties:@{@"cohort_date"	: [[[cohortDate formattedISO8601String] componentsSeparatedByString:@"T"] firstObject]}];
			
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - cohort_week"
											   withProperties:@{@"cohort_week"	: [NSString stringWithFormat:@"%04d-W%02d", [cohortDate year], [cohortDate weekOfYear]]}];
			
			[Flurry setUserID:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])];
			
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[HONLayerKitAssistant sharedInstance] connectClientToServiceWithCompletion:^(BOOL success, NSError *error) {
					NSLog(@"connectClientToServiceWithCompletion:success:[%@] error:[%@]", NSStringFromBOOL(success), error);
					
					[[HONLayerKitAssistant sharedInstance] authenticateUserWithUserID:[[HONUserAssistant sharedInstance] activeUserID] withCompletion:^(BOOL success, NSError *error) {
						NSLog(@"AUTH RESULT:%@ -=- %@", NSStringFromBOOL(success), error);
					}];
				}];
			});

			
			if ([[[HONUserAssistant sharedInstance] activeUserLoginDate] elapsedSecondsSinceDate:[[HONUserAssistant sharedInstance] activeUserSignupDate]] == 0)
				[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
			
			if (self.window.rootViewController == nil) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONHomeViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				
				self.window.rootViewController = navigationController;
				self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				
				self.navController = navigationController;
			}
		}
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
	self.window.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
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
	
	if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
		
		if (_noNetworkView != nil) {
			[_noNetworkView removeFromSuperview];
			_noNetworkView = nil;
		}
		
		if (![[HONAPICaller sharedInstance] canPingConfigServer]) {
			[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
				   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
		}
		
		[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeBoot];
		
		[self.window makeKeyAndVisible];
		[self _retrieveConfigJSON];
		
	} else {
		[self.window makeKeyAndVisible];
		
		NSLog(@"!¡!¡!¡!¡!¡ AIN'T NO NETWORK HERE ¡!¡!¡!¡!¡!");
		self.window.backgroundColor = [UIColor redColor];
		
		UIView *noNetworkView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 233.0, 320.0, 90.0)];
		[noNetworkView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNetworkBG"]]];
		[self.window addSubview:noNetworkView];
		
		UILabel *noNetworkLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 85.0, 220.0, 20.0)];
		noNetworkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16.0];
		noNetworkLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
		noNetworkLabel.backgroundColor = [UIColor clearColor];
		noNetworkLabel.textAlignment = NSTextAlignmentCenter;
		noNetworkLabel.text = NSLocalizedString(@"no_network", @"");
		[noNetworkView addSubview:noNetworkLabel];
	}
	
//	NSLog(@"NSUserDefaults:[%@]", [[NSUserDefaults standardUserDefaults] objectDictionary]);
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Launching"
//									 withProperties:@{@"boots"	: @([[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBoot])}];
	
	//[[SKPaymentQueue defaultQueue] addTransactionObserver:[[HONStoreTransactionObserver alloc] init]];
//	[self performSelector:@selector(_picoCandyTest) withObject:nil afterDelay:4.0];
	
#ifdef FONTS
	[self _showFonts];
#endif
	
	//[UIImageDebugger startDebugging];
	
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
//									 withProperties:@{@"total"		: @([[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeBackground]),
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
//													  @"total"		: @([[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBackground])}];
	
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"[:|:] [applicationDidBecomeActive] [:|:]");
	
//	[FBAppEvents activateApp];
	
	[KeenClient sharedClientWithProjectId:kKeenIOProjectID
							  andWriteKey:kKeenIOWriteKey
							   andReadKey:kKeenIOReadKey];
	[KeenClient disableGeoLocation];
//	[KeenClient enableLogging];
	
	[[UIApplication sharedApplication] cancelAllLocalNotifications];
	
	[[HONStateMitigator sharedInstance] resetTotalCounterForType:HONStateMitigatorTotalTypeTrackingCalls withValue:0];
	[[HONStateMitigator sharedInstance] updateAppEntryTimestamp:[NSDate date]];
	[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
	
	[Flurry logEvent:@"App_Active"];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	if (_isFromBackground) {
		[Flurry logEvent:@"resume"];
		
		if ([[HONDeviceIntrinsics sharedInstance] hasNetwork]) {
			self.window.userInteractionEnabled = YES;
			
			if (_noNetworkView != nil) {
				[_noNetworkView removeFromSuperview];
				_noNetworkView = nil;
			}
			
			if ([[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] objectForKey:CFBridgingRelease(kSecAttrAccount)] length] > 0) {
				
			}
			
			if (![[HONAPICaller sharedInstance] canPingConfigServer]) {
				[self _showOKAlert:NSLocalizedString(@"alert_connectionError_t", nil)
					   withMessage:NSLocalizedString(@"alert_connectionError_m", nil)];
				
			} else
				[[NSNotificationCenter defaultCenter] postNotificationName:@"CHECK_INVITES" object:nil];
//				NSLog(@"APP ACTIVE |||| GO GET BOOT & -> FIND USER |||||"); //				[self _retrieveConfigJSON];
		
		} else {
			NSLog(@"!¡!¡!¡!¡!¡ AIN'T NO NETWORK HERE ¡!¡!¡!¡!¡!");
			
			self.window.userInteractionEnabled = NO;
			
			_noNetworkView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 233.0, 320.0, 90.0)];
			[_noNetworkView addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"noNetworkBG"]]];
			[self.window addSubview:_noNetworkView];
			
			UILabel *noNetworkLabel = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 85.0, 220.0, 20.0)];
			noNetworkLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16.0];
			noNetworkLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
			noNetworkLabel.backgroundColor = [UIColor clearColor];
			noNetworkLabel.textAlignment = NSTextAlignmentCenter;
			noNetworkLabel.text = NSLocalizedString(@"no_network", @"");
			[_noNetworkView addSubview:noNetworkLabel];
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
	if ([protocol isEqualToString:@"dood"]) {
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"DEEPLINK - create"];
		
		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
		_loadingOverlayView.delegate = self;
		
		NSRange range = [[[url absoluteString] lowercaseString] rangeOfString:@"://"];
		NSArray *path = [[[[[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString] substringFromIndex:range.location + range.length] componentsSeparatedByString:@"/"];
		
		
		NSString *subjectName = [path lastObject];
		
		NSLog(@"PATH:[%@]", subjectName);
		
		NSError *error;
		NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[@"using"] options:0 error:&error]
													 encoding:NSUTF8StringEncoding];
		
		NSMutableDictionary *submitParams = [@{@"user_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
											   @"img_url"		: [NSString stringWithFormat:@"%@/%@", [HONAPICaller s3BucketForType:HONAmazonS3BucketTypeClubsSource], [[HONClubAssistant sharedInstance] defaultStatusUpdatePhotoURL]],
											   @"club_id"		: @([[HONClubAssistant sharedInstance] globalClub].clubID),
											   @"challenge_id"	: @(0),
											   @"topic_id"		: @(11),
											   @"topic_name"	: @"using",
											   @"subjects"		: jsonString} mutableCopy];
		NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", submitParams);
		
		LYRConversation *conversation = [[HONLayerKitAssistant sharedInstance] generateConversationWithParticipants:@[] withTopicName:[submitParams objectForKey:@"topic_name"] andSubject:subjectName];
		NSData *data = [[NSString stringWithFormat:@"- is %@ %@", [submitParams objectForKey:@"topic_name"], subjectName] dataUsingEncoding:NSUTF8StringEncoding];
		LYRMessage *message = [[HONLayerKitAssistant sharedInstance] generateMessageOfType:HONMessageTypeText withContent:data];
		
		if (![[HONLayerKitAssistant sharedInstance] sendMessage:message toConversation:conversation])
			NSLog(@"SEND FAILED!!");
		
		else {
			NSLog(@"CONVERSATION:\n%@", [conversation toString]);
			
//			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[submitParams setValue:conversation.identifier.absoluteString forKey:@"img_url"];
				[submitParams setValue:[NSString stringWithFormat:@"%@|%@", [submitParams objectForKey:@"topic_name"], subjectName] forKey:@"subject"];
				
				NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", submitParams);
				[[HONAPICaller sharedInstance] submitStatusUpdateWithDictionary:submitParams completion:^(NSDictionary *result) {
					if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
						if (_progressHUD == nil)
							_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
						_progressHUD.minShowTime = kProgressHUDMinDuration;
						_progressHUD.mode = MBProgressHUDModeCustomView;
						_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
						_progressHUD.labelText = @"Error!";
						[_progressHUD show:NO];
						[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
						_progressHUD = nil;
						
					} else {
						[_loadingOverlayView outro];
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
					}
				}];
//			});
		}
	}
	
//	NSString *protocol = [[[url absoluteString] lowercaseString] substringToIndex:[[url absoluteString] rangeOfString:@"://"].location];
//	if ([protocol isEqualToString:@"selfieclub"]) {
//		NSRange range = [[[url absoluteString] lowercaseString] rangeOfString:@"://"];
//		NSArray *path = [[[[[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString] substringFromIndex:range.location + range.length] componentsSeparatedByString:@"/"];
//		NSLog(@"PATH:[%@]", path);
//		
//		if ([path count] == 2) {
//			NSString *username = [[path firstObject] lowercaseString];
//			NSString *clubName = [[path lastObject] lowercaseString];
//			
//			[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeDeepLink];
//			
			// already a member
//			if ([[HONClubAssistant sharedInstance] isClubNameMatchedForUserClubs:clubName]) {
//				for (NSDictionary *dict in [[[HONClubAssistant sharedInstance] fetchUserClubs] objectForKey:@"owned"]) {
//					if ([[[dict objectForKey:@"owner"] objectForKey:@"id"] intValue] == [[HONUserAssistant sharedInstance] activeUserID]) {
//						NSLog(@"OWNER_ID:[%d]", [[[dict objectForKey:@"owner"] objectForKey:@"id"] intValue]);
//						_selectedClubVO = [HONUserClubVO clubWithDictionary:dict];
//						break;
//					}
//				}
//				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_member", @"You are already a member of"), _selectedClubVO.clubName]
//																	message:NSLocalizedString(@"alert_enterClub", @"Want to go there now?")
//																   delegate:self
//														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
//														  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
//				[alertView setTag:HONAppDelegateAlertTypeEnterClub];
//				[alertView show];
//				
//			} else { // search for this user
//				[[HONAPICaller sharedInstance] searchForUsersByUsername:username completion:^(NSArray *result) {
//					int userID = 0;
//					if ([result count] == 0) {
//						[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"hud_usernameNotFound", @"Username Not Found!")
//													message:@""
//												   delegate:nil
//										  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//										  otherButtonTitles:nil] show];
//						
//					} else { // user found
//						for (NSDictionary *user in result) {
//							if ([username isEqualToString:[[user objectForKey:@"username"] lowercaseString]]) {
//								userID = [[user objectForKey:@"id"] intValue];
//								break;
//							}
//						}
//						
//						NSLog(@"userID:[%d]", userID);
//						if (userID == 0) { // didn't find the user
//							[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"hud_usernameNotFound", @"Username Not Found!")
//														message:@""
//													   delegate:nil
//											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//											  otherButtonTitles:nil] show];
//							
//						} else { // found the user
//							[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:userID completion:^(NSDictionary *result) {
//								int clubID = 0;
//								for (NSDictionary *club in [result objectForKey:@"owned"]) {
//									if ([[[club objectForKey:@"name"] lowercaseString] isEqualToString:clubName	]) {
//										_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
//										clubID = [[club objectForKey:@"id"] intValue];
//										break;
//									}
//								}
//								
//								if (clubID > 0) { // user is the owner, prompt for join
//									[[HONAPICaller sharedInstance] retrieveClubByClubID:clubID withOwnerID:userID completion:^(NSDictionary *result) {
//										_selectedClubVO = [HONUserClubVO clubWithDictionary:result];
//										
//										UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
//																							message:[NSString stringWithFormat:NSLocalizedString(@"alert_join", @"Would you like to join the %@ Selfieclub?"), _selectedClubVO.clubName]
//																						   delegate:self
//																				  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//																				  otherButtonTitles:NSLocalizedString(@"alert_cancel", nil), nil];
//										[alertView setTag:HONAppDelegateAlertTypeJoinCLub];
//										[alertView show];
//									}];
//																	
//								} else { // user isn't the owner
//									_clubName = clubName;
//									UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"club_notfound", @"Club Not Found!")
//																						message: NSLocalizedString(@"alert_create_it", @"Would you like to create it?")
//																					   delegate:self
//																			  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
//																			  otherButtonTitles:NSLocalizedString(@"alert_no", nil), nil];
//									[alertView setTag:HONAppDelegateAlertTypeCreateClub];
//									[alertView show];
//								}
//							}]; // clubs for owner
//						} // found club owner
//					} // user found
//				}]; // username search
//			} // two fields
//		} // path split
//	}
	
	return (YES);
}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notification {
	[[UIApplication sharedApplication]cancelAllLocalNotifications];
	app.applicationIconBadgeNumber = notification.applicationIconBadgeNumber -1;
	
	notification.soundName = UILocalNotificationDefaultSoundName;
	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
	
	[self _showOKAlert:nil withMessage:notification.alertBody];
}


- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	NSString *pushToken = [[deviceToken description] substringFromIndex:1];
	pushToken = [pushToken substringToIndex:[pushToken length] - 1];
	pushToken = [pushToken stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"\t—//]> [%@ didRegisterForRemoteNotificationsWithDeviceToken] (%@)", self.class, pushToken);
	[[HONDeviceIntrinsics sharedInstance] writePushToken:pushToken];
	[[HONLayerKitAssistant sharedInstance] notifyClientWithPushToken:deviceToken];
	
	if (![[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"device_token"] isEqualToString:pushToken]) {
		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
			[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] areEnabled:YES completion:^(NSDictionary *result) {
				if (![result isEqual:[NSNull null]])
					[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
			}];
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
	[[HONLayerKitAssistant sharedInstance] notifyClientPushTokenNotAvailibleFromError:error];
	
	if (![[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"device_token"] isEqualToString:@""]) {
		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
			[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] areEnabled:NO completion:^(NSDictionary *result) {
				if (![result isEqual:[NSNull null]])
					[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
			}];
		}];
	}
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:@"didFailToRegisterForRemoteNotificationsWithError"
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
//	[[HONLayerKitAssistant sharedInstance] notifyClientRemotePushWasReceived:userInfo withCompletionHandler:completionHandler];
	
	NSLog(@"\t—//]> [%@ didReceiveRemoteNotification - BG] (%@)", self.class, userInfo);
	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
	
	// Increment badge count if a message
//	if ([[userInfo valueForKeyPath:@"aps.content-available"] integerValue] != 0) {
//		NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
//		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
//	}
	
//	[[[UIAlertView alloc] initWithTitle:nil
//							   message:[NSString stringWithFormat:@"%@\n%@\n%@", [[userInfo objectForKey:@"layer"] objectForKey:@"conversation_identifier"], [[userInfo objectForKey:@"layer"] objectForKey:@"event_url"], [[userInfo objectForKey:@"layer"] objectForKey:@"message_identifier"]]
//							  delegate:nil
//					 cancelButtonTitle:@"OK"
//					 otherButtonTitles:nil] show];
	
	[[HONLayerKitAssistant sharedInstance] notifyClientRemotePushWasReceived:userInfo withCompletionHandler:completionHandler];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"\t—//]> [%@ didReceiveRemoteNotification - FG] (%@)", self.class, userInfo);
	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
	
//	// Increment badge count if a message
//	if ([[userInfo valueForKeyPath:@"aps.content-available"] integerValue] != 0) {
//		NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
//		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
//	}
	
	
	
	[[HONLayerKitAssistant sharedInstance] notifyClientRemotePushWasReceived:userInfo withCompletionHandler:nil];
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
	NSDictionary *userDefaults = @{@"is_deactivated"	: NSStringFromBOOL(NO),
								   @"votes"				: @{},
								   @"layer"				: @{},
								   @"user_lookup"		: @{},
								   @"avatars"			: @{},
								   @"purchases"			: @[],
								   @"home_club"			: @{},
								   @"invites"			: @[],
								   @"location_club"		: @{},
								   @"coords"			: @{@"lat" : @(0.00), @"lon" : @(0.00)},
								   @"device_locale"		: @{},
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

	AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:[[HONAPICaller s3Credentials] objectForKey:@"key"]
																									 secretKey:[[HONAPICaller s3Credentials] objectForKey:@"secret"]];
	
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
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SHARE_SHELF" object:@{@"captions"			: @{@"instagram"	: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeInstagram], [[HONUserAssistant sharedInstance] activeUsername]],
																															@"twitter"		: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeTwitter], [[HONUserAssistant sharedInstance] activeUsername]],
																															@"sms"			: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeSMS], [[HONUserAssistant sharedInstance] activeUsername]],
																															@"email"		: @{@"subject"	: [[[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeEmail] componentsSeparatedByString:@"|"] firstObject],
																																				@"body"		: [NSString stringWithFormat:[[[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeEmail] componentsSeparatedByString:@"|"] firstObject], [[HONUserAssistant sharedInstance] activeUsername]]},
																															@"clipboard"	: [NSString stringWithFormat:[HONSocialCoordinator shareMessageForSocialPlatform:HONSocialPlatformShareTypeClipboard], [[HONUserAssistant sharedInstance] activeUsername]]},
																									@"image"			: [[HONUserAssistant sharedInstance] activeUserInfo],
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


#pragma mark - LoadingOverlayView Delegates
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView {
	
}

- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView {
	
}

#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (actionSheet.tag == 0) {
		//[[HONAnalyticsParams sharedInstance] trackEvent:[[_shareInfo objectForKey:@"mp_event"] stringByAppendingString:[@" - Share " stringByAppendingString:(buttonIndex == HONShareSheetActionTypeKik) ? @"Kik" : (buttonIndex == HONShareSheetActionTypeInstagram) ? @"Instagram" : (buttonIndex == HONShareSheetActionTypeTwitter) ? @"Twitter" : (buttonIndex == HONShareSheetActionTypeFacebook) ? @"Facebook" : (buttonIndex == HONShareSheetActionTypeSMS) ? @"SMS" : (buttonIndex == HONShareSheetActionTypeEmail) ? @"Email" : (buttonIndex == HONShareSheetActionTypeClipboard) ? @"Link" : @"Cancel"]]];
		
//		if (buttonIndex == HONShareSheetActionTypeKik) {
//			[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[HONAppDelegate kikCardURL]]];
//			
//
		if (buttonIndex == HONSocialPlatformShareActionSheetTypeInstagram) {
			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
			[[HONImageBroker sharedInstance] saveForInstagram:[_shareInfo objectForKey:@"image"]
									withUsername:[[HONUserAssistant sharedInstance] activeUsername]
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
		
		} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeTwitter) {
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
		
		} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeSMS) {
			if ([MFMessageComposeViewController canSendText]) {
				MFMessageComposeViewController *messageComposeViewController = [[MFMessageComposeViewController alloc] init];
				messageComposeViewController.body = [[_shareInfo objectForKey:@"captions"] objectForKey:@"sms"];
				messageComposeViewController.messageComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:messageComposeViewController animated:YES completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"SMS Error"
											message:@"Cannot send SMS from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeEmail) {
			if ([MFMailComposeViewController canSendMail]) {
				MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
				[mailComposeViewController setSubject:[[[_shareInfo objectForKey:@"captions"] objectForKey:@"email"] objectForKey:@"subject"]];
				[mailComposeViewController setMessageBody:[[[_shareInfo objectForKey:@"captions"] objectForKey:@"email"] objectForKey:@"body"] isHTML:NO];
				mailComposeViewController.mailComposeDelegate = self;
				
				[[_shareInfo objectForKey:@"view_controller"] presentViewController:mailComposeViewController
																		   animated:YES
																		 completion:^(void) {}];
				
			} else {
				[[[UIAlertView alloc] initWithTitle:@"Email Error"
											message:@"Cannot send email from this device!"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		
		} else if (buttonIndex == HONSocialPlatformShareActionSheetTypeClipboard) {
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = @"Get DOOD - A live photo feed of who is doing what around you. getdood.com";
			
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
		[[HONSocialCoordinator sharedInstance] writeTrivialUserToDeviceContacts:nil];
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

