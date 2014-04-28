//
//  HONRegisterViewController.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 03.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "ImageFilter.h"
#import "MBProgressHUD.h"

#import "HONRegisterViewController.h"
#import "HONEnterPINViewController.h"
#import "HONHeaderView.h"


#define SPLASH_BLUE_TINT_COLOR		[UIColor colorWithRed:0.008 green:0.373 blue:0.914 alpha:0.667]
#define SPLASH_MAGENTA_TINT_COLOR	[UIColor colorWithRed:0.910 green:0.009 blue:0.520 alpha:0.667]
#define SPLASH_GREEN_TINT_COLOR		[UIColor colorWithRed:0.009 green:0.910 blue:0.178 alpha:0.667]
#define SPLASH_TINT_FADE_DURATION	2.50f
#define SPLASH_TINT_TIMER_DURATION	3.33f


@interface HONRegisterViewController ()
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
@property (nonatomic, strong) UIImagePickerController *profileImagePickerController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *imageFilename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UIButton *addAvatarButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *phone1TextField;
@property (nonatomic, strong) UITextField *phone2TextField;
@property (nonatomic, strong) UITextField *phone3TextField;
@property (nonatomic, strong) UIButton *usernameButton;
@property (nonatomic, strong) UIButton *passwordButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIImageView *usernameCheckImageView;
@property (nonatomic, strong) UIImageView *passwordCheckImageView;
@property (nonatomic, strong) UIImageView *phoneCheckImageView;
@property (nonatomic, strong) UIView *profileCameraOverlayView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *tintedMatteView;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic) int tintIndex;

@property (nonatomic) int selfieAttempts;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		[[Mixpanel sharedInstance] track:@"Register - Show" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
		
		_username = [[HONAppDelegate infoForUser] objectForKey:@"username"];
		_imageFilename = @"";
		_isFirstAppearance = YES;
		_selfieAttempts = 0;
		_tintIndex = 0;
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
- (void)_checkUsername {
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_username andPhone:[_phone stringByAppendingString:@"@selfieclub.com"] completion:^(NSObject *result) {
		if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 0) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[self _finalizeUser];
			
		} else {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 1) ? @"Username taken!" : ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 2) ? @"Phone # taken!" : @"Username & phone # taken!";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 1) {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_usernameTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
			}
			
			else if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 2) {
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_phone = @"";
				_phone1TextField.text = @"";
				_phone1TextField.text = @"";
				_phone1TextField.text = @"";
				[_phone1TextField becomeFirstResponder];
			
			} else {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_usernameTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
				
				_phone = @"";
				_phone1TextField.text = @"";
				_phone1TextField.text = @"";
				_phone1TextField.text = @"";
			}
			
			_usernameCheckImageView.alpha = 1.0;
			_phoneCheckImageView.alpha = 1.0;
		}
	}];
}

- (void)_uploadPhotos:(UIImage *)image {
	_imageFilename = [NSString stringWithFormat:@"%@_%@-%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], [[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], _imageFilename);
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucketType:HONS3BucketTypeAvatars withFilename:_imageFilename completion:^(NSObject *result) {}];
	
	
}

