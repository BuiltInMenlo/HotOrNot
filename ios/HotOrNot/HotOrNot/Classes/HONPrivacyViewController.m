//
//  HONPrivacyViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPrivacyViewController.h"
#import "HONAppDelegate.h"

@interface HONPrivacyViewController () <UIWebViewDelegate>
@end

@implementation HONPrivacyViewController

- (id)init {
	if ((self = [super initWithURL:[NSString stringWithFormat:@"%@/privacy.htm", [HONAppDelegate apiServerPath]] title:@"Privacy Policy"])) {
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
}


#pragma mark - Navigation


#pragma mark - WebView Delegates
@end
