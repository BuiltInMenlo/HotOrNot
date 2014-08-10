//
//  HONEnterPINViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 16:36 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONEnterPINViewController.h"
#import "HONHeaderView.h"

@interface HONEnterPINViewController ()
@property (nonatomic, strong) NSString *pin;
@property (nonatomic, strong) UIButton *pinButton;
@property (nonatomic, strong) UITextField *pinTextField;
@property (nonatomic, strong) UIImageView *pinCheckImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) int validateCounter;
@end


@implementation HONEnterPINViewController

- (id)init {
	if ((self = [super init])) {
		_validateCounter = 0;
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotate {
	return (NO);
}


#pragma mark - Data Calls
- (void)_validatePinCode {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] validatePhoneNumberForUser:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] usingPINCode:_pin completion:^(NSDictionary *result) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		if ([[result objectForKey:@"result"] intValue] == 0) {
			
			_pin = @"";
			_pinTextField.text = @"";
			[_pinTextField becomeFirstResponder];
			
			_pinCheckImageView.image = [UIImage imageNamed:@"xIcon"];
			_pinCheckImageView.alpha = 1.0;
			
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_pin", @"Invalid Pin!")
										message:@"Please try again or press the resend button"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			
		} else
			[self _finishFirstRun];
	}];
}


#pragma mark - Data Manip
- (void)_finishFirstRun {
	_pinCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	_pinCheckImageView.alpha = 1.0;
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		
		KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
		[keychain setObject:@"YES" forKey:CFBridgingRelease(kSecAttrAccount)];
		
		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
		pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: http://joinselfie.club/%@/%@", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""], [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""]];
		
//					[[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"Your %@ has been copied!", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@"s Club"]]
//												message:[NSString stringWithFormat:@"\nPaste this URL anywhere to have your friends join!"]											   delegate:nil
//									  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
//									  otherButtonTitles:nil] show];
		
		[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
		
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"enter_pin", nil)]; //@"Enter Pin"];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(0.0, 1.0, 93.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(226.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	 
	_pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_pinButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_normal"] forState:UIControlStateNormal];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_normal"] forState:UIControlStateHighlighted];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_normal"] forState:UIControlStateSelected];
	[self.view addSubview:_pinButton];
	
	_pinTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 81.0, 77.0, 30.0)];
	[_pinTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_pinTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_pinTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_pinTextField setReturnKeyType:UIReturnKeyDone];
	[_pinTextField setTextColor:[UIColor blackColor]];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_pinTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	_pinTextField.keyboardType = UIKeyboardTypeDecimalPad;
	_pinTextField.text = @"";
	_pinTextField.delegate = self;
	[self.view addSubview:_pinTextField];
	[_pinTextField becomeFirstResponder];
	
	_pinCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_pinCheckImageView.frame = CGRectOffset(_pinCheckImageView.frame, 258.0, 65.0);
	_pinCheckImageView.alpha = 0.0;
	[self.view addSubview:_pinCheckImageView];
	
	UIImageView *footerTextImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed: @"pinText"]]; //@"pinFooterText"]];
	footerTextImageView.frame = CGRectOffset(footerTextImageView.frame, 0.0, 129.0);
	[self.view addSubview:footerTextImageView];
	
	UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	resendButton.frame = CGRectMake(200.0, 160.0, 55.0, 24.0);
	[resendButton addTarget:self action:@selector(_goResend) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:resendButton];
	
	
#if __APPSTORE_BUILD__ == 0
	UIButton *cheatButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cheatButton.frame = CGRectMake(152.0, kNavHeaderHeight - 8.0, 16.0, 16.0);
	[cheatButton addTarget:self action:@selector(_goCheat) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:cheatButton];
#endif
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}


#pragma mark - Navigation
- (void)_goBack {
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goDone {
	
	_pin = _pinTextField.text;
	if ([_pin length] < 4) {
		_pin = @"";
		_pinTextField.text = @"";
		[_pinTextField becomeFirstResponder];
		
		[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_pin", nil) //@"Invalid Pin!"
									message:NSLocalizedString(@"invalid_pin_msg", nil) //@"Pin numbers need to be 4 numbers"
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	
	} else {
		[_pinTextField resignFirstResponder];
	}
}

- (void)_goResend {
	[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
		_pinTextField.text = @"";
		[_pinTextField becomeFirstResponder];
	}];
}

- (void)_goCheat {
	_pinTextField.text = @"0000";
	_pin = _pinTextField.text;
	
	_pinCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	_pinCheckImageView.alpha = 1.0;
	
	[self _finishFirstRun];
}

#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	_pinCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
//	_pinCheckImageView.alpha = (int)([_pinTextField.text length] == 4);
	
	if ([_pinTextField.text length] == 4) {
		_pin = _pinTextField.text;
		[_pinTextField resignFirstResponder];
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[_pinButton setSelected:YES];

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
	return (!([textField.text length] > 3 && [string length] > range.length));
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	[_pinButton setSelected:NO];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	_pin = _pinTextField.text;
	[self _validatePinCode];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_pin = _pinTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}

@end
