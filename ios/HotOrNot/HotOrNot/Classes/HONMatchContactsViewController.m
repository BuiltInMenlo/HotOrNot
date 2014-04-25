//
//  HONMatchContactsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONMatchContactsViewController.h"
#import "HONUtilsSuite.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"


@interface HONMatchContactsViewController ()
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL isEmail;
@property (nonatomic) float submitButtonOriginY;
@end

@implementation HONMatchContactsViewController 

- (id)initAsEmailVerify:(BOOL)isEmail {
	if ((self = [super init])) {
		_isEmail = isEmail;
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
- (void)_submitContact {
	void (^completionBlock)(NSObject *result) = ^void(NSObject *result) {
		[[HONAPICaller sharedInstance] showSuccessHUD];
		
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Great!"
															message:@"We will notify you when new friends are on Selfieclub!"
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView setTag:1];
		[alertView show];
	};
	
	if (_isEmail)
		[[HONAPICaller sharedInstance] submitEmailAddressForContactsMatching:_textField.text completion:completionBlock];
	
	else
		[[HONAPICaller sharedInstance] submitPhoneNumberForContactsMatching:_textField.text completion:completionBlock];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:[NSString stringWithFormat:@"Enter your %@", (_isEmail) ? @"email" : @"phone #"]];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:cancelButton];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
	//[_textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_textField setReturnKeyType:UIReturnKeyGo];
	[_textField setTextColor:[UIColor blackColor]];
	[_textField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_textField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_textField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:18];
	_textField.keyboardType = (_isEmail) ? UIKeyboardTypeEmailAddress : UIKeyboardTypePhonePad;
	_textField.placeholder = (_isEmail) ? @"Please provide your email address" : @"Please provide your mobile #";
	_textField.text = @"";
	_textField.delegate = self;
	[self.view addSubview:_textField];
	
	UIImageView *divider1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider1ImageView.frame = CGRectOffset(divider1ImageView.frame, 0.0, 128.0);
	[self.view addSubview:divider1ImageView];
	
	
	_submitButtonOriginY = ([UIScreen mainScreen].bounds.size.height == self.view.frame.size.height) ? [UIScreen mainScreen].bounds.size.height - 53.0 : [UIScreen mainScreen].bounds.size.height - 73.0;
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, _submitButtonOriginY, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[_textField becomeFirstResponder];

	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 delay:1.0 options:UIViewAnimationOptionCurveLinear animations:^(void) {
		_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY - 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);
	} completion:nil];
}


#pragma mark - Navigation
- (void)_goSubmit {
	[_textField resignFirstResponder];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Matching - Cancel", (_isEmail) ? @"Email" : @"Phone"]
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Email Matching - Invalid Email"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		[_textField becomeFirstResponder];
	
	} else if (alertView.tag == 1) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
		[self dismissViewControllerAnimated:YES completion:nil];
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"";
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY - 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	if ([textField.text length] > 0) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Matching - Entered %@", (_isEmail) ? @"Email" : @"Phone", (_isEmail) ? @"Email" : @"Phone"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  textField.text, (_isEmail) ? @"email": @"phone", nil]];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY + 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
		} completion:^(BOOL finished) {
			_submitButton.hidden = YES;
		}];
		
		
		if (_isEmail) {
			if ([HONAppDelegate isValidEmail:textField.text])
				[self _submitContact];
			
			else {
				[[[UIAlertView alloc] initWithTitle:@"No email!"
											message:@"You need to enter a valid email address!"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else
			[self _submitContact];
		
	} else
		textField.text = @"";
}

- (void)_onTextEditingDidEnd:(id)sender {
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}


@end
