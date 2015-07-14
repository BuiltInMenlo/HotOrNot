//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import <AddressBook/AddressBook.h>
#import <AdSupport/AdSupport.h>
#import <CommonCrypto/CommonHMAC.h>
#import <QuartzCore/QuartzCore.h>
#import <Social/SLComposeViewController.h>
#import <Social/SLServiceTypes.h>
#import <StoreKit/StoreKit.h>


#import <sys/utsname.h>
#import </usr/include/objc/objc-class.h>

#import <AWSiOSSDKv2/AWSCore.h>
#import <FBSDKMessengerShareKit/FBSDKMessengerShareKit.h>
#import <HockeySDK/HockeySDK.h>
#import "Hoko.h"
#import <KakaoOpenSDK/KakaoOpenSDK.h>
//#import <Tapjoy/Tapjoy.h>


#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSData+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"
#import "PubNub+BuiltInMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UIViewController+BuiltInMenlo.h"

#import "AFNetworking.h"
//#import "AWSCore.h"
#import "BlowfishAlgorithm.h"
#import "Flurry.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "GAIFields.h"
#import "KeenClient.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"
#import <Social/Social.h>
#import "TSTapstream.h"
#import "UIImageDebugger.h"
//#import "WXApi.h"


#import "HONAppDelegate.h"
#import "HONStoreTransactionObserver.h"
#import "HONUserVO.h"
#import "HONHomeViewController.h"
#import "HONActivityViewController.h"
#import "HONSettingsViewController.h"
#import "HONComposeTopicViewController.h"
#import "HONStatusUpdateViewController.h"
#import "HONLoadingOverlayView.h"


NSString * const kBlowfishKey = @"KJkljP9898kljbm675865blkjghoiubdrsw3ye4jifgnRDVER8JND997";
NSString * const kBlowfishIV = @"„7ì”~ís";

#if __APPSTORE_BUILD__ == 1
NSString * const kKeenIOProjectID = @"559fbb4f672e6c4e2cea1bab";//@"551054dfe085576f3fb24cfd";//@"54bb13196f31a230ad1cfef9";
NSString * const kKeenIOMasterKey = @"9AD6705D760DE306DEA59827D0CF1D62";//@"980A6532BC7AB5B6489BBA2458BBFBCF";//@"3DB8C226B5D919804F9A08D6413D4CE2";
NSString * const kKeenIOReadKey = @"a704d1b101e28221727b7b5e97bad1a5c7aa4deca37ad6ea0b03f676557a44b18e4e9918c52fc3019b6f63c73022d9f3fff37800b34e483513f1fffc5281551b6bcfef2f03309fa556f95f9fd0925ad43d1d52a70857a65d185d143a93f9867c7d8a9a3bcf311119438d1c26e838f59e";//@"0b7a1444ba73e7584da531247968ecde3b54733993fece6cb9827dca50248f8df1b3cfd888d39ab9dc326d3c25fabf023a30995b66fe34679d174e2fd56c2cc66039123ae17ad192c4024fc3169922b560616b355d9a7263fac1b37189ad628537a9fd2378ded658cbcf66128ce14dea";//@"683f55a5dff7cef2d6ac81dbf83d2c8ca51e8575f67d6f0d00011b160893026a4bd2641020530cd38472cea9decd9c372ee72b430758167e5875f2bfe35e8a406ae844d79a56c7f2852b71953623c4d52447be7f72478ae25605313828b59a39d9755456f8a932c91d6571f452228ef9";
NSString * const kKeenIOWriteKey = @"be8e83a45f01146d0bf9e569e73c9ebac017da3a37eaa6d01483bddf0ac93c43ff7c67b1a93cf22cca9b6a5d44f443c12b5654a9e3e47d53b970d11a1ddb0e3f44c405a07f13bc94fbdf8c7a3af3b861b04b5797a863b3686947ec9ee96768409703d2572fd903e761a8ff3768d5cb02";//@"42e6a5311c254b6030c0f2d9f035377e2be399b744c55e09a6c3cfb8c682917f1f02c6d237f3c1b7d160df58b09ce8648de7bbeff3dd189da67e496fbd25312fcea72f189bc21c1bdafe01db17aef22cfd606985acea4e43f184210e588f64fedfecbe041301ab7436e8982dec4e955f";//@"d398f1a3a660a1420b6bcd827370458d57249a373393b17ed022aabb8b5f7cf25ffaf34994285c6a0d9d776c4316ffc48cdf514fcc3d4c3e5166b4e2a30ba9b0b029dc536872ca36c50516ae38c396f42b1394244360226e173f6938dc541e6759915a45e5d32f1b72e9aaefbf1c49d2";
#else
NSString * const kKeenIOProjectID = @"54bb1391e0855733be551306";
NSString * const kKeenIOMasterKey = @"D805BE8BA8AF8F65F7C4825CA31C58E1";
NSString * const kKeenIOReadKey = @"984990cfc1ba74d560bc85d2fe78ebb4d3595d9d14169a041ac7a3c80d6710c4a43dbcc1b1556f4361e8097cfd11e62bbdcf43be2c612f296225c52d32e12762864d9c569aa277632c08ee6b82783118a9d5052c0dccdf8d364993e184b23a1367e5de9b742b848a9f4f9ded7e58b186";
NSString * const kKeenIOWriteKey = @"3765f6e50fdb595882038fb5c336dd31cbe55a2977ae03aa25d32fa0ef09b5ef9249a383dc54557c2eafbb539301094b347d97bafd67e948f33ff5df60aa438c02e1be7c06abdeafa468ca8e8cde4dafd54872f82fc21ac1e64d82f4522a86820e20f226253006b2aa713c9ac211ba83";
#endif

