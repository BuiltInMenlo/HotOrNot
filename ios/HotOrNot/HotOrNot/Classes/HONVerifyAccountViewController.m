//
//  HONVerifyAccountViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.09.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONVerifyAccountViewController.h"


@interface HONVerifyAccountViewController () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, retain) UITextField *textField;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic) BOOL isEmail;
@property (nonatomic) float submitButtonOriginY;
@end

@implementation HONVerifyAccountViewController 

- (id)initAsEmailVerify:(BOOL)isEmail {
	if ((self = [super init])) {
		_isEmail = isEmail;
		
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Verification - Open", (_isEmail) ? @"Email" : @"Phone"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
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
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							[[HONAppDelegate infoForUser] objectForKey:@"sms_code"], @"code",
							_textField.text, (_isEmail) ? @"email" : @"phone", nil];
	
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
//			VolleyJSONLog(@"//—> AFNetworking -{%@}- (%@) %@", [[self class] description], [[operation request] URL], result);
			
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
	
	UIImageView *captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(44.0, ([HONAppDelegate isRetina4Inch]) ? 54.0 : 19.0, 231.0, ([HONAppDelegate isRetina4Inch]) ? 99.0 : 89.0)];
	captionImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? (_isEmail) ? @"verifyEmailText-568h@2x" : @"verifyPhoneText-568h@2x" : (_isEmail) ? @"verifyEmailText" : @"verifyPhoneText"];
	[self.view addSubview:captionImageView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(252.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	UIImageView *usernameBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, ([HONAppDelegate isRetina4Inch]) ? 192.0 : 130.0, 244.0, 44.0)];
	usernameBGImageView.image = [UIImage imageNamed:@"firstRunInputBG"];
	[self.view addSubview:usernameBGImageView];
	
	_textField = [[UITextField alloc] initWithFrame:CGRectMake(55.0, ([HONAppDelegate isRetina4Inch]) ? 201.0 : 138.0, 210.0, 30.0)];
	[_textField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_textField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_textField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_textField setReturnKeyType:UIReturnKeyGo];
	[_textField setTextColor:[HONAppDelegate honBlueTextColor]];
	[_textField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_textField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_textField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_textField.keyboardType = (_isEmail) ? UIKeyboardTypeEmailAddress : UIKeyboardTypePhonePad;
	_textField.text = @"";
	_textField.delegate = self;
	[self.view addSubview:_textField];
	
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

- (void)_goDone {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Verification - Done", (_isEmail) ? @"Email" : @"Phone"]
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
																		 message:[NSString stringWithFormat:@"Really!? %@ is more fun with friends!", [HONAppDelegate brandedAppName]]
																		delegate:self
															cancelButtonTitle:@"Cancel"
															otherButtonTitles:@"Yes, I'm Sure", nil];
	[alertView setTag:0];
	[alertView show];
}


#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		switch(buttonIndex) {
			case 0:
				[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Verification - Done Cancel", (_isEmail) ? @"Email" : @"Phone"]
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				break;
				
			case 1:
				[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Verification - Done Confirm", (_isEmail) ? @"Email" : @"Phone"]
											 properties:[NSDictionary dictionaryWithObjectsAndKeys:
															 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
				[self dismissViewControllerAnimated:YES completion:nil];
				break;
		}
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
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"%@ Verification - Entered %@", (_isEmail) ? @"Email" : @"Phone", (_isEmail) ? @"Email" : @"Phone"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  textField.text, (_isEmail) ? @"email": @"phone", nil]];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_submitButton.frame = CGRectMake(_submitButton.frame.origin.x, _submitButtonOriginY + 216.0, _submitButton.frame.size.width, _submitButton.frame.size.height);//_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
		} completion:^(BOOL finished) {
			_submitButton.hidden = YES;
		}];
		
		[self _submitVerify];
		
	} else
		textField.text = @"";
}

- (void)_onTextEditingDidEnd:(id)sender {
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}



@end
