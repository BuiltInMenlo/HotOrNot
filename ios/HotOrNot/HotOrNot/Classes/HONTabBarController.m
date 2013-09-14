//
//  HONTabBarController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImage+ImageEffects.h"

#import "HONTabBarController.h"
#import "HONAlertPopOverView.h"
#import "HONImagingDepictor.h"

@interface HONTabBarController ()
@property (nonatomic, retain) UIButton *timelineButton;
@property (nonatomic, retain) UIButton *challengesButton;
@property (nonatomic, retain) UIButton *discoveryButton;
@property (nonatomic, retain) UIButton *settingsButton;

@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, strong) HONAlertPopOverView *alertPopOverView;
@property (nonatomic) CGPoint touchPt;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTabs:) name:@"SHOW_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideTabs:) name:@"HIDE_TABS" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[self _hideNativeTabBar];
	[self _addCustomTabs];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	_alertPopOverView = [[HONAlertPopOverView alloc] initWithFrame:CGRectMake(165.0, self.view.frame.size.height - 74.0, 39.0, 39.0)];
	//if ([[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"] != nil)
	//	[self _updateChallengeAlerts];
	
//	[self _showAlertPopOverWithTotals:[NSDictionary dictionaryWithObjectsAndKeys:
//												  [NSNumber numberWithInt:arc4random() % 15], @"status",
//												  [NSNumber numberWithInt:arc4random() % 15], @"score",
//												  [NSNumber numberWithInt:arc4random() % 15], @"comments", nil]];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


#pragma mark - Presentation
- (void)_hideNativeTabBar {
	for (UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]])
		_tabBarView = view;//view.hidden = YES;
		
//		else
//			[view setFrame:[UIScreen mainScreen].bounds];//[view setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
		
		NSLog(@"VIEW:[%@][%@]", [view class], NSStringFromCGRect(view.frame));
	}

//	for (UIViewController *viewController in self.viewControllers)
//		viewController.view.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height);
}

- (void)hideNewTabBar {
	_timelineButton.hidden = YES;
	_challengesButton.hidden = YES;
	_discoveryButton.hidden = YES;
	_settingsButton.hidden = YES;
}

- (void)showNewTabBar {
	_timelineButton.hidden = NO;
	_challengesButton.hidden = NO;
	_discoveryButton.hidden = NO;
	_settingsButton.hidden = NO;
}

-(void)_addCustomTabs {
	_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kTabSize.height, 320.0, kTabSize.height)];
	[self.view addSubview:_tabHolderView];
	
