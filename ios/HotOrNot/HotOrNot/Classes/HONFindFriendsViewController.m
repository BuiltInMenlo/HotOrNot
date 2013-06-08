//
//  HONFindFriendsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONFindFriendsViewController.h"
#import "HONAppDelegate.h"

@interface HONFindFriendsViewController ()
@end

@implementation HONFindFriendsViewController 

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Find Friends - Open"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [HONAppDelegate honGreenColor];
	
	UIImageView *promoteImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 35.0, 320.0, 94.0)];
	[promoteImageView setImageWithURL:[NSURL URLWithString:[HONAppDelegate promoteInviteImageForType:1]] placeholderImage:nil];
	[self.view addSubview:promoteImageView];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(253.0, 3.0, 64.0, 44.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:skipButton];
	
	UIImageView *mobileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kNavBarHeaderHeight + 116.0, 320.0, 320.0)];
	mobileImageView.image = [UIImage imageNamed:@"mobileNumberHack"];
	[self.view addSubview:mobileImageView];
	
	UIButton *mobileButton = [UIButton buttonWithType:UIButtonTypeCustom];
	mobileButton.frame = mobileImageView.frame;
	[mobileButton addTarget:self action:@selector(_goMobile) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:mobileButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Find Friends - Skip"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)_goMobile {
	[[Mixpanel sharedInstance] track:@"Find Friends -Clicked"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}


@end
