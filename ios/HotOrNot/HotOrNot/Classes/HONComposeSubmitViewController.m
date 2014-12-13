//
//  HONComposeSubmitViewController.m
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSDate+Operations.h"
#import "NSMutableDictionary+Replacements.h"

#import "HONComposeSubmitViewController.h"
#import "HONRefreshControl.h"
#import "HONTableView.h"
#import "HONSubjectViewCell.h"
#import "HONSubjectVO.h"

@interface HONComposeSubmitViewController () <HONSubjectViewCellDeleagte>
@property (nonatomic, strong) HONTableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSMutableArray *subjects;
@property (nonatomic, strong) HONSubjectVO *selectedSubjectVO;
@property (nonatomic, strong) NSMutableDictionary *submitParams;
@end

@implementation HONComposeSubmitViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeComposeSubmit;
		_viewStateType = HONStateMitigatorViewStateTypeComposeSubmit;
	}
	
	return (self);
}

- (id)initWithSubmitParameters:(NSDictionary *)submitParams {
	if ((self = [self init])) {
		_submitParams = [submitParams mutableCopy];
	}
	
	return (self);
}

- (void)dealloc {
	[[_tableView visibleCells] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONSubjectViewCell *cell = (HONSubjectViewCell *)obj;
		cell.delegate = nil;
	}];
	
	_tableView.dataSource = nil;
	_tableView.delegate = nil;
	
	[super destroy];
}


#pragma mark - Data Calls
- (void)_retrieveSubjects {
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"compose_subjects"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dict = (NSDictionary *)obj;
		[_subjects addObject:[HONSubjectVO subjectWithDictionary:dict]];
	}];
	
	
	[self _didFinishDataRefresh];
}


- (void)_submitStatusUpdate {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit"
//									   withProperties:[self _trackingProps]];
	
	[_submitParams setValue:_selectedSubjectVO.subjectName forKey:@"subject"];
	
	NSLog(@"*^*|~|*|~|*|~|*|~|*|~|*|~| SUBMITTING -=- [%@] |~|*|~|*|~|*|~|*|~|*|~|*^*", _submitParams);
	[[HONAPICaller sharedInstance] submitClubPhotoWithDictionary:_submitParams completion:^(NSDictionary *result) {
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
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
			}];
		}
	}];
}


#pragma mark - Data Handling
- (void)_goDataRefresh:(HONRefreshControl *)sender {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Refresh Contacts"];
	[self _goReloadContents];
}

- (void)_goReloadContents {
	if (![_refreshControl isRefreshing])
		[_refreshControl beginRefreshing];
	
	_subjects = [NSMutableArray array];
	[_tableView reloadData];
	
	[self _retrieveSubjects];
}

- (void)_didFinishDataRefresh {
	NSLog(@"%@._didFinishDataRefresh - [%d]", self.class, [_subjects count]);

	[_tableView reloadData];
	[_refreshControl endRefreshing];
}

#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_subjects = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] init];
	[self.view addSubview:_headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = _headerView.frame;
	[backButton setBackgroundImage:[UIImage imageNamed:@"composeSubmitHeaderButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"composeSubmitHeaderButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:backButton];
	
	_tableView = [[HONTableView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, self.view.frame.size.height - (kNavHeaderHeight))];
	_tableView.backgroundView = [[UIView alloc] initWithFrame:CGRectFromSize(_tableView.frame.size)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	[self.view addSubview:_tableView];
	
	_refreshControl = [[UIRefreshControl alloc] init];
	[_refreshControl addTarget:self action:@selector(_goDataRefresh:) forControlEvents:UIControlEventValueChanged];
	[_tableView addSubview: _refreshControl];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 50.0, 320.0, 50.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	[self _goReloadContents];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}


#pragma mark - UI Presentation
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
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.labelText = NSLocalizedString(@"hud_loading", @"Loading…");
		_progressHUD.mode = MBProgressHUDModeIndeterminate;
		_progressHUD.minShowTime = kProgressHUDMinDuration;
		_progressHUD.taskInProgress = YES;
		
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
	
	_selectedSubjectVO = subjectVO;
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return (1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_subjects count]);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	return (nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSubjectViewCell alloc] initAsSelected:NO];
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	[cell hideChevron];
	cell.subjectVO = (HONSubjectVO *)[_subjects objectAtIndex:indexPath.row];
	cell.delegate = self;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (58.0);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return (0.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
	HONSubjectViewCell *cell = (HONSubjectViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	
	NSLog(@"[[- cell.subjectVO:[%@]", [cell.subjectVO toString]);

	[cell invertSelected];
	_selectedSubjectVO = cell.subjectVO;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	cell.alpha = 1.0;
//	[UIView animateKeyframesWithDuration:0.125 delay:0.050 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
//		cell.alpha = 1.0;
//	} completion:^(BOOL finished) {
//	}];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
		}
	}
}

@end
