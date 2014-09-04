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
#import "HONInviteClubsViewController.h"
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
		
		_clubVO = [[HONClubAssistant sharedInstance] userSignupClub];
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
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"alert_inviteContact_t", nil), _searchUserVO.username]
																message:NSLocalizedString(@"alert_inviteContact_m", nil)
															   delegate:self
													  cancelButtonTitle:NSLocalizedString(@"alert_yes", nil)
													  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
			[alertView setTag:0];
			[alertView show];
			
		} else {
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_inviteNewContact_t", nil)
										message:NSLocalizedString(@"alert_inviteContact_m", nil)
									   delegate:self
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:NSLocalizedString(@"not_now", nil), nil];
			[alertView setTag:1];
			[alertView show];
			
			_contactUserVO = [HONContactUserVO contactWithDictionary:@{@"f_name"	: @" ",
																	   @"l_name"	: @" ",
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
	
//	[_tableView reloadData];
//	[_refreshControl endRefreshing];
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	_isDismissing = NO;
	_searchUsers = [NSMutableArray array];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonBlue_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButtonBlue_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(227.0, 0.0, 93.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_findFriends", @"Find friends")];
	[headerView addButton:cancelButton];
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
	
	_countryCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 256.0, 72.0, 28.0)];
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

- (void)_goCancel {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Cancel"];
	
	_isDismissing = YES;
	[self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"User Search - Submit"];
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
	
	//_clubNameLabel.text = ([_usernameTextField.text length] > 0) ? [NSString stringWithFormat:@"joinselfie.club/%@/%@", _usernameTextField.text, _usernameTextField.text] : @"joinselfie.club/";
	
	
//	if ([_usernameTextField isFirstResponder]) {
//		_usernameCheckImageView.alpha = 0.0;
//		_usernameCheckImageView.image = [UIImage imageNamed:([_usernameTextField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
//	}
//
//	if ([_phoneTextField isFirstResponder]) {
//		_phoneCheckImageView.alpha = 0.0;
//		_phoneCheckImageView.image = [UIImage imageNamed:([_phoneTextField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
//	}
}


#pragma mark - CallingCodesViewController Delegates
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodesViewController:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	
	_countryCodeLabel.text = [@"+" stringByAppendingString:countryVO.callingCode];
	
	[_countryButton setTitle:countryVO.countryName forState:UIControlStateNormal];
	[_countryButton setTitle:countryVO.countryName forState:UIControlStateHighlighted];
}



#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
//		_phoneCheckImageView.alpha = 0.0;
//		[_usernameButton setSelected:NO];
//		[_phoneButton setSelected:YES];
	
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
	NSMutableCharacterSet *invalidCharSet = [NSCharacterSet characterSetWithCharactersInString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"invalid_chars"] componentsJoinedByString:@""] stringByAppendingString:@"\\"]];
	[invalidCharSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
	
	NSLog(@"textField:[%@] shouldChangeCharactersInRange:[%@] replacementString:[%@] -- (%@)", textField.text, NSStringFromRange(range), string, NSStringFromRange([string rangeOfCharacterFromSet:invalidCharSet]));
	
//	_usernameCheckImageView.alpha = (int)([string rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound || range.location == 25);
//	_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
	
	if ([string rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 25 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	NSLog(@"[*:*] textFieldDidEndEditing:[%@]", textField.text);
		  
	[textField resignFirstResponder];
	
	_phone = _phone = [_countryCodeLabel.text stringByAppendingString:_phoneTextField.text];
		
//	if (textField.tag == 0) {
//		_usernameCheckImageView.alpha = 1.0;
//		_usernameCheckImageView.image = [UIImage imageNamed:([textField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
	
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
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"User Search - Found User Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"] withTrivialUser:_searchUserVO];
		
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithTrivialUser:_searchUserVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	
	} else if (alertView.tag == 1) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"User Search - No Result Alert " stringByAppendingString:(buttonIndex == 0) ? @"Confirm" : @"Cancel"] withContactUser:_contactUserVO];
		
		if (buttonIndex == 0) {
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONInviteClubsViewController alloc] initWithContactUser:_contactUserVO]];
			[navigationController setNavigationBarHidden:YES];
			[self presentViewController:navigationController animated:YES completion:nil];
		}
	}
}

@end