//	UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, kTabSize.height)];
//	bgImageView.image = [[UIImage imageNamed:@"tabMenuBackground"] applyBlurWithRadius:5.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil];
//	bgImageView.userInteractionEnabled = YES;
//	[_tabHolderView addSubview:bgImageView];
	
	_timelineButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_timelineButton.frame = CGRectMake(20.0, 0.0, kTabSize.width, kTabSize.height);
	[_timelineButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateNormal];
	[_timelineButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Tapped"] forState:UIControlStateHighlighted];
	[_timelineButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateSelected];
	[_timelineButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	//[_timelineButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateDisabled];
	[_timelineButton setTag:0];
	[_timelineButton setSelected:YES];
	
	_discoveryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_discoveryButton.frame = CGRectMake(40.0 + kTabSize.width, 0.0, kTabSize.width, kTabSize.height);
	[_discoveryButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_discoveryButton_nonActive"] forState:UIControlStateNormal];
	[_discoveryButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_discoveryButton_Tapped"] forState:UIControlStateHighlighted];
	[_discoveryButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_discoveryButton_Active"] forState:UIControlStateSelected];
	[_discoveryButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_discoveryButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	//[_discoveryButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_discoveryButton_nonActive"] forState:UIControlStateDisabled];
	[_discoveryButton setTag:1];
	
	_challengesButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_challengesButton.frame = CGRectMake(60.0 + (kTabSize.width * 2.0), 0.0, kTabSize.width, kTabSize.height);
	[_challengesButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_nonActive"] forState:UIControlStateNormal];
	[_challengesButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Tapped"] forState:UIControlStateHighlighted];
	[_challengesButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Active"] forState:UIControlStateSelected];
	[_challengesButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	//[_challengesButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_nonActive"] forState:UIControlStateDisabled];
	[_challengesButton setTag:2];
	
//	_settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_settingsButton.frame = CGRectMake(kTabSize.width * 3.0, 0.0, kTabSize.width, kTabSize.height);
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_profileButton_nonActive"] forState:UIControlStateNormal];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_profileButton_Tapped"] forState:UIControlStateHighlighted];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_profileButton_Active"] forState:UIControlStateSelected];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_profileButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
//	//[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_profileButton_nonActive"] forState:UIControlStateDisabled];
//	[_settingsButton setTag:3];
	
	[_tabHolderView addSubview:_timelineButton];
	[_tabHolderView addSubview:_challengesButton];
	[_tabHolderView addSubview:_discoveryButton];
//	[_tabHolderView addSubview:_settingsButton];
	
	[self _toggleTabsEnabled:YES];
}

- (void)_showAlertPopOverWithTotals:(NSDictionary *)dict {
	[_alertPopOverView setAlerts:dict];
	_alertPopOverView.alpha = 0.0;
	[self.view addSubview:_alertPopOverView];
	
	[UIView animateWithDuration:0.25 delay:0.67 options:UIViewAnimationOptionCurveLinear animations:^(void) {
		_alertPopOverView.alpha = 1.0;
	} completion:^(BOOL finished) {
	}];
}

- (void)_hideAlertPopOver {
	
	// update local
	[[NSUserDefaults standardUserDefaults] setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"update_challenges"] forKey:@"local_challenges"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	if (_alertPopOverView.alpha == 1.0) {
		[UIView animateWithDuration:0.125 animations:^(void) {
			_alertPopOverView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_alertPopOverView removeFromSuperview];
		}];
	}
}

- (void)_toggleTabsEnabled:(BOOL)isEnabled {
	if	(isEnabled) {
		[_timelineButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_challengesButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_discoveryButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_settingsButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	
	} else {
		[_timelineButton removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_challengesButton removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_discoveryButton removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
		[_settingsButton removeTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
	}
}


#pragma mark - Navigation
- (void)buttonClicked:(id)sender {
	[self _selectTab:[sender tag]];
}

- (void)_selectTab:(int)tabID {
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tabID];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	NSString *mixPanelTrack = @"";
	NSString *notificationName = @"";
	
	switch(tabID) {
		case 0:
			[_timelineButton setSelected:YES];
			[_challengesButton setSelected:NO];
			[_discoveryButton setSelected:NO];
			[_settingsButton setSelected:NO];
			
			mixPanelTrack = @"Tab Bar - Timeline";
			notificationName = @"SELECTED_VOTE_TAB";
			break;
			
		case 1:
			[_timelineButton setSelected:NO];
			[_challengesButton setSelected:NO];
			[_discoveryButton setSelected:YES];
			[_settingsButton setSelected:NO];
			
			mixPanelTrack = @"Tab Bar - Discover";
			notificationName = @"SELECTED_DISCOVERY_TAB";
			break;
			
		case 2:
			[self _hideAlertPopOver];
			
			[_timelineButton setSelected:NO];
			[_challengesButton setSelected:YES];
			[_discoveryButton setSelected:NO];
			[_settingsButton setSelected:NO];
			
			mixPanelTrack = @"Tab Bar - Activity";
			notificationName = @"SELECTED_CHALLENGES_TAB";
			break;
			
		case 3:
			[_timelineButton setSelected:NO];
			[_challengesButton setSelected:NO];
			[_discoveryButton setSelected:NO];
			[_settingsButton setSelected:YES];
			
			mixPanelTrack = @"Tab Bar - Settings";
			//notificationName = @"SELECTED_PROFILE_TAB";
			//notificationName = @"SELECTED_VOTE_TAB";
			break;
	}
	
	[[Mixpanel sharedInstance] track:mixPanelTrack
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	//int daysSinceInstall = [[NSDate new] timeIntervalSinceDate:[[NSUserDefaults standardUserDefaults] objectForKey:@"install_date"]] / 86400;
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
	self.selectedIndex = tabID;
	//[self _updateChallengeAlerts];
	
	selectedViewController.view.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_TABLE" object:nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"KILL_TOOLTIP" object:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tabID] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//[self _dropTabs];
}


#pragma mark - Notifications
- (void)_showTabs:(NSNotification *)notification {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - kTabSize.height, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		_tabBarView.frame = CGRectMake(_tabBarView.frame.origin.x, self.view.frame.size.height - 49.0, _tabBarView.frame.size.width, _tabBarView.frame.size.height);//CGRectOffset(_tabBarView.frame, 0.0, -44.0);
	}];
}

- (void)_hideTabs:(NSNotification *)notification {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		_tabBarView.frame = _tabBarView.frame = CGRectMake(_tabBarView.frame.origin.x, self.view.frame.size.height, _tabBarView.frame.size.width, _tabBarView.frame.size.height);//CGRectOffset(_tabBarView.frame, 0.0, 44.0);
	}];
}


#pragma mark - Data Housekeeping
- (void)_updateChallengeAlerts {
	NSMutableDictionary *alertTotals = [NSMutableDictionary dictionaryWithObjectsAndKeys:
													[NSNumber numberWithInt:0], @"status",
													[NSNumber numberWithInt:0], @"score",
													[NSNumber numberWithInt:0], @"comments", nil];
	
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 3], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIChallenges parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSArray *unsortedChallenges = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//VolleyJSONLog(@"AFNetworking [-] %@ %@", [[self class] description], unsortedChallenges);
			
			int statusChanges = 0;
			int voteChanges = 0;
			int commentChanges = 0;
			
			NSMutableArray *challenges = [NSMutableArray array];
			for (NSDictionary *serverList in unsortedChallenges) {
				HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:serverList];
				
				if (vo != nil)// && (vo.statusID == 1 && vo.creatorID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]))
					[challenges addObject:vo];
			}
			
			NSMutableArray *updateChallenges = [NSMutableArray array];
			for (HONChallengeVO *vo in challenges) {
				NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
											 [NSNumber numberWithInt:vo.challengeID], @"id",
											 (vo.statusID == 1 || vo.statusID == 2) ? @"created" : @"started", @"status",
											 [NSNumber numberWithInt:(vo.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorVO.score : ((HONOpponentVO *)[vo.challengers lastObject]).score], @"score",
											 [NSNumber numberWithInt:vo.commentTotal], @"comments",
											 nil];
				
				[updateChallenges addObject:dict];
			}
			
			NSArray *localChallenges = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"];
			for (NSDictionary *lDict in localChallenges) {
				for (NSDictionary *uDict in updateChallenges) {
					if ([[lDict objectForKey:@"id"] isEqual:[uDict objectForKey:@"id"]]) {
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
			
			[[NSUserDefaults standardUserDefaults] setValue:updateChallenges forKey:@"update_challenges"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			//NSLog(@"CHANGES:\n%@", alertTotals);
			
			if ([[alertTotals objectForKey:@"status"] intValue] > 0 || [[alertTotals objectForKey:@"score"] intValue] > 0 || [[alertTotals objectForKey:@"comments"] intValue] > 0) {
				[self _showAlertPopOverWithTotals:alertTotals];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}

@end
