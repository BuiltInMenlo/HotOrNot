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
#import "UILabel+FormattedText.h"

#import "ImageFilter.h"
#import "KeychainItemWrapper.h"
#import "MBProgressHUD.h"

#import "HONRegisterViewController.h"
#import "HONCallingCodesViewController.h"
#import "HONEnterPINViewController.h"
#import "HONTermsViewController.h"
#import "HONHeaderView.h"
#import "HONNextNavButtonView.h"
#import "HONLineButtonView.h"


@interface HONRegisterViewController () <HONCallingCodesViewControllerDelegate, HONLineButtonViewDelegate>
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
@property (nonatomic, strong) UILabel *clubNameLabel;
@property (nonatomic, strong) UITextField *phoneTextField;
@property (nonatomic, strong) UIButton *usernameButton;
@property (nonatomic, strong) UIButton *callCodeButton;
@property (nonatomic, strong) UIButton *phoneButton;
@property (nonatomic, strong) UIImageView *usernameCheckImageView;
@property (nonatomic, strong) UIImageView *phoneCheckImageView;
@property (nonatomic, strong) UIView *profileCameraOverlayView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) HONNextNavButtonView *nextButton;

@property (nonatomic) int selfieAttempts;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		_totalType = HONStateMitigatorTotalTypeRegistration;
		_viewStateType = HONStateMitigatorViewStateTypeRegistration;
		
		_username = @"";
		_phone = @"";
		_imageFilename = @"";
		_isFirstAppearance = YES;
		_selfieAttempts = 0;
		
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Start First Run"];
	}
	
	return (self);
}

- (void)dealloc {
	_usernameTextField.delegate = nil;
	_phoneTextField.delegate = nil;
}


