//
//  HONSplashViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.30.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONSplashViewController.h"

@interface HONSplashViewController ()

@end

@implementation HONSplashViewController

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *holderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, 480.0)];
	holderImgView.image = [UIImage imageNamed:@""];
	[self.view addSubview:holderImgView];
	
	//UIbutton *loginButton =
}

- (void)viewDidLoad {
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goContinue {
	
}

- (void)_goLogin {
	
}



@end