NSString * const kFacebookAppID = @"600550136636754";
NSString * const kHockeyAppToken = @"a2f42fed0f269018231f6922af0d8ad3";
NSString * const kTapStreamSecretKey = @"Y0Xvvy5xTjuJFydsMeAmRA";//@"WTmu7AxOTDmzwzo1xu-ESw"; //@"8Q6fJ5eKTbSOHxzGGrX8pA";
//NSString * const kTapStreamSecretKey = @"WTmu7AxOTDmzwzo1xu-ESw"; //@"8Q6fJ5eKTbSOHxzGGrX8pA";
NSString * const kTapjoyAppID = @"13b84737-f359-4bf1-b6a0-079e515da029";
NSString * const kTapjoyAppSecretKey = @"llSjQBKKaGBsqsnJZlxE";
NSString * const kFlurryAPIKey = @"MK2QRHS5GHHMG7NC8F52";//@"QT9CV529T9WRJ9P9MP26";

// view heights
const CGFloat kNavHeaderHeight = 64.0;
const CGFloat kSearchHeaderHeight = 43.0f;
const CGFloat kDetailsHeroImageHeight = 324.0;

// animation params
const CGFloat kProfileTime = 0.25f;
const CGFloat kButtonSelectDelay = 0.0625;

NSString * const kTwilioSMS = @"6475577873";


#if __APPSTORE_BUILD__ == 0
@interface HONAppDelegate() <BITHockeyManagerDelegate, FBSDKMessengerURLHandlerDelegate, HONLoadingOverlayViewDelegate, PNDelegate>
#else
@interface HONAppDelegate() <FBSDKMessengerURLHandlerDelegate, HONLoadingOverlayViewDelegate, PNDelegate>
#endif
@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *noNetworkView;
@property (nonatomic, strong) NSDictionary *shareInfo;
@property (nonatomic, strong) UIImageView *taskImageView;
@property (nonatomic) BOOL isFromBackground;
@property (nonatomic) int challengeID;
@property (nonatomic, strong) HONUserClubVO *selectedClubVO;
@property (nonatomic, strong) NSString *clubName;
@property (nonatomic) int clubID;
@property (nonatomic) int userID;
@property (nonatomic) BOOL awsUploadCounter;
@property (nonatomic, copy) NSString *currentConversationID;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) FBSDKMessengerURLHandler *messageURLHandler;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) NSTimer *tintTimer;

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
	NSString *filePath = [[NSBundle mainBundle] pathForResource:@"boot_sc0011" ofType:@"json"];
	NSData *data = [NSData dataWithContentsOfFile:filePath];
	NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
	
//	[[HONAPICaller sharedInstance] retreiveBootConfigWithCompletion:^(NSDictionary *result) {
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"appstore_id"] forKey:@"appstore_id"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"server_apis"] forKey:@"server_apis"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"support_urls"] forKey:@"support_urls"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"ts_name"] forKey:@"ts_name"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"default_imgs"] forKey:@"default_imgs"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invalid_chars"] forKey:@"invalid_chars"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"timeout_interval"] forKey:@"timeout_interval"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"occupancy_timeout"] forKey:@"occupancy_timeout"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"expire_interval"] forKey:@"expire_interval"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_templates"] forKey:@"share_templates"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"share_url"] forKey:@"share_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[[[result objectForKey:@"app_schemas"] objectForKey:@"kik"] objectForKey:@"ios"] forKey:@"kik_card"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"jpeg_compress"] forKey:@"jpeg_compress"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"join_radius"] forKey:@"join_radius"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"global_club"] forKey:@"global_club"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"staff_clubs"] forKey:@"staff_clubs"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"compose_topics"] forKey:@"compose_topics"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"switches"] forKey:@"switches"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"alert_formats"] forKey:@"alert_formats"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"invite_formats"] forKey:@"invite_formats"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"cross_post"] forKey:@"cross_post"];
		[[NSUserDefaults standardUserDefaults] setObject:[result objectForKey:@"channels"] forKey:@"channels"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[[result objectForKey:@"share_formats"] objectForKey:@"sheet_title"] forKey:@"share_title"];
		[[NSUserDefaults standardUserDefaults] setObject:@{@"default"	: [[result objectForKey:@"share_formats"] objectForKey:@"default"],
														   @"clipboard"	: [[result objectForKey:@"share_formats"] objectForKey:@"clipboard"],
														   @"instagram"	: [[result objectForKey:@"share_formats"] objectForKey:@"instagram"],
														   @"twitter"	: [[result objectForKey:@"share_formats"] objectForKey:@"twitter"],
														   @"facebook"	: [[result objectForKey:@"share_formats"] objectForKey:@"facebook"],
														   @"sms"		: [[result objectForKey:@"share_formats"] objectForKey:@"sms"],
														   @"email"		: [[result objectForKey:@"share_formats"] objectForKey:@"email"]} forKey:@"share_formats"];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
		[[[NSUserDefaults standardUserDefaults] objectForKey:@"alert_formats"] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
			NSDictionary *dict = (NSDictionary *)obj;
			
			NSString *token = @"";
			NSString *replacement = @"";
			
			NSLog(@"alert_format:[%@]", dict);
			
			if ([(NSString *)key isEqualToString:@"participant_push"]) {
				
				int secs = [[[NSUserDefaults standardUserDefaults] objectForKey:@"occupancy_timeout"] intValue];
				int mins = [NSDate elapsedMinutesFromSeconds:secs];
				int hours = [NSDate elapsedHoursFromSeconds:secs];
				
				NSLog(@"timeout:[%02d:%02d:%02d]", hours, mins, secs);
				
				token = @"__{OCCUPANCY_TIMEOUT}__";
				replacement = (hours > 0) ? [NSString stringWithFormat:@"%d hour%@", hours, (hours == 1) ? @"" : @"s"] : (mins > 0) ? [NSString stringWithFormat:@"%d minute%@", mins, (mins == 1) ? @"" : @"s"] : [NSString stringWithFormat:@"%d second%@", secs, (secs == 1) ? @"" : @"s"];
			}
			
			NSLog(@"TOKEN:[%@] REPLACE:[%@]", token, replacement);
			NSLog(@"TITLE:[%@] MSG:[%@]", [[dict objectForKey:@"title"] stringByReplacingOccurrencesOfString:token withString:replacement], [[dict objectForKey:@"msg"] stringByReplacingOccurrencesOfString:token withString:replacement]);
			
			if ([token length] > 0) {
				NSMutableDictionary *alertsDict = [[[NSUserDefaults standardUserDefaults] objectForKey:@"alert_formats"] mutableCopy];
				[alertsDict replaceObject:@{@"title"	: [[dict objectForKey:@"title"] stringByReplacingOccurrencesOfString:token withString:replacement],
											@"msg"	: [[dict objectForKey:@"msg"] stringByReplacingOccurrencesOfString:token withString:replacement]} forKey:(NSString *)key];
				
				[[NSUserDefaults standardUserDefaults] replaceObject:[alertsDict copy] forKey:@"alertDict"];
			}
			
			NSLog(@"alert_format:[%@]", [[[NSUserDefaults standardUserDefaults] objectForKey:@"alert_formats"] objectForKey:@"alert_format"]);
//		}];

		
		
		NSLog(@"API BASE PATHS:\nPHP\t\t: [%@]\nPYTHON\t: [%@]\n[=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=]", [[HONAPICaller sharedInstance] phpAPIBasePath], [[HONAPICaller sharedInstance] pythonAPIBasePath]);
		NSLog(@"DEVICE IP:[%@]", [[HONDeviceIntrinsics sharedInstance] lanIPAddress]);
		
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
//	[[HONAPICaller sharedInstance] registerNewUserWithCompletion:^(NSDictionary *result) {
//		if ([result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
//			[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
	
			//NSDate *cohortDate = [[HONUserAssistant sharedInstance] activeUserSignupDate];
			
			
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - day"
//											   withProperties:@{@"day"	: [NSDate utcNowDate]}];
//			
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - cohort_date"
//											   withProperties:@{@"cohort_date"	: [[[cohortDate formattedISO8601String] componentsSeparatedByString:@"T"] firstObject]}];
//			
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"ENGAGEMENT - cohort_week"
//											   withProperties:@{@"cohort_week"	: [NSString stringWithFormat:@"%04d-W%02d", [cohortDate year], [cohortDate weekOfYear]]}];
	
			//[Flurry setUserID:NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID])];
			
			[[HONPubNubOverseer sharedInstance] activateService];
			
			if ([[[HONUserAssistant sharedInstance] activeUserLoginDate] elapsedSecondsSinceDate:[[HONUserAssistant sharedInstance] activeUserSignupDate]] == 0)
				[[[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil] setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)];
			
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - activated"];
			
			if (self.window.rootViewController == nil) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONHomeViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				
				self.window.rootViewController = navigationController;
				self.window.rootViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
				
				self.navController = navigationController;
			}
