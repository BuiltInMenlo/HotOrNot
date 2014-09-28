//
//  HONNavigationController.m
//  HotOrNot
//
//  Created by BIM  on 9/27/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONNavigationController.h"

@interface HONNavigationController ()
@end

@implementation HONNavigationController

- (id)initWithRootViewController:(UIViewController *)rootViewController {
	if ((self = [super initWithRootViewController:rootViewController])) {
		[self setNavigationBarHidden:YES];
	}
	
	return (self);
}

@end
