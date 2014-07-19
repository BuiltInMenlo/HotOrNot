//
//  HONTermsConditionsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONTermsConditionsViewController.h"


@interface HONTermsConditionsViewController () <UIWebViewDelegate>
@end

@implementation HONTermsConditionsViewController

- (id)init {
	if ((self = [super initWithURL:[[HONAppDelegate customerServiceURL] stringByAppendingString:@"/terms2.htm"] title:@"Terms"])) {
		self.view.backgroundColor = [UIColor colorWithWhite:1.00 alpha:1.0];
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
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


@end