//		}
//	}];
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

- (void)_changeLoadTint {
//	NSArray *colors = @[[UIColor colorWithRed:0.396 green:0.596 blue:0.922 alpha:1.00],
//						[UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00],
//						[UIColor colorWithRed:0.400 green:0.839 blue:0.698 alpha:1.00],
//						[UIColor colorWithRed:0.337 green:0.239 blue:0.510 alpha:1.00]];
//	
//	UIColor *color = [colors randomElement];
//	[UIView animateWithDuration:0.125 animations:^(void) {
//		[[HONViewDispensor sharedInstance] tintView:_loadingView withColor:color];
//	} completion:nil];
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
	
#if __FORCE_NEW_USER__ == 1 || __FORCE_REGISTER__ == 1
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
#endif
	
#if __FORCE_NEW_USER__ == 1
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)]; // 1st run
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecValueData)]; // device id
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrService)]; // phone #
	[[HONStateMitigator sharedInstance] resetAllTotalCounters];
#endif
	
#if __FORCE_REGISTER__ == 1
	[keychain setObject:@"" forKey:CFBridgingRelease(kSecAttrAccount)]; // 1st run
#endif
	
	id<GAITracker> tracker = [[GAI sharedInstance] trackerWithName:@"tracker"
														trackingId:@"UA-65006670-1"];

	GAIDictionaryBuilder *builder = [GAIDictionaryBuilder createScreenView];
	[builder set:@"start" forKey:kGAISessionControl];
	[tracker set:kGAIScreenName value:@"Launch"];
	[tracker send:[builder build]];
	
//	[tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Barren Fields"
//														  action:@"Rescue"
//														   label:@"Dragon"
//														   value:@1] build]];
	
	[Flurry setCrashReportingEnabled:YES];
	[Flurry setShowErrorInLogEnabled:YES];
	[Flurry setLogLevel:FlurryLogLevelCriticalOnly];
	[Flurry startSession:kFlurryAPIKey];
	//[Flurry logEvent:@"launch"];
	
	//[Hoko setupWithToken:@"501ae96a404f6bfbc6c3929846041a6915564f87"];
	
	NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
	
//	HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"products/:product_id"
//										   routeParameters:@{@"product_id": @(self.product.identifier)}
//										   queryParameters:@{@"referrer": self.user.name}
//												  metadata:@{@"coupon": @"20"}];
//	[deeplink addURL:@"http://awesomeapp.com/the_perfect_product" forPlatform:HOKDeeplinkPlatformWeb];
//	[deeplink addURL:@"http://awesomeapp.com/no_android_app_yet" forPlatform:HOKDeeplinkPlatformAndroid];
//	
//	[[Hoko deeplinking] generateSmartlinkForDeeplink:deeplink success:^(NSString *smartlink) {
//  [[Social sharedInstance] shareProduct:self.product link:smartlink];
//	} failure:^(NSError *error) {
//  // Share web link instead
//  [[Social sharedInstance] shareProduct:self.product link:self.product.webLink];
//	}];
	
	
	
	
	[[HONStateMitigator sharedInstance] updateAppEntryTimestamp:[NSDate date]];
	[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	[[HONStateMitigator sharedInstance] updateLastTrackingCallTimestamp:[NSDate date]];
	
//	NSLog(@"PAD:%@", [NSString stringWithFormat:@"%0*d", 8, [@"1F604" length]]);
	
	[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeBoot];
	[[HONStateMitigator sharedInstance] updateCurrentViewState:HONStateMitigatorViewStateTypeNotAvailable];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"clubs"] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"clubs"];
	
	
	_messageURLHandler = [[FBSDKMessengerURLHandler alloc] init];
	_messageURLHandler.delegate = self;
	
	
