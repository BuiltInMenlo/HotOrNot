//
//  HONSettingsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.07.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSettingsViewController.h"

@interface HONSettingsViewController ()

@end

@implementation HONSettingsViewController

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Settings", @"Settings");
		self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
	
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
	toolbar.frame = CGRectMake(0, 0, 320.0, 50.0);
	toolbar.barStyle = UIBarStyleDefault;
	[toolbar sizeToFit];
	[self.view addSubview:toolbar];
	
	UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_goDone)];
	NSArray *items = [[NSArray alloc] initWithObjects:flexibleSpace, doneButton, nil];
	[toolbar setItems:items];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goDone {
	[self dismissViewControllerAnimated:YES completion:nil];
}

@end
