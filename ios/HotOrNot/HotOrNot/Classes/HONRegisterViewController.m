//
//  HONRegisterViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSCharacterSet+BuiltinMenlo.h"
#import "NSDate+BuiltinMenlo.h"
#import "UIImage+BuiltinMenlo.h"
#import "UIImageView+AFNetworking.h"
#import "UILabel+BuiltinMenlo.h"
#import "NSString+BuiltinMenlo.h"

#import "ImageFilter.h"
#import "KeychainItemWrapper.h"

#import "HONRegisterViewController.h"
#import "HONCallingCodesViewController.h"
#import "HONEnterPINViewController.h"
#import "HONTermsViewController.h"
#import "HONNextNavButtonView.h"

@interface HONRegisterViewController () <HONCallingCodesViewControllerDelegate>
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, strong) NSString *callingCode;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *usernameButton;
@property (nonatomic, strong) UIButton *callCodeButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIImageView *phoneCheckImageView;
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSTimer *overlayTimer;
@property (nonatomic, strong) UIImageView *brandingImageView;
@property (nonatomic, strong) UIImageView *txtFieldBGImageView;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeRegistration;
		_viewStateType = HONStateMitigatorViewStateTypeRegistration;
		_phone = [NSString stringWithFormat:@"+1%d", [NSDate elapsedUTCSecondsSinceUnixEpoch]];
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - enter"];
	}
	
	return (self);
}

- (void)dealloc {
	_phoneTextField.delegate = nil;
}


#pragma mark - Data Calls
- (void)_checkUsername {
	
	_overlayView = [[UIView alloc] initWithFrame:self.view.frame];
	_overlayView.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.75];
	[self.view addSubview:_overlayView];
	
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"";//NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	
	NSLog(@"_checkUsername -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"_checkUsername -- USERNAME:[%@]", ([_usernameTextField.text length] > 0) ? _usernameTextField.text : [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"_checkUsername -- PHONE:[%@]", [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** USER/PHONE API CHECK **********\n");
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_usernameTextField.text completion:^(NSDictionary *result) {
		NSLog(@"RESULT:[%@]", result);
		
		if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
			
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
			
			[self _orphanSubmitOverlay];
			[_usernameTextField becomeFirstResponder];
			
		} else {
			[[HONAPICaller sharedInstance] checkForAvailablePhone:_phone completion:^(NSDictionary *result) {
				if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
					
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
					
					_phone = [NSString stringWithFormat:@"+1%d", [NSDate elapsedUTCSecondsSinceUnixEpoch]];
					_phoneTextField.text = @"";
					_phoneTextField.text = @"";
					_phoneTextField.text = @"";
					[_phoneTextField becomeFirstResponder];
					
				} else {
					NSLog(@"\n\n******** PASSED API NAME/PHONE CHECK **********");
					
					_submitButton.userInteractionEnabled = NO;
					
					NSLog(@"_finalizeUser -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
					NSLog(@"_finalizeUser -- USERNAME_TXT:[%@] -=- PREV:[%@]", ([_usernameTextField.text length] > 0) ? _usernameTextField.text : [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"username"]);
					NSLog(@"_finalizeUser -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
					
					NSLog(@"\n\n******** FINALIZE W/ API **********");
					[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																				@"username"		: ([_usernameTextField.text length] > 0) ? _usernameTextField.text : [[HONAppDelegate infoForUser] objectForKey:@"username"],
																				@"phone"		: [_phone stringByAppendingString:@"@selfieclub.com"]} completion:^(NSDictionary *result) {
																					
						int responseCode = [[result objectForKey:@"result"] intValue];
						if (result != nil && responseCode == 0) {
							
							[[HONAPICaller sharedInstance] updateAvatarWithImagePrefix:[[HONUserAssistant sharedInstance] rndAvatarURL] completion:^(NSDictionary *result) {
								if (![[result objectForKey:@"result"] isEqualToString:@"fail"]) {
									[HONAppDelegate writeUserInfo:result];
								}
							}];
							
							[[HONAPICaller sharedInstance] updateUsernameForUser:([_usernameTextField.text length] > 0) ? _usernameTextField.text : [[HONAppDelegate infoForUser] objectForKey:@"username"] completion:^(NSDictionary *result) {
								if (![[result objectForKey:@"result"] isEqualToString:@"fail"]) {
								}
							}];
							
								
							_phoneCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
							_phoneCheckImageView.alpha = 1.0;
							
							[HONAppDelegate writeUserInfo:result];
							[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:_phone];
							
							[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
								if (_progressHUD != nil) {
									[_progressHUD hide:YES];
									_progressHUD = nil;
								}
								
								[_overlayView removeFromSuperview];
								_overlayView = nil;
								
								if ([_overlayTimer isValid])
									[_overlayTimer invalidate];
								
								[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - complete"];
								
								[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
									KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
									[keychain setObject:NSStringFromBOOL(YES) forKey:CFBridgingRelease(kSecAttrAccount)];
									
									[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
								}];
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
								
								_phone = [NSString stringWithFormat:@"+1%d", [NSDate elapsedUTCSecondsSinceUnixEpoch]];
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
			}];
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@""];
	//[self.view addSubview:_headerView];
	
	_brandingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signupBranding"]];
	_brandingImageView.frame = CGRectOffset(_brandingImageView.frame, 0.0, 97.0);
	[self.view addSubview:_brandingImageView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:UIControlStateNormal];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:UIControlStateHighlighted];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:UIControlStateSelected];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:(UIControlStateSelected|UIControlStateHighlighted)];
//	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:_usernameButton];
	
	_txtFieldBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, self.view.frame.size.height - 136.0, 320.0, 44.0)];
	_txtFieldBGImageView.image = [UIImage imageNamed:@"signupButtonBG_normal"];
	_txtFieldBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:_txtFieldBGImageView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(14.0, 9.0, 220.0, 26.0)];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor blackColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.placeholder = NSLocalizedString(@"register_submit", @"Terms");
	//_usernameTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"username"];
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[_txtFieldBGImageView addSubview:_usernameTextField];
	
	
//	UILabel *submitLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 9.0, 200.0, 26.0)];
//	submitLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
//	submitLabel.textColor =  [UIColor blackColor];
//	submitLabel.backgroundColor = [UIColor clearColor];
//	submitLabel.text = NSLocalizedString(@"register_submit", @"Terms");
//	[submitButton addSubview:submitLabel];
	
	UIImageView *chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron"]];
	chevronImageView.frame = CGRectOffset(chevronImageView.frame, 280.0, 0.0);
	[_txtFieldBGImageView addSubview:chevronImageView];
	
	UIButton *termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	termsButton.frame = CGRectMake(60.0, self.view.frame.size.height - 55.0, 200.0, 18.0);
	[termsButton setTitleColor:[[HONColorAuthority sharedInstance] percentGreyscaleColor:0.80] forState:UIControlStateNormal];
	[termsButton setTitleColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor] forState:UIControlStateHighlighted];
	termsButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:15];
	[termsButton setTitle:NSLocalizedString(@"register_footer", @"Terms") forState:UIControlStateNormal];
	[termsButton setTitle:NSLocalizedString(@"register_footer", @"Terms") forState:UIControlStateHighlighted];
	[termsButton addTarget:self action:@selector(_goTerms) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:termsButton];
	
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
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, NSStringFromBOOL(animated));
	[super viewDidAppear:animated];
	
	_submitButton.userInteractionEnabled = YES;
