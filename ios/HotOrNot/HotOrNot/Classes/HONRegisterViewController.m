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
#import "HONEnterPINViewController.h"
#import "HONTermsViewController.h"
#import "HONNextNavButtonView.h"
#import "HONLoadingOverlayView.h"

@interface HONRegisterViewController () <HONLoadingOverlayViewDelegate>
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *termsCheckButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIImageView *brandingImageView;
@property (nonatomic, strong) UIImageView *txtFieldBGImageView;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeRegistration;
		_viewStateType = HONStateMitigatorViewStateTypeRegistration;
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - enter"];
	}
	
	return (self);
}

- (void)dealloc {
}


#pragma mark - Data Calls
- (void)_checkUsername {
	NSLog(@"_checkUsername -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
	NSLog(@"_checkUsername -- USERNAME:[%@]", _username);
	NSLog(@"_checkUsername -- PHONE:[%@]", [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** USER/PHONE API CHECK **********\n");
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_username completion:^(NSDictionary *result) {
		NSLog(@"RESULT:[%@]", result);
		
		if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
			[_loadingOverlayView outro];
			
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
			
			[_usernameTextField becomeFirstResponder];
			
		} else {
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				[[HONAPICaller sharedInstance] checkForAvailablePhone:[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]] completion:^(NSDictionary *result) {
					if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue])
						NSLog(@"\n\n!¡!¡!¡ FAILED API NAME/PHONE CHECK !¡!¡!¡");
					
					else
						NSLog(@"\n\n******** PASSED API NAME/PHONE CHECK **********");
				}];
			});
			
			
			_submitButton.userInteractionEnabled = NO;
			
			NSLog(@"_finalizeUser -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
			NSLog(@"_finalizeUser -- USERNAME_TXT:[%@] -=- PREV:[%@]", _username, [[HONUserAssistant sharedInstance] activeUsername]);
			NSLog(@"_finalizeUser -- PHONE_TXT:[%@] -=- PREV[%@]", [NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]], [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
			
			NSLog(@"\n\n******** FINALIZE W/ API **********");
			[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"		: NSStringFromInt([[HONUserAssistant sharedInstance] activeUserID]),
																		@"username"		: _username,
																		@"phone"		: [[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]] stringByAppendingString:@"@selfieclub.com"]} completion:^(NSDictionary *result) {
				
																			
				NSLog(@"~*~*~*~*~*~* FINALIZE UPDATE !¡!¡!¡!¡!¡!¡!¡!\n%@", result);
				int responseCode = [[result objectForKey:@"result"] intValue];
				if (result != nil && responseCode == 0) {
					[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
					[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:[NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]]];
					
					[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - complete"];
					[_loadingOverlayView outro];
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
						KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
						[keychain setObject:NSStringFromBOOL(YES) forKey:CFBridgingRelease(kSecAttrAccount)];
						
						dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
							[[HONAPICaller sharedInstance] updateUsernameForUser:_username completion:^(NSDictionary *result) {
								NSLog(@"~*~*~*~*~*~* USERAME UPDATE !¡!¡!¡!¡!¡!¡!¡!");
								
								if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
									[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
								
								[[HONAPICaller sharedInstance] updateAvatarWithImagePrefix:[[HONUserAssistant sharedInstance] rndAvatarURL] completion:^(NSDictionary *result) {
									NSLog(@"~*~*~*~*~*~* AVATAR UPDATE !¡!¡!¡!¡!¡!¡!¡!");
									
									if (![[result objectForKey:@"result"] isEqualToString:@"fail"])
										[[HONUserAssistant sharedInstance] writeActiveUserInfo:result];
									
									[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
										NSLog(@"~*~*~*~*~*~* PHONE UPDATE !¡!¡!¡!¡!¡!¡!¡!\n");
										
										if (!((BOOL)[[result objectForKey:@"result"] intValue]))
											NSLog(@"!¡!¡!¡!¡!¡!¡!¡ PHONE UPDATE FAILED !¡!¡!¡!¡!¡!¡!¡!");
									}];
								}];
							}];
						});
						
						[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
					}];
					
				} else {
					[_loadingOverlayView outro];
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
				}
			}]; // finalize
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_username = [[HONUserAssistant sharedInstance] activeUsername];
	
	_brandingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signupBranding"]];
	_brandingImageView.frame = CGRectOffset(_brandingImageView.frame, 0.0, 114.0);
	[self.view addSubview:_brandingImageView];
	
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
	_usernameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.placeholder = NSLocalizedString(@"register_submit", @"Terms");
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[_txtFieldBGImageView addSubview:_usernameTextField];
	
	
	UIImageView *chevronImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"chevron"]];
	chevronImageView.frame = CGRectOffset(chevronImageView.frame, 280.0, 0.0);
	[_txtFieldBGImageView addSubview:chevronImageView];
	
	UIButton *enterButton = [UIButton buttonWithType:UIButtonTypeCustom];
	enterButton.frame = CGRectMake(280.0, 0.0, 40.0, 44.0);
	[enterButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_txtFieldBGImageView addSubview:enterButton];
	
	_termsCheckButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_termsCheckButton.frame = CGRectMake(80.0, self.view.frame.size.height - 56.0, 20.0, 20.0);
	[_termsCheckButton setBackgroundImage:[UIImage imageNamed:@"termsCheckbox_normal"] forState:UIControlStateNormal];
