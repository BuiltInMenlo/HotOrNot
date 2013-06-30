//
//  HONInstagramLoginViewController.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/24/13 @ 7:29 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONInstagramLoginViewController.h"


@interface HONInstagramLoginViewController () <UITextFieldDelegate>
@property (nonatomic, retain) UITextField *usernameTextField;
@property (nonatomic, retain) UITextField *passwordTextField;
@property (nonatomic, retain) UIButton *submitButton;
@end


@implementation HONInstagramLoginViewController

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
- (void)_submitLogin {
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
							[NSString stringWithFormat:@"%d", 12], @"action",
							[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
							_usernameTextField.text, @"instau",
							_passwordTextField.text, @"instap", nil];
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers);
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
	}];
}


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [HONAppDelegate honOrthodoxGreenColor];
	
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:doneButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.0, 100.0, 200.0, 30.0)];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyNext];
	[_usernameTextField setTextColor:[UIColor whiteColor]];
	_usernameTextField.backgroundColor = [HONAppDelegate honDebugGreenColor];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = @"";
	_usernameTextField.delegate = self;
	[_usernameTextField setTag:0];
	[self.view addSubview:_usernameTextField];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(60.0, 150.0, 200.0, 30.0)];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_passwordTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_passwordTextField setReturnKeyType:UIReturnKeyGo];
	[_passwordTextField setTextColor:[UIColor whiteColor]];
	_passwordTextField.backgroundColor = [HONAppDelegate honDebugRedColor];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_passwordTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_passwordTextField.keyboardType = UIKeyboardTypeDefault;
	_passwordTextField.secureTextEntry = YES;
	_passwordTextField.text = @"";
	_passwordTextField.delegate = self;
	[_passwordTextField setTag:1];
	[self.view addSubview:_passwordTextField];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 73.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
	
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
	}];
	
	[_usernameTextField becomeFirstResponder];
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
- (void)_goDone {
	[[Mixpanel sharedInstance] track:@"Instagram Login - Done"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goNext {
	if ([_usernameTextField.text length] > 0 && [_passwordTextField.text length] > 0) {
		[[Mixpanel sharedInstance] track:@"Instagram Login - Submit"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  _usernameTextField.text, @"mobile", nil]];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
		} completion:^(BOOL finished) {
			_submitButton.hidden = YES;
		}];
		
		[self _submitLogin];
		
	} else
		NSLog(@"CANT LOGIN");
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"";
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	NSLog(@"textFieldDidEndEditing");
	
	
}

- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"_onTextEditingDidEnd");
	
	
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"_onTextEditingDidEndOnExit");
}

@end
