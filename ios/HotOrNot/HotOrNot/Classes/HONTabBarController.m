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
#import "HONChangeAvatarViewController.h"

const CGSize kTabSize = {80.0, 50.0};

@interface HONTabBarController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITabBar *nativeTabBar;
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, retain) UIButton *contactsButton;
@property (nonatomic, retain) UIButton *clubsButton;
@property (nonatomic, retain) UIButton *newsButton;
@property (nonatomic, retain) NSDictionary *badgeTotals;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toggleTabs:) name:@"TOGGLE_TABS" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeTab:) name:@"CHANGE_TAB" object:nil];
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
	
	NSString *notificationName = @"";
	NSString *totalKey = @"";
	
	switch ((HONTabBarButtonType)selectedIndex) {
		case HONTabBarButtonTypeFriends:
			notificationName = @"CONTACTS_TAB";
			totalKey = @"friendsTab";
			
			[_contactsButton setSelected:YES];
			[_newsButton setSelected:NO];
			[_clubsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeNewsFeed:
			notificationName = @"NEWS_TAB";
			totalKey = @"newsTab";
			
			[_contactsButton setSelected:NO];
			[_newsButton setSelected:YES];
			[_clubsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeClubs:
			notificationName = @"CLUBS_TAB";
			totalKey = @"clubsTab";
			
			[_contactsButton setSelected:NO];
			[_newsButton setSelected:NO];
			[_clubsButton setSelected:YES];
			break;
			
		default:
			break;
	}
	
	[HONAppDelegate incTotalForCounter:totalKey];
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	
//	[[UIApplication sharedApplication] setStatusBarStyle:(selectedIndex == HONTabBarButtonTypeVerify) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault animated:YES];
	[[NSNotificationCenter defaultCenter] postNotificationName:[@"SELECTED_" stringByAppendingString:notificationName] object:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:selectedIndex] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	for (UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]])
			_nativeTabBar = (UITabBar *)view;
	}
	
	
	_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kTabSize.height, 320.0, kTabSize.height)];
	[self.view addSubview:_tabHolderView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabMenuBackground"]];
	bgImageView.userInteractionEnabled = YES;
	[_tabHolderView addSubview:bgImageView];
	[bgImageView setTag:-1];
	bgImageView.hidden = YES;
	
	_contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_contactsButton.frame = CGRectMake(0.0, 0.0, 107.0, kTabSize.height);
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_nonActive"] forState:UIControlStateNormal];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_Active"] forState:UIControlStateHighlighted];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_Tapped"] forState:UIControlStateSelected];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_friendsButton_nonActive"] forState:UIControlStateDisabled];
	[_contactsButton setTag:HONTabBarButtonTypeFriends];
	[_contactsButton setSelected:YES];
	[_tabHolderView addSubview:_contactsButton];
	
	_newsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_newsButton.frame = CGRectMake(107.0, 0.0, 107.0, kTabSize.height);
	[_newsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_newsButton_nonActive"] forState:UIControlStateNormal];
	[_newsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_newsButton_Active"] forState:UIControlStateHighlighted];
	[_newsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_newsButton_Tapped"] forState:UIControlStateSelected];
	[_newsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_newsButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_newsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_newsButton_nonActive"] forState:UIControlStateDisabled];
	[_newsButton setTag:HONTabBarButtonTypeNewsFeed];
	[_tabHolderView addSubview:_newsButton];
	
	_clubsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clubsButton.frame = CGRectMake(213.0, 0.0, 106.0, kTabSize.height);
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_nonActive"] forState:UIControlStateNormal];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Active"] forState:UIControlStateHighlighted];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Tapped"] forState:UIControlStateSelected];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_nonActive"] forState:UIControlStateDisabled];
	[_clubsButton setTag:HONTabBarButtonTypeClubs];
	[_tabHolderView addSubview:_clubsButton];
	
	
	[self _toggleTabButtonsEnabled:YES];
}


