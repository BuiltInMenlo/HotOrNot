//
//  HONContactsSearchViewController.m
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"

#import "HONContactsSearchViewController.h"
#import "HONCallingCodesViewController.h"
#import "HONComposeTopicViewController.h"
#import "HONUserVO.h"
#import "HONContactUserVO.h"
#import "HONUserClubVO.h"

@interface HONContactsSearchViewController () <HONCallingCodesViewControllerDelegate>
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *countryButton;
@property (nonatomic, strong) UILabel *countryCodeLabel;
@property (nonatomic, strong) NSString *callingCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSMutableArray *searchUsers;
@property (nonatomic, strong) HONUserVO *searchUserVO;
@property (nonatomic, strong) HONContactUserVO *contactUserVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic) BOOL isDismissing;
@end

@implementation HONContactsSearchViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeSearchUsername;
		_viewStateType = HONStateMitigatorViewStateTypeSearchUsername;
		
		_callingCode = @"+1";
		_phone = @"";
		_isDismissing = NO;
		
		_clubVO = nil;
	}
	
	return (self);
}

- (void)dealloc {
	_phoneTextField.delegate = nil;
	[super destroy];
}

- (id)initWithClub:(HONUserClubVO *)clubVO {
	if ((self = [self init])) {
		_callingCode = @"+1";
		_phone = @"";
		_isDismissing = NO;
		
		_clubVO = clubVO;
	}
	
	return (self);
}


#pragma mark - Data Calls
- (void)_searchUsersByPhoneNumber {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_searchUsers", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	_searchUsers = [NSMutableArray array];
	[[HONAPICaller sharedInstance] searchUsersByPhoneNumber:_phone completion:^(NSArray *result) {
		NSLog(@"SEARCH:[%@]", result);
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		if ([result count] > 0) {
			NSDictionary *dict = [result firstObject];
			_searchUserVO = [HONUserVO userWithDictionary:@{@"id"		: [dict objectForKey:@"id"],
																   @"username"	: [dict objectForKey:@"username"],
																   @"img_url"	: [dict objectForKey:@"avatar_url"]}];
			[_searchUsers addObject:_searchUserVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
																message:[NSString stringWithFormat:@"%@ has been found, would you like to send them an update?", _phone]
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
			[alertView setTag:0];
			[alertView show];
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
										message:[NSString stringWithFormat:@"%@ has been not found, would you like to send them an update?", _phone]
									   delegate:self
							  cancelButtonTitle:NSLocalizedString(@"not_now", nil)
							  otherButtonTitles:NSLocalizedString(@"alert_yes", nil), nil];
			[alertView setTag:1];
			[alertView show];
			
			_contactUserVO = [HONContactUserVO contactWithDictionary:@{@"f_name"	: [_phone substringFromIndex:1],
																	   @"l_name"	: @"",
																	   @"phone"		: _phone,
																	   @"email"		: @"",
																	   @"image"		: UIImagePNGRepresentation([UIImage imageNamed:@"avatarPlaceholder"])}];
		}
		
		[self _didFinishDataRefresh];
	}];
}


#pragma mark - Data Handling
- (void)_didFinishDataRefresh {
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_isDismissing = NO;
	_searchUsers = [NSMutableArray array];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_search", @"Search")];
	[_headerView addCloseButtonWithTarget:self action:@selector(_goClose)];
	[_headerView addNextButtonWithTarget:self action:@selector(_goSubmit)];
	[self.view addSubview:_headerView];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactsSearchBG"]];
	bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, kNavHeaderHeight + 49.0);
	[self.view addSubview:bgImageView];
	
	NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = 26.0;
	paragraphStyle.maximumLineHeight = paragraphStyle.minimumLineHeight;
	paragraphStyle.alignment = NSTextAlignmentCenter;
	
	UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(5.0, kNavHeaderHeight + 38.0, 310.0, 56.0)];
	footerLabel.textColor = [UIColor blackColor];
	footerLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:17];
	footerLabel.numberOfLines = 2;
	footerLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"search_footer", @"Provide a country code and a phone\nnumber to search for a Selfieclub friend") attributes:@{NSParagraphStyleAttributeName	: paragraphStyle}];
	[self.view addSubview:footerLabel];
	
	
	
	NSDictionary *country = ([[NSUserDefaults standardUserDefaults] objectForKey:@"country_code"] != nil) ? [[NSUserDefaults standardUserDefaults] objectForKey:@"country_code"] : @{@"code"	: @"1",
																																													 @"name"	: @"United States"};
	
	_countryButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_countryButton.frame = CGRectMake(20.0, 194.0, 260.0, 64.0);
	[_countryButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[_countryButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	_countryButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_countryButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
	[_countryButton setTitle:[country objectForKey:@"name"] forState:UIControlStateNormal];
	[_countryButton setTitle:[country objectForKey:@"name"] forState:UIControlStateHighlighted];
	[_countryButton addTarget:self action:@selector(_goCountryCodes) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_countryButton];
	
	_countryCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, 256.0, 72.0, 28.0)];
	_countryCodeLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:28];
	_countryCodeLabel.textAlignment = NSTextAlignmentCenter;
	_countryCodeLabel.textColor = [UIColor blackColor];
	_countryCodeLabel.backgroundColor = [UIColor clearColor];
	_countryCodeLabel.text = [@"+" stringByAppendingString:[country objectForKey:@"code"]];
	[self.view addSubview:_countryCodeLabel];
	
	_phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(105.0, 256.0, 294.0, 27.0)];
	[_phoneTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phoneTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phoneTextField setReturnKeyType:UIReturnKeyDone];
	[_phoneTextField setTextColor:[UIColor blackColor]];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phoneTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:27];
	_phoneTextField.keyboardType = UIKeyboardTypePhonePad;
	_phoneTextField.placeholder = NSLocalizedString(@"phone number", @"phone number");
	_phoneTextField.text = @"";
	_phoneTextField.delegate = self;
	[self.view addSubview:_phoneTextField];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	[_phoneTextField becomeFirstResponder];
}


