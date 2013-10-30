//
//  HONFAQViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONFAQViewController.h"


@interface HONFAQViewController () <UIWebViewDelegate>
@end

@implementation HONFAQViewController

- (id)init {
	if ((self = [super initWithURL:[NSString stringWithFormat:@"%@/faq.htm", [HONAppDelegate customerServiceURL]] title:@"Verify Help"])) {
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
	self.view.backgroundColor = [UIColor whiteColor];;
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


@end
