//
//  HONEnterPINViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 16:36 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UILabel+FormattedText.h"

#import "KeychainItemWrapper.h"

#import "HONEnterPINViewController.h"
#import "HONBackNavButtonView.h"

@interface HONEnterPINViewController ()
@property (nonatomic, strong) NSString *pin;
@property (nonatomic, strong) UIButton *pinButton;
@property (nonatomic, strong) UITextField *pinTextField;
@property (nonatomic, strong) UIImageView *pinCheckImageView;
@property (nonatomic) int validateCounter;
@property (nonatomic) BOOL isPopping;
@end


@implementation HONEnterPINViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypePINEntry;
		_viewStateType = HONStateMitigatorViewStateTypePINEntry;
		
		_validateCounter = 0;
	}
	
	return (self);
}

- (void)dealloc {
	_pinTextField.delegate = nil;
}


#pragma mark - Data Calls
- (void)_generateClub:(HONUserClubVO *)vo {
	[[HONAPICaller sharedInstance] createClubWithTitle:vo.clubName withDescription:vo.blurb withImagePrefix:vo.coverImagePrefix completion:^(NSDictionary *result) {
	}];
}

- (void)_validatePinCode {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] validatePhoneNumberForUser:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] usingPINCode:_pin completion:^(NSDictionary *result) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		//[[HONAnalyticsReporter sharedInstance] trackEvent:[NSString stringWithFormat:@"Registration - PIN Validation %@", ([[result objectForKey:@"result"] intValue] == 0) ? @"Failed" : @"Pass"]];
		
		if ([[result objectForKey:@"result"] intValue] == 0) {
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_pin", @"Invalid Pin!")
										message: NSLocalizedString(@"try_again", @"Please try again or press the resend button")
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			_pin = @"";
			_pinTextField.text = @"";
			[_pinTextField becomeFirstResponder];
			
//			_pinCheckImageView.image = [UIImage imageNamed:@"xIcon"];
//			_pinCheckImageView.alpha = 1.0;
			
		} else
			[self _finishFirstRun];
	}];
}


#pragma mark - Data Manip
- (void)_finishFirstRun {
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"ACTIVATION - exit_fr"];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:NO completion:^(void) {
		KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
		[keychain setObject:@"YES" forKey:CFBridgingRelease(kSecAttrAccount)];
		
//		[[HONClubAssistant sharedInstance] copyUserSignupClubToClipboardWithAlert:NO];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
		
		if ([[UIApplication sharedApplication] respondsToSelector:@selector(isRegisteredForRemoteNotifications)]) {
			[[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
			[[UIApplication sharedApplication] registerForRemoteNotifications];
			
		} else
			[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_pin", @"Enter pin")];
	[_headerView addBackButtonWithTarget:self action:@selector(_goBack)];
	[self.view addSubview:_headerView];
	
	
	_pinButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_pinButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:UIControlStateNormal];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:UIControlStateHighlighted];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:UIControlStateSelected];
	[_pinButton setBackgroundImage:[UIImage imageNamed:@"pinRowBG_normal"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	[self.view addSubview:_pinButton];
	
	_pinTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, _pinButton.frame.origin.y + 21.0, 177.0, 22.0)];
	[_pinTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_pinTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_pinTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_pinTextField setReturnKeyType:UIReturnKeyDone];
	[_pinTextField setTextColor:[UIColor blackColor]];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_pinTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_pinTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	_pinTextField.keyboardType = UIKeyboardTypeNumberPad;
	_pinTextField.placeholder = NSLocalizedString(@"enter_pin", @"Enter four digit pin");
	_pinTextField.text = @"";
	_pinTextField.delegate = self;
	[self.view addSubview:_pinTextField];
	
	_pinCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_pinCheckImageView.frame = CGRectOffset(_pinCheckImageView.frame, 258.0, _pinButton.frame.origin.y + 3.0);
	_pinCheckImageView.alpha = 0.0;
	[self.view addSubview:_pinCheckImageView];
	
	UIButton *resendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	resendButton.frame = CGRectMake(120.0, 146.0, 80.0, 20.0);
	[resendButton setTitleColor:[[HONColorAuthority sharedInstance] percentGreyscaleColor:0.80] forState:UIControlStateNormal];
	[resendButton setTitleColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor] forState:UIControlStateHighlighted];
	resendButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:16];
	[resendButton setTitle:@"Resend" forState:UIControlStateNormal];
	[resendButton setTitle:@"Resend" forState:UIControlStateHighlighted];
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
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewWillAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewWillAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewWillAppear:animated];
	
	_isPopping = NO;
	[self _goCheat];
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	_isPopping = NO;
//	[_pinTextField becomeFirstResponder];
}



#pragma mark - Navigation
- (void)_goBack {
	_pin = @"";
	_isPopping = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goResend {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.yOffset = -80.0;
	_progressHUD.graceTime = kProgressHUDMinDuration;
	_progressHUD.mode = MBProgressHUDModeCustomView;
	_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_pass"]];
	[_progressHUD show:NO];
	[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
	_progressHUD = nil;
	
	[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
		_pinTextField.text = @"";
		[_pinTextField becomeFirstResponder];
	}];
}

- (void)_goCheat {
	_pinTextField.text = @"0000";
	_pin = _pinTextField.text;
	
	_isPopping = YES;
	[_pinTextField resignFirstResponder];
	[self _finishFirstRun];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		if (!_isPopping) {
			if ([_pin length] < 4) {
				[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_pin", @"Invalid Pin!")
											message:NSLocalizedString(@"invalid_pin_msg", @"Pin numbers need to be 4 numbers")
										   delegate:nil
								  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
								  otherButtonTitles:nil] show];
				_pin = @"";
				_pinTextField.text = @"";
				[_pinTextField becomeFirstResponder];
				
			} else {
				_isPushing = YES;
				[self _validatePinCode];
			}
		}
	}
	
	if ([gestureRecognizer velocityInView:self.view].x >= 2000) {
		_isPopping = YES;
		[self.navigationController popViewControllerAnimated:YES];
	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	_pinCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
//	_pinCheckImageView.alpha = (int)([_pinTextField.text length] == 4);
	
	if ([_pinTextField.text length] == 4) {
//		_pin = _pinTextField.text;
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
	
	if (!_isPopping) {
		if ([_pin length] < 4) {
			[[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"invalid_pin", @"Invalid Pin!")
										message:NSLocalizedString(@"invalid_pin_msg", @"Pin numbers need to be 4 numbers")
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
			_pin = @"";
			_pinTextField.text = @"";
			[_pinTextField becomeFirstResponder];
			
		} else
			[self _validatePinCode];
	}
}

- (void)_onTextEditingDidEnd:(id)sender {
	_pin = _pinTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}

@end
