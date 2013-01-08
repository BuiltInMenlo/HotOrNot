//
//  HONFacebookSwitchView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.16.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Facebook.h"
#import "Mixpanel.h"

#import "HONFacebookSwitchView.h"
#import "HONAppDelegate.h"
#import "HONLoginViewController.h"

@implementation HONFacebookSwitchView

@synthesize switchButton = _switchButton;

- (id)init {
	if ((self = [super initWithFrame:CGRectMake(6.0, 26.0, 64.0, 34.0)])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateFBPosting:) name:@"UPDATE_FB_POSTING" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_fbSwitchHidden:) name:@"FB_SWITCH_HIDDEN" object:nil];
		
		_switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_switchButton.frame = CGRectMake(0.0, 0.0, 64.0, 34.0);
		[_switchButton setBackgroundImage:[UIImage imageNamed:@"facebookToggle_off"] forState:UIControlStateNormal];
		[_switchButton setBackgroundImage:[UIImage imageNamed:@"facebookToggle_on"] forState:UIControlStateSelected];
		[_switchButton addTarget:self action:@selector(_goToggle) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_switchButton];
		
		[self _updateSwitch];
	}
	return (self);
}


#pragma mark - Navigation
- (void)_goToggle {
	BOOL canPost = [HONAppDelegate allowsFBPosting];
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Toggle Facebook - (%d)", canPost]
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[HONAppDelegate setAllowsFBPosting:!canPost];
	[self _updateSwitch];
	
	if (FBSession.activeSession.state != 513) {
		UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:[[HONLoginViewController alloc] init]];
		[navController setNavigationBarHidden:YES];
		[[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:navController animated:YES completion:nil];
	}
}

#pragma mark - Notifications
- (void)_updateFBPosting:(NSNotification *)notification {
	[self _updateSwitch];
}

- (void)_fbSwitchHidden:(NSNotification *)notification {
	if ([(NSString *)[notification object] isEqualToString:@"Y"])
		[self removeFromSuperview];
	
	[self _updateSwitch];
}


- (void)_updateSwitch {
	NSLog(@"FB POSTING:[%d]", [HONAppDelegate allowsFBPosting]);
	[_switchButton setSelected:[HONAppDelegate allowsFBPosting]];
}

@end
