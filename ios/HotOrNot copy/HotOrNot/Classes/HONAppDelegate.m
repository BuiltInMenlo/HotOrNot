//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <KiipSDK/KiipSDK.h>
#import <Parse/Parse.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "AFJSONRequestOperation.h"
#import "UAirship.h"
#import "UAPush.h"
#import "HONAppDelegate.h"
#import "Parse/Parse.h"
#import "Mixpanel.h"
#import "Reachability.h"
#import "TapForTap.h"
#import "Chartboost.h"

#import "HONTabBarController.h"
#import "HONChallengesViewController.h"
#import "HONVoteViewController.h"
#import "HONPopularViewController.h"
#import "HONImagePickerViewController.h"
#import "HONVoteViewController.h"
#import "HONSettingsViewController.h"
#import "HONLoginViewController.h"
#import "HONChallengeVO.h"
#import "HONFacebookSwitchView.h"
#import "HONUsernameViewController.h"
#import "HONWebCTAViewController.h"
#import "HONInviteFriendsViewController.h"

NSString *const HONSessionStateChangedNotification = @"com.builtinmenlo.hotornot:HONSessionStateChangedNotification";
NSString *const FacebookAppID = @"529054720443694";

@interface HONAppDelegate() <UIAlertViewDelegate, KiipDelegate>
@property (nonatomic, strong) HONFacebookSwitchView *facebookSwitchView;
@property (nonatomic, strong) AVAudioPlayer *mp3Player;
@property (nonatomic) BOOL isFromBackground;
- (void)_registerUser;
@end

@implementation HONAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize client = _client;

+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSString *)dailySubjectName {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"daily_challenge"]);
}

+ (NSDictionary *)s3Credentials {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"s3_creds"]);
}

+ (NSString *)facebookCanvasURL {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"facebook_url"]);
}

+ (NSDictionary *)facebookFriendPosting {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"fb_network"]);
}

+ (NSString *)ctaForChallenge:(HONChallengeVO *)vo {
	NSString *message;
	
	if (vo.statusID == 1)
		message = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ctas"] objectAtIndex:2];
	
	else if (vo.statusID == 2)
		message = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ctas"] objectAtIndex:0];
	
	else
		message = [[[NSUserDefaults standardUserDefaults] objectForKey:@"ctas"] objectAtIndex:1];
	
	message = [message stringByReplacingOccurrencesOfString:@"{{CREATOR}}" withString:vo.creatorName];
	message = [message stringByReplacingOccurrencesOfString:@"{{CHALLENGER}}" withString:vo.challengerName];
	message = [message stringByReplacingOccurrencesOfString:@"{{SUBJECT}}" withString:vo.subjectName];
	message = [message stringByReplacingOccurrencesOfString:@"{{GENDER}}" withString:@"her"];
	
	return (message);
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

+ (BOOL)isCharboostEnabled {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"ad_networks"] objectForKey:@"chartboost"] isEqualToString:@"Y"]);
}

+ (BOOL)isKiipEnabled {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"ad_networks"] objectForKey:@"kiip"] isEqualToString:@"Y"]);
}

+ (BOOL)isTapForTapEnabled {
	return ([[[[NSUserDefaults standardUserDefaults] objectForKey:@"ad_networks"] objectForKey:@"tapfortap"] isEqualToString:@"Y"]);
}

+ (NSString *)rndDefaultSubject {
	NSArray *subjects = [[NSUserDefaults standardUserDefaults] objectForKey:@"default_subjects"];
	return ([subjects objectAtIndex:(arc4random() % [subjects count])]);
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

+ (NSDictionary *)infoForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
}

+ (void)writeFBProfile:(NSDictionary *)profile {
	if (profile != nil)
		[[NSUserDefaults standardUserDefaults] setObject:profile forKey:@"fb_profile"];
	
	else
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"fb_profile"];
	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSDictionary *)fbProfileForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"fb_profile"]);
}

+ (void)setAllowsFBPosting:(BOOL)canPost {
	[[NSUserDefaults standardUserDefaults] setObject:(canPost) ? @"YES" : @"NO" forKey:@"fb_posting"];	
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)allowsFBPosting {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"] isEqualToString:@"YES"]);
}

+ (BOOL)hasVoted:(int)challengeID {
	NSArray *voteArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"votes"];
	
	for (NSNumber *cID in voteArray) {
		if ([cID intValue] == challengeID)
			return (YES);
	}
	
	return (NO);
}

