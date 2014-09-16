//
//  HONEnterPINViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 02/28/2014 @ 16:36 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONEnterPINViewController.h"
#import "HONHeaderView.h"
#import "HONPostStatusUpdateViewController.h"

@interface HONEnterPINViewController ()
@property (nonatomic, strong) NSString *pin;
@property (nonatomic, strong) UIButton *pinButton;
@property (nonatomic, strong) UITextField *pinTextField;
@property (nonatomic, strong) UIImageView *pinCheckImageView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) int validateCounter;
@property (nonatomic) BOOL isPopping;
@end


@implementation HONEnterPINViewController

- (id)init {
	if ((self = [super init])) {
		_validateCounter = 0;
	}
	
	return (self);
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"enter_pin", @"Enter Pin"])];
	[self.view addSubview:headerView];
	
//	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	backButton.frame = CGRectMake(-4.0, 1.0, 44.0, 44.0);
//	[backButton setBackgroundImage:[UIImage imageNamed:@"backArrowButton_nonActive"] forState:UIControlStateNormal];
//	[backButton setBackgroundImage:[UIImage imageNamed:@"backArrowButton_Active"] forState:UIControlStateHighlighted];
//	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
//	[headerView addButton:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 45.0, 1.0, 44.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"contactListGraphic"]];
	bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, 103.0);
	[self.view addSubview:bgImageView];
	
	UIButton *bgImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
	bgImageButton.frame = bgImageView.frame;
	[bgImageButton addTarget:self action:@selector(_goAlertContacts) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:bgImageButton];
	
	UIButton *accessButton = [UIButton buttonWithType:UIButtonTypeCustom];
	accessButton.frame = CGRectMake(0.0, 520.0, 320.0, 48.0);
	[accessButton setBackgroundImage:[UIImage imageNamed:@"accessContacts_nonActive@2x"] forState:UIControlStateNormal];
	[accessButton setBackgroundImage:[UIImage imageNamed:@"accessContacts_Active@2x"] forState:UIControlStateHighlighted];
	[accessButton addTarget:self action:@selector(_goAlert) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:accessButton];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
	[[HONAnalyticsParams sharedInstance] trackEvent:@"First Run - Entering PIN Step 2"];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        				[self _promptForAddressBookPermission];
    
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
    
    } else
        				[self _promptForAddressBookAccess];

}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	_isPopping = NO;
	[_pinTextField becomeFirstResponder];
}



#pragma mark - Navigation
- (void)_goBack {
	_pin = @"";
	_isPopping = YES;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)_goDone {
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		
		KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
		[keychain setObject:@"YES" forKey:CFBridgingRelease(kSecAttrAccount)];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
		
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	}];
}

- (void)_goAlert {
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined)
        [self _promptForAddressBookPermission];
    
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
		[self _goDone];
		
    } else
        [self _promptForAddressBookAccess];
    
}

- (void)_goAlertContacts {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"moji uses your contacts to allow you to send emoji updates to all of your friends. It is fast, easy, and you will always be in control over who can see."
														message:nil
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
											  otherButtonTitles:nil];
	[alertView show];
}

- (void)_goCheat {
	_pinTextField.text = @"0000";
	_pin = _pinTextField.text;
	
	_isPopping = YES;
	[self _goDone];
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
			
		}
	}
}

- (void)_onTextEditingDidEnd:(id)sender {
	_pin = _pinTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}
#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Main View - Alert Prompt Access Contacts %@", (buttonIndex == 0) ? @"No" : @"Yes"]];
		
		NSLog(@"CONTACTS:[%d]", buttonIndex);
		if (buttonIndex == 1) {
			if (ABAddressBookRequestAccessWithCompletion) {
				ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
				NSLog(@"ABAddressBookGetAuthorizationStatus() = [%@]", (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) ? @"kABAuthorizationStatusNotDetermined" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusDenied) ? @"kABAuthorizationStatusDenied" : (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) ? @"kABAuthorizationStatusAuthorized" : @"OTHER");
				
				if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                    });
                    
				} else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
					ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
					});
                    
				} else {
				}
			}
		}
	}
}
#pragma mark - UI Presentation
- (void)_promptForAddressBookAccess {
	[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"ok_access", @"We need your OK to access the address book.")
								message:NSLocalizedString(@"grant_access", @"Flip the switch in Settings -> Privacy -> Contacts -> Selfieclub to grant access.")
							   delegate:nil
					  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
					  otherButtonTitles:nil] show];
}

- (void)_promptForAddressBookPermission {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"allow_access", @"Allow Access to your contacts?")
														message:nil
													   delegate:self
											  cancelButtonTitle:NSLocalizedString(@"alert_no", nil)
											  otherButtonTitles:@"Yes", nil];
	[alertView setTag:0];
	[alertView show];
}

@end
