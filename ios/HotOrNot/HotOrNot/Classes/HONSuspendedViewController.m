//
//  HONSuspendedViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 10/25/13 @ 3:18 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "HONSuspendedViewController.h"
#import "HONHeaderView.h"

@interface HONSuspendedViewController ()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *passcode;
@property (nonatomic, strong) UITextField *passcodeTextField;
@property (nonatomic, strong) UIButton *submitButton;

@end


@implementation HONSuspendedViewController

- (id)init {
	if ((self = [super init])) {
		
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Account Suspended"];
	[self.view addSubview:headerView];
	
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 80.0, 320.0, 20.0)];
	label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:16];
	label.textColor = [UIColor grayColor];
	label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	label.numberOfLines = 0;
	label.text = @"Your account has been suspended!";
	[self.view addSubview:label];

	
	UIButton *requestButton = [UIButton buttonWithType:UIButtonTypeCustom];
	requestButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0);
	[requestButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_nonActive"] forState:UIControlStateNormal];
	[requestButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_Active"] forState:UIControlStateHighlighted];
	[requestButton addTarget:self action:@selector(_goMail) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:requestButton];

	
	
	
	
//
//	UIImageView *txtBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"registerSelected"]];
//	txtBGImageView.frame = CGRectOffset(txtBGImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 333.0);
//	[self.view addSubview:txtBGImageView];
//	
//	_passcodeTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, [UIScreen mainScreen].bounds.size.height - 315.0, 250.0, 30.0)];
//	[_passcodeTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
//	[_passcodeTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
//	_passcodeTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
//	[_passcodeTextField setReturnKeyType:UIReturnKeyDone];
//	[_passcodeTextField setTextColor:[UIColor blackColor]];
//	[_passcodeTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
//	[_passcodeTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
//	_passcodeTextField.font = [[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:18];
//	_passcodeTextField.keyboardType = UIKeyboardTypeAlphabet;
//	_passcodeTextField.text = @"";
//	_passcodeTextField.delegate = self;
//	[self.view addSubview:_passcodeTextField];
//	
//	UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
//	dividerImageView.frame = CGRectOffset(dividerImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 334.0);
//	[self.view addSubview:dividerImageView];
//	
//	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0);
//	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_nonActive"] forState:UIControlStateNormal];
//	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_Active"] forState:UIControlStateHighlighted];
//	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:_submitButton];
//
//	[_passcodeTextField becomeFirstResponder];
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
- (void)_goMail {
	
	if ([MFMailComposeViewController canSendMail]) {
		MFMailComposeViewController *mailComposeViewController = [[MFMailComposeViewController alloc] init];
		mailComposeViewController.mailComposeDelegate = self;
		[mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@selfieclubapp.com"]];
		[mailComposeViewController setSubject:@"Account Suspended"];
		[mailComposeViewController setMessageBody:[NSString stringWithFormat:@"%@ - %@\nType your desired email address here.", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]] isHTML:NO];
		
		[self presentViewController:mailComposeViewController animated:YES completion:^(void) {}];
		
	} else {
		[[[UIAlertView alloc] initWithTitle:@"Email Error"
									message:@"Cannot send email from this device!"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (void)_goSubmit {

	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - _submitButton.frame.size.height, 320.0, _submitButton.frame.size.height);
	} completion:^(BOOL finished) {
		_submitButton.hidden = YES;
	}];
	
	[[HONAPICaller sharedInstance] submitPasscodeToLiftAccountSuspension:_passcode completion:^(NSDictionary *result) {
		if ((BOOL)[[result objectForKey:@"result"] intValue]) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Passcode Verified!"
																message:@"Your account has been re-instated"
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView setTag:0];
			[alertView show];
		
		} else {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = @"Passcode Failed!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;

			_passcode = @"";
			[_passcodeTextField becomeFirstResponder];
		}
	}];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_passcode = _passcodeTextField.text;
	[self _goSubmit];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"_onTextEditingDidEndOnExit");
}


#pragma mark - MailCompose Delegates
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	
	NSString *mpAction = @"";
	switch (result) {
		case MFMailComposeResultCancelled:
			mpAction = @"Canceled";
			break;
		
		case MFMailComposeResultFailed:
			mpAction = @"Failed";
			break;
			
		case MFMailComposeResultSaved:
			mpAction = @"Saved";
			break;
			
		case MFMailComposeResultSent:
			mpAction = @"Sent";
			break;
			
		default:
			mpAction = @"Not Sent";
			break;
	}
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 269.0, 320.0, _submitButton.frame.size.height);
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
//	_usernameLabel.hidden = (textField.tag == 0);
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
//	_usernameLabel.hidden = ([_usernameTextField.text length] > 0);
	_passcode = textField.text;
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[self dismissViewControllerAnimated:YES completion:^(void) {}];
	}
}

@end