#pragma mark - Data Calls
- (void)_checkUsername {
	NSLog(@"_checkUsername -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"_checkUsername -- USERNAME_TXT:[%@] -=- PREV:[%@]", _username, [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"_checkUsername -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** USER/PHONE API CHECK **********\n");
	
	[[HONAPICaller sharedInstance] checkForAvailableUsername:_username completion:^(NSDictionary *result) {
		NSLog(@"RESULT:[%@]", result);
		
		if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
			[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Username Taken"];
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_usernameTaken", @"Username taken!");
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
			_progressHUD = nil;
			
			_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
			_usernameCheckImageView.alpha = 1.0;
			
			_clubNameLabel.text = @"joinselfie.club/";
			_usernameTextField.text = @"";
			[_usernameTextField becomeFirstResponder];
		
		} else {
			[[HONAPICaller sharedInstance] checkForAvailablePhone:_phone completion:^(NSDictionary *result) {
				if ((BOOL)[[result objectForKey:@"found"] intValue] && !(BOOL)[[result objectForKey:@"self"] intValue]) {
					[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Phone Taken"];
					
					if (_progressHUD == nil)
						_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
					[_progressHUD setYOffset:-80.0];
					_progressHUD.minShowTime = kProgressHUDMinDuration;
					_progressHUD.mode = MBProgressHUDModeCustomView;
					_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
					_progressHUD.labelText = NSLocalizedString(@"phone_taken", @"Phone # taken!");
					[_progressHUD show:NO];
					[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration];
					_progressHUD = nil;
					
					_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
					_phoneCheckImageView.alpha = 1.0;
					
					_phone = @"";
					_phoneTextField.text = @"";
					_phoneTextField.text = @"";
					_phoneTextField.text = @"";
					[_phoneTextField becomeFirstResponder];
					
				} else {
					NSLog(@"\n\n******** PASSED API NAME/PHONE CHECK **********");
					[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Username & Phone OK"];
					[self _finalizeUser];
				}
			}];
		}
	}];
}

- (void)_uploadPhotos:(UIImage *)image {
	_imageFilename = [NSString stringWithFormat:@"%@_%d", [[[HONDeviceIntrinsics sharedInstance] identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	NSLog(@"FILE PREFIX: %@/%@", [HONAppDelegate s3BucketForType:HONAmazonS3BucketTypeAvatarsSource], _imageFilename);
	
	UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
	UIImage *tabImage = [[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMakeFromSize(CGSizeMult(kSnapTabSize, 2.0))];
	
	[[HONAPICaller sharedInstance] uploadPhotosToS3:@[UIImageJPEGRepresentation(largeImage, [HONAppDelegate compressJPEGPercentage]), UIImageJPEGRepresentation(tabImage, [HONAppDelegate compressJPEGPercentage] * 0.85)] intoBucketType:HONS3BucketTypeAvatars withFilename:_imageFilename completion:^(NSObject *result) {}];
}

- (void)_finalizeUser {
	if (_progressHUD == nil)
		_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_loading", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
	_progressHUD.taskInProgress = YES;
	
	_nextButton.userInteractionEnabled = NO;
	
	NSLog(@"_finalizeUser -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"_finalizeUser -- USERNAME_TXT:[%@] -=- PREV:[%@]", _username, [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"_finalizeUser -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
	
	NSLog(@"\n\n******** FINALIZE W/ API **********");
	[[HONAPICaller sharedInstance] finalizeUserWithDictionary:@{@"user_id"	: [[HONAppDelegate infoForUser] objectForKey:@"id"],
																@"username"	: _username,
																@"phone"	: [_phone stringByAppendingString:@"@selfieclub.com"],
																@"filename"	: _imageFilename} completion:^(NSDictionary *result) {
																	
		int responseCode = [[result objectForKey:@"result"] intValue];
		if (result != nil && responseCode == 0) {
			_usernameCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
			_usernameCheckImageView.alpha = 1.0;
			
			_phoneCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
			_phoneCheckImageView.alpha = 1.0;
			
			
			[HONAppDelegate writeUserInfo:result];
			[[HONDeviceIntrinsics sharedInstance] writePhoneNumber:_phone];
			
			[[HONAPICaller sharedInstance] updatePhoneNumberForUserWithCompletion:^(NSDictionary *result) {
				[[HONAPICaller sharedInstance] retrieveClubsForUserByUserID:[[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue] completion:^(NSDictionary *result) {
					[[HONClubAssistant sharedInstance] writeUserClubs:result];
					if (_progressHUD != nil) {
						[_progressHUD hide:YES];
						_progressHUD = nil;
					}
					
					[self.navigationController pushViewController:[[HONEnterPINViewController alloc] init] animated:YES];
				}];
			}];
			
			
		} else {
			_nextButton.userInteractionEnabled = YES;
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			
			[_progressHUD setYOffset:-80.0];
			_progressHUD.minShowTime = kProgressHUDErrorDuration;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hudLoad_fail"]];
			_progressHUD.labelText = NSLocalizedString((responseCode == 1) ? @"hud_usernameTaken" : (responseCode == 2) ? @"phone_taken" : (responseCode == 3) ? @"user_phone" : @"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kProgressHUDErrorDuration + 0.75];
			_progressHUD = nil;
			
			if (responseCode == 1) {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
				
				_username = @"";
				_usernameTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
			
			} else if (responseCode == 2) {
				_usernameCheckImageView.image = [UIImage imageNamed:@"checkMarkIcon"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_phone = @"";
				_phoneTextField.text = @"";
				[_phoneTextField becomeFirstResponder];
			}
			
			else {
				_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
				
				_username = @"";
				_usernameTextField.text = @"";
				_phone = @"";
				_phoneTextField.text = @"";
				[_usernameTextField becomeFirstResponder];
			}
			
			_usernameCheckImageView.alpha = 1.0;
			_phoneCheckImageView.alpha = 1.0;
		}
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	ViewControllerLog(@"[:|:] [%@ loadView] [:|:]", self.class);
	[super loadView];
	
	_nextButton = [[HONNextNavButtonView alloc] initWithTarget:self action:@selector(_goSubmit)];
	
	HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:NSLocalizedString(@"header_signUp", @"Sign up")];
	[headerView addButton:_nextButton];
	[self.view addSubview:headerView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, kNavHeaderHeight, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"usernameRowBG_normal"] forState:UIControlStateNormal];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"usernameRowBG_normal"] forState:UIControlStateHighlighted];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"usernameRowBG_normal"] forState:UIControlStateSelected];
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"usernameRowBG_normal"] forState:(UIControlStateSelected|UIControlStateHighlighted)];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(2.0, 65.0, 64.0, 64.0)];
	[self.view addSubview:_avatarImageView];
	
	[[HONViewDispensor sharedInstance] maskView:_avatarImageView withMask:[UIImage imageNamed:@"thumbPhotoMask"]];
	
//	_addAvatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_addAvatarButton.frame = _avatarImageView.frame;
//	[_addAvatarButton setBackgroundImage:[UIImage imageNamed:@"avatarPlaceholder"] forState:UIControlStateNormal];
//	[_addAvatarButton setBackgroundImage:[UIImage imageNamed:@"avatarPlaceholder"] forState:UIControlStateHighlighted];
//	[_addAvatarButton addTarget:self action:@selector(_goCamera) forControlEvents:UIControlEventTouchUpInside];
//	[self.view addSubview:_addAvatarButton];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 85.0, 294.0, 24.0)];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[UIColor blackColor]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.placeholder = NSLocalizedString(@"enter_username", @"Enter username");
	_usernameTextField.text = @"";
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	_clubNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(14.0, 98.0, 294, 18.0)];
	_clubNameLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:11];
	_clubNameLabel.textColor = [[HONColorAuthority sharedInstance] honGreyTextColor];
	_clubNameLabel.backgroundColor = [UIColor clearColor];
	_clubNameLabel.text = @"joinselfie.club/";
//	[self.view addSubview:_clubNameLabel];
	
	_usernameCheckImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmarkIcon"]];
	_usernameCheckImageView.frame = CGRectOffset(_usernameCheckImageView.frame, 258.0, 63.0);
	_usernameCheckImageView.alpha = 0.0;
	[self.view addSubview:_usernameCheckImageView];
	
	_phoneButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_phoneButton.frame = CGRectMake(0.0, 128.0, 320.0, 64.0);
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:UIControlStateNormal];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:UIControlStateHighlighted];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:UIControlStateSelected];
	[_phoneButton setBackgroundImage:[UIImage imageNamed:@"phoneRowBG_normal"] forState:(UIControlStateHighlighted|UIControlStateSelected)];
	[_phoneButton addTarget:self action:@selector(_goPhone) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_phoneButton];
	
	CGSize size = [@"+14" boundingRectWithSize:CGSizeMake(60.0, 24.0)
										options:NSStringDrawingTruncatesLastVisibleLine
									 attributes:@{NSFontAttributeName:[[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:18]}
										context:nil].size;
	
	NSLog(@"SIZE:[%@]", NSStringFromCGSize(size));
	_callCodeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_callCodeButton.frame = CGRectMake(13.0, 127.0, 60.0, 64.0);
//	[_callCodeButton setBackgroundImage:[UIImage imageNamed:@"callCodesButton_nonActive"] forState:UIControlStateNormal];
	[_callCodeButton setBackgroundImage:[UIImage imageNamed:@"callCodesButton_Active"] forState:UIControlStateHighlighted];
	[_callCodeButton setTitleColor:[[HONColorAuthority sharedInstance] honLightGreyTextColor] forState:UIControlStateNormal];
	[_callCodeButton setTitleColor:[[HONColorAuthority sharedInstance] honGreyTextColor] forState:UIControlStateHighlighted];
	[_callCodeButton setTitleEdgeInsets:UIEdgeInsetsMake(3.0, -6.0, 0.0, 0.0)];
	_callCodeButton.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:26];
	[_callCodeButton setTitle:@"+1" forState:UIControlStateNormal];
	[_callCodeButton setTitle:@"+1" forState:UIControlStateHighlighted];
	[_callCodeButton addTarget:self action:@selector(_goCallingCodes) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_callCodeButton];
	
	_phoneTextField = [[UITextField alloc] initWithFrame:CGRectMake(83.0, 150.0, 200.0, 22.0)];
	[_phoneTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_phoneTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_phoneTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_phoneTextField setReturnKeyType:UIReturnKeyDone];
	[_phoneTextField setTextColor:[UIColor blackColor]];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_phoneTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_phoneTextField.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
	_phoneTextField.keyboardType = UIKeyboardTypePhonePad;
	_phoneTextField.placeholder = NSLocalizedString(@"enter_phone", @"Enter phone");
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
				[[HONImageBroker sharedInstance] writeImageFromWeb:[(NSDictionary *)result objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
		}];
	}
	
	HONLineButtonView *bgView = [[HONLineButtonView alloc] initAsType:HONLineButtonViewTypeRegister withCaption:@"Enter your phone number.\nTerms" usingTarget:self action:@selector(_goTerms)];
	bgView.hidden = NO;
	[bgView setYOffset:-34.0];
	[self.view addSubview:bgView];
	
	NSLog(@"loadView -- ID:[%d]", [[[HONAppDelegate infoForUser] objectForKey:@"id"] intValue]);
	NSLog(@"loadView -- USERNAME_TXT:[%@] -=- PREV:[%@]", _username, [[HONAppDelegate infoForUser] objectForKey:@"username"]);
	NSLog(@"loadView -- PHONE_TXT:[%@] -=- PREV[%@]", _phone, [[HONDeviceIntrinsics sharedInstance] phoneNumber]);
}

