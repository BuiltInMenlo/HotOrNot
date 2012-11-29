//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <KiipSDK/KiipSDK.h>
#import <Parse/Parse.h>

#import "UAirship.h"
#import "UAPush.h"
#import "ASIFormDataRequest.h"
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

NSString *const SCSessionStateChangedNotification = @"com.facebook.Scrumptious:SCSessionStateChangedNotification";

@interface HONAppDelegate() <UIAlertViewDelegate, ASIHTTPRequestDelegate, KiipDelegate>
@property (nonatomic, strong) UIAlertView *networkAlertView;
- (void)_registerUser;
@end

@implementation HONAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;
@synthesize networkAlertView = _networkAlertView;

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize client = _client;

+ (NSString *)apiServerPath {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"server_api"]);
}

+ (NSNumber *)challengeDuration {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"challange_duration"]);
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
		NSLog(@"cID:[%d] <> challengeID:[%d]", [cID intValue], challengeID);
		if ([cID intValue] == challengeID) {
			return (YES);
		}
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
	return ([NSArray arrayWithObjects:@"publish_actions", @"status_update", @"publish_stream", nil]);
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

+ (UIFont *)honHelveticaNeueFontBold {
	return [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
}

+ (UIFont *)honHelveticaNeueFontMedium {
	return [UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0];
}

+ (UIColor *)honBlueTxtColor {
	return ([UIColor colorWithRed:0.17647058823529 green:0.33333333333333 blue:0.6078431372549 alpha:1.0]);
}

+ (UIColor *)honGreyTxtColor {
	return ([UIColor colorWithWhite:0.482 alpha:1.0]);
}

+ (int)secondsBeforeDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([date timeIntervalSinceDate:utcDate]);
}

+ (int)minutesBeforeDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([date timeIntervalSinceDate:utcDate] / 60);
}