//	NSString *src = @"1426799062_2a85921f3cbf4f8f9e99d37842c09818";
//	NSString *match = @"^\\d{10,}_[a-f0-9]{32}$";
//	NSLog(@"RegEx TEST --- (%@) CONTAINS (%@) ::::: [%@]", src, match, NSStringFromBOOL([[[NSRegularExpression alloc] initWithPattern:match] isMatch:src]));
	
	
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
	
	
	_taskImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appTaskBG"]];
	
	
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//self.window.backgroundColor = [UIColor colorWithRed:0.937 green:0.937 blue:0.957 alpha:1.000];
	[self.window addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"appBG"]]];
	_isFromBackground = NO;
	
	

	
	
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
	
	
//	[[Hoko deeplinking] mapDefaultRouteToTarget:^(HOKDeeplink *deeplink) {
//		NSLog(@"HOKO ROUTE:[%@]", deeplink);
//	}];
//	
//	
//	
//	HOKDeeplink *deeplink = [HOKDeeplink deeplinkWithRoute:@"4c07fbc6-35a5-4d5c-87b1-1ccd5146893f_1436743103"
//										   routeParameters:@{@"channel_name": @"4c07fbc6-35a5-4d5c-87b1-1ccd5146893f_1436743103"}
//										   queryParameters:@{@"referrer": @"derp"}
//												  metadata:@{@"coupon": @"20"}];
//	[deeplink addURL:@"http://popup.rocks/router.php?channel=4c07fbc6-35a5-4d5c-87b1-1ccd5146893f_1436743103" forPlatform:HOKDeeplinkPlatformWeb];
//	[deeplink addURL:@"http://popup.rocks/router.php?channel=4c07fbc6-35a5-4d5c-87b1-1ccd5146893f_1436743103" forPlatform:HOKDeeplinkPlatformAndroid];
//	
//	[[Hoko deeplinking] generateSmartlinkForDeeplink:deeplink success:^(NSString *smartlink) {
//		NSLog(@"HOKO:[%@]", smartlink);
//	} failure:^(NSError *error) {
//		NSLog(@"HOKO ERROR:[%@]", error);
//	}];
	
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0512Actives - boot"
									   withProperties:@{@"day"	: [NSDate utcNowDate]}];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	NSLog(@"KC VAL:[%d]", ([[keychain objectForKey:CFBridgingRelease(kSecAttrService)] intValue] == 0));
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrService)] intValue] == 0) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - install"];
		[keychain setObject:@([NSDate elapsedUTCSecondsSinceUnixEpoch]) forKey:CFBridgingRelease(kSecAttrService)];
		NSLog(@"KEYCHAIN:[%@]", [keychain objectForKey:CFBridgingRelease(kSecAttrService)]);
	}
	
	return (YES);
}

- (void)_goLogin {
	[[KOSession sharedSession] close];
	
	[[KOSession sharedSession] openWithCompletionHandler:^(NSError *error) {
		
		if ([[KOSession sharedSession] isOpen]) {
			// login success.
			NSLog(@"login success.");
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"에러"
																message:error.localizedDescription
															   delegate:nil
													  cancelButtonTitle:@"확인"
													  otherButtonTitles:nil];
			[alertView show];
		}
		
	}];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	NSLog(@"[:|:] [applicationWillResignActive] [:|:]");
	
//	_taskImageView.alpha = 0.0;
//	[self.window addSubview:_taskImageView];
//	[UIView animateWithDuration:0.333 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
//		_taskImageView.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];	
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"[:|:] [applicationDidEnterBackground] [:|:]");
	
//	if ([MPMusicPlayerController applicationMusicPlayer].volume == 0.0)
//		[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	
//	[HONAppDelegate incTotalForCounter:@"background"];
	[[HONStateMitigator sharedInstance] incrementTotalCounterForType:HONStateMitigatorTotalTypeBackground];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_ENTERING_BACKGROUND" object:nil];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0512Actives - background"];
	
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
	
//	if ([passedRegistration length] == 0 && [[NSUserDefaults standardUserDefaults] objectForKey:@"local_reg"] == nil) {
//		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Backgrounding First Run"];
//		
//		UILocalNotification *localNotification = [[UILocalNotification alloc] init];
//		localNotification.fireDate = [[NSDate date] dateByAddingTimeInterval:180];
//		localNotification.timeZone = [NSTimeZone systemTimeZone];
//		localNotification.alertAction = @"View";
//		localNotification.alertBody = NSLocalizedString(@"alert_register_m", nil);
//		localNotification.soundName = @"selfie_notification.caf";
//		localNotification.userInfo = @{};
//		
//		[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
//		
//		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"local_reg"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//	}
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"[:|:] [applicationWillEnterForeground] [:|:]");
	
	[[HONStateMitigator sharedInstance] updateAppEntryPoint:HONStateMitigatorAppEntryTypeSpringboard];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"APP_LEAVING_BACKGROUND" object:nil];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Leaving Background"