//	[_termsCheckButton setBackgroundImage:[UIImage imageNamed:@"termsCheckbox_normal"] forState:(UIControlStateNormal|UIControlStateHighlighted)];
	[_termsCheckButton setBackgroundImage:[UIImage imageNamed:@"termsCheckbox_selected"] forState:(UIControlStateSelected)];
	[_termsCheckButton setBackgroundImage:[UIImage imageNamed:@"termsCheckbox_selected"] forState:(UIControlStateSelected|UIControlStateHighlighted)];
	[_termsCheckButton addTarget:self action:@selector(_goToggleTerms) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_termsCheckButton];
	
	UIButton *termsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	termsButton.frame = CGRectMake(77.0, self.view.frame.size.height - 56.0, 200.0, 18.0);
	[termsButton setTitleColor:[[HONColorAuthority sharedInstance] percentGreyscaleColor:0.58] forState:UIControlStateNormal];
	[termsButton setTitleColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor] forState:UIControlStateHighlighted];
	termsButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	[termsButton setTitle:NSLocalizedString(@"register_footer", @"Terms") forState:UIControlStateNormal];
	[termsButton setTitle:NSLocalizedString(@"register_footer", @"Terms") forState:UIControlStateHighlighted];
	[termsButton addTarget:self action:@selector(_goTerms) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:termsButton];
	
	NSLog(@"loadView -- ID:[%d]", [[HONUserAssistant sharedInstance] activeUserID]);
	NSLog(@"loadView -- USERNAME_TXT:[%@] -=- PREV:[%@]", [[HONUserAssistant sharedInstance] activeUsername], [[HONUserAssistant sharedInstance] activeUsername]);
	NSLog(@"loadView -- PHONE_TXT:[%@] -=- PREV[%@]", [NSString stringWithFormat:@"+1%d", [[[HONUserAssistant sharedInstance] activeUserSignupDate] unixEpochTimestamp]], [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
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
- (void)_goToggleTerms {
	[_termsCheckButton setSelected:!_termsCheckButton.selected];
	
	if (!_termsCheckButton.selected) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_alert", @"You must agree to the terms of service to sign up!")
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_agree", nil), nil];
		[alertView setTag:HONRegisterAlertTagTerms];
		[alertView show];
	}
}

- (void)_goTerms {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
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
	
	
	if (!_termsCheckButton.selected) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"register_alert", @"You must agree to the terms of service to sign up!")
															message:nil
														   delegate:self
												  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
												  otherButtonTitles:NSLocalizedString(@"alert_agree", nil), nil];
		[alertView setTag:HONRegisterAlertTagTerms];
		[alertView show];
	
	} else {
		_isPushing = YES;
		
		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
		[self.view addSubview:_loadingOverlayView];
		
		_username = ([_usernameTextField.text length] > 0) ? _usernameTextField.text : _username;
		
		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
		_loadingOverlayView.delegate = self;
		
		[self _checkUsername];
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
}


#pragma mark - LoadingOverlayView Delegates
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView {
	NSLog(@"[*:*] loadingOverlayViewDidIntro [*:*]");
}

- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView {
	NSLog(@"[*:*] loadingOverlayViewDidOutro [*:*]");
	loadingOverlayView.delegate = nil;
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - nickname"];
	
	_usernameTextField.text = _username;
	[_usernameTextField selectAll:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registrationBranding"]];
	bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, 102.0);
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
	
	return ([textField.text length] < 50 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}


#pragma mark - AlertView Deleagtes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONRegisterAlertTagTerms) {
		if (buttonIndex == 1) {
			[_termsCheckButton setSelected:YES];
		}
	}
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (alertView.tag == HONRegisterAlertTagTerms) {
		if (buttonIndex == 1) {
			[self _goSubmit];
		}
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
