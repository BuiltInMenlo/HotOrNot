//
//  HONSnapPreviewViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 7/22/13 @ 5:33 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONSnapPreviewViewController.h"
#import "HONImageLoadingView.h"


@interface HONSnapPreviewViewController ()
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) UIImageView *imageView;
@end


@implementation HONSnapPreviewViewController

- (id)initWithImageURL:(NSString *)url {
	if ((self = [super init])) {
		_url = url;
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


#pragma mark - Data Calls


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor blackColor];
	
	HONImageLoadingView *imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointMake(128.0, ([UIScreen mainScreen].bounds.size.height - 64.0) * 0.5)];
	[self.view addSubview:imageLoadingView];
	
	_imageView = [[UIImageView alloc] initWithFrame:CGRectMake((320.0 - kSnapLargeDim) * 0.5, ([UIScreen mainScreen].bounds.size.height - kSnapLargeDim) * 0.5, kSnapLargeDim, kSnapLargeDim)];
	[_imageView setImageWithURL:[NSURL URLWithString:_url] placeholderImage:nil];
	
	[self.view addSubview:_imageView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
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


@end
