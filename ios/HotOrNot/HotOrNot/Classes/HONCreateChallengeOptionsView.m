//
//  HONCreateChallengeOptionsView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCreateChallengeOptionsView.h"


@interface HONCreateChallengeOptionsView()
@property (nonatomic, strong) UIButton *publicButton;
@property (nonatomic, strong) UIButton *randomButton;
@property (nonatomic, strong) UIButton *expire10MinsButton;
@property (nonatomic, strong) UIButton *expire24HoursButton;
@property (nonatomic, strong) UIButton *privateButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HONCreateChallengeOptionsView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"typeOverlay"]];
		bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, self.frame.size.height - 422.0);
		bgImageView.userInteractionEnabled = YES;
		[self addSubview:bgImageView];
		
		float offset = 30.0;
		_publicButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_publicButton.frame = CGRectMake(28.0, offset, 264.0, 64.0);
		[_publicButton setBackgroundImage:[UIImage imageNamed:@"publicVolley_nonActive"] forState:UIControlStateNormal];
		[_publicButton setBackgroundImage:[UIImage imageNamed:@"publicVolley_Active"] forState:UIControlStateHighlighted];
		[_publicButton addTarget:self action:@selector(_goPublic) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_publicButton];
		
		_randomButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_randomButton.frame = CGRectMake(28.0, offset + 80.0, 264.0, 64.0);
		[_randomButton setBackgroundImage:[UIImage imageNamed:@"randomVolley_nonActive"] forState:UIControlStateNormal];
		[_randomButton setBackgroundImage:[UIImage imageNamed:@"randomVolley_Active"] forState:UIControlStateHighlighted];
		[_randomButton addTarget:self action:@selector(_goRandom) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_randomButton];
		
		_privateButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_privateButton.frame = CGRectMake(28.0, offset + 160.0, 264.0, 64.0);
		[_privateButton setBackgroundImage:[UIImage imageNamed:@"privateVolley_nonActive"] forState:UIControlStateNormal];
		[_privateButton setBackgroundImage:[UIImage imageNamed:@"privateVolley_Active"] forState:UIControlStateHighlighted];
		[_privateButton addTarget:self action:@selector(_goPrivate) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_privateButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(28.0, offset + 270.0, 264.0, 64.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_cancelButton];

		
//		_expire10MinsButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_expire10MinsButton.frame = CGRectMake(28.0, offset + 70.0, 264.0, 64.0);
//		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_nonActive"] forState:UIControlStateNormal];
//		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_Active"] forState:UIControlStateHighlighted];
//		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_Tapped"] forState:UIControlStateSelected];
//		[_expire10MinsButton addTarget:self action:@selector(_goExpire10Mins) forControlEvents:UIControlEventTouchUpInside];
//		[bgImageView addSubview:_expire10MinsButton];
//
//		_expire24HoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_expire24HoursButton.frame = CGRectMake(28.0, offset + 140.0, 264.0, 64.0);
//		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_nonActive"] forState:UIControlStateNormal];
//		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_Active"] forState:UIControlStateHighlighted];
//		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_Tapped"] forState:UIControlStateSelected];
//		[_expire24HoursButton addTarget:self action:@selector(_goExpire24Hours) forControlEvents:UIControlEventTouchUpInside];
//		[bgImageView addSubview:_expire24HoursButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goPublic {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Public"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate challengeOptionsViewMakePublic:self];
	[self _goClose];
}

- (void)_goRandom {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Random"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate challengeOptionsViewMakeRandom:self];
	[self _goClose];
}

- (void)_goPrivate {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Private"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate challengeOptionsViewMakePrivate:self];
	[self _goClose];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Cancel"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _goClose];
}


//- (void)_goExpire10Mins {
//	[[Mixpanel sharedInstance] track:@"Create Snap Options - Expire 10 Minutes"
//						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//	
//	[self _unselectAll];
//	[_expire10MinsButton setSelected:YES];
//	[self _goClose];
//}
//
//- (void)_goExpire24Hours {
//	[[Mixpanel sharedInstance] track:@"Create Snap Options - Expire 24 Hours"
//						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//	
//	[self _unselectAll];
//	[_expire24HoursButton setSelected:YES];
//	[self _goClose];
//}


#pragma mark - UI Presentation
- (void)_unselectAll {
	[_publicButton setSelected:NO];
	[_expire10MinsButton setSelected:NO];
	[_expire24HoursButton setSelected:NO];
	[_privateButton setSelected:NO];
	[_cancelButton setSelected:NO];
}

- (void)_goClose {
	[self.delegate challengeOptionsViewClose:self];
}

@end
