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
@property (nonatomic, strong) NSString *callingCode;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UIButton *addAvatarButton;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *usernameButton;
@property (nonatomic, strong) UIButton *callCodeButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIImageView *usernameCheckImageView;
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
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_username andPhone:[_phone stringByAppendingString:@"@selfieclub.com"] completion:^(NSDictionary *result) {
		HONRegisterCheckErrorType checkErrorType = (HONRegisterCheckErrorType)[[result objectForKey:@"result"] intValue];
		
		if (checkErrorType == HONRegisterErrorTypeNone) {
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
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
			if (checkErrorType == HONRegisterErrorTypeUsername) {
				_progressHUD.labelText = @"Username taken!";
				
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_usernameTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
			
			} else if (checkErrorType == HONRegisterCheckErrorTypePhone) {
				_progressHUD.labelText = @"Phone # taken!";
				
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_phone = @"";
				_phoneTextField.text = @"";
				_phoneTextField.text = @"";
				_phoneTextField.text = @"";
				[_phoneTextField becomeFirstResponder];
			
			} else if (checkErrorType == (HONRegisterCheckErrorTypeUsername|HONRegisterCheckErrorTypePhone)) {
				_progressHUD.labelText = @"Username & phone # taken!";
				
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_usernameTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
				
				_phone = @"";
				_phoneTextField.text = @"";
				_phoneTextField.text = @"";
				_phoneTextField.text = @"";
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
																@"phone"	: _phone,
																@"filename"	: _imageFilename} completion:^(NSDictionary *result) {
		if (result != nil) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			
			[HONAppDelegate writeUserInfo:result];
			[HONAppDelegate writePhoneNumber:_phone];
			
			[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSObject *result) {
				[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Pass First Run"];
				[[HONAnalyticsParams sharedInstance] identifyPersonEntityWithProperties:@{@"$email"			: [[HONAppDelegate infoForUser] objectForKey:@"email"],
																						  @"$created"		: [[HONAppDelegate infoForUser] objectForKey:@"added"],
																						  @"id"				: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																						  @"username"		: [[HONAppDelegate infoForUser] objectForKey:@"username"],
																						  @"deactivated"	: [[NSUserDefaults standardUserDefaults] objectForKey:@"is_deactivated"]}];
				
				
				[self.navigationController pushViewController:[[HONEnterPINViewController alloc] init] animated:YES];
				
//				[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
//					[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_CONTACTS_TAB" object:nil];
//					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_CONTACTS_TUTORIAL" object:nil];
//				}];
			}];
						
		} else {
			int errorCode = [[result objectForKey:@"result"] intValue];
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
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
	
	UIFont *textFont = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:14];
	
	UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	doneButton.frame = CGRectMake(228.0, 1.0, 93.0, 44.0);
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[doneButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[doneButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Registration"];
	[headerView addButton:doneButton];
	[self.view addSubview:headerView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_normal"] forState:UIControlStateNormal];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_selected"] forState:UIControlStateHighlighted];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_selected"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, 72.0, 48.0, 48.0)];
	[self.view addSubview:_avatarImageView];
	
	[HONImagingDepictor maskImageView:_avatarImageView withMask:[UIImage imageNamed:@"avatarMask"]];
	
	_addAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_addAvatarButton.frame = _avatarImageView.frame;
	[_addAvatarButton setBackgroundImage:[UIImage imageNamed:@"avatarPlaceholder"] forState:UIControlStateNormal];
	[_addAvatarButton setBackgroundImage:[UIImage imageNamed:@"avatarPlaceholder"] forState:UIControlStateHighlighted];
	[_addAvatarButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_addAvatarButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(64.0, 86.0, 220.0, 22.0)];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor blackColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = textFont;
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
	
	_phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_phoneButton.frame = CGRectMake(0.0, 128.0, 320.0, 64.0);
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_normal"] forState:UIControlStateNormal];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_selected"] forState:UIControlStateHighlighted];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBG_selected"] forState:UIControlStateSelected];
	[_phoneButton addTarget:self action:@selector(_goPhone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_phoneButton];
	
	_callCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_callCodeButton.frame = CGRectMake(8.0, 126.0, 64.0, 64.0);
	[_callCodeButton setBackgroundImage:[UIImage imageNamed:@"callCodesButton_nonActive"] forState:UIControlStateNormal];
	[_callCodeButton setBackgroundImage:[UIImage imageNamed:@"callCodesButton_Active"] forState:UIControlStateHighlighted];
	[_callCodeButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColor] forState:UIControlStateNormal];
	[_callCodeButton setTitleColor:[[HONColorAuthority sharedInstance] honBlueTextColorHighlighted] forState:UIControlStateHighlighted];
	[_callCodeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0, -15.0, 0.0, 0.0)];
	_callCodeButton.titleLabel.font = textFont;
	[_callCodeButton setTitle:@"+1" forState:UIControlStateNormal];
	[_callCodeButton setTitle:@"+1" forState:UIControlStateHighlighted];
