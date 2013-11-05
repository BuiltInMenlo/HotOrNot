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
#import "HONImagingDepictor.h"
#import "HONChangeAvatarViewController.h"

const CGSize kTabSize = {80.0, 50.0};

@interface HONTabBarController ()
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, retain) UIButton *homeButton;
@property (nonatomic, retain) UIButton *exploreButton;
@property (nonatomic, retain) UIButton *verifyButton;
@property (nonatomic, retain) UIButton *avatarNeededButton;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showTabs:) name:@"SHOW_TABS" object:nil];
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hideTabs:) name:@"HIDE_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshProfile:) name:@"REFRESH_PROFILE" object:nil];
		
		 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateTabBarAB:) name:@"UPDATE_TAB_BAR_AB" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	for (UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]])
			_tabBarView = view;
	}
	
	[self _addCustomTabs];
	
//	if (![HONAppDelegate hasTakenSelfie]) {
//		_avatarNeededButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_avatarNeededButton.frame = CGRectMake(10.0, [UIScreen mainScreen].bounds.size.height - (kTabSize.height + 54.0), 44.0, 44.0);
//		[_avatarNeededButton setBackgroundImage:[UIImage imageNamed:@"needSeflieButton_nonActive"] forState:UIControlStateNormal];
//		[_avatarNeededButton setBackgroundImage:[UIImage imageNamed:@"needSeflieButton_Active"] forState:UIControlStateHighlighted];
//		[_avatarNeededButton addTarget:self action:@selector(_goProfileAvatar) forControlEvents:UIControlEventTouchUpInside];
//		[self.view addSubview:_avatarNeededButton];
//	}
	
//	[self _createPopoverBadge];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


#pragma mark - Presentation
-(void)_addCustomTabs {
	_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kTabSize.height, 320.0, kTabSize.height)];
	[self.view addSubview:_tabHolderView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabMenuBackground"]];
	bgImageView.userInteractionEnabled = YES;
	[_tabHolderView addSubview:bgImageView];
	[bgImageView setTag:-1];
	bgImageView.hidden = YES;
	
	_homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_homeButton.frame = CGRectMake(20.0, 0.0, kTabSize.width, kTabSize.height);
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateNormal];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Tapped"] forState:UIControlStateHighlighted];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateSelected];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateDisabled];
	[_tabHolderView addSubview:_homeButton];
	[_homeButton setTag:0];
	
	_exploreButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_exploreButton.frame = CGRectMake(40.0 + kTabSize.width, 0.0, kTabSize.width, kTabSize.height);
	[_exploreButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_exploreButton_nonActive"] forState:UIControlStateNormal];
	[_exploreButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_exploreButton_Tapped"] forState:UIControlStateHighlighted];
	[_exploreButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_exploreButton_Active"] forState:UIControlStateSelected];
	[_exploreButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_exploreButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_exploreButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_exploreButton_nonActive"] forState:UIControlStateDisabled];
	[_tabHolderView addSubview:_exploreButton];
	[_exploreButton setTag:1];
	
	NSString *verifyTabPrefix = ([[HONAppDelegate infoForABTab] objectForKey:@"tab_asset"]);
	_verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_verifyButton.frame = CGRectMake(60.0 + (kTabSize.width * 2.0), 0.0, kTabSize.width, kTabSize.height);
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_nonActive", verifyTabPrefix]] forState:UIControlStateNormal];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Tapped", verifyTabPrefix]] forState:UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Active", verifyTabPrefix]] forState:UIControlStateSelected];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Active", verifyTabPrefix]] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_nonActive", verifyTabPrefix]] forState:UIControlStateDisabled];
	[_tabHolderView addSubview:_verifyButton];
	[_verifyButton setTag:2];
	
	[_homeButton setSelected:YES];
	[self _toggleTabButtonsEnabled:YES];
}

//- (void)_showBadgesWithTotals:(NSDictionary *)dict {
//	[_alertPopOverView setAlerts:dict];
//	_alertPopOverView.alpha = 0.0;
//	[self.view addSubview:_alertPopOverView];
//	
//	[UIView animateWithDuration:0.25 delay:0.67 options:UIViewAnimationOptionCurveLinear animations:^(void) {
//		_alertPopOverView.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
//}

//- (void)_hideBadges {
//	[[NSUserDefaults standardUserDefaults] setValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"update_challenges"] forKey:@"local_challenges"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
//	
//	if (_alertPopOverView.alpha == 1.0) {
//		[UIView animateWithDuration:0.125 animations:^(void) {
//			_alertPopOverView.alpha = 0.0;
//		} completion:^(BOOL finished) {
//			[_alertPopOverView removeFromSuperview];
//		}];
//	}
//}