//									 withProperties:@{@"duration"	: @([NSDate elapsedSecondsSinceDate:[[HONStateMitigator sharedInstance] appExitTimestamp]]),
//													  @"total"		: @([[HONStateMitigator sharedInstance] totalCounterForType:HONStateMitigatorTotalTypeBackground])}];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0512Actives - resume"
									   withProperties:@{@"day"	: [NSDate utcNowDate]}];
	
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	NSLog(@"[:|:] [applicationDidBecomeActive] [:|:]");
	
	if (_taskImageView != nil) {
		[UIView animateWithDuration:0.125 delay:0.00 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
			_taskImageView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_taskImageView removeFromSuperview];
		}];
	}
	
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
	
	//[Flurry logEvent:@"App_Active"];
	[[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	NSLog(@"KEYCHAIN:[%@]", [keychain objectForKey:CFBridgingRelease(kSecAttrService)]);
	
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrService)] intValue] != 0) {
		[[UIApplication sharedApplication] cancelAllLocalNotifications];
		
		NSDate *installDate = [NSDate dateFromUnixTimestamp:[[keychain objectForKey:CFBridgingRelease(kSecAttrService)] floatValue]];
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		
		if ([installDate elapsedDaysSincenDate:[NSDate utcNowDate]] < 7) {
			//if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"day7_push"] isEqualToString:@"YES"]) {
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@""];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				NSDateComponents *components = [[NSDateComponents alloc] init];
				components.day = 7;
				NSDate *targetDate = [calendar dateByAddingComponents:components toDate:installDate options:0];
				
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				localNotification.fireDate = targetDate;
				localNotification.timeZone = [NSTimeZone systemTimeZone];
				localNotification.alertAction = @"View";
				localNotification.alertBody = @"Someone has joined your Popup";
				localNotification.soundName = @"selfie_notification.caf";
				localNotification.userInfo = @{};
				
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			//}
		}
		
		
		if ([installDate elapsedDaysSincenDate:[NSDate utcNowDate]] < 14) {
			//if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"day30_push"] isEqualToString:@"YES"]) {
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@""];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				NSDateComponents *components = [[NSDateComponents alloc] init];
				components.day = 14;
				NSDate *targetDate = [calendar dateByAddingComponents:components toDate:installDate options:0];
				
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				localNotification.fireDate = targetDate;
				localNotification.timeZone = [NSTimeZone systemTimeZone];
				localNotification.alertAction = @"View";
				localNotification.alertBody = @"Someone has joined your Popup";
				localNotification.soundName = @"selfie_notification.caf";
				localNotification.userInfo = @{};
				
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			//}
			
		}
		
		if ([installDate elapsedDaysSincenDate:[NSDate utcNowDate]] < 30) {
			//if (![[[NSUserDefaults standardUserDefaults] objectForKey:@"day14_push"] isEqualToString:@"YES"]) {
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@""];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				NSDateComponents *components = [[NSDateComponents alloc] init];
				components.day = 14;
				NSDate *targetDate = [calendar dateByAddingComponents:components toDate:installDate options:0];
				
				UILocalNotification *localNotification = [[UILocalNotification alloc] init];
				localNotification.fireDate = targetDate;
				localNotification.timeZone = [NSTimeZone systemTimeZone];
				localNotification.alertAction = @"View";
				localNotification.alertBody = @"Someone has joined your Popup";
				localNotification.soundName = @"selfie_notification.caf";
				localNotification.userInfo = @{};
				
				[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
			//}
		}
	}
	
	
	if (_isFromBackground) {
		//[Flurry logEvent:@"resume"];
		
		
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
			NSLog(@"REMOTE PUSHES ENABLED:[%d]", [[UIApplication sharedApplication] isRegisteredForRemoteNotifications]);
			
			
			if (![[UIApplication sharedApplication] isRegisteredForRemoteNotifications]) {
				[[[UIAlertView alloc] initWithTitle:@"Push Notifications are Disabled!"
											message:@"You'll only receive messages when Popup is open. Re-enable push notifications in Settings -> Notification Center -> Popup"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
			
		} else {
			NSLog(@"REMOTE PUSHES:[%d]", [[UIApplication sharedApplication] enabledRemoteNotificationTypes]);
			if ([[UIApplication sharedApplication] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone) {
				[[[UIAlertView alloc] initWithTitle:@"Push Notifications are Disabled!"
											message:@"You'll only receive messages when Popup is open. Re-enable push notifications in Settings -> Notification Center -> Popup"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
			}
		}
		
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
				
			} else {
//					[self _retrieveConfigJSON];
			}
			
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
	
//	if ([MPMusicPlayerController applicationMusicPlayer].volume == 0.0)
//		[[MPMusicPlayerController applicationMusicPlayer] setVolume:0.5];
	
	[[HONStateMitigator sharedInstance] updateAppExitTimestamp:[NSDate date]];
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"App - Terminating"
//									 withProperties:@{@"duration"	: @([NSDate elapsedSecondsSinceDate:[[HONStateMitigator sharedInstance] appEntryTimestamp]])}];
	
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	NSLog(@"application:openURL:[%@]", [url absoluteString]);
	
	if (!url)
		return (NO);
	
	NSString *protocol = [[[url absoluteString] lowercaseString] substringToIndex:[[url absoluteString] rangeOfString:@"://"].location];
	
	if ([protocol isEqualToString:@"fb600550136636754"]) {
		if ([_messageURLHandler canOpenURL:url sourceApplication:sourceApplication])
			[_messageURLHandler openURL:url sourceApplication:sourceApplication];
			
	} else if ([protocol isEqualToString:@"popuprocks"]) {
		
		NSRange range = [[[url absoluteString] lowercaseString] rangeOfString:@"://"];
		NSArray *path = [[[[[url absoluteString] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] lowercaseString] substringFromIndex:range.location + range.length] componentsSeparatedByString:@"/"];
		
		NSLog(@"isNumeric:[%@][%@] -=- %@/%@", [path firstObject], [path lastObject], NSStringFromBOOL([[path firstObject] isNumeric]), NSStringFromBOOL([[path lastObject] isNumeric]));
		NSLog(@"currentViewController:[%@]", [UIViewController currentViewController].class);
		
		
		NSString *channelName = ([[path lastObject] length] > 0) ? [path lastObject] : @"";
		
		if ([channelName length] > 0 && ![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
			_loadingView = [[UIView alloc] initWithFrame:self.window.frame];
			_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
			[self.window addSubview:_loadingView];
			
			UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
			activityIndicatorView.center = CGPointMake(_loadingView.bounds.size.width * 0.5, (_loadingView.bounds.size.height + 20.0) * 0.5);
			[activityIndicatorView startAnimating];
			[_loadingView addSubview:activityIndicatorView];
			
			[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithChannelName:channelName] animated:YES];
			
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
				[_tintTimer invalidate];
				_tintTimer = nil;
				[_loadingView removeFromSuperview];
				
				[_loadingOverlayView outro];
			});
		}
		
		
		
		
//		if ([[path firstObject] isEqualToString:@"username"]) {
//			NSMutableDictionary *userInfo = [[[HONUserAssistant sharedInstance] activeUserInfo] mutableCopy];
//			[userInfo replaceObject:[path lastObject] forKey:@"username"];
//			[[HONUserAssistant sharedInstance] writeActiveUserInfo:[userInfo copy]];
//			
//			[[HONAPICaller sharedInstance] updateUsernameForUser:[path lastObject] completion:^(NSDictionary *result) {
//				if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
//					[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//			}];
//		}
//		
//		if (![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
//			[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - fromDeep"];
//			if ([[path firstObject] isNumeric]) {
//				[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:[[path firstObject] intValue] completion:^(NSDictionary *result) {
//					if (![[result objectForKey:@"detail"] isEqualToString:@"Not found"]) {
//						
//						if (![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
//							_loadingView = [[UIView alloc] initWithFrame:self.window.frame];
//							_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
//							[self.window addSubview:_loadingView];
//							
//							UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.window.frame];
//							animationImageView.animationImages = @[[UIImage imageNamed:@"loading_01"],
//																   [UIImage imageNamed:@"loading_02"],
//																   [UIImage imageNamed:@"loading_03"],
//																   [UIImage imageNamed:@"loading_04"],
//																   [UIImage imageNamed:@"loading_05"],
//																   [UIImage imageNamed:@"loading_06"],
//																   [UIImage imageNamed:@"loading_07"],
//																   [UIImage imageNamed:@"loading_08"]];
//							animationImageView.animationDuration = 0.75;
//							animationImageView.animationRepeatCount = 0;
//							[animationImageView startAnimating];
//							[_loadingView addSubview:animationImageView];
//							
//							_tintTimer = [NSTimer scheduledTimerWithTimeInterval:0.333
//																		  target:self
//																		selector:@selector(_changeLoadTint)
//																		userInfo:nil repeats:YES];
//
//							HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:result];
//							[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:vo forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:YES];
//							
//							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//								[_tintTimer invalidate];
//								_tintTimer = nil;
//								[_loadingView removeFromSuperview];
//								
//								[_loadingOverlayView outro];
//							});
//						}
//					
//					} else {
//						[_tintTimer invalidate];
//						_tintTimer = nil;
//						[_loadingView removeFromSuperview];
//						
//						[_loadingOverlayView outro];
//
//						
//						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chat Link not found!"
//																			message:@"Would you like to start a new chat?"
//																		   delegate:self
//																  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
//																  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
//						[alertView setTag:HONAppDelegateAlertTypeCreateChat];
//						[alertView show];
//					}
//				}];
//				
//			} else if ([[path lastObject] isNumeric]) {
//				[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:[[path lastObject] intValue] completion:^(NSDictionary *result) {
//					if (![[result objectForKey:@"detail"] isEqualToString:@"Not found"]) {
//						if (![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
//							
//							_loadingView = [[UIView alloc] initWithFrame:self.window.frame];
//							_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
//							[self.window addSubview:_loadingView];
//							
//							UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.window.frame];
//							animationImageView.animationImages = @[[UIImage imageNamed:@"loading_01"],
//																   [UIImage imageNamed:@"loading_02"],
//																   [UIImage imageNamed:@"loading_03"],
//																   [UIImage imageNamed:@"loading_04"],
//																   [UIImage imageNamed:@"loading_05"],
//																   [UIImage imageNamed:@"loading_06"],
//																   [UIImage imageNamed:@"loading_07"],
//																   [UIImage imageNamed:@"loading_08"]];
//							animationImageView.animationDuration = 0.75;
//							animationImageView.animationRepeatCount = 0;
//							[animationImageView startAnimating];
//							[_loadingView addSubview:animationImageView];
//							
//							_tintTimer = [NSTimer scheduledTimerWithTimeInterval:0.333
//																		  target:self
//																		selector:@selector(_changeLoadTint)
//																		userInfo:nil repeats:YES];
//							
//							HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:result];
//							[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:vo forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:YES];
//							
//							dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
//								[_tintTimer invalidate];
//								_tintTimer = nil;
//								[_loadingView removeFromSuperview];
//								
//								[_loadingOverlayView outro];
//							});
//						}
//					
//					} else {
//						[_tintTimer invalidate];
//						_tintTimer = nil;
//						[_loadingView removeFromSuperview];
//						
//						[_loadingOverlayView outro];
//
//						UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chat Link not found!"
//																			message:@"Would you like to start a new chat?"
//																		   delegate:self
//																  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
//																  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
//						[alertView setTag:HONAppDelegateAlertTypeCreateChat];
//						[alertView show];
//					}
//				}];
//				
//			} else {
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chat Link not found!"
//																	message:@"Would you like to start a new chat?"
//																   delegate:self
//														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
//														  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
//				[alertView setTag:HONAppDelegateAlertTypeCreateChat];
//				[alertView show];
//			}
//		}
	}
	
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
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - acceptPush"];
	
	NSLog(@"\t—//]> [%@ didRegisterForRemoteNotificationsWithDeviceToken] (%@)", self.class, pushToken);
	[[HONDeviceIntrinsics sharedInstance] writePushToken:pushToken];
	[[HONDeviceIntrinsics sharedInstance] writeDataPushToken:deviceToken];
	
//	if (![[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"device_token"] isEqualToString:pushToken]) {
//		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
//			[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] areEnabled:YES completion:^(NSDictionary *result) {
//				if (![result isEqual:[NSNull null]])
//					[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//			}];
//		}];
//	}
	
//	[[[UIAlertView alloc] initWithTitle:@"Remote Notification"
//								message:[[HONDeviceIntrinsics sharedInstance] pushToken]
//							   delegate:nil
//					  cancelButtonTitle:@"OK"
//					  otherButtonTitles:nil] show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
	NSLog(@"\t—//]> [%@ didFailToRegisterForRemoteNotificationsWithError] (%@)", self.class, error);
	
	[[HONDeviceIntrinsics sharedInstance] writePushToken:@""];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"0527Cohort - deniedPush"];
	
//	if (![[[[HONUserAssistant sharedInstance] activeUserInfo] objectForKey:@"device_token"] isEqualToString:@""]) {
//		[[HONAPICaller sharedInstance] updateDeviceTokenWithCompletion:^(NSDictionary *result) {
//			[[HONAPICaller sharedInstance] togglePushNotificationsForUserByUserID:[[HONUserAssistant sharedInstance] activeUserID] areEnabled:NO completion:^(NSDictionary *result) {
//				if (![result isEqual:[NSNull null]])
//					[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
//			}];
//		}];
//	}
	
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
	
	
	NSString *channelName = ([[userInfo objectForKey:@"aps"] objectForKey:@"channel"] != nil) ? [[userInfo objectForKey:@"aps"] objectForKey:@"channel"] : @"";
	
	if ([channelName length] > 0 && ![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
		_loadingView = [[UIView alloc] initWithFrame:self.window.frame];
		_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
		[self.window addSubview:_loadingView];
		
		UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicatorView.center = CGPointMake(_loadingView.bounds.size.width * 0.5, (_loadingView.bounds.size.height + 20.0) * 0.5);
		[activityIndicatorView startAnimating];
		[_loadingView addSubview:activityIndicatorView];
		
		[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithChannelName:channelName] animated:YES];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			[_tintTimer invalidate];
			_tintTimer = nil;
			[_loadingView removeFromSuperview];
			
			[_loadingOverlayView outro];
		});
	}
	
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
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
	NSLog(@"\t—//]> [%@ didReceiveRemoteNotification - FG] (%@)", self.class, userInfo);
	[[HONAudioMaestro sharedInstance] cafPlaybackWithFilename:@"selfie_notification"];
	