//	[_callCodeButton addTarget:self action:@selector(_goCallingCodes) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_callCodeButton];
	
	_phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(70.0, 147.0, 200.0, 22.0)];
	[_phoneTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phoneTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phoneTextField setReturnKeyType:UIReturnKeyDone];
	[_phoneTextField setTextColor:[UIColor blackColor]];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phoneTextField.font = textFont;
	_phoneTextField.keyboardType = UIKeyboardTypePhonePad;
	_phoneTextField.placeholder = @"Enter phone";
	_phoneTextField.text = @"";
	[_phoneTextField setTag:1];
	_phoneTextField.delegate = self;
	[self.view addSubview:_phoneTextField];
	
	_phoneCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_phoneCheckImageView.frame = CGRectOffset(_phoneCheckImageView.frame, 258.0, 129.0);
	_phoneCheckImageView.alpha = 0.0;
	[self.view addSubview:_phoneCheckImageView];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] == nil) {
		[[HONAPICaller sharedInstance] recreateUserWithCompletion:^(NSObject *result){
			if ([(NSDictionary *)result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
				[HONAppDelegate writeUserInfo:(NSDictionary *)result];
				[HONImagingDepictor writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
		}];
	}
	
	UILabel *phoneInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 212.0, 320.0, 35.0)];
	phoneInfoLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	phoneInfoLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	phoneInfoLabel.backgroundColor = [UIColor clearColor];
	phoneInfoLabel.textAlignment = NSTextAlignmentCenter;
	phoneInfoLabel.numberOfLines = 2;
	phoneInfoLabel.text = @"Please enter your phone number\nit will be used to login";
	[self.view addSubview:phoneInfoLabel];
	
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Login"];
	
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
	[[HONAnalyticsParams sharedInstance] trackEvent:[NSString stringWithFormat:@"Register - Camera %@vailable", ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) ? @"A" : @"Una"]];
	
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
		
//		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		flipButton.frame = CGRectMake(0.0, 0.0, 64.0, 64.0);
//		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
//		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
//		[flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:flipButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(228.0, 3.0, 84.0, 44.0);
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
		[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
		[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:skipButton];
		
		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 141.0, 320.0, 141.0)];
		gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_profileCameraOverlayView addSubview:gutterView];
		
//		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
//		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterButton_nonActive"] forState:UIControlStateNormal];
//		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterButton_Active"] forState:UIControlStateHighlighted];
//		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
//		[_profileCameraOverlayView addSubview:_changeTintButton];
		
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
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Switch Camera"];
	
	if (self.profileImagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		self.profileImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
	} else {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	}
}

- (void)_goCameraRoll {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Camera Roll"];
	
	self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	self.profileImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)_goChangeTint {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Change Tint Overlay"];
	
	_tintIndex = ++_tintIndex % [[HONAppDelegate colorsForOverlayTints] count];
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:0.33];
	[_tintedMatteView setBackgroundColor:[[HONAppDelegate colorsForOverlayTints] objectAtIndex:_tintIndex]];
	[UIView commitAnimations];
}

- (void)_goSkip {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Skip Photo"];

	_imageFilename = @"";
	[self _finalizeUser];
}

