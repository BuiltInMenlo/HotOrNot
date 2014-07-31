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

@interface HONWebViewController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) HONHeaderView *headerView;
@end

@implementation HONWebViewController
@synthesize headerTitle = _headerTitle;
@synthesize url = _url;

- (id)initWithURL:(NSString *)url title:(NSString *)title {
	if ((self = [super init])) {
		_url = url;
		_headerTitle = title;
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setHeaderTitle:(NSString *)headerTitle {
	_headerTitle = headerTitle;
	
	[_headerView setTitle:_headerTitle];
}

- (void)setUrl:(NSString *)url {
	_url = url;
	
	if ([_webView isLoading])
		[_webView stopLoading];
	
	[self _removeHUD];
	
	
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, [UIScreen mainScreen].bounds.size.height - kNavHeaderHeight)];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.delegate = self;
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
	[self.view addSubview:_webView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:_headerTitle];
	[_headerView addButton:doneButton];
	[self.view addSubview:_headerView];
}


#pragma mark - Navigation
- (void)_goDone {
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UI Presentation
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
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.taskInProgress = YES;
	_progressHUD.minShowTime = kHUDTime;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self _removeHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"didFailLoadWithError:[%@]", error);
	
	if ([error code] == NSURLErrorCancelled) {
		[self _removeHUD];
		return;
	}
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kHUDErrorTime];
	_progressHUD = nil;
}

@end
