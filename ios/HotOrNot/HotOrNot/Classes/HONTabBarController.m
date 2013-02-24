//
//  HONTabBarController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Facebook.h"
#import "Mixpanel.h"


#import "HONTabBarController.h"
#import "HONAppDelegate.h"
#import "HONAlertPopOverView.h"

@interface HONTabBarController ()
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, strong) HONAlertPopOverView *alertPopOverView;
@property (nonatomic) CGPoint touchPt;
@end

@implementation HONTabBarController

@synthesize btn1, btn2, btn3, btn4, btn5;

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - Touch Handlers
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self.view];
	
	if ([touch view] == _tabHolderView) {
		_touchPt = CGPointMake(_tabHolderView.center.x - location.x, _tabHolderView.center.y - location.y);
	}
	
	if (_alertPopOverView.alpha == 1.0) {
		[UIView animateWithDuration:0.125 animations:^(void) {
			_alertPopOverView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_alertPopOverView removeFromSuperview];
		}];
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	
	if ([touch view] == _tabHolderView) {
		CGPoint touchLocation = [touch locationInView:self.view];
		float minY = (self.view.frame.size.height - (kTabButtonHeight * 2.0)) + (_tabHolderView.frame.size.height * 0.5);
		float maxY = (self.view.frame.size.height - kTabButtonHeight) + (_tabHolderView.frame.size.height * 0.5);
		
		CGPoint location = CGPointMake(_tabHolderView.center.x, MIN(MAX(_touchPt.y + touchLocation.y, minY), maxY));
		_tabHolderView.center = location;
		
		return;
	}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint location = CGPointMake(_tabHolderView.center.x - [touch locationInView:self.view].x, _tabHolderView.center.y - [touch locationInView:self.view].y);
	
	if (location.y > _touchPt.y) {
		[UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - (kTabButtonHeight * 2.0), _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		} completion:^(BOOL finished) {
		}];
		
	} else {
		[UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
			_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - kTabButtonHeight, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		} completion:^(BOOL finished) {
		}];
	}
	
//	if (_tabHolderView.center.y < (self.view.frame.size.height - 24.0)) {
//		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
//			_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - 96.0, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
//		} completion:^(BOOL finished) {
//		}];
//	
//	} else {
//		[UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^(void) {
//			_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - 48.0, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
//		} completion:^(BOOL finished) {
//		}];
//	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[self hideTabBar];
	
	[self addCustomElements];
	[self showNewTabBar];
	
	_alertPopOverView = [[HONAlertPopOverView alloc] initWithFrame:CGRectMake(64.0, self.view.frame.size.height - (kTabButtonHeight * 0.67), 60.0, 22.0)];
	
	[self _updateChallengeAlerts];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


#pragma mark - Presentation
- (void)hideTabBar {
	for (UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]])
			view.hidden = YES;//[view setFrame:CGRectMake(view.frame.origin.x, self.view.frame.size.height, view.frame.size.width, view.frame.size.height)];
		
		else
			[view setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
		
		//NSLog(@"VIEW:[%@][%@]", [view class], NSStringFromCGRect(view.frame));
	}

