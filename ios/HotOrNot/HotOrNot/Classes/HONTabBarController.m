//
//  HONTabBarController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONTabBarController.h"
//#import <FacebookSDK/FacebookSDK.h>
#import "Facebook.h"
#import "Mixpanel.h"

#import "HONAppDelegate.h"
#import "HONResultsViewController.h"

@interface HONTabBarController ()
@property (nonatomic) int challengeHits;
@end

@implementation HONTabBarController

@synthesize btn1, btn2, btn3, btn4, btn5;
@synthesize challengeHits;

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showResults:) name:@"SHOW_RESULTS" object:nil];
		self.challengeHits = 0;
	}
	
	return (self);
}

- (void)loadView {
	[super loadView];
	
	[self hideTabBar];
	[self addCustomElements];
	[self showNewTabBar];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)hideTabBar {
	for(UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]]) {
			view.hidden = YES;
			break;
		}
	}
}

- (void)hideNewTabBar {
	self.btn1.hidden = YES;
	self.btn2.hidden = YES;
	self.btn3.hidden = YES;
	self.btn4.hidden = YES;
	self.btn5.hidden = YES;
}

- (void)showNewTabBar {
	self.btn1.hidden = NO;
	self.btn2.hidden = NO;
	self.btn3.hidden = NO;
	self.btn4.hidden = NO;
	self.btn5.hidden = NO;
}