//	// Increment badge count if a message
//	if ([[userInfo valueForKeyPath:@"aps.content-available"] integerValue] != 0) {
//		NSInteger badgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber];
//		[[UIApplication sharedApplication] setApplicationIconBadgeNumber:badgeNumber + 1];
//	}
	
	NSString *channelName = ([[userInfo objectForKey:@"aps"] objectForKey:@"channel"] != nil) ? [[userInfo objectForKey:@"aps"] objectForKey:@"channel"] : @"";
	
	if ([channelName length] > 0 && ![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
		_loadingView = [[UIView alloc] initWithFrame:self.window.frame];
		_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
		[self.window addSubview:_loadingView];
		
		UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		activityIndicatorView.center = CGPointMake(_loadingView.bounds.size.width * 0.5, (_loadingView.bounds.size.height + 20.0) * 0.5);
		[activityIndicatorView startAnimating];
		[_loadingView addSubview:activityIndicatorView];
		
		[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithChannelName:channelName] animated:YES];
		
		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
			[_tintTimer invalidate];
			_tintTimer = nil;
			[_loadingView removeFromSuperview];
			
			[_loadingOverlayView outro];
		});
	}
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
								   @"back_chat"			: NSStringFromBOOL(NO),
								   @"invites"			: @[],
								   @"location_club"		: @{},
								   @"coords"			: @{@"lat" : @(0.00), @"lon" : @(0.00)},
								   @"device_locale"		: @{},
								   @"terms"				: @"",
								   @"activity_updated"	: @"0000-00-00 00:00:00"};
	
	for (NSString *key in [userDefaults allKeys]) {
		if (![[NSUserDefaults standardUserDefaults] hasObjectForKey:key])
			[[NSUserDefaults standardUserDefaults] setObject:[userDefaults objectForKey:key] forKey:key];
	}
	
	for (NSString *key in [[[HONStateMitigator sharedInstance] _totalKeyPrefixesForTypes] allKeys]) {
		NSString *keyName = [key stringByAppendingString:kStateMitigatorTotalCounterKeySuffix];
		if (![[NSUserDefaults standardUserDefaults] hasObjectForKey:keyName])
			[[HONStateMitigator sharedInstance] resetTotalCounterForType:(HONStateMitigatorTotalType)[[[HONStateMitigator sharedInstance] _totalKeyPrefixesForTypes] objectForKey:keyName] withValue:-1];
	}
	