- (void)viewDidLoad {
	ViewControllerLog(@"[:|:] [%@ viewDidLoad] [:|:]", self.class);
	[super viewDidLoad];
	
//	_panGestureRecognizer.enabled = YES;
}

- (void)viewDidAppear:(BOOL)animated {
	ViewControllerLog(@"[:|:] [%@ viewDidAppear:%@] [:|:]", self.class, [@"" stringFromBool:animated]);
	[super viewDidAppear:animated];
	
	[_usernameTextField becomeFirstResponder];
	[_usernameButton setSelected:YES];
	
	_nextButton.userInteractionEnabled = YES;
}


#pragma mark - Navigation
- (void)_goLogin {
	
	KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:[[NSBundle mainBundle] bundleIdentifier] accessGroup:nil];
	if ([[keychain objectForKey:CFBridgingRelease(kSecAttrAccount)] length] > 0) {
		if ([MFMailComposeViewController canSendMail]) {
			_mailComposeViewController = [[MFMailComposeViewController alloc] init];
			_mailComposeViewController.mailComposeDelegate = self;
			[_mailComposeViewController setToRecipients:[NSArray arrayWithObject:@"support@getselfieclub.com"]];
			[_mailComposeViewController setSubject:@"Selfieclub - Help! I need to log back in"];
			[_mailComposeViewController setMessageBody:[NSString stringWithFormat:@"My name is %@ and I need to log back into my account. Please help, my email is %@. Thanks!", [[HONAppDelegate infoForUser] objectForKey:@"username"], [[HONAppDelegate infoForUser] objectForKey:@"email"]] isHTML:NO];
			
		} else {
			[[[UIAlertView alloc] initWithTitle:@"Email Error"
										message:@"Cannot send email from this device!"
									   delegate:nil
							  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
							  otherButtonTitles:nil] show];
		}
		
	} else {
		[[[UIAlertView alloc] initWithTitle:@"This device has never been logged in!"
									message:@""
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}

- (void)_goCamera {
	
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
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(320.0, [UIScreen mainScreen].bounds.size.height))];
		_profileCameraOverlayView.alpha = 0.0;
		
		imagePickerController.cameraOverlayView = _profileCameraOverlayView;
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_profileCameraOverlayView.alpha = 1.0;
		} completion:^(BOOL finished) {}];
		
		UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(320.0, 50.0))];
		headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
		[_profileCameraOverlayView addSubview:headerBGView];
		
