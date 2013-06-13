//
//  HONCreateChallengeOptionsView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCreateChallengeOptionsView.h"
#import "HONAppDelegate.h"

@interface HONCreateChallengeOptionsView()
@property (nonatomic, strong) UIButton *publicButton;
@property (nonatomic, strong) UIButton *expire10MinsButton;
@property (nonatomic, strong) UIButton *expire24HoursButton;
@property (nonatomic, strong) UIButton *privateButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HONCreateChallengeOptionsView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.33];
		float offset = 64.0 + ((int)[HONAppDelegate isRetina5] * 50.0);
		
		_publicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_publicButton.frame = CGRectMake(28.0, offset, 264.0, 64.0);
		[_publicButton setBackgroundImage:[UIImage imageNamed:@"publicButton_nonActive"] forState:UIControlStateNormal];
		[_publicButton setBackgroundImage:[UIImage imageNamed:@"publicButton_Active"] forState:UIControlStateHighlighted];
		[_publicButton setBackgroundImage:[UIImage imageNamed:@"publicButton_Tapped"] forState:UIControlStateSelected];
		[_publicButton addTarget:self action:@selector(_goPublic) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_publicButton];
		
		_expire10MinsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_expire10MinsButton.frame = CGRectMake(28.0, offset + 70.0, 264.0, 64.0);
		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_nonActive"] forState:UIControlStateNormal];
		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_Active"] forState:UIControlStateHighlighted];
		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_Tapped"] forState:UIControlStateSelected];
		[_expire10MinsButton addTarget:self action:@selector(_goExpire10Mins) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_expire10MinsButton];
		
		_expire24HoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_expire24HoursButton.frame = CGRectMake(28.0, offset + 140.0, 264.0, 64.0);
		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_nonActive"] forState:UIControlStateNormal];
		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_Active"] forState:UIControlStateHighlighted];
		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_Tapped"] forState:UIControlStateSelected];
		[_expire24HoursButton addTarget:self action:@selector(_goExpire24Hours) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_expire24HoursButton];
		
		_privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_privateButton.frame = CGRectMake(28.0, offset + 210.0, 264.0, 64.0);
		[_privateButton setBackgroundImage:[UIImage imageNamed:@"privateMessage_nonActive"] forState:UIControlStateNormal];
		[_privateButton setBackgroundImage:[UIImage imageNamed:@"privateMessage_Active"] forState:UIControlStateHighlighted];
		[_privateButton setBackgroundImage:[UIImage imageNamed:@"privateMessage_Tapped"] forState:UIControlStateSelected];
		[_privateButton addTarget:self action:@selector(_goPrivate) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_privateButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(28.0, offset + 320.0, 264.0, 64.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_Active"] forState:UIControlStateHighlighted];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_Tapped"] forState:UIControlStateSelected];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		[_publicButton setSelected:YES];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goPublic {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Public"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _unselectAll];
	[_publicButton setSelected:YES];
	[self _goClose];
}

- (void)_goExpire10Mins {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Expire 10 Minutes"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _unselectAll];
	[_expire10MinsButton setSelected:YES];
	[self _goClose];
}

- (void)_goExpire24Hours {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Expire 24 Hours"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _unselectAll];
	[_expire24HoursButton setSelected:YES];
	[self _goClose];
}

- (void)_goPrivate {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Private"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _unselectAll];
	[_privateButton setSelected:YES];
	[self _goClose];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Close"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_cancelButton setSelected:YES];
	[self _goClose];
}


#pragma mark - UI Presentation
- (void)_unselectAll {
	[_publicButton setSelected:NO];
	[_expire10MinsButton setSelected:NO];
	[_expire24HoursButton setSelected:NO];
	[_privateButton setSelected:NO];
	[_cancelButton setSelected:NO];
}

- (void)_goClose {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"CLOSE_OPTIONS" object:nil];
}

@end
