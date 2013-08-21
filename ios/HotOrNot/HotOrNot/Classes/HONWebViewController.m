//
//  HONWebViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.26.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "HONWebViewController.h"
#import "HONHeaderView.h"

@interface HONWebViewController () <UIWebViewDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *headerTitle;
@property (nonatomic, strong) UIButton *doneButton;
@end

@implementation HONWebViewController

- (id)initWithURL:(NSString *)url title:(NSString *)title {
	if ((self = [super init])) {
		_url = url;
		_headerTitle = title;
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
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h@2x" : @"mainBG"]];
	bgImageView.frame = self.view.bounds;
	[self.view addSubview:bgImageView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:_headerTitle];
	[headerView hideRefreshing];
	[self.view addSubview:headerView];
	
	_doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_doneButton.frame = CGRectMake(-7.0, 0.0, 64.0, 44.0);
	[_doneButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_nonActive"] forState:UIControlStateNormal];
	[_doneButton setBackgroundImage:[UIImage imageNamed:@"closeModalButton_Active"] forState:UIControlStateHighlighted];
	[_doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:_doneButton];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 45.0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 45.0)];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.delegate = self;
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
	[self.view addSubview:_webView];
	
	if (!_progressHUD) {
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.taskInProgress = YES;
		_progressHUD.minShowTime = kHUDTime;
		
		[self performSelector:@selector(_removeHUD) withObject:nil afterDelay:8.0];
	}
	
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Accessors
- (void)hideDoneButton {
	[_doneButton removeTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[_doneButton removeFromSuperview];
}


#pragma mark - Navigation
- (void)_goDone {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_removeHUD {
	if (_progressHUD != nil) {
		_progressHUD.taskInProgress = NO;
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}


#pragma mark - WebView Delegates
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	return (YES);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self _removeHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"didFailLoadWithError:[%@]", error);
	
	[self _removeHUD];
	
	if ([error code] == NSURLErrorCancelled)
		return;
}

@end