#if __FORCE_REGISTER__ == 1
	for (NSString *key in [userDefaults allKeys])
		[[NSUserDefaults standardUserDefaults] replaceObject:[userDefaults objectForKey:key] forKey:key];
	
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

	[PubNub setDelegate:self];
	
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


/*
 * When people enter your app through the composer in Messenger,
 * this delegate function will be called.
 */
- (void)messengerURLHandler:(FBSDKMessengerURLHandler *)messengerURLHandler didHandleOpenFromComposerWithContext:(FBSDKMessengerURLHandlerOpenFromComposerContext *)context {
	NSLog(@"didHandleOpenFromComposerWithContext:[%@]", context.metadata);
}

/*
 * When people enter your app through the "Reply" button on content
 * this delegate function will be called.
 */
- (void)messengerURLHandler:(FBSDKMessengerURLHandler *)messengerURLHandler didHandleReplyWithContext:(FBSDKMessengerURLHandlerReplyContext *)context; {
	NSLog(@"didHandleReplyWithContext:[%@]", context.metadata);
	int statusUpdateID = [[[[[[context.metadata componentsSeparatedByString:@":"] lastObject] stringByReplacingOccurrencesOfString:@"\"" withString:@""] componentsSeparatedByString:@"_"] lastObject] intValue];
	
	if (statusUpdateID > 0) {
		[[HONAPICaller sharedInstance] retrieveStatusUpdateByStatusUpdateID:statusUpdateID completion:^(NSDictionary *result) {
			if (![[result objectForKey:@"detail"] isEqualToString:@"Not found"]) {
				HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:result];
				
				if (![NSStringFromClass([UIViewController currentViewController].class) isEqualToString:NSStringFromClass([HONStatusUpdateViewController class])]) {
					_loadingView = [[UIView alloc] initWithFrame:self.window.frame];
					_loadingView.backgroundColor = [UIColor colorWithRed:0.839 green:0.729 blue:0.400 alpha:1.00];
					[self.window addSubview:_loadingView];
					
					UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:self.window.frame];
					animationImageView.animationImages = @[[UIImage imageNamed:@"loading_01"],
														   [UIImage imageNamed:@"loading_02"],
														   [UIImage imageNamed:@"loading_03"],
														   [UIImage imageNamed:@"loading_04"],
														   [UIImage imageNamed:@"loading_05"],
														   [UIImage imageNamed:@"loading_06"],
														   [UIImage imageNamed:@"loading_07"],
														   [UIImage imageNamed:@"loading_08"]];
					animationImageView.animationDuration = 0.75;
					animationImageView.animationRepeatCount = 0;
					[animationImageView startAnimating];
					[_loadingView addSubview:animationImageView];
					
					_tintTimer = [NSTimer scheduledTimerWithTimeInterval:0.333
																  target:self
																selector:@selector(_changeLoadTint)
																userInfo:nil repeats:YES];
					
					[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:vo forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:YES];
					
					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
						[_tintTimer invalidate];
						_tintTimer = nil;
						[_loadingView removeFromSuperview];
						
						[_loadingOverlayView outro];
					});
				}
				
			} else {
				[_tintTimer invalidate];
				_tintTimer = nil;
				[_loadingView removeFromSuperview];
				
				[_loadingOverlayView outro];

				
				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Chat Link not found!"
																	message:@"Would you like to start a new chat?"
																   delegate:self
														  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
														  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
				[alertView setTag:HONAppDelegateAlertTypeCreateChat];
				[alertView show];
			}
		}];
	}
}



