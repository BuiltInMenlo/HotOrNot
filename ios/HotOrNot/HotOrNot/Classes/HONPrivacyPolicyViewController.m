//
//  HONPrivacyPolicyViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPrivacyPolicyViewController.h"


@interface HONPrivacyPolicyViewController ()
@end

@implementation HONPrivacyPolicyViewController

- (id)init {
	if ((self = [super initWithURL:[HONAppDelegate customerServiceURLForKey:@"privacy"]
							 title: NSLocalizedString(@"privacy_policy", nil)])) { //@"Privacy Policy"])) {
	}
	
	return (self);
}

@end