#pragma mark - Navigation
- (void)_goCountryCodes {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Country Selector"];
	
	HONCallingCodesViewController *callingCodesViewController = [[HONCallingCodesViewController alloc] init];
	callingCodesViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callingCodesViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goClose {
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Cancel"];
	
	_isDismissing = YES;
	[_phoneTextField resignFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSubmit {
//	[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Submit"
//									 withProperties:@{@"query"	: [_countryCodeLabel.text stringByAppendingString:_phoneTextField.text]}];
	[_phoneTextField resignFirstResponder];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
//	NSLog(@"[:|:] _goPanGesture:[%@]-=(%@)=-", NSStringFromCGPoint([gestureRecognizer velocityInView:self.view]), (gestureRecognizer.state == UIGestureRecognizerStateBegan) ? @"BEGAN" : (gestureRecognizer.state == UIGestureRecognizerStateCancelled) ? @"CANCELED" : (gestureRecognizer.state == UIGestureRecognizerStateEnded) ? @"ENDED" : (gestureRecognizer.state == UIGestureRecognizerStateFailed) ? @"FAILED" : (gestureRecognizer.state == UIGestureRecognizerStatePossible) ? @"POSSIBLE" : (gestureRecognizer.state == UIGestureRecognizerStateChanged) ? @"CHANGED" : (gestureRecognizer.state == UIGestureRecognizerStateRecognized) ? @"RECOGNIZED" : @"N/A");
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].y >= 2000 || [gestureRecognizer velocityInView:self.view].x >= 2000) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Cancel SWIPE"];
		
		_isDismissing = YES;
		[_phoneTextField resignFirstResponder];
		[self dismissViewControllerAnimated:YES completion:^(void) {
		}];
	}
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		[_phoneTextField resignFirstResponder];
	}
}

- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"[*:*] _onTextEditingDidEnd:[%@]", _phoneTextField.text);
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"[*:*] _onTextEditingDidEndOnExit:[%@]", _phoneTextField.text);
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_phoneTextField.text isEqualToString:@"¡"]) {
		_phoneTextField.text = [[HONUserAssistant sharedInstance] activeUsername];
		_phoneTextField.text = @"2393709811";
	}
#endif
}


#pragma mark - CallingCodesViewController Delegates
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodesViewController:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Country Selector Choosen"
//									 withProperties:@{@"code"	: [@"+" stringByAppendingString:countryVO.callingCode]}];
	
	_countryCodeLabel.text = [@"+" stringByAppendingString:countryVO.callingCode];
	
	[_countryButton setTitle:countryVO.countryName forState:UIControlStateNormal];
	[_countryButton setTitle:countryVO.countryName forState:UIControlStateHighlighted];
}



