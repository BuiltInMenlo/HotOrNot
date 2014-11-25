//
//  HONTabBarController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIImage+ImageEffects.h"

#import "HONTabBarController.h"
#import "HONChallengeVO.h"
#import "HONComposeViewController.h"


@interface HONTabBarController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITabBar *nativeTabBar;
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, retain) UIButton *contactsButton;
@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) NSDictionary *badgeTotals;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
//		[[NSNotificationCenter defaultCenter] addObserver:self
//												 selector:@selector(_toggleTabs:)
//													 name:@"TOGGLE_TABS" object:nil];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(_changeTab:)
													 name:@"CHANGE_TAB" object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


- (void)setSelectedIndex:(NSUInteger)selectedIndex {
	[super setSelectedIndex:selectedIndex];
	
	NSLog(@"--- setSelectedIndex ---");
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:selectedIndex];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	NSString *analyticsEvent = @"";
	NSString *notificationName = @"";
	
	switch ((HONTabBarButtonType)selectedIndex) {
		case HONTabBarButtonTypeHome:
			analyticsEvent = @"Home";
			notificationName = @"HOME_TAB";
			break;
			
		case HONTabBarButtonTypeSettings:
			analyticsEvent = @"Settings";
			notificationName = @"SETTINGS_TAB";
			break;
			
		default:
			break;
	}
	
	[_contactsButton setSelected:((HONTabBarButtonType)selectedIndex == HONTabBarButtonTypeHome)];
	[_settingsButton setSelected:((HONTabBarButtonType)selectedIndex == HONTabBarButtonTypeSettings)];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Change Tabs - %@", analyticsEvent]];
	
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	[[NSNotificationCenter defaultCenter] postNotificationName:[@"SELECTED_" stringByAppendingString:notificationName] object:nil];
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	for (UIView *view in self.view.subviews) {
		view.backgroundColor = [UIColor blackColor];
		if([view isKindOfClass:[UITabBar class]])
			_nativeTabBar = (UITabBar *)view;
	}
	
	
	_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kTabSize.height, 320.0, kTabSize.height)];
	_tabHolderView.hidden = YES;
	[self.view addSubview:_tabHolderView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabMenuBackground"]];
	bgImageView.userInteractionEnabled = YES;
	[bgImageView setTag:-1];
	[_tabHolderView addSubview:bgImageView];
	
	_contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_contactsButton.frame = CGRectMake(31.0, 0.0, 107.0, kTabSize.height);
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_nonActive"] forState:UIControlStateNormal];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_Active"] forState:UIControlStateHighlighted];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_Tapped"] forState:UIControlStateSelected];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_nonActive"] forState:UIControlStateDisabled];
	[_contactsButton setTag:HONTabBarButtonTypeHome];
	[_contactsButton setSelected:YES];
	[_tabHolderView addSubview:_contactsButton];
	
	_settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_settingsButton.frame = CGRectMake(180.0, 0.0, 107.0, kTabSize.height);
	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_settingsButton_NonActive"] forState:UIControlStateNormal];
	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_settingsButton_Active"] forState:UIControlStateHighlighted];
	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_settingsButton_Tapped"] forState:UIControlStateSelected];
	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_settingsButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_settingsButton_NonActive"] forState:UIControlStateDisabled];
	[_settingsButton setTag:HONTabBarButtonTypeSettings];
	[_tabHolderView addSubview:_settingsButton];
	
	
	[self _toggleTabButtonsEnabled:YES];
	
	
	
	UIButton *composeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	composeButton.frame = CGRectMake(0.0, self.view.frame.size.height - 44.0, 320.0, 44.0);
	[composeButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
	[composeButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
	[composeButton addTarget:self action:@selector(_goCompose) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:composeButton];
}


#pragma mark - Navigation
- (void)_goTabButton:(id)sender event:(UIEvent *)event {
	HONTabBarButtonType tabBarButtonType = [sender tag];
	UITouch *touch = [[event allTouches] anyObject];
	
	NSString *analyticsEvent = @"";
	NSString *notificationName = @"";
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tabBarButtonType];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	
	switch (tabBarButtonType) {
		case HONTabBarButtonTypeHome:
			analyticsEvent = @"Home";
			notificationName = @"CONTACTS_TAB";
			break;
			
		case HONTabBarButtonTypeSettings:
			analyticsEvent = @"Settings";
			notificationName = @"SETTINGS_TAB";
			break;
			
		default:
			break;
	}
	
	
	[_contactsButton setSelected:(tabBarButtonType == HONTabBarButtonTypeHome)];
	[_settingsButton setSelected:(tabBarButtonType == HONTabBarButtonTypeSettings)];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Change Tabs %@- %@", (touch.tapCount == 1) ? @"" : @"Double Tap ", analyticsEvent]];
	
	[super setSelectedIndex:tabBarButtonType];
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@_%@", (touch.tapCount == 1) ? @"SELECTED" : @"TARE", notificationName] object:nil];
}

- (void)_goCompose {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:[[HONClubAssistant sharedInstance] clubWithClubID:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"orthodox_club"] objectForKey:@"club_id"] intValue]]]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:NO completion:nil];
}


