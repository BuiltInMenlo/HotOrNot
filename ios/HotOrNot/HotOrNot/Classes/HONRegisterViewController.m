//
//  HONRegisterViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "NSString+Formatting.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+FormattedText.h"

#import "ImageFilter.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONRegisterViewController.h"
#import "HONCallingCodesViewController.h"
#import "HONEnterPINViewController.h"
#import "HONTermsViewController.h"
#import "HONHeaderView.h"
#import "HONNextNavButtonView.h"

@interface HONRegisterViewController () <HONCallingCodesViewControllerDelegate>
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *callingCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *callCodeButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIImageView *phoneCheckImageView;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeRegistration;
		_viewStateType = HONStateMitigatorViewStateTypeRegistration;
		
		_phone = @"";
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Start First Run"];
	}
	
	return (self);
}

- (void)dealloc {
	_phoneTextField.delegate = nil;
}


#pragma mark - Data Calls
- (void)_checkUsername {
	NSLog(@"_checkUsername -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"_checkUsername -- USERNAME_TXT:[%@] -=- PREV:[%@]", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"_checkUsername -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** USER/PHONE API CHECK **********\n");
	
	[[HONAPICaller sharedInstance] checkForAvailableUsername:[[HONAppDelegate infoForUser] objectForKey:@"username"] completion:^(NSDictionary *result) {
		NSLog(@"RESULT:[%@]", result);
		
		if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Username Taken"];
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_usernameTaken", @"Username taken!");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
			
		} else {
			[[HONAPICaller sharedInstance] checkForAvailablePhone:_phone completion:^(NSDictionary *result) {
				if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
					[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Phone Taken"];
					
					if (_progressHUD == nil)
						_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
					[_progressHUD setYOffset:-80.0];
					_progressHUD.minShowTime = kProgressHUDMinDuration;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
					_progressHUD.labelText = NSLocalizedString(@"phone_taken", @"Phone # taken!");
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
					_progressHUD = nil;
					
					_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
					_phoneCheckImageView.alpha = 1.0;
					
					_phone = @"";
					_phoneTextField.text = @"";
					_phoneTextField.text = @"";
					_phoneTextField.text = @"";
					[_phoneTextField becomeFirstResponder];
					
				} else {
					NSLog(@"\n\n******** PASSED API NAME/PHONE CHECK **********");
					[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Username & Phone OK"];
					[self _finalizeUser];
				}
			}];
		}
	}];
}

- (void)_finalizeUser {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	_submitButton.userInteractionEnabled = NO;
	
	NSLog(@"_finalizeUser -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"_finalizeUser -- USERNAME_TXT:[%@] -=- PREV:[%@]", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"_finalizeUser -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** FINALIZE W/ API **********");
	[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																@"username"	: [[HONAppDelegate infoForUser] objectForKey:@"username"],
																@"phone"	: [_phone stringByAppendingString:@"@selfieclub.com"],
																@"filename"	: @""} completion:^(NSDictionary *result) {
																	
		int responseCode = [[result objectForKey:@"result"] intValue];
		if (result != nil && responseCode == 0) {
			_phoneCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
			_phoneCheckImageView.alpha = 1.0;
			
			
			[HONAppDelegate writeUserInfo:result];
			[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:_phone];
			
			[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				[self.navigationController pushViewController:[[HONEnterPINViewController alloc] init] animated:YES];
			}];
			
		} else {
			_submitButton.userInteractionEnabled = YES;
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kProgressHUDErrorDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString((responseCode == 1) ? @"hud_usernameTaken" : (responseCode == 2) ? @"phone_taken" : (responseCode == 3) ? @"user_phone" : @"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration + 0.75];
			_progressHUD = nil;
			
			if (responseCode == 1) {
				_phoneCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
			
			} else if (responseCode == 2) {
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_phone = @"";
				_phoneTextField.text = @"";
				[_phoneTextField becomeFirstResponder];
			}
			
			else {
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				_phoneTextField.text = @"";
			}
			
			_phoneCheckImageView.alpha = 1.0;
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_signUp", @"Sign up")];
	[self.view addSubview:headerView];
	
	_phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_phoneButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:UIControlStateNormal];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:UIControlStateHighlighted];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:UIControlStateSelected];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	[_phoneButton addTarget:self action:@selector(_goPhone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_phoneButton];
	
//	CGSize size = [@"+14" boundingRectWithSize:CGSizeMake(60.0, 24.0)
//										options:NSStringDrawingTruncatesLastVisibleLine
//									 attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:18]}
//										context:nil].size;
	
	_callCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_callCodeButton.frame = CGRectMake(4.0, _phoneButton.frame.origin.y - 1.0, 60.0, 64.0);
//	[_callCodeButton setBackgroundImage:[UIImage imageNamed:@"callCodesButton_Active"] forState:UIControlStateNormal];
	[_callCodeButton setBackgroundImage:[UIImage imageNamed:@"callCodesButton_Active"] forState:UIControlStateHighlighted];
	[_callCodeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
	[_callCodeButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateHighlighted];
	[_callCodeButton setTitleEdgeInsets:UIEdgeInsetsMake(3.0, -6.0, 0.0, 0.0)];
	_callCodeButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:24];
	[_callCodeButton setTitle:@"+1" forState:UIControlStateNormal];
	[_callCodeButton setTitle:@"+1" forState:UIControlStateHighlighted];
	[_callCodeButton addTarget:self action:@selector(_goCallingCodes) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_callCodeButton];
	
	_phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(79.0, _phoneButton.frame.origin.y + 21.0, 200.0, 22.0)];
	[_phoneTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phoneTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phoneTextField setReturnKeyType:UIReturnKeyDone];
	[_phoneTextField setTextColor:[UIColor blackColor]];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phoneTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_phoneTextField.keyboardType = UIKeyboardTypePhonePad;
	_phoneTextField.placeholder = NSLocalizedString(@"enter_phone", @"Enter phone number");
	_phoneTextField.text = @"";
	_phoneTextField.delegate = self;
	[self.view addSubview:_phoneTextField];
	
	_phoneCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_phoneCheckImageView.frame = CGRectOffset(_phoneCheckImageView.frame, 258.0, _phoneButton.frame.origin.y + 3.0);
	_phoneCheckImageView.alpha = 0.0;
	[self.view addSubview:_phoneCheckImageView];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] == nil) {
		[[HONAPICaller sharedInstance] recreateUserWithCompletion:^(NSObject *result){
			if ([(NSDictionary *)result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
				[HONAppDelegate writeUserInfo:(NSDictionary *)result];
				[[HONImageBroker sharedInstance] writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
		}];
	}
	
	
	UIButton *termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	termsButton.frame = CGRectMake(120.0, 146.0, 80.0, 20.0);
	[termsButton setTitleColor:[[HONColorAuthority sharedInstance] percentGreyscaleColor:0.80] forState:UIControlStateNormal];
	[termsButton setTitleColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor] forState:UIControlStateHighlighted];
	termsButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	[termsButton setTitle:@"Terms" forState:UIControlStateNormal];
	[termsButton setTitle:@"Terms" forState:UIControlStateHighlighted];
	[termsButton addTarget:self action:@selector(_goTerms) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:termsButton];
	
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, self.view.frame.size.height - 64.0, 320.0, 64.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton setImage:[UIImage imageNamed:@"buttonChevron"] forState:UIControlStateNormal];
	[_submitButton setImage:[UIImage imageNamed:@"buttonChevron"] forState:UIControlStateHighlighted];
	[_submitButton setImageEdgeInsets:UIEdgeInsetsMake(0.0, 140.0, 0.0, 0.0)];
	_submitButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
	[_submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[_submitButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateHighlighted];
	[_submitButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -45.0, 0.0, 0.0)];
	[_submitButton setTitle:@"Submit" forState:UIControlStateNormal];
	[_submitButton setTitle:@"Submit" forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
	
	NSLog(@"loadView -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"loadView -- USERNAME_TXT:[%@] -=- PREV:[%@]", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"loadView -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	_submitButton.userInteractionEnabled = YES;
	[_phoneTextField becomeFirstResponder];
}


#pragma mark - Navigation
- (void)_goCallingCodes {
	HONCallingCodesViewController *callingCodesViewController = [[HONCallingCodesViewController alloc] init];
	callingCodesViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callingCodesViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goTerms {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goPhone {
	[_phoneTextField becomeFirstResponder];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
		[self _goSubmit];
	}
}

- (void)_goSubmit {	
	if ([_phoneTextField isFirstResponder])
		[_phoneTextField resignFirstResponder];
	
	[_phoneButton setSelected:NO];
		
	HONRegisterErrorType registerErrorType = ((int)([[[HONAppDelegate infoForUser] objectForKey:@"username"] length] == 0) * HONRegisterErrorTypeUsername) + ((int)([_phone length] == 0) * HONRegisterErrorTypePhone);
	if (registerErrorType == HONRegisterErrorTypeNone) {
		_phone = [_callCodeButton.titleLabel.text stringByAppendingString:_phoneTextField.text];
		
		_isPushing = YES;
		[self _checkUsername];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"no_user", @"No Username!")
									message: NSLocalizedString(@"no_user_msg", @"You need to enter a username to use Selfieclub")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypePhone) {
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.alpha = 1.0;
		
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"no_phone", @"No Phone!")
									message: NSLocalizedString(@"no_phone_msg", @"You need a phone # to use Selfieclub.")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
		_phone = @"";
		_phoneTextField.text = @"";
		[_phoneTextField becomeFirstResponder];
	
	} else if (registerErrorType == (HONRegisterErrorTypeUsername | HONRegisterErrorTypePhone)) {
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.alpha = 1.0;
		
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"no_userphone", @"No Username & Phone!")
									message: NSLocalizedString(@"no_userphone_msg", @"You need to enter a username and phone # to use Selfieclub")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_phoneTextField.text isEqualToString:@"¡"]) {
		_phoneTextField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
}


