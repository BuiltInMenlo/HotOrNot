//
//  HONComposeSubmitViewController.m
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSMutableDictionary+Replacements.h"

#import "HONComposeSubjectViewController.h"

@interface HONComposeSubjectViewController () <HONSubjectViewCellDeleagte>
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSTimer *overlayTimer;
@property (nonatomic, strong) NSString *topicName;
@end

@implementation HONComposeSubjectViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeComposeSubmit;
		_viewStateType = HONStateMitigatorViewStateTypeComposeSubmit;
	}
	
	return (self);
}

- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	if ((self = [super initWithSubmitParameters:submitParams])) {
		
		NSError *error = nil;
		NSArray *subjects = [NSJSONSerialization JSONObjectWithData:[_submitParams objectForKey:@"subjects"] options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"subjects:[%@]", subjects);
		}
		
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveSubjects {
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"compose_topics"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTopicVO *vo = [HONTopicVO topicWithDictionary:(NSDictionary *)obj];
		if (vo.parentID == 0)
			[_subjects addObject:vo];
	}];
	
	[super _didFinishDataRefresh];
}


- (void)_submitStatusUpdate {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit"
//									   withProperties:[self _trackingProps]];
	
	[_submitParams setValue:_selectedSubjectVO.subjectName forKey:@"subject"];
	
	NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", _submitParams);
	[[HONAPICaller sharedInstance] submitStatusUpdateWithDictionary:_submitParams completion:^(NSDictionary *result) {
		if ([[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"Error!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
			
		} else {
			[self _orphanSubmitOverlay];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
			}];
		}
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Refresh Contacts"];
	[super _goDataRefresh:sender];
}

- (void)_goReloadContents {
	[super _goReloadContents];
	[self _retrieveSubjects];
}

#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = _headerView.frame;
	[backButton setBackgroundImage:[UIImage imageNamed:@"composeSubmitHeaderButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"composeSubmitHeaderButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
//	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 58.0, 320.0, 58.0);
//	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
//	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
//	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:submitButton];
	
	[self _goReloadContents];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - UI Presentation
- (void)_orphanSubmitOverlay {
	NSLog(@"::|> _orphanSubmitOverlay <|::");
	
	if ([_overlayTimer isValid])
		[_overlayTimer invalidate];
	
	if (_overlayTimer != nil);
	_overlayTimer = nil;
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	if (_overlayView != nil) {
		[_overlayView removeFromSuperview];
		_overlayView = nil;
	}
}


#pragma mark - Navigation
- (void)_goBack {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Back"];
	
	[_headerView tappedTitle];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kButtonSelectDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[self.navigationController popViewControllerAnimated:NO];
	});
}

- (void)_goSubmit {
	if (_selectedSubjectVO == nil) {
		[[[UIAlertView alloc] initWithTitle:nil
									message:@"You must select a subject"
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
		_overlayView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.667];
		[self.view addSubview:_overlayView];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = @"";
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kProgressHUDMinDuration;
		_progressHUD.taskInProgress = YES;
		
		_overlayTimer = [NSTimer timerWithTimeInterval:[HONAppDelegate timeoutInterval] target:self
											  selector:@selector(_orphanSubmitOverlay)
											  userInfo:nil repeats:NO];
		
		[self _submitStatusUpdate];
	}
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	
	if (gestureRecognizer.state != UIGestureRecognizerStateBegan && gestureRecognizer.state != UIGestureRecognizerStateCancelled && gestureRecognizer.state != UIGestureRecognizerStateEnded)
		return;
	
	if ([gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Back SWIPE"];
//		[self.navigationController popViewControllerAnimated:YES];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit SWIPE"];
//		[self _goSubmit];
	}
}



#pragma mark - SubjectViewCell Delegates
- (void)subjectViewCell:(HONSubjectViewCell *)viewCell didSelectSubject:(HONSubjectVO *)subjectVO {
	NSLog(@"[*:*] subjectViewCell:didSelectSubject:[%@]", [subjectVO toString]);
	
	[super subjectViewCell:viewCell didSelectSubject:subjectVO];
	[self _goSubmit];
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([super numberOfSectionsInTableView:tableView]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([super tableView:tableView numberOfRowsInSection:section]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([super tableView:tableView cellForRowAtIndexPath:indexPath]);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return ([super tableView:tableView heightForRowAtIndexPath:indexPath]);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	[self _goSubmit];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
		}
	}
}

@end
