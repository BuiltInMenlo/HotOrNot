//
//  HONTutorialView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 03/26/2014 @ 22:45 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTutorialView.h"
#import "HONDeviceTraits.h"

@interface HONTutorialView ()
@end


@implementation HONTutorialView
@synthesize delegate = _delegate;

- (id)initWithBGImage:(UIImage *)bgImage {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		
		self.alpha = 0.0;
		[self addSubview:[[UIImageView alloc] initWithImage:bgImage]];
		
		UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeButton.frame = CGRectMake(241.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 97.0 : 50.0, 44.0, 44.0);
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_nonActive"] forState:UIControlStateNormal];
		[closeButton setBackgroundImage:[UIImage imageNamed:@"tutorial_closeButton_Active"] forState:UIControlStateHighlighted];
		[closeButton addTarget:self action:@selector(_goRemove) forControlEvents:UIControlEventTouchDown];
		[self addSubview:closeButton];
		
		UIButton *avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
		avatarButton.frame = CGRectMake(-1.0, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 416.0 : 374.0, 320.0, 64.0);
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_nonActive"] forState:UIControlStateNormal];
		[avatarButton setBackgroundImage:[UIImage imageNamed:@"tutorial_profilePhoto_Active"] forState:UIControlStateHighlighted];
		[avatarButton addTarget:self action:@selector(_goTakeAvatar) forControlEvents:UIControlEventTouchDown];
		[self addSubview:avatarButton];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)introWithCompletion:(void (^)(BOOL finished))completion {
	self.alpha = 0.0;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		self.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		if (completion)
			completion(finished);
	}];
}

- (void)outroWithCompletion:(void (^)(BOOL finished))completion {
	[UIView animateWithDuration:0.25 animations:^(void) {
		self.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		for (UIView *view in self.subviews) {
			[view removeFromSuperview];
		}
		
		if (completion)
			completion(finished);
	}];
}


#pragma mark - Navigation
- (void)_goRemove {
	[self.delegate tutorialViewClose:self];
}

- (void)_goTakeAvatar {
	[self.delegate tutorialViewTakeAvatar:self];
}


@end
