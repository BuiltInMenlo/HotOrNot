//
//  HONTabBarController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.04.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONTabBarController.h"
#import "Facebook.h"
#import "Mixpanel.h"

#import "HONAppDelegate.h"

@interface HONTabBarController ()
@property (nonatomic) int challengeHits;
@property (nonatomic) BOOL hasVisitedSettings;
@property (nonatomic, strong) UIView *tabHolderView;
@property (nonatomic) CGPoint touchPt;
@end

@implementation HONTabBarController

@synthesize btn1, btn2, btn3, btn4, btn5;
@synthesize challengeHits;
@synthesize hasVisitedSettings;

- (id)init {
	if ((self = [super init])) {
		self.challengeHits = 0;
		self.hasVisitedSettings = [[[NSUserDefaults standardUserDefaults] objectForKey:@"shown_settings"] isEqualToString:@"YES"];
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
	
	if ([touch view] == _tabHolderView)
		_touchPt = CGPointMake(_tabHolderView.center.x - location.x, _tabHolderView.center.y - location.y);
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
		[UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^(void) {
			_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - (kTabButtonHeight * 2.0), _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
		} completion:^(BOOL finished) {
		}];
		
	} else {
		[UIView animateWithDuration:0.125 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^(void) {
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
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}


#pragma mark - Presentation
- (void)hideTabBar {
	for(UIView *view in self.view.subviews) {
		if([view isKindOfClass:[UITabBar class]]) {
			view.hidden = YES;
			break;
		}
	}
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
	
	
//	UISwipeGestureRecognizer *oneFingerSwipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeUp:)];
//	[oneFingerSwipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
//	[self.view addGestureRecognizer:oneFingerSwipeUp];
//	
//	UISwipeGestureRecognizer *oneFingerSwipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(oneFingerSwipeDown:)];
//	[oneFingerSwipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
//	[self.view addGestureRecognizer:oneFingerSwipeDown];
}


#pragma mark - Button Handlers
- (void)buttonClicked:(id)sender {
	int tagNum = [sender tag];
	[self selectTab:tagNum];
}

- (void)selectTab:(int)tabID {
	[self.delegate tabBarController:self shouldSelectViewController:[self.viewControllers objectAtIndex:tabID]];
	
	switch(tabID) {
		case 0:
			self.challengeHits++;
			
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
			
			if (!self.hasVisitedSettings && ![HONAppDelegate allowsFBPosting]) {
				self.hasVisitedSettings = YES;
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"shown_settings"];
				[[NSUserDefaults standardUserDefaults] synchronize];
			}
			
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
		if (tabID == 0)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
		
		else if (tabID == 1)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CHALLENGES_TAB" object:nil];
		
		else if (tabID == 3)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_POPULAR_TAB" object:nil];
		
		else if (tabID == 4)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SETTINGS_TAB" object:nil];
		
		self.selectedIndex = tabID;
	}
	
	[self.delegate tabBarController:self didSelectViewController:[self.viewControllers objectAtIndex:tabID]];
	[[NSNotificationCenter defaultCenter] postNotificationName:HONSessionStateChangedNotification object:FBSession.activeSession];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"HIDE_SEARCH_RESULTS" object:nil];
}


#pragma mark - GestureRecognizer Handlers
- (void)oneFingerSwipeUp:(UISwipeGestureRecognizer *)recognizer {
	CGPoint point = [recognizer locationInView:[self view]];
	NSLog(@"Swipe up - start location: %f,%f", point.x, point.y);
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - (kTabButtonHeight * 2.0), _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
	}];
}

- (void)oneFingerSwipeDown:(UISwipeGestureRecognizer *)recognizer {
	CGPoint point = [recognizer locationInView:[self view]];
	NSLog(@"Swipe down - start location: %f,%f", point.x, point.y);
	[UIView animateWithDuration:0.125 animations:^(void) {
		_tabHolderView.frame = CGRectMake(_tabHolderView.frame.origin.x, self.view.frame.size.height - kTabButtonHeight, _tabHolderView.frame.size.width, _tabHolderView.frame.size.height);
	}];
}

@end
