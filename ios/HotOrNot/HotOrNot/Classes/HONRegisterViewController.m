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

#import "ImageFilter.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "HONRegisterViewController.h"
#import "HONEnterPINViewController.h"
#import "HONAnalyticsParams.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONHeaderView.h"
#import "HONAPICaller.h"
#import "HONImagingDepictor.h"


#define SPLASH_BLUE_TINT_COLOR		[UIColor colorWithRed:0.008 green:0.373 blue:0.914 alpha:0.667]
#define SPLASH_MAGENTA_TINT_COLOR	[UIColor colorWithRed:0.910 green:0.009 blue:0.520 alpha:0.667]
#define SPLASH_GREEN_TINT_COLOR		[UIColor colorWithRed:0.009 green:0.910 blue:0.178 alpha:0.667]
#define SPLASH_TINT_FADE_DURATION	2.50f
#define SPLASH_TINT_TIMER_DURATION	3.33f


@interface HONRegisterViewController ()
@property (nonatomic, strong) MFMailComposeViewController *mailComposeViewController;
//@property (nonatomic, strong) UIImagePickerController *splashImagePickerController;
@property (nonatomic, strong) UIImagePickerController *profileImagePickerController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UIView *rotatingTintView;
@property (nonatomic, strong) NSTimer *tintTimer;
@property (nonatomic, strong) NSString *imageFilename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *phone1TextField;
@property (nonatomic, strong) UITextField *phone2TextField;
@property (nonatomic, strong) UITextField *phone3TextField;
@property (nonatomic, strong) UIButton *usernameButton;
@property (nonatomic, strong) UIButton *passwordButton;
@property (nonatomic, strong) UIButton *phoneButton;
//@property (nonatomic, strong) UIButton *birthdayButton;
@property (nonatomic, strong) UIImageView *usernameCheckImageView;
@property (nonatomic, strong) UIImageView *passwordCheckImageView;
@property (nonatomic, strong) UIImageView *phoneCheckImageView;
//@property (nonatomic, strong) UIDatePicker *datePicker;
//@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) UIView *profileCameraOverlayView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIView *tintedMatteView;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *formHolderView;
@property (nonatomic, strong) UIView *splashHolderView;
@property (nonatomic, strong) NSString *splashImageURL;
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
		
		NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
		[dateComponents setYear:-[HONAppDelegate minimumAge]];
		
		NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
		[dateFormat setDateFormat:@"yyyy-MM-dd"];
		
		_birthday = [dateFormat stringFromDate:[calendar dateByAddingComponents:dateComponents toDate:[[NSDate alloc] init] options:0]];
		
		_splashImageURL = [[[NSUserDefaults standardUserDefaults] objectForKey:@"splash_image"] stringByAppendingString:[[NSString stringWithFormat:([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? @"_%@-568h" : @"_%@", [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] stringByReplacingOccurrencesOfString:@"." withString:@""]] stringByAppendingString:@"@2x.png"]];
		NSLog(@"SPLASH TEXT:[%@]", _splashImageURL);
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
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_username andPhone:_password completion:^(NSObject *result) {
		if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 0) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[[NSUserDefaults standardUserDefaults] setObject:([_imageFilename length] == 0) ? @"YES" : @"NO" forKey:@"skipped_selfie"];
			[[NSUserDefaults standardUserDefaults] synchronize];
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
				_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
				
				_usernameTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
			}
			
			else if ([[(NSDictionary *)result objectForKey:@"result"] intValue] == 2) {
				_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
				
				_phone = @"";
				_phone1TextField.text = @"";
				_phone1TextField.text = @"";
				_phone1TextField.text = @"";
				[_phone1TextField becomeFirstResponder];
			
			} else {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
				
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
	_imageFilename = [NSString stringWithFormat:@"%@_%@-%d", [[[HONDeviceTraits sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], [[[HONDeviceTraits sharedInstance] advertisingIdentifierWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:@"avatars"], _imageFilename);
	
	UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [HONImagingDepictor cropImage:largeImage toRect:CGRectMake(0.0, 0.0, kSnapTabSize.width * 2.0, kSnapTabSize.height * 2.0)];
	
	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucket:@"hotornot-avatars" withFilename:_imageFilename completion:^(NSObject *result){
//		[self _finalizeUser];
	}];
}

- (void)_finalizeUser {
	[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																@"username"	: _username,
																@"email"	: _password,
																@"birthday"	: _birthday,
																@"filename"	: _imageFilename} completion:^(NSObject *result){
		if (result != nil) {
			if (_progressHUD != nil) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
			}
			
			[HONAppDelegate writeUserInfo:(NSDictionary *)result];
			[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
			
			[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
			
			Mixpanel *mixpanel = [Mixpanel sharedInstance];
			[mixpanel identify:[[HONDeviceTraits sharedInstance] advertisingIdentifierWithoutSeperators:NO]];
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
			
			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_HOME_TAB" object:nil];
				
				if ([HONAppDelegate switchEnabledForKey:@"firstrun_subscribe"])
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_SUGGESTED_FOLLOWING" object:nil];
				
				else
					[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_HOME_TUTORIAL" object:nil];
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
				_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
			
			else if (errorCode == 2)
				_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
			
			else {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
			}
			
			_usernameCheckImageView.alpha = 1.0;
			_phoneCheckImageView.alpha = 1.0;
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:@"NO"];
	
	
	_formHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_formHolderView.hidden = YES;
	[self.view addSubview:_formHolderView];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Get started"];
	[_formHolderView addSubview:headerView];
	
	UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
	nextButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_nonActive"] forState:UIControlStateNormal];
	[nextButton setBackgroundImage:[UIImage imageNamed:@"nextButton_Active"] forState:UIControlStateHighlighted];
	[nextButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[headerView addButton:nextButton];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_nonActive"] forState:UIControlStateNormal];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateHighlighted];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:_usernameButton];
	
	
	UIButton *addAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
	addAvatarButton.frame = CGRectMake(8.0, 85.0, 48.0, 48.0);
	[addAvatarButton setBackgroundImage:[UIImage imageNamed:@"firstRunPhotoButton_nonActive"] forState:UIControlStateNormal];
	[addAvatarButton setBackgroundImage:[UIImage imageNamed:@"firstRunPhotoButton_Active"] forState:UIControlStateHighlighted];
	[addAvatarButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:addAvatarButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(68.0, 92.0, 308.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[[HONColorAuthority sharedInstance] honBlueTextColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.placeholder = @"Enter username";
	_usernameTextField.text = @"";
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[_formHolderView addSubview:_usernameTextField];
	
	_usernameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkButton_nonActive"]];
	_usernameCheckImageView.frame = CGRectOffset(_usernameCheckImageView.frame, 257.0, 77.0);
	_usernameCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_usernameCheckImageView];
	
	_passwordButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_passwordButton.frame = CGRectMake(0.0, 141.0, 320.0, 64.0);
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_nonActive"] forState:UIControlStateNormal];
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateHighlighted];
	[_passwordButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowBackround_Active"] forState:UIControlStateSelected];
	[_passwordButton addTarget:self action:@selector(_goEmail) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:_passwordButton];
	
	_passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(17.0, 157.0, 230.0, 30.0)];
	[_passwordTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_passwordTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_passwordTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
//	_passwordTextField.secureTextEntry = YES;
	[_passwordTextField setReturnKeyType:UIReturnKeyDone];
	[_passwordTextField setTextColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor]];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_passwordTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_passwordTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
	_passwordTextField.keyboardType = UIKeyboardTypeEmailAddress;
	_passwordTextField.placeholder = @"Enter email";
	_passwordTextField.text = @"";
	[_passwordTextField setTag:1];
	_passwordTextField.delegate = self;
	[_formHolderView addSubview:_passwordTextField];
	
	_passwordCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkButton_nonActive"]];
	_passwordCheckImageView.frame = CGRectOffset(_passwordCheckImageView.frame, 257.0, 141.0);
	_passwordCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_passwordCheckImageView];
	
	_phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_phoneButton.frame = CGRectMake(0.0, 205.0, 320.0, 64.0);
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowNumBackround_nonActive"] forState:UIControlStateNormal];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowNumBackround_Active"] forState:UIControlStateHighlighted];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"firstRunRowNumBackround_Active"] forState:UIControlStateSelected];
	[_phoneButton addTarget:self action:@selector(_goPhone) forControlEvents:UIControlEventTouchUpInside];
	[_formHolderView addSubview:_phoneButton];
	
	_phone1TextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 222.0, 45.0, 30.0)];
	[_phone1TextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phone1TextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phone1TextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phone1TextField setReturnKeyType:UIReturnKeyNext];
	[_phone1TextField setTextColor:[[HONColorAuthority sharedInstance] honGreyTextColor]];
	[_phone1TextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phone1TextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phone1TextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:19];
	_phone1TextField.keyboardType = UIKeyboardTypeDecimalPad;
	_phone1TextField.text = @"";
	[_phone1TextField setTag:2];
	_phone1TextField.delegate = self;
	[_formHolderView addSubview:_phone1TextField];
	
	_phone2TextField = [[UITextField alloc] initWithFrame:CGRectMake(81.0, 222.0, 45.0, 30.0)];
	[_phone2TextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phone2TextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phone2TextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phone2TextField setReturnKeyType:UIReturnKeyNext];
	[_phone2TextField setTextColor:[[HONColorAuthority sharedInstance] honGreyTextColor]];
	[_phone2TextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phone2TextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phone2TextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:19];
	_phone2TextField.keyboardType = UIKeyboardTypeDecimalPad;
	_phone2TextField.text = @"";
	[_phone2TextField setTag:3];
	_phone2TextField.delegate = self;
	[_formHolderView addSubview:_phone2TextField];
	
	_phone3TextField = [[UITextField alloc] initWithFrame:CGRectMake(147.0, 222.0, 55.0, 30.0)];
	[_phone3TextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phone3TextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phone3TextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phone3TextField setReturnKeyType:UIReturnKeyNext];
	[_phone3TextField setTextColor:[[HONColorAuthority sharedInstance] honGreyTextColor]];
	[_phone3TextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phone3TextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phone3TextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:19];
	_phone3TextField.keyboardType = UIKeyboardTypeDecimalPad;
	_phone3TextField.text = @"";
	[_phone3TextField setTag:4];
	_phone3TextField.delegate = self;
	[_formHolderView addSubview:_phone3TextField];
	
//	_birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 212.0, 219.0, 30.0)];
//	_birthdayLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:18];
//	_birthdayLabel.textColor = [[HONColorAuthority sharedInstance] honPlaceholderTextColor];
//	_birthdayLabel.backgroundColor = [UIColor clearColor];
//	_birthdayLabel.text = @"What is your birthday?";
//	[_formHolderView addSubview:_birthdayLabel];
	
	_phoneCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkButton_nonActive"]];
	_phoneCheckImageView.frame = CGRectOffset(_phoneCheckImageView.frame, 257.0, 205.0);
	_phoneCheckImageView.alpha = 0.0;
	[_formHolderView addSubview:_phoneCheckImageView];
	
//	NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
//	NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
//	[dateComponents setYear:-[HONAppDelegate minimumAge]];
//	
//	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//	[dateFormat setDateFormat:@"yyyy-MM-dd"];
//
//	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0)];
//	_datePicker.datePickerMode = UIDatePickerModeDate;
//	_datePicker.minimumDate = [dateFormat dateFromString:@"1981-07-10"];
//	_datePicker.maximumDate = [calendar dateByAddingComponents:dateComponents toDate:[[NSDate alloc] init] options:0];
//	[_datePicker addTarget:self action:@selector(_pickerValueChanged) forControlEvents:UIControlEventValueChanged];
//	[_formHolderView addSubview:_datePicker];
//	
//	_birthday = [dateFormat stringFromDate:_datePicker.date];
	
	_splashHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_splashHolderView.alpha = 0.0;
	[self.view addSubview:_splashHolderView];
	
	UIImageView *splashTxtImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	[_splashHolderView addSubview:splashTxtImageView];
	
	void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		splashTxtImageView.image = image;
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_splashHolderView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	};
	
	void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		splashTxtImageView.image = [UIImage imageNamed:@"splashBG"];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_splashHolderView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
	};
	
	[splashTxtImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_splashImageURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
							  placeholderImage:nil
									   success:successBlock
									   failure:failureBlock];
	
	
	UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
	loginButton.frame = CGRectMake(212.0, -4.0, 104.0, 44.0);
	[loginButton setBackgroundImage:[UIImage imageNamed:@"loginButton_nonActive"] forState:UIControlStateNormal];
	[loginButton setBackgroundImage:[UIImage imageNamed:@"loginButton_Active"] forState:UIControlStateHighlighted];
	[loginButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
	[_splashHolderView addSubview:loginButton];
	
	UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
	signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 74.0, 320.0, 74.0);
	[signupButton setBackgroundImage:[UIImage imageNamed:@"getStartedButton_nonActive"] forState:UIControlStateNormal];
	[signupButton setBackgroundImage:[UIImage imageNamed:@"getStartedButton_Active"] forState:UIControlStateHighlighted];
	[signupButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
	[_splashHolderView addSubview:signupButton];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
//	_rotatingTintView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//	_rotatingTintView.backgroundColor = SPLASH_BLUE_TINT_COLOR;
//	[_splashHolderView addSubview:_rotatingTintView];
//	
//	if (_tintTimer != nil) {
//		[_tintTimer invalidate];
//		_tintTimer = nil;
//	}
//	
//	_tintTimer = [NSTimer scheduledTimerWithTimeInterval:SPLASH_TINT_TIMER_DURATION target:self selector:@selector(_nextSplashTint) userInfo:nil repeats:YES];
//	
//	UIImageView *splashTxtImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//	[_splashHolderView addSubview:splashTxtImageView];
//	
//	if ([HONAppDelegate switchEnabledForKey:@"splash_camera"]) {
//		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//			splashTxtImageView.image = image;
//		};
//		
//		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//			splashTxtImageView.image = [UIImage imageNamed:@"splashBG"];
//		};
//		
//		[splashTxtImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_splashImageURL] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
//								  placeholderImage:nil
//										   success:successBlock
//										   failure:failureBlock];
//		
//		UIButton *loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		loginButton.frame = CGRectMake(212.0, -8.0, 104.0, 44.0);
//		[loginButton setBackgroundImage:[UIImage imageNamed:@"loginButton_nonActive"] forState:UIControlStateNormal];
//		[loginButton setBackgroundImage:[UIImage imageNamed:@"loginButton_Active"] forState:UIControlStateHighlighted];
//		[loginButton addTarget:self action:@selector(_goLogin) forControlEvents:UIControlEventTouchUpInside];
//		[_splashHolderView addSubview:loginButton];
//		
//		UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 74.0, 320.0, 74.0);
//		[signupButton setBackgroundImage:[UIImage imageNamed:@"getStartedButton_nonActive"] forState:UIControlStateNormal];
//		[signupButton setBackgroundImage:[UIImage imageNamed:@"getStartedButton_Active"] forState:UIControlStateHighlighted];
//		[signupButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
//		[_splashHolderView addSubview:signupButton];
//
//		
//		if (_isFirstAppearance) {
//			_isFirstAppearance = NO;
//			
//			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//				UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
//				imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
//				imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
//				imagePickerController.delegate = nil;
//				imagePickerController.showsCameraControls = NO;
//				imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.65f : 1.0f, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.65f : 1.0f);
//				imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
//				
//				imagePickerController.cameraOverlayView = _splashHolderView;
//				self.splashImagePickerController = imagePickerController;
//				
//				[self presentViewController:self.splashImagePickerController animated:NO completion:^(void) {
//					[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
//						_splashHolderView.alpha = 1.0;
//					} completion:^(BOOL finished) {
//					}];
//				}];
//				
//			} else {
//				[self.view addSubview:_splashHolderView];
//				
//				[UIView animateWithDuration:0.33 animations:^(void) {
//					_splashHolderView.alpha = 1.0;
//				} completion:^(BOOL finished) {
//				}];
//			}
//		}
//	
//	} else {
//		[self.view addSubview:_splashHolderView];
//		
//		[UIView animateWithDuration:0.33 animations:^(void) {
//			_splashHolderView.alpha = 1.0;
//		} completion:^(BOOL finished) {}];
//	}
}