+ (int)hoursBeforeDate:(NSDate *)date {
	NSDateFormatter *utcFormatter = [[NSDateFormatter alloc] init];
	[utcFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	[utcFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-MM-ddHH:mm:ss"];
	NSDate *utcDate = [dateFormatter dateFromString:[utcFormatter stringFromDate:[NSDate new]]];
	
	return ([date timeIntervalSinceDate:utcDate] / 3600);
}


- (BOOL)openSession {
	NSLog(@"openSession");
	//	[FBSession openActiveSessionWithPublishPermissions:<#(NSArray *)#> defaultAudience:<#(FBSessionDefaultAudience)#> allowLoginUI:<#(BOOL)#> completionHandler:<#^(FBSession *session, FBSessionState status, NSError *error)handler#>]
	
//	return ([FBSession openActiveSessionWithReadPermissions:[HONAppDelegate fbPermissions]
//															 allowLoginUI:NO
//													  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
//														  NSLog(@"STATE:%d", state);
//														  [self sessionStateChanged:session state:state error:error];
//													  }]);
	
	return ([FBSession openActiveSessionWithPermissions:[HONAppDelegate fbPermissions]
														allowLoginUI:NO
												 completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
													 NSLog(@"STATE:%d", state);
													 [self sessionStateChanged:session state:state error:error];
	 }]);
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
	// FBSample logic
	// Any time the session is closed, we want to display the login controller (the user
	// cannot use the application unless they are logged in to Facebook). When the session
	// is opened successfully, hide the login controller and show the main UI.
	
	NSLog(@"sessionStateChanged:[%d]", state);
	
	switch (state) {
		case FBSessionStateOpen: {
			NSLog(@"--FBSessionStateOpen--");
			[self.loginViewController dismissViewControllerAnimated:YES completion:nil];
			
			//			if (self.loginViewController != nil) {
			//				UIViewController *topViewController = [self.tabBarController topViewController];
			//				[topViewController dismissModalViewControllerAnimated:YES];
			//				self.loginViewController = nil;
			//			}
			
			// FBSample logic
			// Pre-fetch and cache the friends for the friend picker as soon as possible to improve
			// responsiveness when the user tags their friends.
			FBCacheDescriptor *cacheDescriptor = [FBFriendPickerViewController cacheDescriptor];
			[cacheDescriptor prefetchAndCacheForSession:session];
		}
			break;
		case FBSessionStateClosed:
			NSLog(@"--FBSessionStateClosed--");
			break;
			
		case FBSessionStateClosedLoginFailed: {
			NSLog(@"--FBSessionStateClosedLoginFailed--");
			// FBSample logic
			// Once the user has logged out, we want them to be looking at the root view.
			//			UIViewController *topViewController = [self.navController topViewController];
			//			UIViewController *modalViewController = [topViewController modalViewController];
			//			if (modalViewController != nil) {
			//				[topViewController dismissModalViewControllerAnimated:NO];
			//			}
			//			[self.navController popToRootViewControllerAnimated:NO];
			
			[FBSession.activeSession closeAndClearTokenInformation];
			
			// if the token goes invalid we want to switch right back to
			// the login view, however we do it with a slight delay in order to
			// account for a race between this and the login view dissappearing
			// a moment before
			
			self.loginViewController = [[HONLoginViewController alloc] init];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.loginViewController];
			[navigationController setNavigationBarHidden:YES];
			[self.tabBarController presentViewController:navigationController animated:NO completion:nil];
			
			//			[self performSelector:@selector(showLoginView)
			//						  withObject:nil
			//						  afterDelay:0.5f];
		}
			break;
		default:
			break;
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SCSessionStateChangedNotification
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



#pragma mark - Application Delegates
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	//self.window.frame = CGRectMake(0.0, 0.0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSArray array] forKey:@"votes"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if ([HONAppDelegate hasNetwork] && [HONAppDelegate canPingParseServer]) {
		NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
		[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
		[UAirship takeOff:takeOffOptions];
		[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
		
		[Parse setApplicationId:@"Gi7eI4v6r9pEZmSQ0wchKKelOgg2PIG9pKE160uV" clientKey:@"Bv82pH4YB8EiXZG4V0E2KjEVtpLp4Xds25c5AkLP"];
		[PFUser enableAutomaticUser];
		PFACL *defaultACL = [PFACL ACL];
		
		// If you would like all objects to be private by default, remove this line.
		[defaultACL setPublicReadAccess:YES];
		
		[PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
		
		
	//	PFObject *testObject = [PFObject objectWithClassName:@"APIs"];
	//	[testObject setObject:@"PicChallenge" forKey:@"title"];
	//	[testObject setObject:@"http://discover.getassembly.com/hotornot/api" forKey:@"server_path"];
	//	[testObject save];
		
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
			UIAlertView *alert = [[UIAlertView alloc]
										 initWithTitle:@"Rate PicChallenge"
										 message:@"Why not rate PicChallenge in the app store!"
										 delegate:self
										 cancelButtonTitle:nil
										 otherButtonTitles:@"No Thanks", @"Ask Me Later", @"Visit App Store", nil];
			
			[alert show];
		}
		
		if (![[NSUserDefaults standardUserDefaults] objectForKey:@"fb_posting"])
			[HONAppDelegate setAllowsFBPosting:NO];
		
		
		PFQuery *appIDQuery = [PFQuery queryWithClassName:@"AppIDs"];
		PFObject *appIDObject = [appIDQuery getObjectWithId:@"k2SlH68C62"];
		
		PFQuery *query = [PFQuery queryWithClassName:@"APIs"];
		PFObject *appObject = [query getObjectWithId:@"p8VIk5s3du"];
		
		PFQuery *durationQuery = [PFQuery queryWithClassName:@"Durations"];
		PFObject *durationObject = [durationQuery getObjectWithId:@"ND1LzmULX5"];
		
		PFQuery *dailyQuery = [PFQuery queryWithClassName:@"DailyChallenges"];
		PFObject *dailyObject = [dailyQuery getObjectWithId:@"obmVTq3VHr"];
		
		PFQuery *s3Query = [PFQuery queryWithClassName:@"S3Credentials"];
		PFObject *s3Object = [s3Query getObjectWithId:@"zofEGq6sLT"];
		
		PFQuery *fbQuery = [PFQuery queryWithClassName:@"FacebookPaths"];
		PFObject *fbObject = [fbQuery getObjectWithId:@"9YC4DWz1AY"];
		
		PFQuery *subjectQuery = [PFQuery queryWithClassName:@"PicChallegeDefaultSubjects"];
		NSMutableArray *subjects = [NSMutableArray array];
		for (PFObject *obj in [subjectQuery findObjects])
			[subjects addObject:[obj objectForKey:@"title"]];
		
		[[NSUserDefaults standardUserDefaults] setObject:[appIDObject objectForKey:@"appstore_id"] forKey:@"appstore_id"];
		[[NSUserDefaults standardUserDefaults] setObject:[appObject objectForKey:@"server_path"] forKey:@"server_api"];
		[[NSUserDefaults standardUserDefaults] setObject:[durationObject objectForKey:@"duration"] forKey:@"challange_duration"];
		[[NSUserDefaults standardUserDefaults] setObject:[dailyObject objectForKey:@"subject_name"] forKey:@"daily_challenge"];
		[[NSUserDefaults standardUserDefaults] setObject:[NSDictionary dictionaryWithObjectsAndKeys:[s3Object objectForKey:@"key"], @"key", [s3Object objectForKey:@"secret"], @"secret", nil] forKey:@"s3_creds"];
		[[NSUserDefaults standardUserDefaults] setObject:[fbObject objectForKey:@"canvas_url"] forKey:@"facebook_url"];
		[[NSUserDefaults standardUserDefaults] setObject:[subjects copy] forKey:@"default_subjects"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[TapForTap initializeWithAPIKey:@"13654ee85567a679c190698d04ee87e2"];
		
		Kiip *kiip = [[Kiip alloc] initWithAppKey:@"app_key" andSecret:@"app_secret"];
		kiip.delegate = self;
		[Kiip setSharedInstance:kiip];
		
		if ([HONAppDelegate canPingAPIServer]) {
			UIViewController *challengesViewController, *voteViewController, *popularViewController, *createChallengeViewController, *settingsViewController;
			challengesViewController = [[HONChallengesViewController alloc] init];
			voteViewController = [[HONVoteViewController alloc] init];
			popularViewController = [[HONPopularViewController alloc] init];
			createChallengeViewController = [[HONImagePickerViewController alloc] init];
			settingsViewController = [[HONSettingsViewController alloc] init];
			
			UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:challengesViewController];
			UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:voteViewController];
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
			
			[[Kiip sharedInstance] saveMoment:@"Test Moment" withCompletionHandler:nil];
			
			if (![self openSession]) {
				UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
				[navigationController setNavigationBarHidden:YES];
				[self.tabBarController presentViewController:navigationController animated:NO completion:nil];
			}
			
			NSLog(@"[FBSession.activeSession] (%d)", FBSession.activeSession.state);
		
		} else {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad Network Connection"
																			message:@"Could not connect to PicChallenge servers, please try again."
																		  delegate:nil
															  cancelButtonTitle:nil
															  otherButtonTitles:@"OK", nil];
			[alert show];
		}
	
	} else {
		_networkAlertView = [[UIAlertView alloc] initWithTitle:@"No Network Connection"
																		message:@"This app requires a network connection to work."
																	  delegate:self
														  cancelButtonTitle:nil
														  otherButtonTitles:@"OK", nil];
		[_networkAlertView show];

	}
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[FBSession.activeSession handleDidBecomeActive];
	
	PFQuery *dailyQuery = [PFQuery queryWithClassName:@"DailyChallenges"];
	PFObject *dailyObject = [dailyQuery getObjectWithId:@"obmVTq3VHr"];
	
	[[NSUserDefaults standardUserDefaults] setObject:[dailyObject objectForKey:@"subject_name"] forKey:@"daily_challenge"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
	
	// Configure Chartboost
    Chartboost *cb = [Chartboost sharedChartboost];
    cb.appId = @"50aa71ce17ba472f08000000";
    cb.appSignature = @"7ce4ac44c9ff1a9f4b32757554957a295eb603ca";
    
    // Notify the beginning of a user session
    [cb startSession];
    
    // Show an interstitial
    [cb showInterstitial];
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
	
	//[UAPush shared].delegate = self;
	
	/*
	 int type_id = [[userInfo objectForKey:@"type"] intValue];
	 NSLog(@"TYPE: [%d]", type_id);
	 
	 switch (type_id) {
	 case 1:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_REWARDS_LIST" object:nil];
	 break;
	 
	 case 2:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_REWARDS_LIST" object:nil];
	 break;
	 
	 case 3:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_DEVICES_LIST" object:nil];
	 break;
	 
	 case 4:
	 [[NSNotificationCenter defaultCenter] postNotificationName:@"THANK_YOU_RECIEVED" object:nil];
	 break;
	 
	 }
	 
	 if (type_id == 2) {
	 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Leaving diddit" message:@"Your iTunes gift card number has been copied" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:@"Visit iTunes", nil];
	 [alert show];
	 [alert release];
	 
	 NSString *redeemCode = [[DIAppDelegate md5:[NSString stringWithFormat:@"%d", arc4random()]] uppercaseString];
	 redeemCode = [redeemCode substringToIndex:[redeemCode length] - 12];
	 
	 UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
	 [pasteboard setValue:redeemCode forPasteboardType:@"public.utf8-plain-text"];
	 }
	 
	 UILocalNotification *localNotification = [[[UILocalNotification alloc] init] autorelease];
	 localNotification.fireDate = [[NSDate alloc] initWithTimeIntervalSinceNow:5];
	 localNotification.alertBody = [NSString stringWithFormat:@"%d", [[userInfo objectForKey:@"type"] intValue]];;
	 localNotification.soundName = UILocalNotificationDefaultSoundName;
	 localNotification.applicationIconBadgeNumber = 3;
	 
	 NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:@"Object 1", @"Key 1", @"Object 2", @"Key 2", nil];
	 localNotification.userInfo = infoDict;
	 
	 [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
	 */
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
	return [FBSession.activeSession handleOpenURL:url];
}



- (void)_registerUser {
	//if (![[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
		ASIFormDataRequest *userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
		[userRequest setDelegate:self];
		[userRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[userRequest setPostValue:[HONAppDelegate deviceToken] forKey:@"token"];
		[userRequest startAsynchronous];
	//}
}


#pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	if (viewController == [[tabBarController viewControllers] objectAtIndex:2]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONImagePickerViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[tabBarController presentViewController:navigationController animated:NO completion:nil];
		
		return (NO);
	
//	} else if (viewController == [[tabBarController viewControllers] objectAtIndex:4]) {
//		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSettingsViewController alloc] init]];
//		[tabBarController presentViewController:navigationController animated:YES completion:nil];
//		
//		return (NO);
		
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
	
	if (alertView == _networkAlertView)
		NSLog(@"EXIT APP");//exit(0);
	
	else {
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


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONAppDelegate [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