#pragma mark - PubNub Delegates
- (void)pubnubClient:(PubNub *)client didSubscribeOnChannels:(NSArray *)channels {
//	NSLog(@"DELEGATE: Subscribed to channel:%@", channels);
}

- (void)pubnubClient:(PubNub *)client didReceiveMessage:(PNMessage *)message {
//	NSLog(@"DELEGATE: Message received.");
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
		
	} else if (alertView.tag == HONAppDelegateAlertTypeCreateChat) {
		if (buttonIndex == 1) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"DEEPLINK - compose"];
			
			_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
			_loadingOverlayView.delegate = self;
			
			NSError *error;
			NSString *jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[@""] options:0 error:&error]
														 encoding:NSUTF8StringEncoding];
			
			NSDictionary *submitParams = @{@"user_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
										   @"img_url"		: @"",
										   @"club_id"		: @([[HONUserAssistant sharedInstance] activeUserID]),
										   @"challenge_id"	: @(0),
										   @"topic_id"		: @(0),
										   @"subject"		: @"using|",
										   @"subjects"		: jsonString};
			NSLog(@"|:|◊≈◊~~◊~~◊≈◊~~◊~~◊≈◊| SUBMIT PARAMS:[%@]", submitParams);
			
			
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
				} // api result
				[_loadingOverlayView outro];
				
				HONStatusUpdateVO *vo = [HONStatusUpdateVO statusUpdateWithDictionary:result];
				
				UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
				pasteboard.string = [NSString stringWithFormat:@"http://popup.vlly.im/%d/", vo.statusUpdateID];
				
				[self.navController pushViewController:[[HONStatusUpdateViewController alloc] initWithStatusUpdate:vo forClub:[[HONClubAssistant sharedInstance] currentLocationClub]] animated:YES];
			}]; // api submit
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
//		if (buttonIndex == HONSocialPlatformShareActionSheetTypeInstagram) {
//			NSString *savePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/selfieclub_instagram.igo"];
//			[[HONImageBroker sharedInstance] saveForInstagram:[_shareInfo objectForKey:@"image"]
//									withUsername:[[HONUserAssistant sharedInstance] activeUsername]
//										  toPath:savePath];
//			
//			if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"instagram://app"]]) {
//				_documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:[NSURL fileURLWithPath:savePath]];
//				_documentInteractionController.UTI = @"com.instagram.exclusivegram";
//				_documentInteractionController.delegate = self;
//				_documentInteractionController.annotation = [NSDictionary dictionaryWithObject:[[_shareInfo objectForKey:@"captions"] objectForKey:@"instagram"] forKey:@"InstagramCaption"];
//				[_documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:((UIViewController *)[_shareInfo objectForKey:@"view_controller"]).view animated:YES];
//				
//			} else {
//				[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"alert_instagramError_t", nil) //@"Not Available"
//											message:@"This device isn't allowed or doesn't recognize Instagram!"
//										   delegate:nil
//								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//								  otherButtonTitles:nil] show];
//			}
//		
//		} else
		if (buttonIndex == HONSocialPlatformShareActionSheetTypeTwitter) {
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
		[[HONSocialCoordinator sharedInstance] writeUserToDeviceContacts:nil];
	}
}



#if __APPSTORE_BUILD__ == 0
#pragma mark - UpdateManager Delegates
- (NSString *)customDeviceIdentifierForUpdateManager:(BITUpdateManager *)updateManager {
	return ([[HONDeviceIntrinsics sharedInstance] uniqueIdentifierWithoutSeperators:NO]);
	return (nil);
}
#endif

@end

