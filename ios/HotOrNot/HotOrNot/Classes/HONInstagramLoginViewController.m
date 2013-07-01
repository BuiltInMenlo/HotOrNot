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
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@end


@implementation HONInstagramLoginViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Instagram Login - Open"
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
- (void)_submitLogin {
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
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
			
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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


#pragma mark - View lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [HONAppDelegate honOrthodoxGreenColor];
	
	UIImageView *captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(44.0, ([HONAppDelegate isRetina5]) ? 54.0 : 19.0, 231.0, ([HONAppDelegate isRetina5]) ? 99.0 : 89.0)];
	captionImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"instagramText-568h@2x" : @"instagramText"];
	[self.view addSubview:captionImageView];
	
	UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
	skipButton.frame = CGRectMake(248.0, 4.0, 64.0, 44.0);
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_nonActive"] forState:UIControlStateNormal];
	[skipButton setBackgroundImage:[UIImage imageNamed:@"skipButton_Active"] forState:UIControlStateHighlighted];
	[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:skipButton];
	
	UIImageView *usernameBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, ([HONAppDelegate isRetina5]) ? 192.0 : 134.0, 244.0, 44.0)];
	usernameBGImageView.image = [UIImage imageNamed:@"fue_inputField_nonActive"];
	[self.view addSubview:usernameBGImageView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(55.0, ([HONAppDelegate isRetina5]) ? 201.0 : 142.0, 200.0, 30.0)];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyNext];
	[_usernameTextField setTextColor:[HONAppDelegate honGrey710Color]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = @"";
	_usernameTextField.delegate = self;
	[_usernameTextField setTag:0];
	[self.view addSubview:_usernameTextField];
	
	
	UIImageView *passwordBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, ([HONAppDelegate isRetina5]) ? 267.0 : 195.0, 244.0, 44.0)];
	passwordBGImageView.image = [UIImage imageNamed:@"fue_inputField_nonActive"];
	[self.view addSubview:passwordBGImageView];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(55.0, ([HONAppDelegate isRetina5]) ? 274.0 : 202.0, 200.0, 30.0)];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_passwordTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_passwordTextField setReturnKeyType:UIReturnKeyGo];
	[_passwordTextField setTextColor:[HONAppDelegate honGrey710Color]];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_passwordTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_passwordTextField.keyboardType = UIKeyboardTypeDefault;
	_passwordTextField.secureTextEntry = YES;
	_passwordTextField.text = @"";
	_passwordTextField.delegate = self;
	[_passwordTextField setTag:1];
	[self.view addSubview:_passwordTextField];
		
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
- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Instagram Login - Skip"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
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
	
	if ([_usernameTextField.text length] == 0)
		[_usernameTextField becomeFirstResponder];
	
	else {
		if ([_passwordTextField.text length] == 0)
			[_passwordTextField becomeFirstResponder];
		
		else {
			[[Mixpanel sharedInstance] track:@"Instagram Login - Submit"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											  _usernameTextField.text, @"username", nil]];
			
			[self _submitLogin];
		}
	}
}

- (void)_onTextEditingDidEnd:(id)sender {
	NSLog(@"_onTextEditingDidEnd");
	
	
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	NSLog(@"_onTextEditingDidEndOnExit");
}

@end