#pragma mark - Navigation
- (void)_goTabButton:(id)sender event:(UIEvent *)event {
	HONTabBarButtonType tabBarButtonType = [sender tag];
	UITouch *touch = [[event allTouches] anyObject];
	
	NSString *analyticsEventName = @"";
	NSString *notificationName = @"";
	NSString *totalKey = @"";
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tabBarButtonType];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	
	switch (tabBarButtonType) {
		case HONTabBarButtonTypeFriends:
			analyticsEventName = @"Friends";
			notificationName = @"CONTACTS_TAB";
			totalKey = @"friendsTab";
			
			[_contactsButton setSelected:YES];
			[_newsButton setSelected:NO];
			[_clubsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeNewsFeed:
			analyticsEventName = @"News";
			notificationName = @"NEWS_TAB";
			totalKey = @"newsTab";
			
			[_contactsButton setSelected:NO];
			[_newsButton setSelected:YES];
			[_clubsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeClubs:
			analyticsEventName = @"Clubs";
			notificationName = @"CLUBS_TAB";
			totalKey = @"clubsTab";
			
			[_contactsButton setSelected:NO];
			[_newsButton setSelected:NO];
			[_clubsButton setSelected:YES];
			break;
			
		default:
			break;
	}
	
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Tab Bar %@ - %@", (touch.tapCount == 1) ? @"Select" : @"Double Tap", analyticsEventName]];
	[HONAppDelegate incTotalForCounter:totalKey];
	
	[super setSelectedIndex:tabBarButtonType];
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
		
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tabBarButtonType] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@_%@", (touch.tapCount == 1) ? @"SELECTED" : @"TARE", notificationName] object:nil];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
//	[[UIApplication sharedApplication] setStatusBarStyle:(tabBarButtonType == HONTabBarButtonTypeVerify) ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault animated:YES];
	
//	UIStatusBarStyle statusBarStyle = [UIApplication sharedApplication].statusBarStyle;
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark - Notifications
- (void)_toggleTabs:(NSNotification *)notification {
	if ([[notification object] isEqualToString:@"SHOW"]) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tabHolderView.frame = CGRectOffset(_tabHolderView.frame, 0.0, -kTabSize.height);
			_nativeTabBar.frame = CGRectOffset(_nativeTabBar.frame, 0.0, -_nativeTabBar.frame.size.height);
			
			_tabHolderView.alpha = 1.0;
			_nativeTabBar.alpha = 1.0;
			
		} completion:^(BOOL finished) {
		}];
		
	} else {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tabHolderView.frame = CGRectOffset(_tabHolderView.frame, 0.0, kTabSize.height);
			_nativeTabBar.frame = CGRectOffset(_nativeTabBar.frame, 0.0, _nativeTabBar.frame.size.height);
			
			_tabHolderView.alpha = 0.0;
			_nativeTabBar.alpha = 0.0;
			
		} completion:^(BOOL finished) {
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
	_badgeTotals = @{@"status"		: [NSNumber numberWithInt:0],
					 @"score"		: [NSNumber numberWithInt:0],
					 @"comments"	: [NSNumber numberWithInt:0]};
	
	[[HONAPICaller sharedInstance] updateTabBarBadgeTotalsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSArray *result) {
		int statusChanges = 0;
		int voteChanges = 0;
		int commentChanges = 0;
		
		NSMutableArray *challenges = [NSMutableArray array];
		for (NSDictionary *dict in result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			
			if (vo != nil)
				[challenges addObject:vo];
		}
		
		NSMutableArray *updateChallenges = [NSMutableArray array];
		for (HONChallengeVO *vo in challenges) {
			[updateChallenges addObject: @{@"id"		: [NSNumber numberWithInt:vo.challengeID],
										   @"status"	: (vo.statusID == 1 || vo.statusID == 2) ? @"created" : @"started",
										   @"score"		: [NSNumber numberWithInt:(vo.creatorVO.userID == [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]) ? vo.creatorVO.score : ((HONOpponentVO *)[vo.challengers lastObject]).score],
										   @"comments"	: [NSNumber numberWithInt:0]}];
		}
		
		NSArray *localChallenges = [[NSUserDefaults standardUserDefaults] objectForKey:@"local_challenges"];
		for (NSDictionary *lDict in localChallenges) {
			for (NSDictionary *uDict in updateChallenges) {
				if ([[lDict objectForKey:@"id"] isEqual:[uDict objectForKey:@"id"]]) {
					if ([[lDict objectForKey:@"status"] isEqualToString:@"created"] && [[uDict objectForKey:@"status"] isEqualToString:@"started"]) {
						[_badgeTotals setValue:[NSNumber numberWithInt:++statusChanges] forKey:@"status"];
					}
					
					if ([[lDict objectForKey:@"score"] intValue] != [[uDict objectForKey:@"score"] intValue]) {
						voteChanges += [[uDict objectForKey:@"score"] intValue] - [[lDict objectForKey:@"score"] intValue];
						[_badgeTotals setValue:[NSNumber numberWithInt:voteChanges] forKey:@"score"];
					}
					
					if ([[lDict objectForKey:@"comments"] intValue] != [[uDict objectForKey:@"comments"] intValue]) {
						commentChanges += [[uDict objectForKey:@"comments"] intValue] - [[lDict objectForKey:@"comments"] intValue];
						[_badgeTotals setValue:[NSNumber numberWithInt:commentChanges] forKey:@"comments"];
					}
				}
			}
		}
		
		if ([localChallenges count] < [updateChallenges count])
			[_badgeTotals setValue:[NSNumber numberWithInt:[[_badgeTotals objectForKey:@"status"] intValue] + ([updateChallenges count] - [localChallenges count])] forKey:@"status"];
		
		[[NSUserDefaults standardUserDefaults] setValue:updateChallenges forKey:@"update_challenges"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		//NSLog(@"CHANGES:\n%@", badgeTotals);
		if ([[_badgeTotals objectForKey:@"status"] intValue] > 0 || [[_badgeTotals objectForKey:@"score"] intValue] > 0 || [[_badgeTotals objectForKey:@"comments"] intValue] > 0)
			[self _toggleBadges:YES];
	}];
}


@end
