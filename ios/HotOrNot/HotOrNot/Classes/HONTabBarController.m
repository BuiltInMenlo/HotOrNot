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
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, strong) UIView *tabBarView;
@property (nonatomic, retain) UIButton *homeButton;
@property (nonatomic, retain) UIButton *clubsButton;
@property (nonatomic, retain) UIButton *activityButton;
@property (nonatomic, retain) UIButton *verifyButton;
@property (nonatomic, retain) UIButton *avatarNeededButton;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
//		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toggleTabs:) name:@"TOGGLE_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_updateWithActivityTab:) name:@"UPDATE_WITH_ACTIVITY_TAB" object:nil];
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
	
//	[self _createPopoverBadge];
}

#pragma mark - UI Presentation
-(void)_addCustomTabs {
	_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - kTabSize.height, 320.0, kTabSize.height)];
	[self.view addSubview:_tabHolderView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabMenuBackground"]];
	bgImageView.userInteractionEnabled = YES;
	[_tabHolderView addSubview:bgImageView];
	[bgImageView setTag:-1];
	bgImageView.hidden = YES;
	
	_homeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_homeButton.frame = CGRectMake(0.0, 0.0, 107.0, kTabSize.height);
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateNormal];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Tapped"] forState:UIControlStateHighlighted];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateSelected];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_homeButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_homeButton_nonActive"] forState:UIControlStateDisabled];
	[_tabHolderView addSubview:_homeButton];
	[_homeButton setTag:HONTabBarButtonTypeHome];
	
	_clubsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_clubsButton.frame = CGRectMake(107.0, 0.0, 106.0, kTabSize.height);
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_nonActive"] forState:UIControlStateNormal];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Tapped"] forState:UIControlStateHighlighted];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Active"] forState:UIControlStateSelected];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_clubsButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_clubsButton_nonActive"] forState:UIControlStateDisabled];
	[_tabHolderView addSubview:_clubsButton];
	[_clubsButton setTag:HONTabBarButtonTypeClubs];
	
//	_activityButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_activityButton.frame = CGRectMake(kTabSize.width * 2.0, 0.0, kTabSize.width, kTabSize.height);
//	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_nonActive"] forState:UIControlStateNormal];
//	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Tapped"] forState:UIControlStateHighlighted];
//	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Active"] forState:UIControlStateSelected];
//	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
//	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_nonActive"] forState:UIControlStateDisabled];
//	[_tabHolderView addSubview:_activityButton];
//	[_activityButton setTag:HONTabBarButtonTypeActivity];
	
	
	_verifyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_verifyButton.frame = CGRectMake(213.0, 0.0, 107.0, kTabSize.height);
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_nonActive"] forState:UIControlStateNormal];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_Tapped"] forState:UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_Active"] forState:UIControlStateSelected];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_verifyButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_verifyButton_nonActive"] forState:UIControlStateDisabled];
	[_tabHolderView addSubview:_verifyButton];
	[_verifyButton setTag:HONTabBarButtonTypeVerify];
	
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
				[button addTarget:self action:@selector(_goTabButton:event:) forControlEvents:UIControlEventTouchUpInside];
		}
		
	} else {
		for (UIButton *button in _tabHolderView.subviews) {
			if (button.tag != -1)
				[button removeTarget:self action:@selector(_goTabButton:event:) forControlEvents:UIControlEventTouchUpInside];
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
- (void)_goTabButton:(id)sender event:(UIEvent *)event {
	HONTabBarButtonType tarBarButtonType = [sender tag];
	
//	UITouch *touch = [[event allTouches] anyObject];
	
	NSString *mpEvent = @"";
	NSString *notificationName = @"";
	NSString *totalKey = @"";
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tarBarButtonType];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];

	
	switch (tarBarButtonType) {
		case HONTabBarButtonTypeHome:
			totalKey = @"timeline";
			mpEvent = @"Timeline";
			notificationName = @"HOME_TAB";
			
			[_homeButton setSelected:YES];
			[_clubsButton setSelected:NO];
			[_activityButton setSelected:NO];
			[_verifyButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeClubs:
			totalKey = @"clubs";
			mpEvent = @"Clubs";
			notificationName = @"CLUBS_TAB";
			
			[_homeButton setSelected:NO];
			[_clubsButton setSelected:YES];
			[_activityButton setSelected:NO];
			[_verifyButton setSelected:NO];
			break;
			
//		case HONTabBarButtonTypeActivity:
//			totalKey = @"alerts";
//			mpEvent = @"Alerts";
//			notificationName = @"ALERTS_TAB";
//			
//			[_homeButton setSelected:NO];
//			[_clubsButton setSelected:NO];
//			[_activityButton setSelected:YES];
//			[_verifyButton setSelected:NO];
//			
//			[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_nonActive"] forState:UIControlStateNormal];
//			[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Tapped"] forState:UIControlStateHighlighted];
//			[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Active"] forState:UIControlStateSelected];
//			[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
//			[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButton_nonActive"] forState:UIControlStateDisabled];
//			break;
			
		case HONTabBarButtonTypeVerify:
			totalKey = @"verify";
			mpEvent = @"Verify";
			notificationName = @"VERIFY_TAB";
			
			[_homeButton setSelected:NO];
			[_clubsButton setSelected:NO];
			[_activityButton setSelected:NO];
			[_verifyButton setSelected:YES];
			break;
			
		default:
			break;
	}
	
//	if (touch.tapCount == 1) {
		mpEvent = [@"Tab Bar - " stringByAppendingString:mpEvent];
		notificationName = [@"SELECTED_" stringByAppendingString:notificationName];
		
//	} else {
//		mpEvent = [@"Tab Bar Double Tap - " stringByAppendingString:mpEvent];
//		notificationName = [@"TARE_" stringByAppendingString:notificationName];
//	}
	
	[[Mixpanel sharedInstance] track:mpEvent properties:@{@"user"	: [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]]}];
	
	[HONAppDelegate incTotalForCounter:totalKey];
	[[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:nil];
	self.selectedIndex = tarBarButtonType;
	
	selectedViewController.view.frame = CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tarBarButtonType] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}