//		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		flipButton.frame = CGRectMakeFromSize(CGSizeMake(64.0, 64.0));
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
		takePhotoButton.frame = CGRectMake(115.0, [UIScreen mainScreen].bounds.size.height - 113.0, 94.0, 94.0);
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
	
	if (self.profileImagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		self.profileImagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
	} else {
		self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
	}
}

- (void)_goCameraRoll {
	
	self.profileImagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	self.profileImagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)_goSkip {

	_imageFilename = @"";
	[self _finalizeUser];
}

- (void)_goTakePhoto {
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Loading…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kProgressHUDMinDuration;
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
	HONCallingCodesViewController *callingCodesViewController = [[HONCallingCodesViewController alloc] init];
	callingCodesViewController.delegate = self;
	
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:callingCodesViewController];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goTerms {
	UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[HONTermsViewController alloc] init]];
	[navigationController setNavigationBarHidden:YES];
	[self presentViewController:navigationController animated:YES completion:nil];
}

- (void)_goPhone {
	[_phoneTextField becomeFirstResponder];
}

- (void)_goPanGesture:(UIPanGestureRecognizer *)gestureRecognizer {
	[super _goPanGesture:gestureRecognizer];
	
	if ([gestureRecognizer velocityInView:self.view].x <= -2000 && !_isPushing) {
		[[HONAnalyticsReporter sharedInstance] trackEvent:@"Camera Step - Next SWIPE"];
		[self _goSubmit];
	}
}