+ (void)setVote:(int)challengeID {
	NSMutableArray *voteArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"votes"] mutableCopy];
	[voteArray addObject:[NSNumber numberWithInt:challengeID]];
	
	[[NSUserDefaults standardUserDefaults] setObject:voteArray forKey:@"votes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


+ (UIViewController *)appTabBarController {
	return ([[UIApplication sharedApplication] keyWindow].rootViewController);
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}


+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor {
	CGSize size = CGSizeMake(image.size.width * factor, image.size.height * factor);
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0, size.height);
	CGContextScaleCTM(context, 1.0, -1.0);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return (croppedImage);
}

+ (NSArray *)fbPermissions {
	return ([NSArray arrayWithObjects:@"publish_actions", @"publish_stream", nil]); //@"status_update",
}

+ (BOOL)isRetina5 {
	return ([UIScreen mainScreen].scale == 2.f && [UIScreen mainScreen].bounds.size.height == 568.0f);
}

+ (BOOL)hasNetwork {
	//Reachability *wifiReachability = [Reachability reachabilityForLocalWiFi];
	//[[Reachability reachabilityForLocalWiFi] startNotifier];
	
	//return ([wifiReachability currentReachabilityStatus] == kReachableViaWiFi);
	
	[[Reachability reachabilityForInternetConnection] startNotifier];
	NetworkStatus networkStatus = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus];
	
	return !(networkStatus == NotReachable);
}

+ (BOOL)canPingServers {
	NetworkStatus apiStatus = [[Reachability reachabilityWithHostName:[[[HONAppDelegate apiServerPath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus];
	NetworkStatus parseStatus = [[Reachability reachabilityWithHostName:@"api.parse.com"] currentReachabilityStatus];
	
	return (!(apiStatus == NotReachable) && !(parseStatus == NotReachable));
}

+ (BOOL)canPingAPIServer {
	NetworkStatus apiStatus = [[Reachability reachabilityWithHostName:[[[HONAppDelegate apiServerPath] componentsSeparatedByString: @"/"] objectAtIndex:2]] currentReachabilityStatus];
	
	return (!(apiStatus == NotReachable));
}

+ (BOOL)canPingParseServer {
	NetworkStatus parseStatus = [[Reachability reachabilityWithHostName:@"api.parse.com"] currentReachabilityStatus];
	
	return (!(parseStatus == NotReachable));
}

+ (BOOL)audioMuted {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"] isEqualToString:@"YES"]);
}

+ (void)toggleViewPushed:(BOOL)isPushed {
	[[NSUserDefaults standardUserDefaults] setObject:(isPushed) ? @"YES" : @"NO" forKey:@"pushed_view"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


+ (UIFont *)honHelveticaNeueFontBold {
	return ([UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]);
}

+ (UIFont *)honHelveticaNeueFontBoldItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0]);
}

+ (UIFont *)honHelveticaNeueFontMedium {
	return ([UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]);
}

+ (UIFont *)freightSansBlack {
	return ([UIFont fontWithName:@"FreightSansBlack" size:18.0]);
}

+ (UIFont *)qualcommBold {
	return ([UIFont fontWithName:@"Qualcomm-Bold" size:18.0]);
}

+ (UIFont *)qualcommLight {
	return ([UIFont fontWithName:@"Qualcomm-Light" size:18.0]);
}

+ (UIFont *)qualcommRegular {
	return ([UIFont fontWithName:@"Qualcomm-Regular" size:18.0]);
}

+ (UIFont *)qualcommSemibold {
	return ([UIFont fontWithName:@"Qualcomm-Semibold" size:18.0]);
}

+ (UIColor *)honBlueTxtColor {
	return ([UIColor colorWithRed:0.17647058823529 green:0.33333333333333 blue:0.6078431372549 alpha:1.0]);
}

+ (UIColor *)honGreyTxtColor {
	return ([UIColor colorWithWhite:0.5922 alpha:1.0]);
}


- (BOOL)openSession {
	NSLog(@"openSession");
	return ([FBSession openActiveSessionWithPublishPermissions:[HONAppDelegate fbPermissions]
															 defaultAudience:FBSessionDefaultAudienceEveryone
																 allowLoginUI:NO
														  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
															  NSLog(@"STATE:%d", state);
															  [self sessionStateChanged:session state:state error:error];
														  }]);
	
//	return ([FBSession openActiveSessionWithPermissions:[HONAppDelegate fbPermissions]
//														allowLoginUI:NO
//												 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//													 NSLog(@"STATE:%d", state);
//													 [self sessionStateChanged:session state:state error:error];
//	 }]);
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
	// FBSample logic
	// Any time the session is closed, we want to display the login controller (the user
	// cannot use the application unless they are logged in to Facebook). When the session
	// is opened successfully, hide the login controller and show the main UI.
	
	NSLog(@"sessionStateChanged:[%d]", state);
	
	switch (state) {
		case FBSessionStateOpen: {
			NSLog(@"--FBSessionStateOpen--AppDelegate");
			[self.loginViewController dismissViewControllerAnimated:YES completion:nil];
						
			// FBSample logic
			// Pre-fetch and cache the friends for the friend picker as soon as possible to improve
			// responsiveness when the user tags their friends.
			FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
			[cacheDescriptor prefetchAndCacheForSession:session];
		} break;
		
		case FBSessionStateClosed:
			NSLog(@"--FBSessionStateClosed--AppDelegate");
			break;
			
		case FBSessionStateClosedLoginFailed: {
			NSLog(@"--FBSessionStateClosedLoginFailed--AppDelegate");
			
			[FBSession.activeSession closeAndClearTokenInformation];
		} break;
		
		default:
			break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:HONSessionStateChangedNotification
																		 object:session];
	
	if (error) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
																			 message:error.localizedDescription
																			delegate:nil
																cancelButtonTitle:@"OK"
																otherButtonTitles:nil];
		[alertView show];
	}
}


