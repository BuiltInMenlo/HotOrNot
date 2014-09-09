//
//  HONTermsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONTermsViewController.h"


@interface HONTermsViewController ()
@end

@implementation HONTermsViewController

- (id)init {
	if ((self = [super initWithURL:[HONAppDelegate customerServiceURLForKey:@"legal"]
							 title:NSLocalizedString(@"terms_service", nil)])) { //@"Terms of Use"])) {
	}
	
	return (self);
}

@end
