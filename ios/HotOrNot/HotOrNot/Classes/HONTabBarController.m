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
#import "HONPostStatusUpdateViewController.h"

@interface HONTabBarController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITabBar *nativeTabBar;
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic, retain) UIButton *contactsButton;
@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) NSDictionary *badgeTotals;
@property(nonatomic, retain) UIView *backgroundView;
@property (strong, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong, nonatomic) UILabel *label;
@end

@implementation HONTabBarController

- (id)init {
	if ((self = [super init])) {
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toggleTabs:) name:@"TOGGLE_TABS" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_changeTab:) name:@"CHANGE_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshStarted:) name:@"REFRESH_STARTED" object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_refreshEnded:) name:@"REFRESH_ENDED" object:nil];
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_delayText: ) name:@"DELAY_TEXT"] object:nil];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//	UITableViewHeaderFooterView *footerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kSHCRecipeDetailIngredientSectionHeaderReuseIdentifier];
//	
//	UILabel *titleLabel = (UILabel *)[footerView.contentView viewWithTag:1];
//	if (titleLabel == nil) {
//		UIColor *backgroundColor = [UIColor blackColor];
//		footerView.contentView.backgroundColor = backgroundColor;
//		titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 0.0f, 300.0f, 44.0f)];
//		titleLabel.textColor = [UIColor whiteColor];
//		titleLabel.backgroundColor = backgroundColor;
//		titleLabel.shadowOffset = CGSizeMake(0.0f, 0.0f);
//		titleLabel.tag = 1;
//		titleLabel.font = [UIFont systemFontOfSize:24.0f];
//		[footerView.contentView addSubview:titleLabel];
//	}
//	
//	NSString *sectionTitle = [self.sections objectAtIndex:section];
//	if (sectionTitle == nil) {
//		sectionTitle = @"Uploaded Just Now";
//	}
//	
//	titleLabel.text = sectionTitle;
//	
//	return footerView;
//}

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
//			[_newsButton setSelected:NO];
			[_settingsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeNewsFeed:
			notificationName = @"NEWS_TAB";
			totalKey = @"newsTab";
			
			[_contactsButton setSelected:NO];
//			[_newsButton setSelected:YES];
			[_settingsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeClubs:
			notificationName = @"CLUBS_TAB";
			totalKey = @"clubsTab";
			
			[_contactsButton setSelected:NO];
//			[_newsButton setSelected:NO];
			[_settingsButton setSelected:YES];
			break;
			
		default:
			break;
	}
	
	[HONAppDelegate incTotalForCounter:totalKey];
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:[@"SELECTED_" stringByAppendingString:notificationName] object:nil];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:selectedIndex] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent)
		//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}


#pragma mark - View Lifecycle
- (void)loadView {
	
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:0] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	for (UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]])
			_nativeTabBar = (UITabBar *)view;
	}
	
	[_nativeTabBar removeFromSuperview];
		_tabHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - (kTabSize.height-3), 320.0, kTabSize.height)];
	[self.view addSubview:_tabHolderView];
	
	//UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tabMenuBackground"]];
	//bgImageView.userInteractionEnabled = YES;
	//bgImageView.frame=CGRectOffset(bgImageView.frame, 0.0, 16.0);
	//[_tabHolderView addSubview:bgImageView];
	//[bgImageView setTag:-1];
	//bgImageView.hidden = YES;
	
	//NSLog(@"---------%@",NSStringFromCGRect(bgImageView.frame));
	//bgImageView.backgroundColor=[UIColor blueColor];
	
	//_tabHolderView.frame = CGRectOffset(_tabHolderView.frame, 0.0, 25);
	_nativeTabBar.frame = CGRectOffset(_nativeTabBar.frame, 0.0, 15);
	//[self.view addSubview:_toolbar];
	[self.navigationController.view setFrame:self.view.frame];
	
//	_contactsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_contactsButton.frame = CGRectMake(0.0, -3.0, 107.0, kTabSize.height);
//	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"mainButton_nonActive"] forState:UIControlStateNormal];
//	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"mainButton_Active"] forState:UIControlStateHighlighted];
//	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"mainButton_Tapped"] forState:UIControlStateSelected];
//	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"mainButton_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
//	[_contactsButton setBackgroundImage:[UIImage imageNamed:@"mainButton_nonActive"] forState:UIControlStateDisabled];
//	[_contactsButton setTag:HONTabBarButtonTypeFriends];
//	[_contactsButton setSelected:YES];
//	[_tabHolderView addSubview:_contactsButton];
	
