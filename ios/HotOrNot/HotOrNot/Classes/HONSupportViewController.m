//
//  HONSupportViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.23.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"
#import "MBProgressHUD.h"

#import "HONSupportViewController.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONSupportViewController () <UIWebViewDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONSupportViewController

- (id)init {
	if ((self = [super initWithURL:[NSString stringWithFormat:@"%@/support.htm", [HONAppDelegate apiServerPath]] title:@"Support"])) {
		[[Mixpanel sharedInstance] track:@"Support"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
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
