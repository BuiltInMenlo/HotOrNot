//
//  HONRegisterViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImageView+AFNetworking.h"

#import "HONRegisterViewController.h"
#import "HONHeaderView.h"
#import "HONRegisterCameraViewController.h"


@interface HONRegisterViewController () <UITextFieldDelegate>
@property (nonatomic, strong) UIImagePickerController *previewPicker;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIView *usernameHolderView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, retain) UIButton *usernameButton;
@property (nonatomic, retain) UIButton *passwordButton;
@property (nonatomic, retain) UIButton *birthdayButton;
@property (nonatomic, strong) UIView *tutorialHolderView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) NSTimer *clockTimer;
@property (nonatomic) int uploadCounter;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didShowViewController:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
		_username = [[HONAppDelegate infoForUser] objectForKey:@"name"];
		
		[[Mixpanel sharedInstance] track:@"Register - Show"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		_isFirstAppearance = YES;
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
- (void)_submitUsername {
	if ([[_username substringToIndex:1] isEqualToString:@"@"])
		_username = [_username substringFromIndex:1];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 7], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									_username, @"username",
									nil];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_checkUsername", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_updateFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if (![[userResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				[HONAppDelegate writeUserInfo:userResult];
				[self _presentCamera];
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_usernameTaken", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
				
				[_usernameTextField becomeFirstResponder];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description],[HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
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
	
	//[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
	
	_headerView = [[HONHeaderView alloc] initWithTitle:@"Register for Volley"];
	[_headerView hideRefreshing];
	[self.view addSubview:_headerView];
	
	_usernameHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -[UIScreen mainScreen].bounds.size.height, 320.0, [UIScreen mainScreen].bounds.size.height)];
	[self.view addSubview:_usernameHolderView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, 44.0, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
	_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 65.0, 308.0, 26.0)];
	_usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_usernameLabel.textColor = [HONAppDelegate honGrey710Color];
	_usernameLabel.backgroundColor = [UIColor clearColor];
	_usernameLabel.text = @"Enter username";
	[self.view addSubview:_usernameLabel];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 65.0, 308.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor blackColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.text = @"";
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	UIImageView *divider1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider1ImageView.frame = CGRectOffset(divider1ImageView.frame, 0.0, 108.0);
	[self.view addSubview:divider1ImageView];
	
	_passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_passwordButton.frame = CGRectMake(0.0, 109.0, 320.0, 64.0);
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_passwordButton addTarget:self action:@selector(_goPassword) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_passwordButton];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 131.0, 230.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_passwordTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_passwordTextField setReturnKeyType:UIReturnKeyDone];
	[_passwordTextField setTextColor:[UIColor blackColor]];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_passwordTextField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_passwordTextField.keyboardType = UIKeyboardTypeAlphabet;
	_passwordTextField.secureTextEntry = YES;
	_passwordTextField.placeholder = @"Enter password";
	_passwordTextField.text = @"";
	[_passwordTextField setTag:1];
	_passwordTextField.delegate = self;
	[self.view addSubview:_passwordTextField];
	
	UIImageView *divider2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider2ImageView.frame = CGRectOffset(divider2ImageView.frame, 0.0, 173.0);
	[self.view addSubview:divider2ImageView];
	
	_birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 191.0, 296.0, 30.0)];
	_birthdayLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_birthdayLabel.textColor = [HONAppDelegate honGrey710Color];
	_birthdayLabel.backgroundColor = [UIColor clearColor];
	_birthdayLabel.text = @"What is your birthday?";
	[self.view addSubview:_birthdayLabel];
	
	_birthdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_birthdayButton.frame = CGRectMake(0.0, 174.0, 320.0, 64.0);
	[_birthdayButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_birthdayButton addTarget:self action:@selector(_goPicker) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_birthdayButton];
	
	UIImageView *divider3ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider3ImageView.frame = CGRectOffset(divider3ImageView.frame, 0.0, 238.0);
	[self.view addSubview:divider3ImageView];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 53.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	NSDateFormatter *dateFormat2 = [[NSDateFormatter alloc] init];
	[dateFormat2 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0)];
	_datePicker.date = [dateFormat2 dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]];
	_datePicker.datePickerMode = UIDatePickerModeDate;
	_datePicker.minimumDate = [dateFormat dateFromString:@"1970-01-01"];
	_datePicker.maximumDate = [NSDate date];
	[_datePicker addTarget:self action:@selector(_pickerValueChanged) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_datePicker];
	_birthday = [[HONAppDelegate infoForUser] objectForKey:@"age"];
	
	_tutorialHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[self.view addSubview:_tutorialHolderView];
	
	UIImageView *page1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _tutorialHolderView.frame.size.height)];
	page1ImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"fue_dynamicImage_A-568h@2x" : @"fue_dynamicImage_A"];
	page1ImageView.userInteractionEnabled = YES;
	page1ImageView.backgroundColor = [UIColor whiteColor];
	[_tutorialHolderView addSubview:page1ImageView];
	
	UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeTutorialButton.frame = CGRectMake(53.0, 371.0, 214.0, 49.0);
	[closeTutorialButton setBackgroundImage:[UIImage imageNamed:@"signUpButton_nonActive"] forState:UIControlStateNormal];
	[closeTutorialButton setBackgroundImage:[UIImage imageNamed:@"signUpButton_Active"] forState:UIControlStateHighlighted];
	[closeTutorialButton addTarget:self action:@selector(_goCloseTutorial) forControlEvents:UIControlEventTouchUpInside];
	[_tutorialHolderView addSubview:closeTutorialButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if (_isFirstAppearance) {
		_isFirstAppearance = NO;
		
		if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
			UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
			imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
			imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
			imagePickerController.delegate = nil;
		
			imagePickerController.showsCameraControls = NO;
			imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f);
			imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
			
			UIView *overlayView = [[UIView alloc] initWithFrame:self.view.frame];
			UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
			closeTutorialButton.frame = CGRectMake(53.0, _tutorialHolderView.frame.size.height - (([HONAppDelegate isRetina5]) ? 129.0 : 118.0), 214.0, 49.0);
			[closeTutorialButton setBackgroundImage:[UIImage imageNamed:@"signUpButton_nonActive"] forState:UIControlStateNormal];
			[closeTutorialButton setBackgroundImage:[UIImage imageNamed:@"signUpButton_Active"] forState:UIControlStateHighlighted];
			[closeTutorialButton addTarget:self action:@selector(_goCloseTutorial) forControlEvents:UIControlEventTouchUpInside];
			[overlayView addSubview:closeTutorialButton];
			imagePickerController.cameraOverlayView = overlayView;
		
			self.previewPicker = imagePickerController;
			[self presentViewController:self.previewPicker animated:NO completion:nil];
		}
	}
}