- (void)_goTakePhoto {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Take Photo"];
	
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

- (void)_goCallingCodes {
	NSLog(@"GO CALLING CODES");
	
	[_callCodeButton setTitle:@"+1" forState:UIControlStateNormal];
	[_callCodeButton setTitle:@"+1" forState:UIControlStateHighlighted];
}

- (void)_goPhone {
	[_phoneTextField becomeFirstResponder];
}

- (void)_goSubmit {
	[[HONAnalyticsParams sharedInstance] trackEvent:@"Register - Submit"];
	
	if ([_usernameTextField isFirstResponder])
		[_usernameTextField resignFirstResponder];
	
	if ([_phoneTextField isFirstResponder])
		[_phoneTextField resignFirstResponder];
	
	[_usernameButton setSelected:NO];
	[_phoneButton setSelected:NO];
	
	_usernameCheckImageView.alpha = 1.0;
	_phoneCheckImageView.alpha = 1.0;
	
	HONRegisterErrorType registerErrorType = ((int)([_usernameTextField.text length] == 0) * HONRegisterErrorTypeUsername) + ((int)([_phone length] == 0) * HONRegisterErrorTypePhone);
	if (registerErrorType == HONRegisterErrorTypeNone) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		_usernameCheckImageView.alpha = 1.0;
		_phoneCheckImageView.alpha = 1.0;
		
		_username = _usernameTextField.text;
		_phone = _phoneTextField.text;
		
		[self _checkUsername];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
									message:@"You need to enter a username to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		_username = @"";
		_usernameTextField.text = @"";
		[_usernameTextField becomeFirstResponder];
	
	} else if (registerErrorType == HONRegisterErrorTypePhone) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkmarkIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Phone!"
									message:@"You need a phone # to use Selfieclub."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		_phone = @"";
		_phoneTextField.text = @"";
		[_phoneTextField becomeFirstResponder];
	
	} else if (registerErrorType == (HONRegisterErrorTypeUsername | HONRegisterErrorTypePhone)) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username & Phone!"
									message:@"You need to enter a username and phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	NSString *phone1 = @"";
	NSString *phone2 = @"";
	NSString *phone3 = @"";
	
	for (int i=0; i<3; i++)
		phone1 = [phone1 stringByAppendingString:[@"" stringFromInt:(arc4random() % 9)]];
	
	for (int i=0; i<3; i++)
		phone2 = [phone2 stringByAppendingString:[@"" stringFromInt:(arc4random() % 9)]];
	
	for (int i=0; i<4; i++)
		phone3 = [phone3 stringByAppendingString:[@"" stringFromInt:(arc4random() % 9)]];
	
#if __APPSTORE_BUILD__ == 0
	if ([_phoneTextField.text isEqualToString:@"¡"]) {
		_phoneTextField.text = [[phone1 stringByAppendingString:phone2] stringByAppendingString:phone3];
		_phone = _phoneTextField.text;
	}
#endif
	
	
	if ([_usernameTextField isFirstResponder]) {
		_usernameCheckImageView.alpha = 1.0;
		_usernameCheckImageView.image = [UIImage imageNamed:([_usernameTextField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
	}
	
	if ([_phoneTextField isFirstResponder]) {
		_phoneCheckImageView.alpha = 1.0;
		_phoneCheckImageView.image = [UIImage imageNamed:([_phoneTextField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
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
		[_phoneButton setSelected:NO];
	
	} else if (textField.tag == 1) {
		_phoneCheckImageView.alpha = 0.0;
		[_usernameButton setSelected:NO];
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
	return ([textField.text length] < 10);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
		
	_username = _usernameTextField.text;
	_phone = _phoneTextField.text;
	
	if (textField.tag == 0) {
		_usernameCheckImageView.alpha = 1.0;
		_usernameCheckImageView.image = [UIImage imageNamed:([textField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
	
	} else if (textField.tag == 1) {
		_phoneCheckImageView.alpha = 1.0;
		_phoneCheckImageView.image = [UIImage imageNamed:([textField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = _usernameTextField.text;
	_phone = _phoneTextField.text;
}

- (void)_onTextEditingDidEndOnExit:(id)sender {
	_username = _usernameTextField.text;
	_phone = _phoneTextField.text;
}


#pragma mark - AlertView Deleagtes
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		_profileCameraOverlayView.alpha = 1.0;
		[_irisView removeFromSuperview];
		_irisView = nil;
	}
	
	else if (alertView.tag == 1) {
		[[HONAnalyticsParams sharedInstance] trackEvent:[@"Register - Skip Photo " stringByAppendingString:(buttonIndex == 0) ? @"Cancel" : @"Confirm"]];

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
	[[HONAnalyticsParams sharedInstance] trackEvent:[@"Register - Login Message " stringByAppendingString:mpAction]];
	[_mailComposeViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

@end