//	for (UIViewController *viewController in self.viewControllers)
//		viewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
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
	_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kTabButtonHeight, 320.0, (kTabButtonHeight * 2.0))];
	_tabHolderView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.01];
	[self.view addSubview:_tabHolderView];
	
	//_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 48.0, 320.0, 48.0)];
	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kTabButtonHeight, 320.0, kTabButtonHeight)];
	bgImageView.image = [UIImage imageNamed:@"footerBackground"];
	[_tabHolderView addSubview:bgImageView];
	
	// Initialise our two images
	UIImage *btnImage = [UIImage imageNamed:@"tabbar_001_nonActive"];
	UIImage *btnImageActive = [UIImage imageNamed:@"tabbar_001_onTap"];
	UIImage *btnImageSelected = [UIImage imageNamed:@"tabbar_001_active"];
	
	self.btn1 = [UIButton buttonWithType:UIButtonTypeCustom]; //Setup the button
	btn1.frame = CGRectMake(0.0, kTabButtonHeight, 64.0, kTabButtonHeight); // Set the frame (size and position) of the button)
	[btn1 setBackgroundImage:btnImage forState:UIControlStateNormal]; // Set the image for the normal state of the button
	[btn1 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted]; // Set the image for the normal state of the button
	[btn1 setBackgroundImage:btnImageSelected forState:(UIControlStateSelected)]; // Set the image for the selected state of the button
	[btn1 setTag:0]; // Assign the button a "tag" so when our "click" event is called we know which button was pressed.
	[btn1 setSelected:true]; // Set this button as selected (we will select the others to false as we only want Tab 1 to be selected initially
	
	// Now we repeat the process for the other buttons
	btnImage = [UIImage imageNamed:@"tabbar_002_nonActive"];
	btnImageActive = [UIImage imageNamed:@"tabbar_002_onTap"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_002_active"];
	self.btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn2.frame = CGRectMake(64.0, kTabButtonHeight, 64.0, kTabButtonHeight);
	[btn2 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn2 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn2 setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[btn2 setTag:1];
	
	btnImage = [UIImage imageNamed:@"tabbar_003_nonActive"];
	btnImageActive = [UIImage imageNamed:@"tabbar_003_onTap"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_003_active"];
	self.btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn3.frame = CGRectMake(128.0, kTabButtonHeight, 64.0, kTabButtonHeight);
	[btn3 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn3 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn3 setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[btn3 setTag:2];
	
	btnImage = [UIImage imageNamed:@"tabbar_004_nonActive"];
	btnImageActive = [UIImage imageNamed:@"tabbar_004_onTap"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_004_active"];
	self.btn4 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn4.frame = CGRectMake(192.0, kTabButtonHeight, 64.0, kTabButtonHeight);
	[btn4 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn4 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn4 setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[btn4 setTag:3];
	
	btnImage = [UIImage imageNamed:@"tabbar_005_nonActive"];
	btnImageActive = [UIImage imageNamed:@"tabbar_005_onTap"];
	btnImageSelected = [UIImage imageNamed:@"tabbar_005_active"];
	self.btn5 = [UIButton buttonWithType:UIButtonTypeCustom];
	btn5.frame = CGRectMake(256.0, kTabButtonHeight, 64.0, kTabButtonHeight);
	[btn5 setBackgroundImage:btnImage forState:UIControlStateNormal];
	[btn5 setBackgroundImage:btnImageActive forState:UIControlStateHighlighted];
	[btn5 setBackgroundImage:btnImageSelected forState:UIControlStateSelected];
	[btn5 setTag:4];
	
	// Add my new buttons to the view
	[_tabHolderView addSubview:btn1];
	[_tabHolderView addSubview:btn2];
	[_tabHolderView addSubview:btn3];
	[_tabHolderView addSubview:btn4];
	[_tabHolderView addSubview:btn5];
	
	// Setup event handlers so that the buttonClicked method will respond to the touch up inside event.
	[btn1 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn2 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn3 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn4 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	[btn5 addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
		
	UIButton *toggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleButton.frame = CGRectMake(130.0, 0.0, 60.0, 58.0);
	toggleButton.backgroundColor = [UIColor redColor];
	[toggleButton addTarget:self action:@selector(_goExpand:) forControlEvents:UIControlEventTouchUpInside];
	//[_bgImageView addSubview:toggleButton];
}


#pragma mark - Button Handlers
- (void)buttonClicked:(id)sender {
	int tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)selectTab:(int)tabID {
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tabID];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	switch(tabID) {
		case 0:
			[[Mixpanel sharedInstance] track:@"Tab - Voting"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:true];
			[btn1 setEnabled:YES];
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
			[[Mixpanel sharedInstance] track:@"Tab - Challenge Wall"
										 properties:[NSDictionary dictionaryWithObjectsAndKeys:
														 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			[btn1 setSelected:false];
			[btn1 setEnabled:YES];
			[btn2 setSelected:true];
			[btn2 setEnabled:YES];
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
			[btn4 setEnabled:YES];
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
			[btn5 setEnabled:YES];
			break;
	}
	
	//int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"]] / 86400;
	
	if (tabID == 2) {
		UINavigationController *navController = (UINavigationController *)[self selectedViewController];
		[navController popToRootViewControllerAnimated:NO];
	
	} else {
		NSString *notificationName = @"";
		
		switch (tabID) {
			case 0:
				notificationName = @"REFRESH_VOTE_TAB";
				break;
		
			case 1:
				notificationName = @"REFRESH_CHALLENGES_TAB";
				break;
		
			case 3:
				notificationName = @"REFRESH_POPULAR_TAB";
				break;
		
			case 4:
				notificationName = @"REFRESH_SETTINGS_TAB";
				break;
		}
		
		[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
		self.selectedIndex = tabID;
		[self _updateChallengeAlerts];
	}
	
	selectedViewController.view.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	[[NSNotificationCenter defaultCenter] postNotificationName:HONSessionStateChangedNotification object:FBSession.activeSession];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_RESULTS" object:nil];
	
	[UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - kTabButtonHeight, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
	} completion:^(BOOL finished) {
	}];
}


#pragma mark - Data Housekeeping
- (void)_updateChallengeAlerts {
	NSMutableDictionary *alertTotals = [NSMutableDictionary dictionaryWithObjectsAndKeys:
													[NSNumber numberWithInt:0], @"status",
													[NSNumber numberWithInt:0], @"score",
													[NSNumber numberWithInt:0], @"comments", nil];
	
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 3], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
		} else {
			int statusChanges = 0;
			int voteChanges = 0;
			int commentChanges = 0;
			
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			NSMutableArray *challenges = [NSMutableArray array];
			for (NSDictionary *serverList in unsortedChallenges) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil)
					[challenges addObject:vo];
			}
			
			NSMutableArray *updateChallenges = [NSMutableArray array];
			for (HONChallengeVO *vo in challenges) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInt:vo.challengeID], @"id",
											 (vo.statusID == 1 || vo.statusID == 2) ? @"created" : @"started", @"status",
											 [NSNumber numberWithInt:(vo.creatorID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorScore : vo.challengerScore], @"score",
											 [NSNumber numberWithInt:vo.commentTotal], @"comments",
											 nil];
				
				[updateChallenges addObject:dict];
			}
			
			NSArray *localChallenges = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"];
			for (NSDictionary *lDict in localChallenges) {
				for (NSDictionary *uDict in updateChallenges) {
					if ([[lDict objectForKey:@"id"] isEqual:[uDict objectForKey:@"id"]]) {
						NSLog(@"UPDATE:\n%@", uDict);
						
						if ([[lDict objectForKey:@"status"] isEqualToString:@"created"] && [[uDict objectForKey:@"status"] isEqualToString:@"started"]) {
							[alertTotals setValue:[NSNumber numberWithInt:++statusChanges] forKey:@"status"];
						}
						
						if ([[lDict objectForKey:@"score"] intValue] != [[uDict objectForKey:@"score"] intValue]) {
							voteChanges += [[uDict objectForKey:@"score"] intValue] - [[lDict objectForKey:@"score"] intValue];
							[alertTotals setValue:[NSNumber numberWithInt:voteChanges] forKey:@"score"];
						}
						
						if ([[lDict objectForKey:@"comments"] intValue] != [[uDict objectForKey:@"comments"] intValue]) {
							commentChanges += [[uDict objectForKey:@"comments"] intValue] - [[lDict objectForKey:@"comments"] intValue];
							[alertTotals setValue:[NSNumber numberWithInt:commentChanges] forKey:@"comments"];
						}
					}
				}
			}
			
			if ([localChallenges count] < [updateChallenges count]) {
				[alertTotals setValue:[NSNumber numberWithInt:[[alertTotals objectForKey:@"status"] intValue] + ([updateChallenges count] - [localChallenges count])] forKey:@"status"];
			}
			
			NSLog(@"CHANGES:\n%@", alertTotals);
			
			// update local
			[[NSUserDefaults standardUserDefaults] setValue:updateChallenges forKey:@"local_challenges"];
			[[NSUserDefaults standardUserDefaults] setValue:alertTotals forKey:@"alert_totals"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			if ([[alertTotals objectForKey:@"status"] intValue] > 0 || [[alertTotals objectForKey:@"score"] intValue] > 0 || [[alertTotals objectForKey:@"comments"] intValue] > 0) {
				[_alertPopOverView setAlerts:alertTotals];
				_alertPopOverView.alpha = 0.0;
				[self.view addSubview:_alertPopOverView];
				
				[UIView animateWithDuration:0.25 delay:0.67 options:UIViewAnimationOptionCurveLinear animations:^(void) {
					_alertPopOverView.alpha = 1.0;
				} completion:^(BOOL finished) {
				}];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"ChallengesViewController AFNetworking %@", [error localizedDescription]);
	}];
}

@end