- (void)_goSubmit {	
	if ([_usernameTextField isFirstResponder])
		[_usernameTextField resignFirstResponder];
	
	if ([_phoneTextField isFirstResponder])
		[_phoneTextField resignFirstResponder];
	
	[_usernameButton setSelected:NO];
	[_phoneButton setSelected:NO];
		
	HONRegisterErrorType registerErrorType = ((int)([_usernameTextField.text length] == 0) * HONRegisterErrorTypeUsername) + ((int)([_phone length] == 0) * HONRegisterErrorTypePhone);
	if (registerErrorType == HONRegisterErrorTypeNone) {
		_username = _usernameTextField.text;
		_phone = [_callCodeButton.titleLabel.text stringByAppendingString:_phoneTextField.text];
		
		_isPushing = YES;
		[self _checkUsername];
	
	} else if (registerErrorType == HONRegisterErrorTypeUsername) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_usernameCheckImageView.alpha = 1.0;
		
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"no_user", @"No Username!")
									message: NSLocalizedString(@"no_user_msg", @"You need to enter a username to use Selfieclub")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
		_username = @"";
		_clubNameLabel.text = @"joinselfie.club/";
		_usernameTextField.text = @"";
		[_usernameTextField becomeFirstResponder];
	
	} else if (registerErrorType == HONRegisterErrorTypePhone) {
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.alpha = 1.0;
		
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"no_phone", @"No Phone!")
									message: NSLocalizedString(@"no_phone_msg", @"You need a phone # to use Selfieclub.")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
		
		_phone = @"";
		_phoneTextField.text = @"";
		[_phoneTextField becomeFirstResponder];
	
	} else if (registerErrorType == (HONRegisterErrorTypeUsername | HONRegisterErrorTypePhone)) {
		_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_usernameCheckImageView.alpha = 1.0;
		
		_phoneCheckImageView.image = [UIImage imageNamed:@"xIcon"];
		_phoneCheckImageView.alpha = 1.0;
		
		[[[UIAlertView alloc] initWithTitle: NSLocalizedString(@"no_userphone", @"No Username & Phone!")
									message: NSLocalizedString(@"no_userphone_msg", @"You need to enter a username and phone # to use Selfieclub")
								   delegate:nil
						  cancelButtonTitle:NSLocalizedString(@"alert_ok", nil)
						  otherButtonTitles:nil] show];
	}
}


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
#if __APPSTORE_BUILD__ == 0
	if ([_usernameTextField.text isEqualToString:@"¡"]) {
		_usernameTextField.text = [[HONAppDelegate infoForUser] objectForKey:@"username"];
		_phoneTextField.text = [[[HONDeviceIntrinsics sharedInstance] phoneNumber] substringFromIndex:2];
	}
#endif
	
	_clubNameLabel.text = ([_usernameTextField.text length] > 0) ? [NSString stringWithFormat:@"joinselfie.club/%@/%@", _usernameTextField.text, _usernameTextField.text] : @"joinselfie.club/";
	
	
//	if ([_usernameTextField isFirstResponder]) {
//		_usernameCheckImageView.alpha = 0.0;
//		_usernameCheckImageView.image = [UIImage imageNamed:([_usernameTextField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
//	}
//
//	if ([_phoneTextField isFirstResponder]) {
//		_phoneCheckImageView.alpha = 0.0;
//		_phoneCheckImageView.image = [UIImage imageNamed:([_phoneTextField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
//	}
}


