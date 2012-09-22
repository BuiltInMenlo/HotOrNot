//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UAirship.h"
#import "UAPush.h"
#import "ASIFormDataRequest.h"

#import "HONAppDelegate.h"

#import "HONChallengesViewController.h"
#import "HONVoteViewController.h"
#import "HONPopularViewController.h"
#import "HONCreateChallengeViewController.h"
#import "HONVoteViewController.h"

@interface HONAppDelegate() <ASIHTTPRequestDelegate>
- (void)_registerUser;
@end

@implementation HONAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

+ (void)writeDeviceToken:(NSString *)token {
	[[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)deviceToken {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"]);
}

+(void)writeUserInfo:(NSDictionary *)userInfo {
	[[NSUserDefaults standardUserDefaults] setObject:userInfo forKey:@"user_info"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

+(NSDictionary *)infoForUser {
	return ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"]);
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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	NSMutableDictionary *takeOffOptions = [[NSMutableDictionary alloc] init];
	[takeOffOptions setValue:launchOptions forKey:UAirshipTakeOffOptionsLaunchOptionsKey];
	[UAirship takeOff:takeOffOptions];
	
	[[UAPush shared] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	
	UIViewController *challengesViewController, *voteViewController, *popularViewController, *createChallengeViewController;
	challengesViewController = [[HONChallengesViewController alloc] init];
	voteViewController = [[HONVoteViewController alloc] init];
	popularViewController = [[HONPopularViewController alloc] init];
	createChallengeViewController = [[HONCreateChallengeViewController alloc] init];
	
	UINavigationController *navController1 = [[UINavigationController alloc] initWithRootViewController:challengesViewController];
	UINavigationController *navController2 = [[UINavigationController alloc] initWithRootViewController:voteViewController];
	UINavigationController *navController3 = [[UINavigationController alloc] initWithRootViewController:popularViewController];
	UINavigationController *navController4 = [[UINavigationController alloc] initWithRootViewController:createChallengeViewController];
	
	[navController1 setNavigationBarHidden:YES];
	[navController2 setNavigationBarHidden:YES];
	[navController3 setNavigationBarHidden:YES];
	[navController4 setNavigationBarHidden:YES];
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.delegate = self;
	//self.tabBarController.;
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:navController1, navController2, navController3, navController4, nil];
	self.window.rootViewController = self.tabBarController;
	[self.window makeKeyAndVisible];
	
	return (YES);
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
	[UAirship land];
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


- (void)_registerUser {
	//if (![[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
		ASIFormDataRequest *userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", kServerPath, kUsersAPI]]];
		[userRequest setDelegate:self];
		[userRequest setPostValue:[NSString stringWithFormat:@"%d", 1] forKey:@"action"];
		[userRequest setPostValue:[HONAppDelegate deviceToken] forKey:@"token"];
		[userRequest startAsynchronous];
	//}
}


#pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	//NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	if (viewController == [[tabBarController viewControllers] objectAtIndex:3]) {
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONCreateChallengeViewController alloc] init]];
		//[navigationController setNavigationBarHidden:YES];
		[tabBarController presentViewController:navigationController animated:YES completion:nil];
		
		return (NO);
		
	} else
		return (YES);
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	//NSLog(@"didSelectViewController:[%@]", viewController);
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
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
			[HONAppDelegate writeUserInfo:userResult];
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
}

@end