//	_settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_settingsButton.frame = CGRectMake(213.0, -2.0, 106.0, kTabSize.height);
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"settings_tab_Button_nonActive"] forState:UIControlStateNormal];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"settings_tab_Button_Active"] forState:UIControlStateHighlighted];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"settings_tab_Button_Tapped"] forState:UIControlStateSelected];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"settings_tab_Button_Tapped"] forState:UIControlStateHighlighted|UIControlStateSelected];
//	[_settingsButton setBackgroundImage:[UIImage imageNamed:@"settings_tab_Button_nonActive"] forState:UIControlStateDisabled];
//	[_settingsButton setTag:HONTabBarButtonTypeClubs];
//	[_tabHolderView addSubview:_settingsButton];
	
	
	[self _toggleTabButtonsEnabled:YES];
	
	_toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0,[UIScreen mainScreen].bounds.size.height - 44.0, 320.0, 44.0)];
	_toolbar.backgroundColor = [UIColor lightGrayColor];
	_label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 44.0 , 320, 44.0)];
	_label.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_toolbar];
	_label.text = @"Updated Just Now";
	_label.textAlignment = NSTextAlignmentCenter;
	_label.font=[_label.font fontWithSize:12];
	[self.view addSubview:_label];
	
	self.view.userInteractionEnabled = YES;
	_toolbar.userInteractionEnabled = YES;
	_toolbar.tintColor = [UIColor orangeColor];
	[_toolbar setItems:@[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(_goCompose:)]]];
	

}

- (void)viewDidLoad
{
	[super viewDidLoad];
}

#pragma mark - Navigation
- (void)_goCompose:(id)sender {
	NSLog(@"OMG LOOK HERE $@&$*&@#(*$&(@*$&(*@&$@&$");
	HONPostStatusUpdateViewController *postStatusViewController = [[HONPostStatusUpdateViewController alloc] init];
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:postStatusViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}


- (void)_goTabButton:(id)sender event:(UIEvent *)event {
	HONTabBarButtonType tabBarButtonType = [sender tag];
	UITouch *touch = [[event allTouches] anyObject];
	
	NSString *analyticsEventName = @"";
	NSString *notificationName = @"";
	NSString *totalKey = @"";
	
	if(tabBarButtonType == HONTabBarButtonTypeNewsFeed)
	{
		return;
	}
	
	UIViewController *selectedViewController = [self.viewControllers objectAtIndex:tabBarButtonType];
	[self.delegate tabBarController:self shouldSelectViewController:selectedViewController];
	

	
	[_contactsButton setSelected:(_contactsButton.tag == tabBarButtonType)];
//	[_newsButton setSelected:(_newsButton.tag == tabBarButtonType)];];
	[_settingsButton setSelected:(_settingsButton.tag == tabBarButtonType)];

	
	
	switch (tabBarButtonType) {
		case HONTabBarButtonTypeFriends:
			analyticsEventName = @"Main View";
			notificationName = @"CONTACTS_TAB";
			totalKey = @"friendsTab";
			
			[_contactsButton setSelected:YES];
//			[_newsButton setSelected:NO];
			[_settingsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeNewsFeed:
			analyticsEventName = @"Newsfeed";
			notificationName = @"NEWS_TAB";
			totalKey = @"newsTab";
			
			[_contactsButton setSelected:NO];
//			[_newsButton setSelected:YES];
			[_settingsButton setSelected:NO];
			break;
			
		case HONTabBarButtonTypeClubs:
			analyticsEventName = @"Settings View";
			notificationName = @"CLUBS_TAB";
			totalKey = @"clubsTab";
			
			[_contactsButton setSelected:NO];
//			[_newsButton setSelected:NO];
			[_settingsButton setSelected:YES];
			break;
			
		default:
			break;
	}
	
	
	[HONAppDelegate incTotalForCounter:totalKey];
	
	[super setSelectedIndex:tabBarButtonType];
	[self.delegate tabBarController:self didSelectViewController:selectedViewController];
		
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:tabBarButtonType] forKey:@"current_tab"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"%@_%@", (touch.tapCount == 1) ? @"SELECTED" : @"TARE", notificationName] object:nil];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"%@ - Entering", analyticsEventName]];
	
	//if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleLightContent)
		//[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark - Notifications
- (void)_toggleTabs:(NSNotification *)notification {
	if ([[notification object] isEqualToString:@"SHOW"]) {
		[UIView animateWithDuration:0.333 delay:0.0
			 usingSpringWithDamping:0.750 initialSpringVelocity:0.125
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent animations:^(void) {
								_tabHolderView.frame = CGRectOffset(_tabHolderView.frame, 0.0, -kTabSize.height);
								_nativeTabBar.frame = CGRectOffset(_nativeTabBar.frame, 0.0, -_nativeTabBar.frame.size.height);
								
								_tabHolderView.alpha = 1.0;
								_nativeTabBar.alpha = 1.0;
							} completion:^(BOOL finished) {
							}];
		
	} else {
		[UIView animateWithDuration:0.333 delay:0.0
			 usingSpringWithDamping:0.875 initialSpringVelocity:0.000
							options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent animations:^(void) {
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

//-(void) fadeOutLabels
//{
//	[UIView animateWithDuration:1.0
//						  delay:0.0
//						options:UIViewAnimationCurveEaseInOut
//					 animations:^ {
//						 _label.alpha = 0.0;
//					 }
//					 completion:^(BOOL finished) {
//						 [_label removeFromSuperview];
//					 }];
//}

- (void)_refreshStarted:(NSNotification *)notification {
	
//	[NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(fadeOutLabels:) userInfo:nil repeats:NO];
	_label.text = @"Loading...";
	
}

- (void)_refreshEnded:(NSNotification *)notification {
	_label.text = @"Updated Just Now";
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
