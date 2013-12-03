//
//  HONCreateChallengeOptionsView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.12.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONCreateChallengeOptionsView.h"


@interface HONCreateChallengeOptionsView()
@property (nonatomic, strong) UIButton *nonExpireButton;
@property (nonatomic, strong) UIButton *expire10MinsButton;
@property (nonatomic, strong) UIButton *expire24HoursButton;
@property (nonatomic, strong) UIImageView *publicPrivateImageView;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HONCreateChallengeOptionsView
@synthesize delegate = _delegate;
@synthesize expireType = _expireType;
@synthesize isPrivate = _isPrivate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"typeOverlay"]];
		bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, self.frame.size.height - 422.0);
		bgImageView.userInteractionEnabled = YES;
		[self addSubview:bgImageView];
		
		_isPrivate = NO;
		
		float offset = 30.0;
		_nonExpireButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_nonExpireButton.frame = CGRectMake(28.0, offset, 264.0, 64.0);
		[_nonExpireButton setBackgroundImage:[UIImage imageNamed:@"foreverButton_nonActive"] forState:UIControlStateNormal];
		[_nonExpireButton setBackgroundImage:[UIImage imageNamed:@"foreverButton_Tapped"] forState:UIControlStateHighlighted];
		[_nonExpireButton setBackgroundImage:[UIImage imageNamed:@"foreverButton_Active"] forState:UIControlStateSelected];
		[_nonExpireButton addTarget:self action:@selector(_goNonExpire) forControlEvents:UIControlEventTouchUpInside];
		[_nonExpireButton setSelected:YES];
		[bgImageView addSubview:_nonExpireButton];
		
		_expire10MinsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_expire10MinsButton.frame = CGRectMake(28.0, offset + 80.0, 264.0, 64.0);
		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_nonActive"] forState:UIControlStateNormal];
		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_Tapped"] forState:UIControlStateHighlighted];
		[_expire10MinsButton setBackgroundImage:[UIImage imageNamed:@"expire10mins_Active"] forState:UIControlStateSelected];
		[_expire10MinsButton addTarget:self action:@selector(_goExpire10Mins) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_expire10MinsButton];
		
		_expire24HoursButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_expire24HoursButton.frame = CGRectMake(28.0, offset + 160.0, 264.0, 64.0);
		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_nonActive"] forState:UIControlStateNormal];
		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_Tapped"] forState:UIControlStateHighlighted];
		[_expire24HoursButton setBackgroundImage:[UIImage imageNamed:@"expire24hours_Active"] forState:UIControlStateSelected];
		[_expire24HoursButton addTarget:self action:@selector(_goExpire24Hours) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_expire24HoursButton];
		
		UILabel *privateLabel = [[UILabel alloc] initWithFrame:CGRectMake(95.0, offset + 259.0, 180.0, 24.0)];
		privateLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:24];
		privateLabel.textColor = [UIColor whiteColor];
		privateLabel.backgroundColor = [UIColor clearColor];
		privateLabel.text = @"Private:";
		[bgImageView addSubview:privateLabel];
		
		_publicPrivateImageView = [[UIImageView alloc] initWithFrame:CGRectMake(178.0, offset + 240.0, 114.0, 64.0)];
		_publicPrivateImageView.image = [UIImage imageNamed:(_isPrivate) ? @"onPrivateMessage_" : @"offPrivateMessage_"];
		[bgImageView addSubview:_publicPrivateImageView];
		
		UIButton *publicPrivateToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
		publicPrivateToggleButton.frame = _publicPrivateImageView.frame;
		[publicPrivateToggleButton addTarget:self action:@selector(_goPublicPrivateToggle) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:publicPrivateToggleButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(28.0, offset + 320.0, 264.0, 64.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_cancelButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setExpireType:(HONChallengeExpireType)expireType {
	_expireType = expireType;
	
	if (expireType == HONChallengeExpireTypeNone) {
		[_nonExpireButton setSelected:YES];
		[_expire10MinsButton setSelected:NO];
		[_expire24HoursButton setSelected:NO];
		
	} else if (expireType == HONChallengeExpireType10Minutes) {
		[_nonExpireButton setSelected:NO];
		[_expire10MinsButton setSelected:YES];
		[_expire24HoursButton setSelected:NO];
		
	} else if (expireType == HONChallengeExpireType24Hours) {
		[_nonExpireButton setSelected:NO];
		[_expire10MinsButton setSelected:NO];
		[_expire24HoursButton setSelected:YES];
	}
}

- (void)setIsPrivate:(BOOL)isPrivate {
	_isPrivate = isPrivate;
	_publicPrivateImageView.image = [UIImage imageNamed:(_isPrivate) ? @"onPrivateMessage_" : @"offPrivateMessage_"];
}


#pragma mark - Navigation
- (void)_goNonExpire {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Non Expire"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_nonExpireButton setSelected:YES];
	[_expire10MinsButton setSelected:NO];
	[_expire24HoursButton setSelected:NO];
	[self.delegate challengeOptionsViewMakeNonExpire:self];
	[self _goClose];
}

- (void)_goExpire10Mins {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Expire 10 Minutes"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_nonExpireButton setSelected:NO];
	[_expire10MinsButton setSelected:YES];
	[_expire24HoursButton setSelected:NO];
	[self.delegate challengeOptionsViewExpire10Minutes:self];
	[self _goClose];
}

- (void)_goExpire24Hours {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Expire 24 Hours"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_nonExpireButton setSelected:NO];
	[_expire10MinsButton setSelected:NO];
	[_expire24HoursButton setSelected:YES];
	[self.delegate challengeOptionsViewExpire24Hours:self];
	[self _goClose];
}

- (void)_goPublicPrivateToggle {
	_isPrivate = !_isPrivate;
	
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Public / Private Toggle"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
									  [NSString stringWithFormat:@"%d", _isPrivate], @"private", nil]];
	
	_publicPrivateImageView.image = [UIImage imageNamed:(_isPrivate) ? @"onPrivateMessage_" : @"offPrivateMessage_"];
	_publicPrivateImageView.image = [UIImage imageNamed:(_isPrivate) ? @"onPrivateMessage_" : @"offPrivateMessage_"];
	
	(_isPrivate) ? [self.delegate challengeOptionsViewMakePrivate:self] : [self.delegate challengeOptionsViewMakePublic:self];
	[self _goClose];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Create Snap Options - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _goClose];
}


#pragma mark - UI Presentation
- (void)_goClose {
	[self.delegate challengeOptionsViewClose:self];
}

@end