#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	NSLog(@"[*:*] textFieldShouldReturn:[%@]", textField.text);
	
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSLog(@"textField:[%@] shouldChangeCharactersInRange:[%@] replacementString:[%@] -- (%@)", textField.text, NSStringFromRange(range), string, NSStringFromRange([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSetWithLetters]]));
	
	if ([string rangeOfCharacterFromSet:[NSCharacterSet invalidCharacterSetWithLetters]].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 25 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	NSLog(@"[*:*] textFieldDidEndEditing:[%@]", textField.text);
		  
	[textField resignFirstResponder];
	_phone = [_countryCodeLabel.text stringByAppendingString:_phoneTextField.text];
		
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	
	if (!_isDismissing) {
		if ([_phoneTextField.text length] == 0) {
			[[[UIAlertView alloc] initWithTitle:@"Nothing Selected!"
										message:@"You need to enter a phone number to search for first"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			[_phoneTextField becomeFirstResponder];
		
		} else {		
			if (![_phone isEqualToString:[[HONDeviceIntrinsics sharedInstance] phoneNumber]])
				[self _searchUsersByPhoneNumber];
			
			else {
				[[[UIAlertView alloc] initWithTitle:@"Cannot Search For Yourself!"
											message:@"You cannot search w/ this query, try again"
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
//				_phone = @"";
//				_phoneTextField.text = @"";
//				[_phoneTextField becomeFirstResponder];
			}
		}
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		NSMutableDictionary *props = [[[HONAnalyticsReporter sharedInstance] propertyForUser:_searchUserVO] mutableCopy];
		[props setValue:(buttonIndex == 0) ? @"Cancel" : @"Confirm" forKey:@"btn"];
		
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Results Alert"
//										 withProperties:[props copy]];
		
		if (buttonIndex == 0) {
//			_clubVO = (_clubVO == nil) ? [[HONClubAssistant sharedInstance] clubWithParticipants:@[_searchUserVO]] : _clubVO;
//			if (_clubVO != nil) {
//				NSLog(@"CLUB -=- (JOIN) -=-");
//				
//				[[HONAPICaller sharedInstance] inviteInAppUsers:@[_searchUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
//					_isDismissing = YES;
//					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:_clubVO]];
//					[navigationController setNavigationBarHidden:YES];
//					[self presentViewController:navigationController animated:YES completion:nil];
//					
////					[self dismissViewControllerAnimated:YES completion:^(void) {
////						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
////					}];
//				}];
//				
//			} else {
//				NSLog(@"CLUB -=- (CREATE) -=-");
//				
//				NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
//				[dict setValue:[NSString stringWithFormat:@"%d_%d", [[HONUserAssistant sharedInstance] activeUserID], [NSDate elapsedUTCSecondsSinceUnixEpoch]] forKey:@"name"];
//				[dict setValue:[[HONClubAssistant sharedInstance] rndCoverImageURL] forKey:@"img"];
//				_clubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
//				
//				[[HONAPICaller sharedInstance] createClubWithTitle:_clubVO.clubName withDescription:_clubVO.blurb withImagePrefix:_clubVO.coverImagePrefix completion:^(NSDictionary *result) {
//					_clubVO = [HONUserClubVO clubWithDictionary:result];
//					
//					[[HONAPICaller sharedInstance] inviteInAppUsers:@[_searchUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
//						_isDismissing = YES;
//						UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:_clubVO]];
//						[navigationController setNavigationBarHidden:YES];
//						[self presentViewController:navigationController animated:YES completion:nil];
//						
////						[self dismissViewControllerAnimated:YES completion:^(void) {
////							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:@"Y"];
////						}];
//					}];
//				}];
//			}
		}
	
	} else if (alertView.tag == 1) {
		NSMutableDictionary *props = [[[HONAnalyticsReporter sharedInstance] propertyForContactUser:_contactUserVO] mutableCopy];
		[props setValue:(buttonIndex == 0) ? @"Cancel" : @"Confirm" forKey:@"btn"];
		
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"User Search Phone - Results Alert"
//										 withProperties:[props copy]];
		
		if (buttonIndex == 1) {
//			_clubVO = (_clubVO == nil) ? [[HONClubAssistant sharedInstance] clubWithParticipants:@[[HONUserVO userFromContactUserVO:_contactUserVO]]] : _clubVO;
////			if (_clubVO != nil) {
////				NSLog(@"CLUB -=- (JOIN) -=-");
////				[[HONAPICaller sharedInstance] inviteNonAppUsers:@[_contactUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
////					_isDismissing = YES;
////					UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:_clubVO]];
////					[navigationController setNavigationBarHidden:YES];
////					[self presentViewController:navigationController animated:YES completion:nil];
////				}];
//				
////			} else {
//				
//				NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] clubDictionaryWithOwner:@{} activeMembers:@[] pendingMembers:@[[HONUserVO userFromContactUserVO:_contactUserVO]]];
//				[dict setValue:[NSString stringWithFormat:@"%d_%d", [[HONUserAssistant sharedInstance] activeUserID], [NSDate elapsedUTCSecondsSinceUnixEpoch]] forKey:@"name"];
//				[dict setValue:[[HONClubAssistant sharedInstance] rndCoverImageURL] forKey:@"img"];
//				_clubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
//				NSLog(@"CLUB -=- (GENERATE) -=-\n%@", _clubVO.dictionary);
//			
////				[[HONAPICaller sharedInstance] createClubWithTitle:_clubVO.clubName withDescription:_clubVO.blurb withImagePrefix:_clubVO.coverImagePrefix completion:^(NSDictionary *result) {
////					_clubVO = [HONUserClubVO clubWithDictionary:result];
////
////					[[HONAPICaller sharedInstance] inviteNonAppUsers:@[_contactUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
//						_isDismissing = YES;
//						UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONComposeViewController alloc] initWithClub:_clubVO]];
//						[navigationController setNavigationBarHidden:YES];
//						[self presentViewController:navigationController animated:YES completion:nil];
////					}];
////				}];
//			}
		}
	}
}

@end
