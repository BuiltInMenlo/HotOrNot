//
//  HONAnimationOverseer.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONAnimationOverseer.h"
#import "HONComposeViewController.h"
#import "HONClubTimelineViewController.h"
#import "HONStoreProductsViewController.h"

const CGFloat kProgressHUDMinDuration = 0.5f;
const CGFloat kProgressHUDErrorDuration = 1.5f;

@implementation HONAnimationOverseer
static HONAnimationOverseer *sharedInstance = nil;

+ (HONAnimationOverseer *)sharedInstance {
	static HONAnimationOverseer *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);	
}


- (BOOL)isScrollingAnimationEnabledForScrollView:(id)scrollView {
//	NSLog(@"*|* [%@] (%@)-=-(%@)", self.class, scrollView, [@"" stringFromClass:scrollView]);
	
	if ([[@"" stringFromClass:scrollView] isEqualToString:@"HONComposeDisplayView"]) {
		return (NO);

	} else if ([[@"" stringFromClass:scrollView] isEqualToString:@"HONStickerButtonsPickerView"]) {
		return (NO);
		
	} else if ([[@"" stringFromClass:scrollView] isEqualToString:@"HONStickerSummaryView"]) {
		return (YES);
	
	} else {
		return (YES);
	}
}

- (BOOL)isSegueAnimationEnabledForModalViewController:(UIViewController *)viewController {
	if ([viewController isKindOfClass:[HONComposeViewController class]]) {
		return (NO);
		
	} else if ([viewController isKindOfClass:[HONStoreProductsViewController class]]) {
		return (YES);
		
	} else {
		return (YES);
	}
}

- (BOOL)isSegueAnimationEnabledForPushViewController:(UIViewController *)viewController {
	if ([viewController isKindOfClass:[HONClubTimelineViewController class]]) {
		return (NO);
		
	} else {
		return (YES);
	}
}

@end
