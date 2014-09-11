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


#pragma mark - Data Calls
- (void)_generateClub:(HONUserClubVO *)vo {
//	[[HONAPICaller sharedInstance] createClubWithTitle:vo.clubName withDescription:vo.blurb withImagePrefix:vo.coverImagePrefix completion:^(NSDictionary *result) {
//	}];
}

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
		
		[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"First Run - %@ PIN Step 2", (BOOL)([[result objectForKey:@"result"] intValue] == 1) ? @"Success" : @"Failure"]];
		
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
	[[HONAPICaller sharedInstance] retrieveLocalSchoolTypeClubsWithAreaCode:[[HONDeviceIntrinsics sharedInstance] areaCodeFromPhoneNumber] completion:^(NSDictionary *result) {
		NSMutableArray *schools = [NSMutableArray array];
		for (NSDictionary *club in [result objectForKey:@"clubs"]) {
			NSMutableDictionary *dict = [club mutableCopy];
			[dict setValue:@"HIGH_SCHOOL" forKey:@"club_type"];
			HONUserClubVO *vo = [HONUserClubVO clubWithDictionary:dict];
			
			NSLog(@"vo:[%@]", vo.clubName);
			[schools addObject:dict];
		}
		
		if ([[NSUserDefaults standardUserDefaults] objectForKey:@"high_schools"] != nil)
			[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"high_schools"];
		
		[[NSUserDefaults standardUserDefaults] setObject:[schools copy] forKey:@"high_schools"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
	
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
		
		KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
		[keychain setObject:@"YES" forKey:CFBridgingRelease(kSecAttrAccount)];
		
		[[HONClubAssistant sharedInstance] copyUserSignupClubToClipboardWithAlert:NO];
		
		
		__block int cnt = 0;
		[[[HONClubAssistant sharedInstance] suggestedClubs] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *fisnished) {
			HONUserClubVO *vo = (HONUserClubVO *)obj;
			[self performSelector:@selector(_generateClub:) withObject:vo afterDelay:0.0];
			cnt++;
		}];
		
//		UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
//		pasteboard.string = [NSString stringWithFormat:@"I have created the Selfieclub %@! Tap to join: http://joinselfie.club/%@/%@", [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""], [[HONAppDelegate infoForUser] objectForKey:@"username"], [[[HONAppDelegate infoForUser] objectForKey:@"username"] stringByAppendingString:@""]];
		
		//[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
		[[NSNotificationCenter defaultCenter] postNotificationName:@"COMPLETED_FIRST_RUN" object:nil];
		
		[[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"enter_pin", @"Enter Pin"])];
	[self.view addSubview:headerView];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = CGRectMake(-4.0, 1.0, 44.0, 44.0);
	[backButton setBackgroundImage:[UIImage imageNamed:@"backArrowButton_nonActive"] forState:UIControlStateNormal];
	[backButton setBackgroundImage:[UIImage imageNamed:@"backArrowButton_Active"] forState:UIControlStateHighlighted];
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:backButton];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - 66.0, 1.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"arrowButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"arrowButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:doneButton];
	
	 
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
        
    } else
        [self _promptForAddressBookAccess];
    
}

- (void)_goCheat {
	_pinTextField.text = @"0000";
	_pin = _pinTextField.text;
	
	_isPopping = YES;
	[self _finishFirstRun];
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
