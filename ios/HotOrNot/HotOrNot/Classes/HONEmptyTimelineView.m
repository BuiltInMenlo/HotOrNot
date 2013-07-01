//
//  HONEmptyTimelineView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/25/13 @ 12:43 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONEmptyTimelineView.h"


@interface HONEmptyTimelineView ()
@end

@implementation HONEmptyTimelineView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:CGRectOffset(frame, 0.0, kNavBarHeaderHeight)])) {
		self.backgroundColor = [UIColor whiteColor];
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 454.0 : 416.0)];
		bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mobile_verification-568h@2x" : @"mobile_verification"];
		[self addSubview:bgImageView];
		
		UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		ctaButton.frame = CGRectMake(0.0, 188.0, 320.0, 53.0);
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"sendVerificationButton_nonActive"] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"sendVerificationButton_Active"] forState:UIControlStateHighlighted];
		[ctaButton addTarget:self action:@selector(_goSMS) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:ctaButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Verify Mobile - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)_goNext {
	[[Mixpanel sharedInstance] track:@"Verify Mobile - Back"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)_goSMS {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SMS_VERIFY" object:nil];
}


@end
