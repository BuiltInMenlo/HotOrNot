//
//  HONContactsSearchViewController.m
//  HotOrNot
//
//  Created by BIM  on 8/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "HONContactsSearchViewController.h"
#import "HONCallingCodesViewController.h"
#import "HONSelfieCameraViewController.h"
#import "HONHeaderView.h"
#import "HONTrivialUserVO.h"
#import "HONContactUserVO.h"
#import "HONUserClubVO.h"

@interface HONContactsSearchViewController () <HONCallingCodesViewControllerDelegate>
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *countryButton;
@property (nonatomic, strong) UILabel *countryCodeLabel;
@property (nonatomic, strong) NSString *callingCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSMutableArray *searchUsers;
@property (nonatomic, strong) HONTrivialUserVO *searchUserVO;
@property (nonatomic, strong) HONContactUserVO *contactUserVO;
@property (nonatomic, strong) HONUserClubVO *clubVO;
@property (nonatomic) BOOL isDismissing;
@end

@implementation HONContactsSearchViewController

- (id)init {
	if ((self = [super init])) {
		_callingCode = @"+1";
		_phone = @"";
		_isDismissing = NO;
		
		_clubVO = nil;
	}
	
	return (self);
}

- (id)initWithClub:(HONUserClubVO *)clubVO {
	if ((self = [super init])) {
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
	_progressHUD.minShowTime = kHUDTime;
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
			_searchUserVO = [HONTrivialUserVO userWithDictionary:@{@"id"		: [dict objectForKey:@"id"],
																   @"username"	: [dict objectForKey:@"username"],
																   @"img_url"	: [dict objectForKey:@"avatar_url"]}];
			[_searchUsers addObject:_searchUserVO];
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone number found"
																message:@"Would you like to send them an update?"
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
			[alertView setTag:0];
			[alertView show];
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Phone number not found"
										message:@"Would you like to invite them to Selfieclub?"
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
	
	UIButton *closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeButton.frame = CGRectMake(-1.0, 2.0, 44.0, 44.0);
	[closeButton setBackgroundImage:[UIImage imageNamed:@"StatusCloseButton_nonActive"] forState:UIControlStateNormal];
	[closeButton setBackgroundImage:[UIImage imageNamed:@"StatusCloseButtonActive"] forState:UIControlStateHighlighted];
	[closeButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(276.0, 2.0, 44.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraNextButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraNextButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitleImage:[UIImage imageNamed:@"searchTitle"]];
	[headerView addButton:closeButton];
	[headerView addButton:submitButton];
	[self.view addSubview:headerView];
	
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"findFriendBackgorund"]];
	bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, kNavHeaderHeight + 49.0);
	[self.view addSubview:bgImageView];
	
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
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	[_phoneTextField becomeFirstResponder];
}



#pragma mark - Navigation
- (void)_goCountryCodes {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Country Selector"];
	
	HONCallingCodesViewController *callingCodesViewController = [[HONCallingCodesViewController alloc] init];
	callingCodesViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callingCodesViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goClose {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Cancel"];
	
	_isDismissing = YES;
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Submit"
									 withProperties:@{@"query"	: [_countryCodeLabel.text stringByAppendingString:_phoneTextField.text]}];
	[_phoneTextField resignFirstResponder];
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
		_phoneTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"username"];
		_phoneTextField.text = @"2393709811";
	}
#endif
}


#pragma mark - CallingCodesViewController Delegates
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodesViewController:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Country Selector Choosen"
									 withProperties:@{@"code"	: [@"+" stringByAppendingString:countryVO.callingCode]}];
	
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
	NSMutableCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"invalid_chars"] componentsJoinedByString:@""] stringByAppendingString:@"\\"]] mutableCopy];
	[invalidCharSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
	
	NSLog(@"textField:[%@] shouldChangeCharactersInRange:[%@] replacementString:[%@] -- (%@)", textField.text, NSStringFromRange(range), string, NSStringFromRange([string rangeOfCharacterFromSet:invalidCharSet]));
	
	if ([string rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound)
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
		[self _searchUsersByPhoneNumber];
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"User Search - Found User Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"]
										withTrivialUser:_searchUserVO];
		
		if (buttonIndex == 0) {
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithUser:_searchUserVO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
			
			_clubVO = (_clubVO == nil) ? [[HONClubAssistant sharedInstance] clubWithParticipants:@[_searchUserVO]] : _clubVO;
			if (_clubVO != nil) {
				NSLog(@"CLUB -=- (JOIN) -=-");
				
				[[HONAPICaller sharedInstance] inviteInAppUsers:@[_searchUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
					[self dismissViewControllerAnimated:YES completion:^(void) {
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
					}];
				}];
				
			} else {
				NSLog(@"CLUB -=- (CREATE) -=-");
				
				NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
				[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
				[dict setValue:[[HONClubAssistant sharedInstance] rndCoverImageURL] forKey:@"img"];
				_clubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
				
				[[HONAPICaller sharedInstance] createClubWithTitle:_clubVO.clubName withDescription:_clubVO.blurb withImagePrefix:_clubVO.coverImagePrefix completion:^(NSDictionary *result) {
					_clubVO = [HONUserClubVO clubWithDictionary:result];
					
					[[HONAPICaller sharedInstance] inviteInAppUsers:@[_searchUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
						[self dismissViewControllerAnimated:YES completion:^(void) {
							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
						}];
					}];
				}];
			}
		}
	
	} else if (alertView.tag == 1) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"User Search - No Result Alert " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]
										withContactUser:_contactUserVO];
		
		if (buttonIndex == 1) {
			_clubVO = (_clubVO == nil) ? [[HONClubAssistant sharedInstance] clubWithParticipants:@[[HONTrivialUserVO userFromContactVO:_contactUserVO]]] : _clubVO;
			if (_clubVO != nil) {
				NSLog(@"CLUB -=- (JOIN) -=-");
				[[HONAPICaller sharedInstance] inviteNonAppUsers:@[_contactUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
//						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
					}];
				}];
				
			} else {
				NSLog(@"CLUB -=- (CREATE) -=-");
				
				NSMutableDictionary *dict = [[HONClubAssistant sharedInstance] emptyClubDictionaryWithOwner:@{}];
				[dict setValue:[NSString stringWithFormat:@"%d_%d", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue], (int)[[[HONDateTimeAlloter sharedInstance] utcNowDate] timeIntervalSince1970]] forKey:@"name"];
				[dict setValue:[[HONClubAssistant sharedInstance] rndCoverImageURL] forKey:@"img"];
				_clubVO = [HONUserClubVO clubWithDictionary:[dict copy]];
				
				[[HONAPICaller sharedInstance] createClubWithTitle:_clubVO.clubName withDescription:_clubVO.blurb withImagePrefix:_clubVO.coverImagePrefix completion:^(NSDictionary *result) {
					_clubVO = [HONUserClubVO clubWithDictionary:result];

					[[HONAPICaller sharedInstance] inviteNonAppUsers:@[_contactUserVO] toClubWithID:_clubVO.clubID withClubOwnerID:_clubVO.ownerID completion:^(NSDictionary *result) {
						[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:@"Y"];
//							[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CLUB_TIMELINE" object:@"Y"];
						}];
					}];
				}];
			}
			
			
//			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONSelfieCameraViewController alloc] initWithContact:_contactUserVO]];
//			[navigationController setNavigationBarHidden:YES];
//			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}

@end
