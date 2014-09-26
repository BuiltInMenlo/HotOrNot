//
//  HONNetworkStatusViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/16/2014 @ 18:35 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "HONNetworkStatusViewController.h"


@interface HONNetworkStatusViewController ()
@end


@implementation HONNetworkStatusViewController

- (id)init {
	if ((self = [super initWithURL:@"https://www.twitter.com/selfiec_status"
							 title:NSLocalizedString(@"network_status", @"Network status")])) {
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Settings Tab - Network Status Close"];
	
	[super _goClose];
}

@end
