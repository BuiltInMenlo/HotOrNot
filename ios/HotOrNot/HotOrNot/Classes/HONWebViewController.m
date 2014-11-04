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

- (void)dealloc {
	_webView.delegate = nil;
	[super destroy];
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
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	
	[super loadView];
	
	_webView = [[UIWebView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, [UIScreen mainScreen].bounds.size.height - kNavHeaderHeight)];
	[_webView setBackgroundColor:[UIColor clearColor]];
	_webView.delegate = self;
	[_webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_url]]];
	[self.view addSubview:_webView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:_headerTitle];
	[_headerView addCloseButtonWithTarget:self usingAction:@selector(_goClose)];
	[self.view addSubview:_headerView];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - Navigation
- (void)_goClose {
	[self dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] [%@]_goPanGesture:[%@]-=(%@)=-", self.class, NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
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
	NSLog(@"[*:*] webView:shouldStartLoadWithRequest:[%@]", request.URL.absoluteString);
	
	return (YES);
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
	NSLog(@"[*:*] webViewDidStartLoad");
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.taskInProgress = YES;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	NSLog(@"[*:*] webViewDidFinishLoad");
	
	[self _removeHUD];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	NSLog(@"[*:*] didFailLoadWithError:[%@]", error);
	
	if ([error code] == NSURLErrorCancelled) {
		[self _removeHUD];
		return;
	}
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
	_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
	_progressHUD = nil;
}

@end
