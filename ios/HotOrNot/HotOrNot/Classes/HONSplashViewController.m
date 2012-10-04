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
	
	UIImageView *holderImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 45.0, 301.0, 482.0)];
	holderImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"firstRun_image0%d.png", ((arc4random() % 4) + 1)]];
	[self.view addSubview:holderImgView];
	
	UIButton *ctaButton = [UIButton buttonWithType:UIButtonTypeCustom];
	ctaButton.frame = CGRectMake(200.0, 10.0, 167.0, 43.0);
	[ctaButton setBackgroundImage:[UIImage imageNamed:@"facebookButton_nonActive.png"] forState:UIControlStateNormal];
	[ctaButton setBackgroundImage:[UIImage imageNamed:@"facebookButton_Active.png"] forState:UIControlStateHighlighted];
	[ctaButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:ctaButton];
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
