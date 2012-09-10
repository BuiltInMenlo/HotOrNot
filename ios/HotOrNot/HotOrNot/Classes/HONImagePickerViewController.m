//
//  HONImagePickerViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.09.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONImagePickerViewController.h"

@interface HONImagePickerViewController ()

@end

@implementation HONImagePickerViewController

- (id)init {
	if ((self = [super init])) {
		self.title = NSLocalizedString(@"Select Image", @"Select Image");
		
		self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
	}
	
	return (self);
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

@end
