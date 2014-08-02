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
							 title:NSLocalizedString(@"network_status", nil)])) { //@"Network Status"])) {
	}
	
	return (self);
}


#pragma mark - Data Calls


#pragma mark - View lifecycle


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}


@end
