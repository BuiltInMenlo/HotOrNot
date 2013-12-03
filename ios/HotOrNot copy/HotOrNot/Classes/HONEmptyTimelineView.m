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
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:CGRectOffset(frame, 0.0, kNavBarHeaderHeight)])) {
		self.backgroundColor = [UIColor whiteColor];
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina4Inch]) ? 454.0 : 366.0)];
		bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"verification-586@2x" : @"verification"];
		[self addSubview:bgImageView];
		
		UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
		ctaButton.frame = CGRectMake(0.0, 192.0, 320.0, 53.0);
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"verifyVolleyAccount_nonActive"] forState:UIControlStateNormal];
		[ctaButton setBackgroundImage:[UIImage imageNamed:@"verifyVolleyAccount_Active"] forState:UIControlStateHighlighted];
		[ctaButton addTarget:self action:@selector(_goVerify) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:ctaButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goVerify {
	[self.delegate emptyTimelineViewVerify:self];
}


@end
