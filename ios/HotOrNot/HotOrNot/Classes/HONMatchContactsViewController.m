//
//  HONMatchContactsViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONMatchContactsViewController.h"
#import "HONHeaderView.h"


@interface HONMatchContactsViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
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
- (void)_submitVerify {
	NSDictionary *params = @{@"userID"							: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"code"							: [[HONAppDelegate infoForUser] objectForKey:@"sms_code"],
							 (_isEmail) ? @"email" : @"phone"	: _textField.text};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], (_isEmail) ? kAPIEmailVerify : kAPIPhoneVerify);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:(_isEmail) ? kAPIEmailVerify : kAPIPhoneVerify parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkIcon"]];
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[self dismissViewControllerAnimated:YES completion:nil];
			result = nil;
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelWhiteButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelWhiteButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:[NSString stringWithFormat:@"Find friends from my %@", (_isEmail) ? @"email" : @"phone #"] hasTranslucency:NO];
	[_headerView addButton:cancelButton];
	[self.view addSubview:_headerView];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
	//[_textField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_textField setReturnKeyType:UIReturnKeyGo];
	[_textField setTextColor:[UIColor blackColor]];
	[_textField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_textField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_textField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
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
				[self _submitVerify];
			
			else {
				[[[UIAlertView alloc] initWithTitle:@"No email!"
											message:@"You need to enter a valid email address!"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
			}
			
		} else
			[self _submitVerify];
		
	} else
		textField.text = @"";
}

- (void)_onTextEditingDidEnd:(id)sender {
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}


@end