- (void)_finalizeUser {
	[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																@"username"	: _username,
																@"email"	: _password,
																@"birthday"	: @"0000-00-00 00:00:00",
																@"filename"	: _imageFilename} completion:^(NSObject *result) {
		if (result != nil) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[[HONAPICaller sharedInstance] submitPhoneNumberForContactsMatching:_phone completion:^(NSObject *result) {}];
			
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			
			[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
			
			Mixpanel *mixpanel = [Mixpanel sharedInstance];
			[mixpanel identify:[[HONDeviceIntrinsics sharedInstance] advertisingIdentifierWithoutSeperators:NO]];
			[mixpanel.people set:@{@"$email"		: [[HONAppDelegate infoForUser] objectForKey:@"email"],
								   @"$created"		: [[HONAppDelegate infoForUser] objectForKey:@"added"],
								   @"id"			: [[HONAppDelegate infoForUser] objectForKey:@"id"],
								   @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
								   @"deactivated"	: [[NSUserDefaults standardUserDefaults] objectForKey:@"is_deactivated"]}];
			
			[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
			[[NSUserDefaults standardUserDefaults] synchronize];
			
			[[HONAPICaller sharedInstance] retrieveFollowingUsersForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSObject *result){
				[HONAppDelegate writeFollowingList:(NSArray *)result];
			}];
			
//			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
				
				if ([HONAppDelegate switchEnabledForKey:@"firstrun_subscribe"])
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
				
				else
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_CONTACTS_TUTORIAL" object:nil];
			}];
			
			
//			[self.navigationController pushViewController:[[HONEnterPINViewController alloc] init] animated:YES];
			
		} else {
			int errorCode = [[(NSDictionary *)result objectForKey:@"result"] intValue];
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = (errorCode == 1) ? @"Username taken!" : (errorCode == 2) ? @"Phone # taken!" : (errorCode == 3) ? @"Username & phone # taken!" : @"Unknown Error";
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			if (errorCode == 1)
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
			
			else if (errorCode == 2)
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
			
			else {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
			}
			
			_usernameCheckImageView.alpha = 1.0;
			_phoneCheckImageView.alpha = 1.0;
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(227.0, 0.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Registration"];
	[headerView addButton:doneButton];
	[self.view addSubview:headerView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG"] forState:UIControlStateNormal];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateHighlighted];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 72.0, 48.0, 48.0)];
	[self.view addSubview:_avatarImageView];
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"maskAvatarBlack.png"]];
	
	_addAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_addAvatarButton.frame = _avatarImageView.frame;
	[_addAvatarButton setBackgroundImage:[UIImage imageNamed:@"defaultAvatarBackground"] forState:UIControlStateNormal];
	[_addAvatarButton setBackgroundImage:[UIImage imageNamed:@"defaultAvatarBackground"] forState:UIControlStateHighlighted];
	[_addAvatarButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_addAvatarButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(64.0, 86.0, 220.0, 22.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[[HONColorAuthority sharedInstance] honBlueTextColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.placeholder = @"Enter username";
	_usernameTextField.text = @"";
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	_usernameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_usernameCheckImageView.frame = CGRectOffset(_usernameCheckImageView.frame, 258.0, 65.0);
	_usernameCheckImageView.alpha = 0.0;
	[self.view addSubview:_usernameCheckImageView];
	
	_passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_passwordButton.frame = CGRectMake(0.0, 128.0, 320.0, 64.0);
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"viewCellBG"] forState:UIControlStateNormal];
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateHighlighted];
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"viewCellSelectedBG"] forState:UIControlStateSelected];
	[_passwordButton addTarget:self action:@selector(_goEmail) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_passwordButton];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(21.0, 147.0, 230.0, 22.0)];
//	_passwordTextField.backgroundColor = [UIColor greenColor];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_passwordTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	_passwordTextField.secureTextEntry = YES;
	[_passwordTextField setReturnKeyType:UIReturnKeyDone];
	[_passwordTextField setTextColor:[UIColor blackColor]];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_passwordTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	_passwordTextField.keyboardType = UIKeyboardTypeEmailAddress;
	_passwordTextField.placeholder = @"Enter password";
	_passwordTextField.text = @"";
	[_passwordTextField setTag:1];
	_passwordTextField.delegate = self;
	[self.view addSubview:_passwordTextField];
	
	_passwordCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_passwordCheckImageView.frame = CGRectOffset(_passwordCheckImageView.frame, 258.0, 129.0);
	_passwordCheckImageView.alpha = 0.0;
	[self.view addSubview:_passwordCheckImageView];
	
	_phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_phoneButton.frame = CGRectMake(0.0, 192.0, 320.0, 64.0);
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneNumberBG"] forState:UIControlStateNormal];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneNumberBG"] forState:UIControlStateHighlighted];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneNumberBG"] forState:UIControlStateSelected];
	[_phoneButton addTarget:self action:@selector(_goPhone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_phoneButton];
	
	_phone1TextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 214.0, 40.0, 22.0)];