- (void)_toggleTabButtonsEnabled:(BOOL)isEnabled {
	if	(isEnabled) {
		for (UIButton *button in _tabHolderView.subviews) {
			if (button.tag != -1)
				[button addTarget:self action:@selector(_goTabButton:) forControlEvents:UIControlEventTouchUpInside];
		}
		
	} else {
		for (UIButton *button in _tabHolderView.subviews) {
			if (button.tag != -1)
				[button removeTarget:self action:@selector(_goTabButton:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
}

- (void)_createPopoverBadge {
//	_alertPopOverView = [[HONAlertPopOverView alloc] initWithFrame:CGRectMake(165.0, self.view.frame.size.height - 74.0, 39.0, 39.0)];
//	
//	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"] != nil)
//		[self _updateBadges];
//
//	[self _showBadgesWithTotals:@{@"status"		: [NSNumber numberWithInt:arc4random() % 15],
//								  @"score"		: [NSNumber numberWithInt:arc4random() % 15],
//								  @"comments"	: [NSNumber numberWithInt:arc4random() % 15]}];
}


#pragma mark - Navigation
- (void)_goTabButton:(id)sender {
	int tabID = [sender tag];
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tabID];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	NSString *mpEvent = @"";
	NSString *notificationName = @"";
	NSString *totalKey = @"";
	
	switch(tabID) {
		case 0:
			[_homeButton setSelected:YES];
			[_verifyButton setSelected:NO];
			[_exploreButton setSelected:NO];
			
			totalKey = @"timeline";
			mpEvent = @"Tab Bar - Timeline";
			notificationName = @"SELECTED_HOME_TAB";
			break;
			
		case 1:
			[_homeButton setSelected:NO];
			[_verifyButton setSelected:NO];
			[_exploreButton setSelected:YES];
			
			totalKey = @"explore";
			mpEvent = @"Tab Bar - Explore";
			notificationName = @"SELECTED_EXPLORE_TAB";
			break;
			
		case 2:
			[_homeButton setSelected:NO];
			[_verifyButton setSelected:YES];
			[_exploreButton setSelected:NO];
			
			totalKey = @"verify";
			mpEvent = @"Tab Bar - Verify";
			notificationName = @"SELECTED_VERIFY_TAB";
			break;
			
		default:
			break;
	}
	
	[[Mixpanel sharedInstance] track:mpEvent
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[HONAppDelegate incTotalForCounter:totalKey];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
	self.selectedIndex = tabID;
//	[self _updateBadges];
	
	selectedViewController.view.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tabID] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_goProfileAvatar {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONChangeAvatarViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_showTabs:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - kTabSize.height, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		_tabBarView.frame = CGRectMake(_tabBarView.frame.origin.x, self.view.frame.size.height - 49.0, _tabBarView.frame.size.width, _tabBarView.frame.size.height);//CGRectOffset(_tabBarView.frame, 0.0, -44.0);
		
		_tabHolderView.alpha = 1.0;
		_tabBarView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		_avatarNeededButton.hidden = NO;
		[UIView animateWithDuration:0.25 animations:^(void) {
			_avatarNeededButton.alpha = 1.0;
		}];
	}];
	
}

- (void)_hideTabs:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		_tabBarView.frame = _tabBarView.frame = CGRectMake(_tabBarView.frame.origin.x, self.view.frame.size.height, _tabBarView.frame.size.width, _tabBarView.frame.size.height);//CGRectOffset(_tabBarView.frame, 0.0, 44.0);
		
		_tabHolderView.alpha = 0.0;
		_tabBarView.alpha = 0.0;
		
		_avatarNeededButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		_avatarNeededButton.hidden = YES;
	}];
}

- (void)_refreshProfile:(NSNotification *)notification {
	if (_avatarNeededButton != nil) {
		_avatarNeededButton.hidden = YES;
		[_avatarNeededButton removeFromSuperview];
		_avatarNeededButton = nil;
	}
}

- (void)_updateTabBarAB:(NSNotification *)notification {
	NSString *verifyTabPrefix = ([[HONAppDelegate infoForABTab] objectForKey:@"tab_asset"]);
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_nonActive", verifyTabPrefix]] forState:UIControlStateNormal];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Tapped", verifyTabPrefix]] forState:UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Active", verifyTabPrefix]] forState:UIControlStateSelected];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_Active", verifyTabPrefix]] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@_nonActive", verifyTabPrefix]] forState:UIControlStateDisabled];
}


#pragma mark - Data Tally
- (void)_updateBadges {
	NSMutableDictionary *alertTotals = [NSMutableDictionary dictionaryWithObjectsAndKeys:
													[NSNumber numberWithInt:0], @"status",
													[NSNumber numberWithInt:0], @"score",
													[NSNumber numberWithInt:0], @"comments", nil];
	
	
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 3],
							 @"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
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
				[updateChallenges addObject: @{@"id"		: [NSNumber numberWithInt:vo.challengeID],
											   @"status"	: (vo.statusID == 1 || vo.statusID == 2) ? @"created" : @"started",
											   @"score"		: [NSNumber numberWithInt:(vo.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorVO.score : ((HONOpponentVO *)[vo.challengers lastObject]).score],
											   @"comments"	: [NSNumber numberWithInt:vo.commentTotal]}];
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
			
//			if ([[alertTotals objectForKey:@"status"] intValue] > 0 || [[alertTotals objectForKey:@"score"] intValue] > 0 || [[alertTotals objectForKey:@"comments"] intValue] > 0) {
//				[self _showBadgesWithTotals:alertTotals];
//			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIChallenges, [error localizedDescription]);
	}];
}

@end