#pragma mark - Navigation
- (void)_goCloseTutorial {
	[[Mixpanel sharedInstance] track:@"Register - Close Splash"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.previewPicker dismissViewControllerAnimated:NO completion:^(void) {}];
	
	[_usernameTextField becomeFirstResponder];
	[_usernameButton setSelected:YES];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
}

- (void)_goUsername {
	[_usernameTextField becomeFirstResponder];
}

- (void)_goPassword {
	[_passwordTextField becomeFirstResponder];
}

- (void)_goPicker {
	[_usernameButton setSelected:NO];
	[_passwordButton setSelected:NO];
	[_birthdayButton setSelected:YES];
	[_usernameTextField resignFirstResponder];
	[_passwordTextField resignFirstResponder];
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 216.0) - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	}];
}

- (void)_goSubmit {
	if ([_usernameTextField.text isEqualToString:@""] || [_usernameTextField.text isEqualToString:@"@"]) {
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
									message:@"You need to enter a username to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	
	} else {
		if ([[NSDate date] timeIntervalSinceDate:_datePicker.date] > ((60 * 60 * 24) * 365) * 20) {
			[[[UIAlertView alloc] initWithTitle:@""
										message:@"Volley is intended for young adults 13-19, you may get flagged by the userbase."
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			
			[self _submitUsername];
		
		} else {
			if ([_passwordTextField.text length] == 0) {
				[[[UIAlertView alloc] initWithTitle:@"No Password!"
											message:@"You need to enter a password to start snapping"
										   delegate:nil
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[_passwordTextField becomeFirstResponder];
			
			} else
				[self _submitUsername];
		}
	}
}

#pragma mark - UI Presentation
- (void)_presentCamera {
	[self.navigationController pushViewController:[[HONRegisterCameraViewController alloc] initWithPassword:_password andBirthday:_birthday] animated:NO];
}

- (void)_pickerValueChanged {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	_birthday = [dateFormat stringFromDate:_datePicker.date];
	
	
	//NSLog(@"DIFF:[%f]", [[NSDate date] timeIntervalSinceDate:_datePicker.date]);
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		[_usernameButton setSelected:YES];
		[_passwordButton setSelected:NO];
		[_birthdayButton setSelected:NO];
	
	} else {
		[_usernameButton setSelected:NO];
		[_passwordButton setSelected:YES];
		[_birthdayButton setSelected:NO];
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0);
		_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
	} completion:^(BOOL finished) {
		_submitButton.hidden = YES;
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 0) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"@";
		
		_usernameLabel.hidden = (textField.tag == 0);
	}
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_usernameLabel.hidden = ([_usernameTextField.text length] > 0);
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height - 216.0) - _submitButton.frame.size.height, _submitButton.frame.size.width, _submitButton.frame.size.height);
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
	}];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = ([_usernameTextField.text length] > 0 && [[_usernameTextField.text substringToIndex:1] isEqualToString:@"@"]) ? [_usernameTextField.text substringFromIndex:1] : _usernameTextField.text;
	_password = _passwordTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}

@end