-(void)addCustomElements {
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 48.0, 320.0, 48.0)];
	bgImgView.image = [UIImage imageNamed:@"footerBackground.png"];
	[self.view addSubview:bgImgView];
	
	// Initialise our two images
	UIImage *btnImage = [UIImage imageNamed:@"tabbar_001_nonActive.png"];
	UIImage *btnImageActive = [UIImage imageNamed:@"tabbar_001_active.png"];
	UIImage *btnImageSelected = [UIImage imageNamed:@"tabbar_001_tapped.png"];
	
	self.btn1 = [UIButton buttonWithType:UIButtonTypeCustom]; //Setup the button
	btn1.frame = CGRectMake(0.0, self.view.frame.size.height - 48.0, 64.0, 48.0); // Set the frame (size and position) of the button)
	[btn1 setBackgroundImage:btnImage forState:UIControlStateNormal]; // Set the image for the normal state of the button
	[btn1 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted]; // Set the image for the normal state of the button
	[btn1 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)]; // Set the image for the selected state of the button
	[btn1 setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
	[btn1 setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
	[btn1 setEnabled:NO];
	
	// Now we repeat the process for the other buttons
	btnImage = [UIImage imageNamed:@"tabbar_002_nonActive.png"];
	btnImageActive = [UIImage imageNamed:@"tabbar_002_active.png"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_002_tapped.png"];
	self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn2.frame = CGRectMake(64.0, self.view.frame.size.height - 48.0, 64.0, 48.0);
	[btn2 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn2 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn2 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn2 setTag:1];
	
	btnImage = [UIImage imageNamed:@"tabbar_003_nonActive.png"];
	btnImageActive = [UIImage imageNamed:@"tabbar_003_active.png"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_003_tapped.png"];
	self.btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn3.frame = CGRectMake(128.0, self.view.frame.size.height - 48.0, 64.0, 48.0);
	[btn3 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn3 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn3 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn3 setTag:2];
	
	btnImage = [UIImage imageNamed:@"tabbar_004_nonActive.png"];
	btnImageActive = [UIImage imageNamed:@"tabbar_004_active.png"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_004_tapped.png"];
	self.btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn4.frame = CGRectMake(192.0, self.view.frame.size.height - 48.0, 64.0, 48.0);
	[btn4 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn4 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn4 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn4 setTag:3];
	
	btnImage = [UIImage imageNamed:@"tabbar_005_nonActive.png"];
	btnImageActive = [UIImage imageNamed:@"tabbar_005_active.png"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_005_tapped.png"];
	self.btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn5.frame = CGRectMake(256.0, self.view.frame.size.height - 48.0, 64.0, 48.0);
	[btn5 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn5 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn5 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected | UIControlStateDisabled)];
	[btn5 setTag:4];
	
	// Add my new buttons to the view
	[self.view addSubview:btn1];
	[self.view addSubview:btn2];
	[self.view addSubview:btn3];
	[self.view addSubview:btn4];
	[self.view addSubview:btn5];
	
	// Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	[btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn4 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn5 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClicked:(id)sender {
	int tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)selectTab:(int)tabID {
	[self.delegate tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:tabID]];
	
	switch(tabID) {
		case 0:
			self.challengeHits++;
			
			[[Mixpanel sharedInstance] track:@"Tab - Challenge Wall"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:true];
			[btn1 setEnabled:NO];
			[btn2 setSelected:false];
			[btn2 setEnabled:YES];
			[btn3 setSelected:false];
			[btn3 setEnabled:YES];
			[btn4 setSelected:false];
			[btn4 setEnabled:YES];
			[btn5 setSelected:false];
			[btn5 setEnabled:YES];
			break;
			
		case 1:
			[[Mixpanel sharedInstance] track:@"Tab - Voting"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:false];
			[btn1 setEnabled:YES];
			[btn2 setSelected:true];
			[btn2 setEnabled:NO];
			[btn3 setSelected:false];
			[btn3 setEnabled:YES];
			[btn4 setSelected:false];
			[btn4 setEnabled:YES];
			[btn5 setSelected:false];
			[btn5 setEnabled:YES];
			break;
			
		case 2:
			[[Mixpanel sharedInstance] track:@"Tab - Create Challenge"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:(self.selectedIndex == 0)];
			[btn1 setEnabled:!(self.selectedIndex == 0)];
			[btn2 setSelected:(self.selectedIndex == 1)];
			[btn2 setEnabled:!(self.selectedIndex == 1)];
			[btn3 setSelected:false];
			[btn4 setSelected:(self.selectedIndex == 3)];
			[btn4 setEnabled:!(self.selectedIndex == 3)];
			[btn5 setSelected:(self.selectedIndex == 4)];
			[btn5 setEnabled:!(self.selectedIndex == 4)];
			break;
			
		case 3:
			[[Mixpanel sharedInstance] track:@"Tab - Popular"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:false];
			[btn1 setEnabled:YES];
			[btn2 setSelected:false];
			[btn2 setEnabled:YES];
			[btn3 setSelected:false];
			[btn3 setEnabled:YES];
			[btn4 setSelected:true];
			[btn4 setEnabled:NO];
			[btn5 setSelected:false];
			[btn5 setEnabled:YES];
			break;
			
		case 4:
			[[Mixpanel sharedInstance] track:@"Tab - Settings"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:false];
			[btn1 setEnabled:YES];
			[btn2 setSelected:false];
			[btn2 setEnabled:YES];
			[btn3 setSelected:false];
			[btn3 setEnabled:YES];
			[btn4 setSelected:false];
			[btn4 setEnabled:YES];
			[btn5 setSelected:true];
			[btn5 setEnabled:NO];
			break;
	}
	
	int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"]] / 86400;
	if (daysSinceInstall >= 1 && tabID == 0) {
		[[NSUserDefaults standardUserDefaults] setObject:[NSDate new] forKey:@"install_date"];
		UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONResultsViewController alloc] init]];
		[navigationController setNavigationBarHidden:YES];
		[self presentViewController:navigationController animated:YES completion:nil];
	}
	
	
	if (tabID == 2 && FBSession.activeSession.state == 513) {
		UINavigationController *navController = (UINavigationController *)[self selectedViewController];
		[navController popToRootViewControllerAnimated:YES];
	
	} else
		self.selectedIndex = tabID;
	
	
	[self.delegate tabBarController:self didSelectViewController:[self.viewControllers objectAtIndex:tabID]];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_LIST" object:nil];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_FB_POSTING" object:nil];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

- (void)_showResults:(NSNotification *)notification {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONResultsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

@end