#pragma mark - Notifications
- (void)_toggleTabs:(NSNotification *)notification {
	CGRect tabHolderFrame = CGRectMake(_tabHolderView.frame.origin.x, ([[notification object] isEqualToString:@"SHOW"]) ? ([UIScreen mainScreen].bounds.size.height - kTabSize.height) : ([UIScreen mainScreen].bounds.size.height + kTabSize.height), _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
	CGRect nativeBarFrame = CGRectMake(_tabHolderView.frame.origin.x, ([[notification object] isEqualToString:@"SHOW"]) ? ([UIScreen mainScreen].bounds.size.height - _nativeTabBar.frame.size.height) : ([UIScreen mainScreen].bounds.size.height + kTabSize.height), _nativeTabBar.frame.size.width, _nativeTabBar.frame.size.height);
	
	if ([[notification object] isEqualToString:@"SHOW"]) {
		[UIView animateWithDuration:0.333 delay:0.125
			 usingSpringWithDamping:0.800 initialSpringVelocity:0.125
							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent) animations:^(void) {
								_tabHolderView.frame = tabHolderFrame;
								_nativeTabBar.frame = nativeBarFrame;
								
								_tabHolderView.alpha = 1.0;
								_nativeTabBar.alpha = 1.0;
							} completion:^(BOOL finished) {
							}];
		
	} else {
		[UIView animateWithDuration:0.500 delay:0.125
			 usingSpringWithDamping:0.900 initialSpringVelocity:0.000
							options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionCurveEaseIn) animations:^(void) {
								_tabHolderView.frame = tabHolderFrame;
								_nativeTabBar.frame = nativeBarFrame;
								
							} completion:^(BOOL finished) {
								_tabHolderView.alpha = 0.0;
								_nativeTabBar.alpha = 0.0;
							}];
	}
}

- (void)_changeTab:(NSNotification *)notification {
	NSLog(@"Gets notification %d", [notification.object intValue]);
	[super setSelectedIndex:[notification.object intValue]];
}

#pragma mark - UI Presentation
- (void)_toggleBadges:(BOOL)isShown {
}

- (void)_toggleTabButtonsEnabled:(BOOL)isEnabled {
	if	(isEnabled) {
		for (UIButton *button in _tabHolderView.subviews) {
			if (button.tag != -1)
				[button addTarget:self action:@selector(_goTabButton:event:) forControlEvents:UIControlEventTouchUpInside];
		}
		
	} else {
		for (UIButton *button in _tabHolderView.subviews) {
			if (button.tag != -1)
				[button removeTarget:self action:@selector(_goTabButton:event:) forControlEvents:UIControlEventTouchUpInside];
		}
	}
}


#pragma mark - Data Tally
- (void)_updateBadges {
	_badgeTotals = @{@"status"		: @(0),
					 @"score"		: @(0),
					 @"comments"	: @(0)};
	
//	[[HONAPICaller sharedInstance] updateTabBarBadgeTotalsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
//		int statusChanges = 0;
//		int voteChanges = 0;
//		int commentChanges = 0;
//		
//		NSMutableArray *challenges = [NSMutableArray array];
//		for (NSDictionary *dict in result) {
//			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
//			
//			if (vo != nil)
//				[challenges addObject:vo];
//		}
//		
//		NSMutableArray *updateChallenges = [NSMutableArray array];
//		for (HONChallengeVO *vo in challenges) {
//			[updateChallenges addObject: @{@"id"		: @(vo.challengeID),
//										   @"status"	: (vo.statusID == 1 || vo.statusID == 2) ? @"created" : @"started",
//										   @"score"		: @((vo.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorVO.score : ((HONOpponentVO *)[vo.challengers lastObject]).score),
//										   @"comments"	: @(0)}];
//		}
//		
//		NSArray *localChallenges = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"];
//		for (NSDictionary *lDict in localChallenges) {
//			for (NSDictionary *uDict in updateChallenges) {
//				if ([[lDict objectForKey:@"id"] isEqual:[uDict objectForKey:@"id"]]) {
//					if ([[lDict objectForKey:@"status"] isEqualToString:@"created"] && [[uDict objectForKey:@"status"] isEqualToString:@"started"]) {
//						[_badgeTotals setValue:@(++statusChanges) forKey:@"status"];
//					}
//					
//					if ([[lDict objectForKey:@"score"] intValue] != [[uDict objectForKey:@"score"] intValue]) {
//						voteChanges += [[uDict objectForKey:@"score"] intValue] - [[lDict objectForKey:@"score"] intValue];
//						[_badgeTotals setValue:@(voteChanges) forKey:@"score"];
//					}
//					
//					if ([[lDict objectForKey:@"comments"] intValue] != [[uDict objectForKey:@"comments"] intValue]) {
//						commentChanges += [[uDict objectForKey:@"comments"] intValue] - [[lDict objectForKey:@"comments"] intValue];
//						[_badgeTotals setValue:@(commentChanges) forKey:@"comments"];
//					}
//				}
//			}
//		}
//		
//		if ([localChallenges count] < [updateChallenges count])
//			[_badgeTotals setValue:@([[_badgeTotals objectForKey:@"status"] intValue] + ([updateChallenges count] - [localChallenges count])) forKey:@"status"];
//		
//		[[NSUserDefaults standardUserDefaults] setValue:updateChallenges forKey:@"update_challenges"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
//		
//		//NSLog(@"CHANGES:\n%@", badgeTotals);
//		if ([[_badgeTotals objectForKey:@"status"] intValue] > 0 || [[_badgeTotals objectForKey:@"score"] intValue] > 0 || [[_badgeTotals objectForKey:@"comments"] intValue] > 0)
//			[self _toggleBadges:YES];
//	}];
}


@end
