//
//  HONPrivacyViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.28.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONPrivacyViewController.h"
#import "HONAppDelegate.h"

#import "MBProgressHUD.h"
#import "HONHeaderView.h"

@interface HONPrivacyViewController () <UIWebViewDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONPrivacyViewController

@synthesize progressHUD = _progressHUD;

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor colorWithWhite:0.85 alpha:1.0];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Privacy"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 0.0, 74.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive.png"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active.png"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:backButton];
	
	UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, 44.0, self.view.frame.size.width, self.view.frame.size.height - 44.0)];
	[webView setBackgroundColor:[UIColor clearColor]];
	webView.delegate = self;
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/privacy.htm", [HONAppDelegate apiServerPath]]]]];
	[self.view addSubview:webView];
	
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

#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
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
