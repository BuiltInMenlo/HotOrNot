//
//  HONUsernameViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 12.18.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "MBProgressHUD.h"

#import "HONUsernameViewController.h"
#import "HONHeaderView.h"


@interface HONUsernameViewController ()
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIButton *submitButton;
@end

@implementation HONUsernameViewController

- (id)init {
	if ((self = [super init])) {
		_username = [[HONAppDelegate infoForUser] objectForKey:@"username"];
	}
	
	return (self);
}


#pragma mark - Data Calls


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButtonBlue_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Username"];
	[headerView addButton:doneButton];
	[self.view addSubview:headerView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDefault];
	[_usernameTextField setTextColor:[[HONColorAuthority sharedInstance] honPercentGreyscaleColor:0.518]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:18];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"username"];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	UIImageView *dividerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"divider"]];
	dividerImageView.frame = CGRectOffset(dividerImageView.frame, 0.0, 128.0);
	[self.view addSubview:dividerImageView];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitBlueButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_submitButton];
	
	[_usernameTextField becomeFirstResponder];
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
}


#pragma mark - Navigation
- (void)_goClose {
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)_goSubmit {
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
	}];
	
	[_usernameTextField resignFirstResponder];
	
	if ([_usernameTextField.text length] == 0)
		_usernameTextField.text = _username;
	
	_username = _usernameTextField.text;
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_submit", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[[HONAPICaller sharedInstance] updateUsernameForUser:_username completion:^(NSDictionary *result) {
		if (![[result objectForKey:@"result"] isEqualToString:@"fail"]) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			[self dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
			}];
			
		} else {
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_usernameTaken", nil);  //@"Username taken!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			[_usernameTextField becomeFirstResponder];
		}
	}];
}


- (void)_onTextEditingDidEnd:(id)sender {
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 216.0) - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
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
	[textField resignFirstResponder];
}

@end