#pragma mark - Notifications
- (void)_toggleTabs:(NSNotification *)notification {
	if ([[notification object] isEqualToString:@"SHOW"]) {
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
		
	} else {
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
}

- (void)_updateWithActivityTab:(NSNotification *)notification {
	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButtonUpdate_nonActive"] forState:UIControlStateNormal];
	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButtonUpdate_Tapped"] forState:UIControlStateHighlighted];
	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButtonUpdate_Active"] forState:UIControlStateSelected];
	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButtonUpdate_Active"] forState:UIControlStateSelected|UIControlStateHighlighted];
	[_activityButton setBackgroundImage:[UIImage imageNamed:@"tabMenu_activityButtonUpdate_nonActive"] forState:UIControlStateDisabled];
}


#pragma mark - Data Tally
- (void)_updateBadges {
	NSDictionary *alertTotals = @{@"status"		: [NSNumber numberWithInt:0],
								  @"score"		: [NSNumber numberWithInt:0],
								  @"comments"	: [NSNumber numberWithInt:0]};
	
	[[HONAPICaller sharedInstance] updateTabBarBadgeTotalsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
		int statusChanges = 0;
		int voteChanges = 0;
		int commentChanges = 0;
		
		NSMutableArray *challenges = [NSMutableArray array];
		for (NSDictionary *dict in (NSArray *)result) {
			HONChallengeVO *vo = [HONChallengeVO challengeWithDictionary:dict];
			
			if (vo != nil)// && (vo.statusID == 1 && vo.creatorID != [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]))
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
		
		if ([localChallenges count] < [updateChallenges count])
			[alertTotals setValue:[NSNumber numberWithInt:[[alertTotals objectForKey:@"status"] intValue] + ([updateChallenges count] - [localChallenges count])] forKey:@"status"];
		
		[[NSUserDefaults standardUserDefaults] setValue:updateChallenges forKey:@"update_challenges"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		//NSLog(@"CHANGES:\n%@", alertTotals);
		
//		if ([[alertTotals objectForKey:@"status"] intValue] > 0 || [[alertTotals objectForKey:@"score"] intValue] > 0 || [[alertTotals objectForKey:@"comments"] intValue] > 0)
//			[self _showBadgesWithTotals:alertTotals];
	}];
}

@end
