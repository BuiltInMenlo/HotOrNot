//
//  HONComposeSubmitViewController.m
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSCharacterSet+AdditionalSets.h"
#import "NSDate+Operations.h"
#import "NSMutableDictionary+Replacements.h"

#import "HONComposeSubjectViewController.h"

@interface HONComposeSubjectViewController () <HONTopicViewCellDelegate>
@property (nonatomic, strong) UITextField *customTopicTextField;
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
		NSLog(@"topic:[%@]", [_submitParams objectForKey:@"topic_name"]);
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_retrieveSubjects {
	[[[NSUserDefaults standardUserDefaults] objectForKey:@"compose_topics"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		HONTopicVO *vo = [HONTopicVO topicWithDictionary:(NSDictionary *)obj];
		if (vo.parentID == [[_submitParams objectForKey:@"topic_id"] intValue])
			[_topics addObject:vo];
	}];
	
	[super _didFinishDataRefresh];
}


- (void)_submitStatusUpdate {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Submit"
//									   withProperties:[self _trackingProps]];
	
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - submit"];
	[_submitParams setValue:[NSString stringWithFormat:@"%@|%@", [_submitParams objectForKey:@"topic_name"], _selectedTopicVO.topicName] forKey:@"subject"];
	
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
	
	[_headerView setTitle:[_submitParams objectForKey:@"topic_name"]];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
	
	_customTopicTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.0, 78.0, 220.0, 26.0)];
	[_customTopicTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_customTopicTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_customTopicTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_customTopicTextField setReturnKeyType:UIReturnKeyDone];
	[_customTopicTextField setTextColor:[UIColor blackColor]];
	[_customTopicTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_customTopicTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_customTopicTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_customTopicTextField.keyboardType = UIKeyboardTypeAlphabet;
	_customTopicTextField.placeholder = NSLocalizedString(@"register_submit", @"Terms");
	_customTopicTextField.delegate = self;
	
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
- (void)_goCustomTopic {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - step_2_custom"];

	[self.view addSubview:_customTopicTextField];
	[_customTopicTextField becomeFirstResponder];
	
	HONTopicViewCell *viewCell = (HONTopicViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[viewCell toggleCaption:NO];
}


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
		[self.navigationController popViewControllerAnimated:YES];
	});
}

- (void)_goSubmit {
	if (_selectedTopicVO == nil) {
		[[[UIAlertView alloc] initWithTitle:nil
									message:@"You must select a subject"
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
	} else {
		_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
		_overlayView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.75];
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


#pragma mark - Notifications
- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"_onTextEditingDidEnd");
	
	[_customTopicTextField resignFirstResponder];
	if ([_customTopicTextField.text length] > 0) {
		_selectedTopicVO = [HONTopicVO topicWithDictionary:@{@"id"			: @(0),
															 @"parent_id"	: @(4),
															 @"name"		: _customTopicTextField.text}];
		[self _goSubmit];
	}
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"_onTextEditingDidEndOnExit");
}

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	if ([_customTopicTextField.text length] == 0)
		[_customTopicTextField resignFirstResponder];
}


#pragma mark - TopicViewCell Delegates
- (void)topicViewCell:(HONTopicViewCell *)viewCell didSelectTopic:(HONTopicVO *)topicVO {
	NSLog(@"[*:*] topicViewCell:didSelectTopic:[%@]", [topicVO toString]);
	
	
	if ([[_submitParams objectForKey:@"topic_id"] intValue] == 4 && viewCell.indexPath.row == 0) {
		[self _goCustomTopic];
	
	} else {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - step_2_select"];
		[super topicViewCell:viewCell didSelectTopic:topicVO];
		[self _goSubmit];
	}
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
	
	
	HONTopicViewCell *cell = (HONTopicViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	if ([[_submitParams objectForKey:@"topic_id"] intValue] == 4 && cell.indexPath.row == 0) {
		[self _goCustomTopic];
		
	} else {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - step_2_select"];
		[self _goSubmit];
	}
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didEndDisplayingCell:cell forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSLog(@"textField:[%@] shouldChangeCharactersInRange:[%@] replacementString:[%@] -- (%@)", textField.text, NSStringFromRange(range), string, NSStringFromRange([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]]));
	
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSet]].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 25 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	
	[_customTopicTextField removeFromSuperview];
	
	HONTopicViewCell *viewCell = (HONTopicViewCell *)[_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
	[viewCell toggleCaption:YES];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		if (buttonIndex == 1) {
		}
	}
}

@end