#pragma mark - Navigation
- (void)_goCloseSplash {
	[[Mixpanel sharedInstance] track:@"Register - Close Splash" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
		
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	
//	if (_tintTimer != nil) {
//		[_tintTimer invalidate];
//		_tintTimer = nil;
//	}
//	
//	_tintIndex = 0;
//	[self.splashImagePickerController dismissViewControllerAnimated:NO completion:^(void) {}];
	_imageFilename = @"";
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] == nil) {
		[[HONAPICaller sharedInstance] recreateUserWithCompletion:^(NSObject *result){
			if ([(NSDictionary *)result objectForKey:@"id"] != [NSNull null] || [(NSDictionary *)result count] > 0) {
				[HONAppDelegate writeUserInfo:(NSDictionary *)result];
				[HONImagingDepictor writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
		}];
	}
	
	_formHolderView.hidden = NO;
	
	[_usernameTextField becomeFirstResponder];
	[_usernameButton setSelected:YES];
	
	[UIView animateWithDuration:0.5 delay:0.33 options:UIViewAnimationOptionAllowAnimatedContent animations:^(void) {
		_splashHolderView.frame = CGRectOffset(_splashHolderView.frame, 0.0, -[UIScreen mainScreen].bounds.size.height);
		
	}  completion:^(BOOL finished) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"TOGGLE_STATUS_BAR_TINT" object:@"YES"];
	}];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_splashHolderView.frame = CGRectOffset(_splashHolderView.frame, 0.0, -[UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
}

- (void)_goLogin {
	[[Mixpanel sharedInstance] track:@"Register - Login" properties:[[HONAnalyticsParams sharedInstance] userProperty]];
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"passed_registration"] != nil) {
		if ([MFMailComposeViewController canSendMail]) {
			_mailComposeViewController = [[MFMailComposeViewController alloc] init];
			_mailComposeViewController.mailComposeDelegate = self;
			[_mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@selfieclubapp.com"]];
			[_mailComposeViewController setSubject:@"Selfieclub - Help! I need to log back in"];
			[_mailComposeViewController setMessageBody:[NSString stringWithFormat:@"My name is %@ and I need to log back into my account. Please help, my email is %@. Thanks!", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"email"]] isHTML:NO];
			
//			if (self.splashImagePickerController != nil)
//				[self.splashImagePickerController presentViewController:_mailComposeViewController animated:YES completion:^(void) {}];
//			
//			else
//				[self presentViewController:_mailComposeViewController animated:YES completion:^(void) {}];
//			
//			[_rotatingTintView.layer removeAllAnimations];
//			if (_tintTimer != nil) {
//				[_tintTimer invalidate];
//				_tintTimer = nil;
//			}
		
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
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.65f : 1.0f, ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.65f : 1.0f);
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
		flipButton.frame = CGRectMake(3.0, 3.0, 44.0, 44.0);
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
		
		_tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_1stRun"]];
		_tutorialImageView.frame = CGRectOffset(_tutorialImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 185.0);
		_tutorialImageView.alpha = 0.0;
		[_profileCameraOverlayView addSubview:_tutorialImageView];
		
		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_nonActive"] forState:UIControlStateNormal];
		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterIcon_Active"] forState:UIControlStateHighlighted];
		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
		[_profileCameraOverlayView addSubview:_changeTintButton];
		
		UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		takePhotoButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 118.0, 94.0, 94.0);
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"profileCameraButton_nonActive"] forState:UIControlStateNormal];
		[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"profileCameraButton_Active"] forState:UIControlStateHighlighted];
		[takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		takePhotoButton.alpha = 0.0;
		[_profileCameraOverlayView addSubview:takePhotoButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(249.0, [UIScreen mainScreen].bounds.size.height - 42.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
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
			[UIView animateWithDuration:0.33 animations:^(void) {
				_tutorialImageView.alpha = 1.0;
			}];
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
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
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
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"skipped_selfie"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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

//- (void)_goPicker {
//	_phoneCheckImageView.alpha = 0.0;
//	
//	[_usernameButton setSelected:NO];
//	[_emailButton setSelected:NO];
//	[_birthdayButton setSelected:YES];
//	[_usernameTextField resignFirstResponder];
//	[_emailTextField resignFirstResponder];
//	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
//	} completion:^(BOOL finished) {
//		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
//		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//		_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
//	}];
//}

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
	
	HONRegisterErrorType registerErrorType = ((int)([_usernameTextField.text length] > 0) * 1) + ((int)([HONAppDelegate isValidEmail:_passwordTextField.text]) * 2) + ((int)([_phone length] == 10) * 4);
	if (registerErrorType == HONRegisterErrorTypeUsernameEmailBirthday) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username, Password or Phone!"
									message:@"You need to enter a username, password & phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	 
	} else if (registerErrorType == HONRegisterErrorTypeEmailBirthday) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Password & Phone!"
									message:@"You need to enter an password & phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsernameBirthday) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username & Phone #!"
									message:@"You need to enter a username and phone # to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypeBirthday) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		
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
	
	} else if (registerErrorType == HONRegisterErrorTypeUsernameEmail) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username & Password!"
									message:@"You need to enter a username and password use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypeEmail) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Password!"
									message:@"You need to enter a password to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
									message:@"You need to enter a username to use Selfieclub"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else {
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		_phoneCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
		
		_usernameCheckImageView.alpha = 1.0;
		_passwordCheckImageView.alpha = 1.0;
		_phoneCheckImageView.alpha = 1.0;
		
		_username = _usernameTextField.text;
		_password = _passwordTextField.text;
		
		//>
		NSArray *tdls = @[@"cc", @"net", @"mil", @"jp", @"fk", @"sm", @"biz"];
		NSString *emailFiller = @"";
		
		for (int i=0; i<((arc4random() % 8) + 3); i++)
			emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
		emailFiller = [emailFiller stringByAppendingString:@"@"];
		
		for (int i=0; i<((arc4random() % 8) + 3); i++)
			emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
		emailFiller = [[emailFiller stringByAppendingString:@"."] stringByAppendingString:[tdls objectAtIndex:(arc4random() % [tdls count])]];
		
		_password = emailFiller;
		//>
		
		
		[self _checkUsername];
	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	
	_phone = [[_phone1TextField.text stringByAppendingString:_phone2TextField.text] stringByAppendingString:_phone3TextField.text];
	
	
	NSArray *tdls = @[@"cc", @"net", @"mil", @"jp", @"fk", @"sm", @"biz"];
	NSString *emailFiller = @"";
	NSString *phone1 = @"";
	NSString *phone2 = @"";
	NSString *phone3 = @"";
	
//	BOOL _isHeads = ((BOOL)roundf(((float)rand() / RAND_MAX)));
	for (int i=0; i<((arc4random() % 8) + 3); i++)
		emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
	emailFiller = [emailFiller stringByAppendingString:@"@"];
	
	for (int i=0; i<((arc4random() % 8) + 3); i++)
		emailFiller = [emailFiller stringByAppendingString:[NSString stringWithFormat:@"%c", (arc4random() % 26 + 65 + (((BOOL)roundf(((float)rand() / RAND_MAX))) * 32))]];
	emailFiller = [[emailFiller stringByAppendingString:@"."] stringByAppendingString:[tdls objectAtIndex:(arc4random() % [tdls count])]];
	
	for (int i=0; i<3; i++)
		phone1 = [phone1 stringByAppendingString:[NSString stringWithFormat:@"%d", (arc4random() % 9)]];
	
	for (int i=0; i<3; i++)
		phone2 = [phone2 stringByAppendingString:[NSString stringWithFormat:@"%d", (arc4random() % 9)]];
	
	for (int i=0; i<4; i++)
		phone3 = [phone3 stringByAppendingString:[NSString stringWithFormat:@"%d", (arc4random() % 9)]];
	
#if __APPSTORE_BUILD__ == 0
	if ([_passwordTextField.text isEqualToString:@"¡"]) {
		_passwordTextField.text = emailFiller;
		_phone1TextField.text = phone1;
		_phone2TextField.text = phone2;
		_phone3TextField.text = phone3;
		_phone = [[_phone1TextField.text stringByAppendingString:_phone2TextField.text] stringByAppendingString:_phone3TextField.text];
	}
#endif
	
	
	if ([_usernameTextField isFirstResponder]) {
		_usernameCheckImageView.alpha = 1.0;
		_usernameCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
	}
	
	if (![HONAppDelegate isValidEmail:_passwordTextField.text] && [_passwordTextField isFirstResponder]) {
		_passwordCheckImageView.alpha = 1.0;
		_passwordCheckImageView.image = [UIImage imageNamed:@"xButton_nonActive"];
	}
	
	if ([HONAppDelegate isValidEmail:_passwordTextField.text]) {
		_passwordCheckImageView.alpha = 1.0;
		_passwordCheckImageView.image = [UIImage imageNamed:@"checkButton_nonActive"];
	}
	
	if ([_phone1TextField isFirstResponder] && [_phone1TextField.text length] == 3)
		[_phone2TextField becomeFirstResponder];
	
	if ([_phone2TextField isFirstResponder] && [_phone2TextField.text length] == 3)
		[_phone3TextField becomeFirstResponder];
	
	if ([_phone1TextField isFirstResponder] || [_phone2TextField isFirstResponder] || [_phone3TextField isFirstResponder]) {
		_phoneCheckImageView.alpha = 1.0;
		_phoneCheckImageView.image = [UIImage imageNamed:([_phone length] != 10) ? @"xButton_nonActive" : @"checkButton_nonActive"];
	}
}


#pragma mark - UI Presentation
//- (void)_pickerValueChanged {
//	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
//	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
//	_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
//	
//	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
//	[dateFormat setDateFormat:@"yyyy-MM-dd"];
//	_birthday = [dateFormat stringFromDate:_datePicker.date];
//}

- (void)_nextSplashTint {
	_tintIndex = ++_tintIndex % 3;
	
	[UIView beginAnimations:@"fade" context:nil];
	[UIView setAnimationDuration:SPLASH_TINT_FADE_DURATION];
	[_rotatingTintView setBackgroundColor:(_tintIndex == 0) ? SPLASH_BLUE_TINT_COLOR : (_tintIndex == 1) ? SPLASH_MAGENTA_TINT_COLOR : SPLASH_GREEN_TINT_COLOR];
	[UIView commitAnimations];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
//	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
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
	
	[self _uploadPhotos:processedImage];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		float scale = ([[HONDeviceTraits sharedInstance] isRetina4Inch]) ? 1.55f : 1.25f;
		
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
//		_phoneCheckImageView.alpha = 0.0;
		[_usernameButton setSelected:NO];
		[_passwordButton setSelected:NO];
		[_phoneButton setSelected:YES];
	}
	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0);
//	} completion:^(BOOL finished) {}];
	
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
	
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
//	} completion:^(BOOL finished) {}];
	
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
			
			_splashHolderView.frame = CGRectOffset(_splashHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			
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
	
	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
	[_mailComposeViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

@end