#pragma mark - CallingCodesViewController Delegates
- (void)callingCodesViewController:(HONCallingCodesViewController *)viewController didSelectCountry:(HONCountryVO *)countryVO {
	NSLog(@"[*:*] callingCodesViewController:didSelectCountry:(%@ - %@)", countryVO.countryName, countryVO.callingCode);
	
	[[NSUserDefaults standardUserDefaults] setObject:@{@"code"	: countryVO.callingCode,
													   @"name"	: countryVO.countryName} forKey:@"country_code"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[HONAnalyticsReporter sharedInstance] trackEvent:@"Registration - Country Selector Choosen"
									 withProperties:@{@"code"	: [@"+" stringByAppendingString:countryVO.callingCode]}];
	
	[_callCodeButton setTitle:[@"+" stringByAppendingString:countryVO.callingCode] forState:UIControlStateNormal];
	[_callCodeButton setTitle:[@"+" stringByAppendingString:countryVO.callingCode] forState:UIControlStateHighlighted];
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:[%f]", [HONAppDelegate minSnapLuminosity]);
	
	UIImage *processedImage = [[HONImageBroker sharedInstance] prepForUploading:[info objectForKey:UIImagePickerControllerOriginalImage]];
	
	NSLog(@"PROCESSED IMAGE:[%@]", NSStringFromCGSize(processedImage.size));
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(processedImage.size)];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:processedImage]];
	
	processedImage = [[HONImageBroker sharedInstance] createImageFromView:canvasView];
	
	if (_progressHUD != nil) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
	}
	
	[self dismissViewControllerAnimated:NO completion:^(void) {
		[self _uploadPhotos:processedImage];
		
		[_addAvatarButton setBackgroundImage:nil forState:UIControlStateNormal];
		[_addAvatarButton setBackgroundImage:nil forState:UIControlStateHighlighted];
		
		UIImage *largeImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:processedImage toSize:CGSizeMake(852.0, kSnapLargeSize.height * 2.0)] toRect:CGRectMake(106.0, 0.0, kSnapLargeSize.width * 2.0, kSnapLargeSize.height * 2.0)];
		
		_avatarImageView.image = [[HONImageBroker sharedInstance] scaleImage:[[HONImageBroker sharedInstance] cropImage:largeImage toRect:CGRectMake(0.0, (largeImage.size.height - largeImage.size.width) * 0.5, largeImage.size.width, largeImage.size.width)] toSize:CGSizeMake(kSnapAvatarSize.width * 2.0, kSnapAvatarSize.height * 2.0)];
		_avatarImageView.frame = CGRectMake(_avatarImageView.frame.origin.x, _avatarImageView.frame.origin.y, kSnapAvatarSize.width, kSnapAvatarSize.height);
	}];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		float scale = ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? ([[HONDeviceIntrinsics sharedInstance] isIOS8]) ? 1.65f : 1.55f : 1.25f;
		
		picker.sourceType = UIImagePickerControllerSourceTypeCamera;
		picker.showsCameraControls = NO;
		picker.cameraViewTransform = CGAffineTransformMakeTranslation(24.0, 90.0);
		picker.cameraViewTransform = CGAffineTransformScale(picker.cameraViewTransform, scale, scale);
		picker.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		picker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(320.0, [UIScreen mainScreen].bounds.size.height))];
		_profileCameraOverlayView.alpha = 0.0;
		
	} else
		[self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
//		_usernameCheckImageView.alpha = 0.0;
		[_usernameButton setSelected:YES];
		[_phoneButton setSelected:NO];
	
	} else if (textField.tag == 1) {
//		_phoneCheckImageView.alpha = 0.0;
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
	NSCharacterSet *invalidCharSet = [NSCharacterSet characterSetWithCharactersInString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"invalid_chars"] componentsJoinedByString:@""] stringByAppendingString:@"\\"]];
	
	NSLog(@"textField:[%@] shouldChangeCharactersInRange:[%@] replacementString:[%@] -- (%@)", textField.text, NSStringFromRange(range), string, NSStringFromRange([string rangeOfCharacterFromSet:invalidCharSet]));
	
	_usernameCheckImageView.alpha = (int)([string rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound || range.location == 25);
	_usernameCheckImageView.image = [UIImage imageNamed:@"xIcon"];
	
	if ([string rangeOfCharacterFromSet:invalidCharSet].location != NSNotFound)
		return (NO);
	
	return ([textField.text length] < 25 || [string isEqualToString:@""]);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
		
	_username = _usernameTextField.text;
	_phone = _phoneTextField.text;
	
//	if (textField.tag == 0) {
//		_usernameCheckImageView.alpha = 1.0;
//		_usernameCheckImageView.image = [UIImage imageNamed:([textField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
//
//	} else if (textField.tag == 1) {
//		_phoneCheckImageView.alpha = 1.0;
//		_phoneCheckImageView.image = [UIImage imageNamed:([textField.text length] == 0) ? @"xIcon" : @"checkmarkIcon"];
//	}
	
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
	
//	NSString *mpAction = @"";
//	switch (result) {
//		case MFMailComposeResultCancelled:
//			mpAction = @"Canceled";
//			break;
//			
//		case MFMailComposeResultFailed:
//			mpAction = @"Failed";
//			break;
//			
//		case MFMailComposeResultSaved:
//			mpAction = @"Saved";
//			break;
//			
//		case MFMailComposeResultSent:
//			mpAction = @"Sent";
//			break;
//			
//		default:
//			mpAction = @"Not Sent";
//			break;
//	}
	
	[_mailComposeViewController dismissViewControllerAnimated:YES completion:^(void) {
	}];
}

@end
