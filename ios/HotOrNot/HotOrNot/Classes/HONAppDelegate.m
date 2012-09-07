//
//  HONAppDelegate.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.06.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONAppDelegate.h"

#import "HONChallengesViewController.h"
#import "HONVoteViewController.h"
#import "HONPopularViewController.h"
#import "HONCreateChallengeViewController.h"

@implementation HONAppDelegate

@synthesize window = _window;
@synthesize tabBarController = _tabBarController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	UIViewController *challengesViewController, *voteViewController, *popularViewController, *createChallengeViewController;
	challengesViewController = [[HONChallengesViewController alloc] init];
	voteViewController = [[HONVoteViewController alloc] init];
	popularViewController = [[HONPopularViewController alloc] init];
	createChallengeViewController = [[HONCreateChallengeViewController alloc] init];
	
	self.tabBarController = [[UITabBarController alloc] init];
	self.tabBarController.delegate = self;
	self.tabBarController.viewControllers = [NSArray arrayWithObjects:challengesViewController, voteViewController, popularViewController, createChallengeViewController, nil];
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
}


# pragma mark - TabBarController Delegates
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
	NSLog(@"shouldSelectViewController:[%@]", viewController);
	
	if (viewController == [[tabBarController viewControllers] objectAtIndex:3]) {
		HONCreateChallengeViewController *createChallengeViewController = [[HONCreateChallengeViewController alloc] init];
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:createChallengeViewController];
		
		[tabBarController presentModalViewController:[[HONCreateChallengeViewController alloc] init] animated:YES];
		return (NO);
	
	} else
		return (YES);
}


- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	NSLog(@"didSelectViewController:[%@]", viewController);
}

- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}

@end