//	[_usernameTextField becomeFirstResponder];
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
	[self presentViewController:navigationController animated:NO completion:nil];
}

- (void)_goPhone {
	[_phoneTextField becomeFirstResponder];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
		[self _goSubmit];
	}
}

- (void)_goSubmit {
	if ([_usernameTextField isFirstResponder])
		[_usernameTextField resignFirstResponder];
	
	[_phoneButton setSelected:NO];
		
	HONRegisterErrorType registerErrorType = ((int)([[[HONAppDelegate infoForUser] objectForKey:@"username"] length] == 0) * HONRegisterErrorTypeUsername) + ((int)([_phone length] == 0) * HONRegisterErrorTypePhone);
	if (registerErrorType == HONRegisterErrorTypeNone) {
//		_phone = [_callCodeButton.titleLabel.text stringByAppendingString:_phoneTextField.text];
		
		_overlayTimer = [NSTimer timerWithTimeInterval:[HONAppDelegate timeoutInterval] target:self
											  selector:@selector(_orphanSubmitOverlay)
											  userInfo:nil repeats:NO];
		
		_isPushing = YES;
		[self _checkUsername];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		[[[UIAlertView alloc] initWithTitle:nil
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
		
		_phone = [NSString stringWithFormat:@"+1%d", [NSDate elapsedUTCSecondsSinceUnixEpoch]];
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
- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"_onTextEditingDidEnd");
	
	[self _goSubmit];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"_onTextEditingDidEndOnExit");
}

- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_phoneTextField.text isEqualToString:@"¡"]) {
		_phoneTextField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
}

- (void)_orphanSubmitOverlay {
	NSLog(@"::|> _orphanSubmitOverlay <|::");
	
	if ([_overlayTimer isValid])
		[_overlayTimer invalidate];
	
	if (_overlayTimer != nil);
	_overlayTimer = nil;
	
	if (_overlayView != nil) {
		[_overlayView removeFromSuperview];
		_overlayView = nil;
	}
}


#pragma mark - CallingCodesViewController Delegates
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodesViewController:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	
	[[NSUserDefaults standardUserDefaults] setObject:@{@"code"	: countryVO.callingCode,
													   @"name"	: countryVO.countryName} forKey:@"country_code"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	//[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Country Selector Choosen"
//									 withProperties:@{@"code"	: [@"+" stringByAppendingString:countryVO.callingCode]}];
	
	[_callCodeButton setTitle:[@"+" stringByAppendingString:countryVO.callingCode] forState:UIControlStateNormal];
	[_callCodeButton setTitle:[@"+" stringByAppendingString:countryVO.callingCode] forState:UIControlStateHighlighted];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - nickname"];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registrationBranding"]];
	bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, 77.0);
	bgImageView.alpha= 0.0;
	[self.view addSubview:bgImageView];
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25
					 animations:^(void) {
						 bgImageView.alpha = 1.0;
						 _brandingImageView.alpha = 0.0;
						 
						 _txtFieldBGImageView.frame = CGRectMake(_txtFieldBGImageView.frame.origin.x, self.view.frame.size.height - (216.0 + _txtFieldBGImageView.frame.size.height), _txtFieldBGImageView.frame.size.width, _txtFieldBGImageView.frame.size.height);
					 } completion:^(BOOL finished) {}];
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