#pragma mark - Notifications
- (void)_fbSwitchHidden:(NSNotification *)notification {
	if ([(NSString *)[notification object] isEqualToString:@"N"] && [[[NSUserDefaults standardUserDefaults] objectForKey:@"pushed_view"] isEqualToString:@"NO"])
		[[[UIApplication sharedApplication] delegate].window addSubview:_facebookSwitchView];
}

- (void)_inviteFriends:(NSNotification *)notification {
	
	if (FBSession.activeSession.state == 513) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteFriendsViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
		
	} else {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
	}
}


- (void)_webCTA:(NSNotification *)notification {
	NSString *url = [[notification object] objectForKey:@"url"];
	NSString *title = [[notification object] objectForKey:@"title"];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONWebCTAViewController alloc] initWithURL:url andTitle:title]];
	[navigationController setNavigationBarHidden:YES];
	[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
}


#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//self.window.frame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"shown_settings"])
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"shown_settings"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"votes"])
		[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
	
	if (![[NSUserDefaults standardUserDefaults] objectForKey:@"audio_muted"])
		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"audio_muted"];
	
	_isFromBackground = NO;
	[HONAppDelegate toggleViewPushed:NO];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fbSwitchHidden:) name:@"FB_SWITCH_HIDDEN" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_inviteFriends:) name:@"INVITE_FRIENDS" object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_webCTA:) name:@"WEB_CTA" object:nil];
	
	//[self _testParseCloudCode];
	
	if ([HONAppDelegate hasNetwork] && [HONAppDelegate canPingParseServer]) {
		NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
		[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
		[UAirship takeOff:takeOffOptions];
		[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		
		[Parse setApplicationId:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV" clientKey:@"Bv82pH4YB8EiXZG4V0E2KjEVtpLp4Xds25c5AkLP"];
		[PFUser enableAutomaticUser];
		PFACL *defaultACL = [PFACL ACL];
		[defaultACL setPublicReadAccess:YES];
		[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
		
		[Mixpanel sharedInstanceWithToken:@"c7bf64584c01bca092e204d95414985f"];
		[[Mixpanel sharedInstance] track:@"App Boot"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		int boot_total = 0;
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
		
		else {
			boot_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"boot_total"] intValue];
			boot_total++;
		
			[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:boot_total] forKey:@"boot_total"];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"])
			[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
		
		if (boot_total == 5) {
			UIAlertView *alertView = [[UIAlertView alloc]
										 initWithTitle:@"Rate PicChallenge"
										 message:@"Why not rate PicChallenge in the app store!"
										 delegate:self
										 cancelButtonTitle:nil
										 otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
			[alertView setTag:2];
			[alertView show];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"])
			[HONAppDelegate setAllowsFBPosting:NO];
		
		PFQuery *appDataQuery = [PFQuery queryWithClassName:@"PicChallenge"];
		PFObject *appDataObject = [appDataQuery getObjectWithId:@"1ZUKru9Qer"];
		
		NSError *error = nil;
		NSDictionary *appDict = [NSJSONSerialization JSONObjectWithData:[[appDataObject objectForKey:@"data"] dataUsingEncoding:NSUTF8StringEncoding]
																				  options:NSJSONReadingMutableContainers
																					 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse app data list JSON: %@", [error localizedFailureReason]);
		
		else {
			//NSLog(@"appDict:\n%@", appDict);
			
			NSMutableArray *hashtags = [NSMutableArray array];
			for (NSString *hashtag in [appDict objectForKey:@"default_hashtags"])
				[hashtags addObject:hashtag];
						
			[[NSUserDefaults standardUserDefaults] setObject:[appDict objectForKey:@"appstore_id"] forKey:@"appstore_id"];
			[[NSUserDefaults standardUserDefaults] setObject:[[appDict objectForKey:@"endpts"] objectForKey:@"data_api"] forKey:@"server_api"];
			[[NSUserDefaults standardUserDefaults] setObject:[[appDict objectForKey:@"endpts"] objectForKey:@"fb_path"] forKey:@"facebook_url"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [[appDict objectForKey:@"fb_posting_rules"] objectForKey:@"friend_wall"], @"friend_wall",
																			  [[appDict objectForKey:@"fb_posting_rules"] objectForKey:@"invite"], @"invite", nil] forKey:@"fb_network"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:
																			  [[appDict objectForKey:@"point_multipliers"] objectForKey:@"vote"],
																			  [[appDict objectForKey:@"point_multipliers"] objectForKey:@"poke"],
																			  [[appDict objectForKey:@"point_multipliers"] objectForKey:@"create"], nil] forKey:@"point_mult"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:
																			  [NSDictionary dictionaryWithObjectsAndKeys:
																				[[[appDict objectForKey:@"web_ctas"] objectAtIndex:0] objectForKey:@"title"], @"title",
																				[[[appDict objectForKey:@"web_ctas"] objectAtIndex:0] objectForKey:@"url"], @"url",
																				[[[appDict objectForKey:@"web_ctas"] objectAtIndex:0] objectForKey:@"enabled"], @"enabled", nil],
																			  [NSDictionary dictionaryWithObjectsAndKeys:
																				[[[appDict objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"title"], @"title",
																				[[[appDict objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"url"], @"url",
																				[[[appDict objectForKey:@"web_ctas"] objectAtIndex:1] objectForKey:@"enabled"], @"enabled", nil], nil] forKey:@"web_ctas"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:
																			  [[appDict objectForKey:@"vote_wall_ctas"] objectForKey:@"waiting"],
																			  [[appDict objectForKey:@"vote_wall_ctas"] objectForKey:@"accepted"],
																			  [[appDict objectForKey:@"vote_wall_ctas"] objectForKey:@"created"], nil] forKey:@"ctas"];
			[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																			  [[appDict objectForKey:@"add_networks"] objectForKey:@"chartboost"], @"chartboost",
																			  [[appDict objectForKey:@"add_networks"] objectForKey:@"kiip"], @"kiip",
																			  [[appDict objectForKey:@"add_networks"] objectForKey:@"tapfortap"], @"tapfortap", nil] forKey:@"ad_networks"];
			[[NSUserDefaults standardUserDefaults] setObject:[hashtags copy] forKey:@"default_subjects"];
		}
		
		PFQuery *s3Query = [PFQuery queryWithClassName:@"S3Credentials"];
		PFObject *s3Object = [s3Query getObjectWithId:@"zofEGq6sLT"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:
																		  [s3Object objectForKey:@"key"], @"key",
																		  [s3Object objectForKey:@"secret"], @"secret", nil] forKey:@"s3_creds"];
		
		PFQuery *dailyQuery = [PFQuery queryWithClassName:@"DailyChallenges"];
		PFObject *dailyObject = [dailyQuery getObjectWithId:@"obmVTq3VHr"];
		[[NSUserDefaults standardUserDefaults] setObject:[dailyObject objectForKey:@"subject_name"] forKey:@"daily_challenge"];
		
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		
//		[TapForTap initializeWithAPIKey:@"13654ee85567a679c190698d04ee87e2"];
//		
//		Kiip *kiip = [[Kiip alloc] initWithAppKey:@"app_key" andSecret:@"app_secret"];
//		kiip.delegate = self;
//		[Kiip setSharedInstance:kiip];
		
		if ([HONAppDelegate canPingAPIServer]) {
			UIViewController *challengesViewController, *voteViewController, *popularViewController, *createChallengeViewController, *settingsViewController;
			challengesViewController = [[HONChallengesViewController alloc] init];
			voteViewController = [[HONVoteViewController alloc] init];
			popularViewController = [[HONPopularViewController alloc] init];
			createChallengeViewController = [[HONImagePickerViewController alloc] init];
			settingsViewController = [[HONSettingsViewController alloc] init];
			
			UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:voteViewController];
			UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:challengesViewController];
			UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:createChallengeViewController];
			UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:popularViewController];
			UINavigationController *navController5 = [[UINavigationController alloc] initWithRootViewController:settingsViewController];
			
			[navController1 setNavigationBarHidden:YES];
			[navController2 setNavigationBarHidden:YES];
			[navController3 setNavigationBarHidden:YES];
			[navController4 setNavigationBarHidden:YES];
			[navController5 setNavigationBarHidden:YES];
			
			self.tabBarController = [[HONTabBarController alloc] init];
			self.tabBarController.delegate = self;
			self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, navController4, navController5, nil];
			
			self.window.rootViewController = self.tabBarController;
			[self.window makeKeyAndVisible];
			
			//[[Kiip sharedInstance] saveMoment:@"Test Moment" withCompletionHandler:nil];
			
			if (![self openSession]) {
				self.loginViewController = [[HONLoginViewController alloc] init];				
//				UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Username"
//																			message:@"Login to Facebook to see your friends or change your username."
//																		  delegate:self
//															  cancelButtonTitle:nil
//															  otherButtonTitles:@"Login", @"Change Username", nil];
//				[alertView setTag:1];
//				[alertView show];
			}
			
			_facebookSwitchView = [[HONFacebookSwitchView alloc] init];
			[self.window addSubview:_facebookSwitchView];
			
					
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad Network Connection"
																			message:@"Could not connect to PicChallenge servers, please try again."
																		  delegate:nil
															  cancelButtonTitle:nil
															  otherButtonTitles:@"OK", nil];
			[alert show];
		}
	
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection"
																		message:@"This app requires a network connection to work."
																	  delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:@"OK", nil];
		[alertView setTag:0];
		[alertView show];

	}
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	_isFromBackground = YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBSession.activeSession handleDidBecomeActive];
	
	if ([HONAppDelegate hasNetwork] && [HONAppDelegate canPingParseServer]) {
		PFQuery *dailyQuery = [PFQuery queryWithClassName:@"DailyChallenges"];
		PFObject *dailyObject = [dailyQuery getObjectWithId:@"obmVTq3VHr"];
	
		[[NSUserDefaults standardUserDefaults] setObject:[dailyObject objectForKey:@"subject_name"] forKey:@"daily_challenge"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
	
//	Chartboost *cb = [Chartboost sharedChartboost];
//	cb.appId = @"50ba9e2717ba47d426000002";
//	cb.appSignature = @"8526c7d52c380c02cc8e59c1c29e8cf4bf779646";
//	[cb startSession];
//	
//	if ([HONAppDelegate isCharboostEnabled])
//		[cb showInterstitial];
	
	if (_isFromBackground && [[[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:0] objectForKey:@"enabled"] isEqualToString:@"Y"])
		[[NSNotificationCenter defaultCenter] postNotificationName:@"WEB_CTA" object:[[[NSUserDefaults standardUserDefaults] objectForKey:@"web_ctas"] objectAtIndex:0]];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[UAirship land];
	[FBSession.activeSession close];
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
	[[UAPush shared] registerDeviceToken:deviceToken];
	
	NSString *deviceID = [[deviceToken description] substringFromIndex:1];
	deviceID = [deviceID substringToIndex:[deviceID length] - 1];
	deviceID = [deviceID stringByReplacingOccurrencesOfString:@" " withString:@""];
	
	NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	[self _registerUser];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *) error {
	UALOG(@"Failed To Register For Remote Notifications With Error: %@", error);
	
	NSString *deviceID = [NSString stringWithFormat:@"%064d", 0];
	NSLog(@"didFailToRegisterForRemoteNotificationsWithError:[%@]", deviceID);
	
	[HONAppDelegate writeDeviceToken:deviceID];
	[self _registerUser];
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
	
	NSLog(@"alert: [%@]", [[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
	
	int type_id = [[userInfo objectForKey:@"type"] intValue];
	switch (type_id) {
		
		// challenge update
		case 1: {
			UIAlertView *alertView = [[UIAlertView alloc]
											  initWithTitle:@"Challenge Update"
											  message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
											  delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
			[alertView show];
//			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//				if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"pushed_view"] isEqualToString:@"YES"]) {
//					[[[UIApplication sharedApplication] delegate].window.rootViewController.navigationController popToRootViewControllerAnimated:YES];
//					[HONAppDelegate toggleViewPushed:NO];
//				}
//			}];
			break; }
			
		// poke
		case 2: {
			UIAlertView *alertView = [[UIAlertView alloc]
											  initWithTitle:@"Poke"
											  message:[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]
											  delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
			[alertView show];
			break;}
	}
	 	
	UILocalNotification *localNotification = [[UILocalNotification alloc] init];
	localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:1];
	localNotification.alertBody = [NSString stringWithFormat:@"%d", [[userInfo objectForKey:@"type"] intValue]];;
	localNotification.soundName = UILocalNotificationDefaultSoundName;
	 
//	NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
//	localNotification.userInfo = infoDict;
	 
	[[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [FBSession.activeSession handleOpenURL:url];
}



- (void)_registerUser {
	//if (![[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
	
//	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.parse.com/1/functions/"]];
//	[httpClient setDefaultHeader:@"X-Parse-Application-Id" value:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV"];
//	[httpClient setDefaultHeader:@"X-Parse-REST-API-Key" value:@"Lf7cT3m2EC8JsXzubpfhD28phm2gA7Y86kiTnAb6"];
//	[httpClient setDefaultHeader:@"Content-Type" value:@"application/json"];
//	[httpClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
		
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 1], @"action",
									[HONAppDelegate deviceToken], @"token",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSLog(@"HONAppDelegate AFNetworking: %@", userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
		}
				
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
}

- (void)_testParseCloudCode {
	// http://stackoverflow.com/questions/10795710/converting-a-curl-request-with-data-urlencode-into-afnetworking-get-request
	/*
	NSDictionary *jsonDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"app_name", @"PicChallenge", nil];
	 
	NSError *error = nil;
	NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:&error];
	 
	if (!jsonData) {
		NSLog(@"NSJSONSerialization failed %@", error);
	}
	 
	NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
	NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:json, @"where", nil];
	*/
	// ////////////////////////////////////////////////////////////////////////////////////////////////////////////// //
	
	
	NSDictionary *parameters = [[NSDictionary alloc] initWithObjectsAndKeys:
										 @"PicChallenge", @"app_name",
										 nil];
	
	AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.parse.com/1/functions/"]];
	[client setDefaultHeader:@"X-Parse-Application-Id" value:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV"];
	[client setDefaultHeader:@"X-Parse-REST-API-Key" value:@"Lf7cT3m2EC8JsXzubpfhD28phm2gA7Y86kiTnAb6"];
	[client setDefaultHeader:@"Content-Type" value:@"application/json"];
	[client registerHTTPOperationClass:[AFJSONRequestOperation class]];
	
	[client postPath:@"duration"
		  parameters:parameters
			  success:^(AFHTTPRequestOperation *operation, id responseObject) {
				  NSError *error = nil;
				  NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
				  NSLog(@"SUCCESS\n%@", result);
				  
			  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
				  NSLog(@"FAILED\n%@", error);
			  }
	 ];
}

- (void)_showFonts {
	NSMutableArray *fontNames = [[NSMutableArray alloc] init];
	
	for (NSString *familyName in [UIFont familyNames]) {
		NSLog(@"Font Family Name = %@", familyName);
		
		NSArray *names = [UIFont fontNamesForFamilyName:familyName];
		NSLog(@"Font Names = %@", fontNames);
		
		[fontNames addObjectsFromArray:names];
	}
}

#pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	if (viewController == [[tabBarController viewControllers] objectAtIndex:2]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[tabBarController presentViewController:navigationController animated:NO completion:nil];
		
		return (NO);
		
	} else
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
		UINavigationController *navigationController;
		
		switch (buttonIndex) {
			case 0:
				navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
				break;
				
			case 1:
				navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONUsernameViewController alloc] init]];
				break;
		}
		
		[navigationController setNavigationBarHidden:YES];
		[self.tabBarController presentViewController:navigationController animated:YES completion:nil];
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
	}
}

@end