//	_phone1TextField.backgroundColor = [UIColor redColor];
	[_phone1TextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phone1TextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phone1TextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phone1TextField setReturnKeyType:UIReturnKeyNext];
	[_phone1TextField setTextColor:[UIColor blackColor]];
	[_phone1TextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phone1TextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phone1TextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:16];
	_phone1TextField.keyboardType = UIKeyboardTypeDecimalPad;
	_phone1TextField.text = @"";
	[_phone1TextField setTag:2];
	_phone1TextField.delegate = self;
	[self.view addSubview:_phone1TextField];
	
	_phone2TextField = [[UITextField alloc] initWithFrame:CGRectMake(85.0, _phone1TextField.frame.origin.y, 40.0, 22.0)];
	_phone2TextField.backgroundColor = _phone1TextField.backgroundColor;
	[_phone2TextField setAutocapitalizationType:_phone1TextField.autocapitalizationType];
	[_phone2TextField setAutocorrectionType:_phone1TextField.autocorrectionType];
	_phone2TextField.keyboardAppearance = _phone1TextField.keyboardAppearance;
	[_phone2TextField setReturnKeyType:_phone1TextField.returnKeyType];
	[_phone2TextField setTextColor:_phone1TextField.textColor];
	[_phone2TextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phone2TextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phone2TextField.font = _phone1TextField.font;
	_phone2TextField.keyboardType = _phone1TextField.keyboardType;
	_phone2TextField.text = @"";
	[_phone2TextField setTag:3];
	_phone2TextField.delegate = self;
	[self.view addSubview:_phone2TextField];
	
	_phone3TextField = [[UITextField alloc] initWithFrame:CGRectMake(147.0, _phone1TextField.frame.origin.y, 50.0, 22.0)];
	_phone3TextField.backgroundColor = _phone1TextField.backgroundColor;
	[_phone3TextField setAutocapitalizationType:_phone1TextField.autocapitalizationType];
	[_phone3TextField setAutocorrectionType:_phone1TextField.autocorrectionType];
	_phone3TextField.keyboardAppearance = _phone1TextField.keyboardAppearance;
	[_phone3TextField setReturnKeyType:_phone1TextField.returnKeyType];
	[_phone3TextField setTextColor:_phone1TextField.textColor];
	[_phone3TextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phone3TextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phone3TextField.font = _phone1TextField.font;;
	_phone3TextField.keyboardType = _phone1TextField.keyboardType;
	_phone3TextField.text = @"";
	[_phone3TextField setTag:4];
	_phone3TextField.delegate = self;
	[self.view addSubview:_phone3TextField];
	
	_phoneCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_phoneCheckImageView.frame = CGRectOffset(_phoneCheckImageView.frame, 258.0, 192.0);
	_phoneCheckImageView.alpha = 0.0;
	[self.view addSubview:_phoneCheckImageView];
	
//	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] == nil) {
		[[HONAPICaller sharedInstance] recreateUserWithCompletion:^(NSObject *result){
			if ([(NSDictionary *)result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
				[HONAppDelegate writeUserInfo:(NSDictionary *)result];
				[HONImagingDepictor writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
		}];
	}
	
	[_usernameTextField becomeFirstResponder];
	[_usernameButton setSelected:YES];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
- (void)_goLogin {
	[[Mixpanel sharedInstance] track:@"Register - Login" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
		if ([MFMailComposeViewController canSendMail]) {
			_mailComposeViewController = [[MFMailComposeViewController alloc] init];
			_mailComposeViewController.mailComposeDelegate = self;
			[_mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@selfieclubapp.com"]];
			[_mailComposeViewController setSubject:@"Selfieclub - Help! I need to log back in"];
			[_mailComposeViewController setMessageBody:[NSString stringWithFormat:@"My name is %@ and I need to log back into my account. Please help, my email is %@. Thanks!", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"email"]] isHTML:NO];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
		}
		
	} else {
		[[[UIAlertView alloc] initWithTitle:@"This device has never been logged in!"
									message:@""
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}

- (void)_goCamera {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Camera %@Available", ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? @"" : @"Not "] properties:[[HONAnalyticsParams sharedInstance] userProperty]];
		
	UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
	imagePickerController.view.backgroundColor = [UIColor whiteColor];
	imagePickerController.sourceType = ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? UIImagePickerControllerSourceTypeCamera : UIImagePickerControllerSourceTypePhotoLibrary;
	imagePickerController.delegate = self;
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.65f : 1.0f, ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.65f : 1.0f);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
		_profileCameraOverlayView.alpha = 0.0;
		
		imagePickerController.cameraOverlayView = _profileCameraOverlayView;
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_profileCameraOverlayView.alpha = 1.0;
		} completion:^(BOOL finished) {}];
		
		_tintIndex = 0;
		_tintedMatteView = [[UIView alloc] initWithFrame:_profileCameraOverlayView.frame];
		_tintedMatteView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
		[_profileCameraOverlayView addSubview:_tintedMatteView];
		
		UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_profileCameraOverlayView addSubview:headerBGView];
		
		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flipButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:flipButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(228.0, 3.0, 84.0, 44.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:skipButton];
		
		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 141.0, 320.0, 141.0)];
		gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_profileCameraOverlayView addSubview:gutterView];
		
		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_nonActive"] forState:UIControlStateNormal];
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_Active"] forState:UIControlStateHighlighted];
		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:_changeTintButton];
		
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		takePhotoButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 118.0, 94.0, 94.0);
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		[takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		takePhotoButton.alpha = 0.0;
		[_profileCameraOverlayView addSubview:takePhotoButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(220.0, [UIScreen mainScreen].bounds.size.height - 42.0, 93.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRollButton_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRollButton_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:cameraRollButton];
		
		
//		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		cancelButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
//		[cancelButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
//		[cancelButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//		[cancelButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:cancelButton];
//
//		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		retakeButton.frame = CGRectMake(106.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
//		[retakeButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
//		[retakeButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//		[retakeButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:retakeButton];
//		
//		UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		acceptButton.frame = CGRectMake(212.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
//		[acceptButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
//		[acceptButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//		[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:acceptButton];
			
		[UIView animateWithDuration:0.25 animations:^(void) {
			takePhotoButton.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	}
	
	self.profileImagePickerController = imagePickerController;
	[self presentViewController:self.profileImagePickerController animated:NO completion:^(void) {}];
}

- (void)_goFlipCamera {
	[[Mixpanel sharedInstance] track:@"Register - Switch Camera" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if (self.profileImagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		self.profileImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
	} else {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	}
}

- (void)_goCameraRoll {
	[[Mixpanel sharedInstance] track:@"Register - Camera Roll" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	self.profileImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)_goChangeTint {
	[[Mixpanel sharedInstance] track:@"Register - Change Tint Overlay" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	_tintIndex = ++_tintIndex % [[HONAppDelegate colorsForOverlayTints] count];
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[_tintedMatteView setBackgroundColor:[[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex]];
	[UIView commitAnimations];
}

- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Register - Skip Photo" properties:[[HONAnalyticsParams sharedInstance] userProperty]];

	_imageFilename = @"";
	[self _finalizeUser];
}

- (void)_goTakePhoto {
	[[Mixpanel sharedInstance] track:@"Register - Take Photo" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	_irisView = [[UIView alloc] initWithFrame:_profileCameraOverlayView.frame];
	_irisView.backgroundColor = [UIColor blackColor];
	_irisView.alpha = 0.0;
	[_profileCameraOverlayView addSubview:_irisView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_irisView.alpha = 1.0;
	}];
	
	[self.profileImagePickerController performSelector:@selector(takePicture) withObject:nil afterDelay:0.25];
}

- (void)_goUsername {
	[_usernameTextField becomeFirstResponder];
}

- (void)_goEmail {
	[_passwordTextField becomeFirstResponder];
}

- (void)_goPhone {
	[_phone1TextField becomeFirstResponder];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Register - Submit Username & Email" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if ([_usernameTextField isFirstResponder])
		[_usernameTextField resignFirstResponder];
	
	if ([_passwordTextField isFirstResponder])
		[_passwordTextField resignFirstResponder];
	
	if ([_usernameTextField isFirstResponder])
		[_usernameTextField resignFirstResponder];
	
	if ([_phone1TextField isFirstResponder])
		[_phone1TextField resignFirstResponder];
	
	if ([_phone2TextField isFirstResponder])
		[_phone2TextField resignFirstResponder];
	
	if ([_phone3TextField isFirstResponder])
		[_phone3TextField resignFirstResponder];
	
	[_usernameButton setSelected:NO];
	[_passwordButton setSelected:NO];
	[_phoneButton setSelected:NO];
	
	_usernameCheckImageView.alpha = 1.0;
	_passwordCheckImageView.alpha = 1.0;
	_phoneCheckImageView.alpha = 1.0;
	
	HONRegisterErrorType registerErrorType = ((int)([_usernameTextField.text length] == 0) * HONRegisterErrorTypeUsername) + ((int)([_passwordTextField.text length] < 4) * HONRegisterErrorTypePassword) + ((int)([_phone length] != 10) * HONRegisterErrorTypePassword);
	if (registerErrorType == HONRegisterErrorTypeNone) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		_usernameCheckImageView.alpha = 1.0;
		_passwordCheckImageView.alpha = 1.0;
		_phoneCheckImageView.alpha = 1.0;
		
		_username = _usernameTextField.text;
		_password = _passwordTextField.text;
		
		[self _checkUsername];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
									message:@"You need to enter a username to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypePassword) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Password!"
									message:@"You need to enter a password to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == (HONRegisterErrorTypePassword | HONRegisterErrorTypeUsername)) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username & Password!"
									message:@"You need to enter a username and password use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypePhone) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Phone!"
									message:@"You need to a phone # to use Selfieclub."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		_phone = @"";
		_phone1TextField.text = @"";
		_phone2TextField.text = @"";
		_phone3TextField.text = @"";
		[_phone1TextField becomeFirstResponder];
	
	} else if (registerErrorType == (HONRegisterErrorTypePhone | HONRegisterErrorTypeUsername)) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username & Phone #!"
									message:@"You need to enter a username and phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == (HONRegisterErrorTypePhone | HONRegisterErrorTypePassword)) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Password & Phone!"
									message:@"You need to enter an password & phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == (HONRegisterErrorTypePhone | HONRegisterErrorTypePassword | HONRegisterErrorTypeUsername)) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username, Password or Phone!"
									message:@"You need to enter a username, password & phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
	
	
//	if (registerErrorType == (HONRegisterErrorTypeUsername | HONRegisterErrorTypePassword | HONRegisterErrorTypePhone)) {
//	} else if (registerErrorType == (HONRegisterErrorTypePassword | HONRegisterErrorTypePhone)) {
//	} else if (registerErrorType == (HONRegisterErrorTypeUsername | HONRegisterErrorTypePhone)) {
//	} else if (registerErrorType == HONRegisterErrorTypePhone) {
//	} else if (registerErrorType == (HONRegisterErrorTypeUsername | HONRegisterErrorTypePassword)) {
//	} else if (registerErrorType == HONRegisterErrorTypePassword) {
//	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
//	} else {
//	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	_phone = [[_phone1TextField.text stringByAppendingString:_phone2TextField.text] stringByAppendingString:_phone3TextField.text];
	
//	NSArray *tdls = @[@"cc", @"net", @"mil", @"jp", @"fk", @"sm", @"biz"];
//	NSString *emailFiller = @"";
	NSString *passwordFiller = @"";
	NSString *phone1 = @"";
	NSString *phone2 = @"";
	NSString *phone3 = @"";
	
//	BOOL _isHeads = ((BOOL)roundf(((float)rand() / RAND_MAX)));
//	for (int i=0; i<((arc4random() % 8) + 3); i++)
//		emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
//	emailFiller = [emailFiller stringByAppendingString:@"@"];
//	
//	for (int i=0; i<((arc4random() % 8) + 3); i++)
//		emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
//	emailFiller = [[emailFiller stringByAppendingString:@"."] stringByAppendingString:[tdls objectAtIndex:(arc4random() % [tdls count])]];
	
	for (int i=0; i<((arc4random() % 12) + 4); i++)
		passwordFiller = [passwordFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
	
	
	for (int i=0; i<3; i++)
		phone1 = [phone1 stringByAppendingString:[@"" stringFromInt:(arc4random() % 9)]];
	
	for (int i=0; i<3; i++)
		phone2 = [phone2 stringByAppendingString:[@"" stringFromInt:(arc4random() % 9)]];
	
	for (int i=0; i<4; i++)
		phone3 = [phone3 stringByAppendingString:[@"" stringFromInt:(arc4random() % 9)]];
	
#if __APPSTORE_BUILD__ == 0
	if ([_passwordTextField.text isEqualToString:@"¡"]) {
		_passwordTextField.text = passwordFiller;
		_phone1TextField.text = phone1;
		_phone2TextField.text = phone2;
		_phone3TextField.text = phone3;
		_phone = [[_phone1TextField.text stringByAppendingString:_phone2TextField.text] stringByAppendingString:_phone3TextField.text];
	}
#endif
	
	
	if ([_usernameTextField isFirstResponder]) {
		_usernameCheckImageView.alpha = 1.0;
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	}
	
	if ([_passwordTextField.text length] < 4 && [_passwordTextField isFirstResponder]) {
		_passwordCheckImageView.alpha = 1.0;
		_passwordCheckImageView.image = [UIImage imageNamed:@"xIcon"];
	}
	
	if ([_passwordTextField.text length] >= 4) {
		_passwordCheckImageView.alpha = 1.0;
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
	}
	
	if ([_phone1TextField isFirstResponder] && [_phone1TextField.text length] == 3)
		[_phone2TextField becomeFirstResponder];
	
	if ([_phone2TextField isFirstResponder] && [_phone2TextField.text length] == 3)
		[_phone3TextField becomeFirstResponder];
	
	if ([_phone1TextField isFirstResponder] || [_phone2TextField isFirstResponder] || [_phone3TextField isFirstResponder]) {
		_phoneCheckImageView.alpha = 1.0;
		_phoneCheckImageView.image = [UIImage imageNamed:([_phone length] != 10) ? @"xIcon" : @"checkmarkIcon"];
	}
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:[%f]", [HONAppDelegate minSnapLuminosity]);
	
	UIImage *processedImage = [HONImagingDepictor prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, processedImage.size.width, processedImage.size.height)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
	
	UIView *overlayTintView = [[UIView alloc] initWithFrame:canvasView.frame];
	overlayTintView.backgroundColor = [[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex];
	[canvasView addSubview:overlayTintView];
	
	processedImage = [HONImagingDepictor createImageFromView:canvasView];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[self _uploadPhotos:processedImage];
		
		[_addAvatarButton setBackgroundImage:nil forState:UIControlStateNormal];
		[_addAvatarButton setBackgroundImage:nil forState:UIControlStateHighlighted];
		
		UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
		
		_avatarImageView.image = [HONImagingDepictor scaleImage:[HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, (largeImage.size.height - largeImage.size.width) * 0.5, largeImage.size.width, largeImage.size.width)] toSize:CGSizeMake(kSnapAvatarSize.width * 2.0, kSnapAvatarSize.height * 2.0)];
		_avatarImageView.frame = CGRectMake(_avatarImageView.frame.origin.x, _avatarImageView.frame.origin.y, kSnapAvatarSize.width, kSnapAvatarSize.height);
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.showsCameraControls = NO;
		picker.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
		picker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
		_profileCameraOverlayView.alpha = 0.0;
		
	} else
		[self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		_usernameCheckImageView.alpha = 0.0;
		[_usernameButton setSelected:YES];
		[_passwordButton setSelected:NO];
		[_phoneButton setSelected:NO];
	
	} else if (textField.tag == 1) {
		_passwordCheckImageView.alpha = 0.0;
		[_usernameButton setSelected:NO];
		[_passwordButton setSelected:YES];
		[_phoneButton setSelected:NO];
	
	} else {
		[_usernameButton setSelected:NO];
		[_passwordButton setSelected:NO];
		[_phoneButton setSelected:YES];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (textField.tag == 2 || textField.tag == 3)
		return (!([textField.text length] > 2 && [string length] > range.length));
	
	else if (textField.tag == 4)
		return (!([textField.text length] > 3 && [string length] > range.length));
	
	else
		return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
		
	_username = _usernameTextField.text;
	_password = _passwordTextField.text;
	_phone = [[_phone1TextField.text stringByAppendingString:_phone2TextField.text] stringByAppendingString:_phone3TextField.text];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = _usernameTextField.text;
	_password = _passwordTextField.text;
	_phone = [[_phone1TextField.text stringByAppendingString:_phone2TextField.text] stringByAppendingString:_phone3TextField.text];
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
}


#pragma mark - AlertView Deleagtes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		_profileCameraOverlayView.alpha = 1.0;
		[_irisView removeFromSuperview];
		_irisView = nil;
	}
	
	else if (alertView.tag == 1) {
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Skip Photo %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"] properties:[[HONAnalyticsParams sharedInstance] userProperty]];

		if (buttonIndex == 1) {
			_imageFilename = @"";
			[self.profileImagePickerController dismissViewControllerAnimated:NO completion:^(void) {}];
			
			[_usernameTextField becomeFirstResponder];
			[_usernameButton setSelected:YES];
		}
	
	} else if (alertView.tag == 2) {
		[self _checkUsername];
	}
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
	
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Login Message %@", mpAction] properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	[_mailComposeViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

@end
