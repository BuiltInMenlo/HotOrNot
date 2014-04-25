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
#import "HONAPICaller.h"
#import "HONImagingDepictor.h"
#import "HONChallengeVO.h"
#import "HONChangeAvatarViewController.h"

const CGSize kTabSize = {80.0, 50.0};

@interface HONTabBarController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITabBar *nativeTabBar;
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, retain) UIButton *contactsButton;
@property (nonatomic, retain) UIButton *clubsButton;
@property (nonatomic, retain) UIButton *verifyButton;
@property (nonatomic, retain) NSDictionary *badgeTotals;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toggleTabs:) name:@"TOGGLE_TABS" object:nil];
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
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateNormal];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateHighlighted];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Tapped"] forState:UIControlStateSelected];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateDisabled];
	[_contactsButton setTag:HONTabBarButtonTypeContacts];
	[_contactsButton setSelected:YES];
	[_tabHolderView addSubview:_contactsButton];
	
	_clubsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clubsButton.frame = CGRectMake(107.0, 0.0, 106.0, kTabSize.height);
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_nonActive"] forState:UIControlStateNormal];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Active"] forState:UIControlStateHighlighted];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Tapped"] forState:UIControlStateSelected];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_nonActive"] forState:UIControlStateDisabled];
	[_clubsButton setTag:HONTabBarButtonTypeClubs];
	[_tabHolderView addSubview:_clubsButton];
	
	_verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_verifyButton.frame = CGRectMake(213.0, 0.0, 107.0, kTabSize.height);
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_nonActive"] forState:UIControlStateNormal];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_Active"] forState:UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_Tapped"] forState:UIControlStateSelected];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_nonActive"] forState:UIControlStateDisabled];
	[_verifyButton setTag:HONTabBarButtonTypeVerify];
	[_tabHolderView addSubview:_verifyButton];
	
	
	[self _toggleTabButtonsEnabled:YES];
}


#pragma mark - Navigation
- (void)_goTabButton:(id)sender event:(UIEvent *)event {
	HONTabBarButtonType tarBarButtonType = [sender tag];
	UITouch *touch = [[event allTouches] anyObject];
	
	NSString *mpEvent = @"";
	NSString *notificationName = @"";
	NSString *totalKey = @"";
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tarBarButtonType];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	
	
	switch (tarBarButtonType) {
		case HONTabBarButtonTypeContacts:
			totalKey = @"contacts";
			mpEvent = @"Contacts";
			notificationName = @"CONTACTS_TAB";
			
			[_contactsButton setSelected:YES];
			[_clubsButton setSelected:NO];
			[_verifyButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeClubs:
			totalKey = @"clubs";
			mpEvent = @"Clubs";
			notificationName = @"CLUBS_TAB";
			
			[_contactsButton setSelected:NO];
			[_clubsButton setSelected:YES];
			[_verifyButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeVerify:
			totalKey = @"verify";
			mpEvent = @"Verify";
			notificationName = @"VERIFY_TAB";
			
			[_contactsButton setSelected:NO];
			[_clubsButton setSelected:NO];
			[_verifyButton setSelected:YES];
			break;
			
		default:
			break;
	}
	
	
	[[HONAnalyticsParams sharedInstance] trackEventWithUserProperty:[NSString stringWithFormat:@"Tab Bar %@ - %@", (touch.tapCount == 1) ? @"Select" : @"Double Tap", mpEvent]];
	[HONAppDelegate incTotalForCounter:totalKey];
	
//	selectedViewController.view.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	self.selectedIndex = tarBarButtonType;
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@_%@", (touch.tapCount == 1) ? @"SELECTED" : @"TARE", notificationName] object:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tarBarButtonType] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
	
	[[HONAPICaller sharedInstance] updateTabBarBadgeTotalsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		int statusChanges = 0;
		int voteChanges = 0;
		int commentChanges = 0;
		
		NSMutableArray *challenges = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
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
