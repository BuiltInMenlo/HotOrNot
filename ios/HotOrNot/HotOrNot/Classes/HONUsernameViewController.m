//
//  HONUsernameViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "ASIFormDataRequest.h"
#import "MBProgressHUD.h"

#import "HONAppDelegate.h"
#import "HONHeaderView.h"
#import "HONUsernameViewController.h"

@interface HONUsernameViewController () <UITextFieldDelegate, ASIHTTPRequestDelegate>
@property(nonatomic, strong) NSString *username;
@property(nonatomic, strong) UITextField *usernameTextField;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic, strong) MBProgressHUD *progressHUD;
@end

@implementation HONUsernameViewController

- (id)init {
	if ((self = [super init])) {
		self.view.backgroundColor = [UIColor whiteColor];
		_username = [[HONAppDelegate infoForUser] objectForKey:@"name"];
	}
	
	return (self);
}

- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
	bgImgView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"mainBG-568h.png" : @"mainBG.png"];
	[self.view addSubview:bgImgView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Username"];
	[self.view addSubview:headerView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(261.0, 5.0, 54.0, 34.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive.png"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active.png"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goDone) forControlEvents:UIControlEventTouchUpInside];
	[headerView addSubview:doneButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 70.0, 240.0, 20.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[HONAppDelegate honBlueTxtColor]];
	[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
	_usernameTextField.keyboardType = UIKeyboardTypeDefault;
	_usernameTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"name"];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_editButton.frame = CGRectMake(265.0, 60.0, 44.0, 44.0);
	[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_nonActive.png"] forState:UIControlStateNormal];
	[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_Active.png"] forState:UIControlStateHighlighted];
	[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_editButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(0.0, 100.0, 320.0, 78.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton.png"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"startChallengeButton_active.png"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
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
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goEditSubject {
	_usernameTextField.text = @"";
	[_usernameTextField becomeFirstResponder];
}

- (void)_goSubmit {
	[_usernameTextField resignFirstResponder];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Submitting…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	ASIFormDataRequest *userRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kUsersAPI]]];
	[userRequest setDelegate:self];
	[userRequest setPostValue:[NSString stringWithFormat:@"%d", 2] forKey:@"action"];
	[userRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"id"] forKey:@"userID"];
	[userRequest setPostValue:_username forKey:@"username"];
	[userRequest setPostValue:[[HONAppDelegate infoForUser] objectForKey:@"fb_id"] forKey:@"fbID"];
	[userRequest startAsynchronous];
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


#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONChallengerPickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error.png"]];
			_progressHUD.labelText = NSLocalizedString(@"Update Failed", @"Status message when downloading fails");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
		
		} else {
			if ([userResult objectForKey:@"id"] != [NSNull null])
				[HONAppDelegate writeUserInfo:userResult];
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
	}
}

-(void)requestFailed:(ASIHTTPRequest *)request {
	NSLog(@"requestFailed:\n[%@]", request.error);
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
}

@end
