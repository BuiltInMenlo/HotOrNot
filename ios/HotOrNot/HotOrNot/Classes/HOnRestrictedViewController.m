//
//  HONRestrictedViewController.m
//  HotOrNot
//
//  Created by BIM  on 1/15/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONRestrictedViewController.h"

@interface HONRestrictedViewController ()
@end

@implementation HONRestrictedViewController


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	UIImageView *brandingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"restrictedBG"]];
	brandingImageView.frame = CGRectOffset(brandingImageView.frame, 0.0, 97.0);
	[self.view addSubview:brandingImageView];
}

@end
