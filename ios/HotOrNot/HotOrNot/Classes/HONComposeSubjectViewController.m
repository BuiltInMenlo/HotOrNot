//
//  HONComposeSubmitViewController.m
//  HotOrNot
//
//  Created by BIM  on 9/13/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <LayerKit/LayerKit.h>

#import "LYRConversation+BuiltinMenlo.h"
#import "NSArray+BuiltinMenlo.h"
#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "NSDictionary+BuiltinMenlo.h"

#import "HONComposeSubjectViewController.h"
#import "HONSubjectViewCell.h"
#import "HONStatusUpdateVO.h"
#import "HONUserClubVO.h"
#import "HONLoadingOverlayView.h"
#import "HONBackNavButtonView.h"

@interface HONComposeSubjectViewController () <HONLoadingOverlayViewDelegate, HONSubjectViewCellDeleagte>
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) UITextField *customTopicTextField;
@property (nonatomic, strong) NSString *topicName;
@property (nonatomic, strong) NSArray *participantIDs;

@property (nonatomic, strong) NSMutableArray *lTopics;
@property (nonatomic, strong) NSMutableArray *rTopics;
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
		if (vo.parentID == [[_submitParams objectForKey:@"topic_id"] intValue]) {
			[_topics addObject:vo];
			
			if (idx % 2 == 0)
				[_lTopics addObject:vo];
			
			else
				[_rTopics addObject:vo];
		}
	}];
	
	[super _didFinishDataRefresh];
}

- (void)_submitStatusUpdate {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - submit"];
	
	
//	[_submitParams setValue:channelName forKey:@"img_url"];
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
			PNChannel *channel = [PNChannel channelWithName:[result objectForKey:@"id"] shouldObservePresence:YES];
			[PubNub subscribeOn:@[channel]];
			
			[[PNObservationCenter defaultCenter] addClientChannelSubscriptionStateObserver:self withCallbackBlock:^(PNSubscriptionProcessState state, NSArray *channels, PNError *error) {
				switch (state) {
					case PNSubscriptionProcessSubscribedState:
						NSLog(@"OBSERVER: Subscribed to Channel: %@", channels[0]);
						break;
						
					case PNSubscriptionProcessNotSubscribedState:
						NSLog(@"OBSERVER: Not subscribed to Channel: %@, Error: %@", channels[0], error);
						break;
						
					case PNSubscriptionProcessWillRestoreState:
						NSLog(@"OBSERVER: Will re-subscribe to Channel: %@", channels[0]);
						break;
						
					case PNSubscriptionProcessRestoredState:
						NSLog(@"OBSERVER: Re-subscribed to Channel: %@", channels[0]);
						break;
				}
			}];
			
			UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
			pasteboard.string = [NSString stringWithFormat:@"doodch.at/%d/", [[result objectForKey:@"id"] intValue]];
			
			[[[UIAlertView alloc] initWithTitle:@"Your DOOD chat link has been copied to your clipboard!"
										message:[NSString stringWithFormat:@"Share your DOOD chat link with friends for them to join. doodch.at/%d/", [[result objectForKey:@"id"] intValue]]
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
			[_loadingOverlayView outro];
			
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
			}]; // modal
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
	
	//self.navigationController.delegate = self;
	
//	[_headerView setTitle:[_submitParams objectForKey:@"topic_name"]];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
//	_headerView.alpha = 0.5;
	
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 31.0, 210.0, 22.0)];
	headerLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	headerLabel.textColor = [UIColor blackColor];
	headerLabel.shadowOffset = CGSizeMake(0.0, 1.0);
	headerLabel.textAlignment = NSTextAlignmentCenter;
	headerLabel.text = @"Select";//[_submitParams objectForKey:@"topic_name"];
	[self.view addSubview:headerLabel];
	
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
	_customTopicTextField.placeholder = NSLocalizedString(@"custom_topic", @"Terms");
	_customTopicTextField.delegate = self;
	
	[self _goReloadContents];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	//[self.navigationController setNavigationBarHidden:YES];
	
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


#pragma mark - Navigation
- (void)_goBack {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Back"];
	
	[_headerView tappedTitle];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kButtonSelectDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		[self.navigationController popViewControllerAnimated:YES];
	});
}

- (void)_goSubmit {
	
	
	
	_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
	_loadingOverlayView.delegate = self;
	
	[self _submitStatusUpdate];
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


#pragma mark - LoadingOverlayView Delegates
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView {
	NSLog(@"[*:*] loadingOverlayViewDidIntro [*:*]");
}

- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView {
	NSLog(@"[*:*] loadingOverlayViewDidOutro [*:*]");
	loadingOverlayView.delegate = nil;
}


#pragma mark - SubjectViewCell Delegates
- (void)subjectViewCell:(HONSubjectViewCell *)viewCell didSelectSubject:(HONTopicVO *)topicVO {
	NSLog(@"[*:*] subjectViewCell:didSelectTopic:[%@]", [topicVO toString]);
	
	if (viewCell.indexPath.row == 0) {
		[self _goCustomTopic];
		
	} else {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"COMPOSE - step_2_select"];
		_selectedTopicVO = topicVO;
		[self _goSubmit];
	}
}


#pragma mark - TableView DataSource Delegates
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return ([super numberOfSectionsInTableView:tableView]);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	//return (([_topics count] / 2) + ([_topics count] % 2));
	return ([_topics count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONSubjectViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONSubjectViewCell alloc] init];
	
	[cell setSize:[tableView rectForRowAtIndexPath:indexPath].size];
	[cell setIndexPath:indexPath];
	
	//int ind = indexPath.row / 2;
	cell.topicVO = [_topics objectAtIndex:indexPath.row];
//	cell.lTopicVO = (HONTopicVO *)[_topics objectAtIndex:(indexPath.row / 2) * 2];
//	cell.rTopicVO = (HONTopicVO *)[_topics objectAtIndex:MAX([_topics count] - 1, ((indexPath.row / 2) * 2) + 1)];
	cell.delegate = self;
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleGray];
	
	if (!tableView.decelerating)
		[cell toggleImageLoading:YES];
	
	return (cell);
	
//	return ([super tableView:tableView cellForRowAtIndexPath:indexPath]);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (54.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (indexPath);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	
	
	HONTopicViewCell *cell = (HONTopicViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	if (cell.indexPath.row == 0) {
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


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.hidden = YES;
}



@end
