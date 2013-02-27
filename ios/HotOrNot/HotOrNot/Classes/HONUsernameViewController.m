//
//  HONUsernameViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"

#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONUsernameViewController.h"

@interface HONUsernameViewController () <UITextFieldDelegate>
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) UITextField *usernameTextField;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONUsernameViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Change Username"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		self.view.backgroundColor = [UIColor whiteColor];
		_username = [[HONAppDelegate infoForUser] objectForKey:@"name"];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}

- (void)dealloc {
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return (NO);
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience3rdStepBackground-568h" : @"cameraExperience3rdStepBackground"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"CHANGE USERNAME"];
	[self.view addSubview:headerView];
	
	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	cancelButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:cancelButton];
	
	UIImageView *subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(23.0, 70.0, 274.0, 44.0)];
	subjectBGImageView.image = [UIImage imageNamed:@"cameraInputField_nonActive"];
	subjectBGImageView.userInteractionEnabled = YES;
	[self.view addSubview:subjectBGImageView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 13.0, 240.0, 20.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor blackColor]];
	[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:16];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"name"];
	_usernameTextField.delegate = self;
	[subjectBGImageView addSubview:_usernameTextField];
	
	_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_editButton.frame = CGRectMake(237.0, 5.0, 34.0, 34.0);
	[_editButton setBackgroundImage:[UIImage imageNamed:@"clearTextButton_nonActive"] forState:UIControlStateNormal];
	[_editButton setBackgroundImage:[UIImage imageNamed:@"clearTextButton_Active"] forState:UIControlStateHighlighted];
	[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
	[subjectBGImageView addSubview:_editButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(18.0, 187.0, 283.0, 78.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitUserNameButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitUserNameButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidUnload {
	[super viewDidUnload];
}


#pragma mark - Navigation
- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Change Username - Close"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goEditSubject {
	[[Mixpanel sharedInstance] track:@"Change Username - Edit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_usernameTextField.text = @"";
	[_usernameTextField becomeFirstResponder];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Change Username - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_usernameTextField resignFirstResponder];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Submitting…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 7], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									_username, @"username",
									nil];
	
	[httpClient postPath:kUsersAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			NSLog(@"HONUsernameViewController AFNetworking - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"Update Failed", @"Status message when update fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			//NSLog(@"HONUsernameViewController AFNetworking: %@", userResult);
			
			if (![[userResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				[HONAppDelegate writeUserInfo:userResult];
				[self dismissViewControllerAnimated:YES completion:^(void) {
					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_SETTINGS_TAB" object:nil];
				}];
				
			} else {
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"Username taken!", @"Status message when update fails");
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"UsernameViewController AFNetworking %@", [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"Connection Error!", @"Status message when no network detected");
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	_editButton.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_editButton.hidden = NO;
	
	if ([textField.text length] == 0)
		textField.text = _username;
	
	else
		_username = textField.text;
}

@end
