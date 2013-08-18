//
//  HONSupportViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSupportViewController.h"


@interface HONSupportViewController () <UIWebViewDelegate>
@end

@implementation HONSupportViewController

- (id)init {
	if ((self = [super initWithURL:[NSString stringWithFormat:@"%@/support.htm", [HONAppDelegate customerServiceURL]] title:@"Support"])) {
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[HONAppDelegate offsetSubviewsForIOS7:self.view];
}


#pragma mark - Navigation


#pragma mark - WebView Delegates
@end