#pragma mark - CallingCodesViewController Delegates
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodesViewController:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	
	[[NSUserDefaults standardUserDefaults] setObject:@{@"code"	: countryVO.callingCode,
													   @"name"	: countryVO.countryName} forKey:@"country_code"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Country Selector Choosen"
									 withProperties:@{@"code"	: [@"+" stringByAppendingString:countryVO.callingCode]}];
	
	[_callCodeButton setTitle:[@"+" stringByAppendingString:countryVO.callingCode] forState:UIControlStateNormal];
	[_callCodeButton setTitle:[@"+" stringByAppendingString:countryVO.callingCode] forState:UIControlStateHighlighted];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	[_phoneButton setSelected:YES];
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _submitButton.frame = CGRectMake(_submitButton.frame.origin.x, self.view.frame.size.height - (217.0 + _submitButton.frame.size.height), _submitButton.frame.size.width, _submitButton.frame.size.height);
					 } completion:^(BOOL finished) {}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSCharacterSet *invalidCharSet = [NSCharacterSet characterSetWithCharactersInString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"invalid_chars"] componentsJoinedByString:@""] stringByAppendingString:@"\\"]];
	
	NSLog(@"textField:[%@] shouldChangeCharactersInRange:[%@] replacementString:[%@] -- (%@)", textField.text, NSStringFromRange(range), string, NSStringFromRange([string rangeOfCharacterFromSet:invalidCharSet]));
	
	if ([string rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 25 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	_phone = _phoneTextField.text;
	
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 _submitButton.frame = CGRectMake(_submitButton.frame.origin.x, self.view.frame.size.height - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
					 } completion:^(BOOL finished) {
						 _submitButton.hidden = YES;
					 }];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_phone = _phoneTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	_phone = _phoneTextField.text;
}


#pragma mark - AlertView Deleagtes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
	}
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	
//	NSString *mpAction = @"";
//	switch (result) {
//		case MFMailComposeResultCancelled:
//			mpAction = @"Canceled";
//			break;
//			
//		case MFMailComposeResultFailed:
//			mpAction = @"Failed";
//			break;
//			
//		case MFMailComposeResultSaved:
//			mpAction = @"Saved";
//			break;
//			
//		case MFMailComposeResultSent:
//			mpAction = @"Sent";
//			break;
//			
//		default:
//			mpAction = @"Not Sent";
//			break;
//	}
	
	[_mailComposeViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

@end
