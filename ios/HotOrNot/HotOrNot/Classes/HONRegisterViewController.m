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
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "HONRegisterViewController.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"
#import "HONAvatarCameraOverlayView.h"
#import "HONHeaderView.h"
#import "HONInviteNetworkViewController.h"
#import "HONVerifyMobileViewController.h"

@interface HONRegisterViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIScrollViewDelegate, HONAvatarCameraOverlayDelegate, AmazonServiceRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePicker;
@property (nonatomic, strong) HONAvatarCameraOverlayView *cameraOverlayView;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIView *usernameHolderView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, strong) UIView *tutorialHolderView;
@property (nonatomic, strong) UIScrollView *tutorialScrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didShowViewController:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
		_username = [[HONAppDelegate infoForUser] objectForKey:@"name"];
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
	
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
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
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONRegisterViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_updateFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-]  HONRegisterViewController: %@", userResult);
			
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
		VolleyJSONLog(@"AFNetworking [-]  HONRegisterViewController %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}

- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	_filename = [NSString stringWithFormat:@"%@.jpg", [HONAppDelegate deviceToken]];
	NSLog(@"FILENAME: https://hotornot-avatars.s3.amazonaws.com/%@", _filename);
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_uploadPhoto", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	@try {
		float avatarSize = 200.0;
		CGSize ratio = CGSizeMake(image.size.width / image.size.height, image.size.height / image.size.width);
		
		UIImage *lImage = (ratio.height >= 1.0) ? [HONImagingDepictor scaleImage:image toSize:CGSizeMake(avatarSize, avatarSize * ratio.height)] : [HONImagingDepictor scaleImage:image toSize:CGSizeMake(avatarSize * ratio.width, avatarSize)];
		lImage =	[HONImagingDepictor cropImage:lImage toRect:CGRectMake(0.0, 0.0, avatarSize, avatarSize)];
		
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-avatars"]];
		S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:_filename inBucket:@"hotornot-avatars"];
		por.contentType = @"image/jpeg";
		por.data = UIImageJPEGRepresentation(lImage, kSnapJPEGCompress);
		por.delegate = self;
		[s3 putObject:por];
		
	} @catch (AmazonClientException *exception) {
		//[[[UIAlertView alloc] initWithTitle:@"Upload Error" message:exception.message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}
}

- (void)_finalizeUser {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 9], @"action",
									[[HONAppDelegate infoForUser] objectForKey:@"id"], @"userID",
									_username, @"username",
									[NSString stringWithFormat:@"https://hotornot-avatars.s3.amazonaws.com/%@", _filename], @"imgURL",
									nil];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = NSLocalizedString(@"hud_submit", nil);
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[HONImagingDepictor writeImageFromWeb:[NSString stringWithFormat:@"https://hotornot-avatars.s3.amazonaws.com/%@", _filename] withDimensions:CGSizeMake(kAvatarDim, kAvatarDim) withUserDefaultsKey:@"avatar_image"];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-]  HONRegisterViewController - Failed to parse job list JSON: %@", [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_updateFail", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:1.5];
			_progressHUD = nil;
			
		} else {
			NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
			VolleyJSONLog(@"AFNetworking [-]  HONRegisterViewController: %@", userResult);
			
			if (![[userResult objectForKey:@"result"] isEqualToString:@"fail"]) {
				[_progressHUD hide:YES];
				_progressHUD = nil;
				
				[HONAppDelegate writeUserInfo:userResult];
				[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
				
				[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
					[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
					
					if ([HONAppDelegate isFUEInviteEnabled])
						[self.navigationController pushViewController:[[HONVerifyMobileViewController alloc] init] animated:YES];
				}];
				
				if (![HONAppDelegate isFUEInviteEnabled])
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = NSLocalizedString(@"hud_submitFailed", nil);
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:1.5];
				_progressHUD = nil;
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-]  HONRegisterViewController %@", [error localizedDescription]);
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_connectionError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:1.5];
		_progressHUD = nil;
	}];
}


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	
	[self.view addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"firstRunBackground-568h" : @"firstRunBackground"]]];
	
	_usernameHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -[UIScreen mainScreen].bounds.size.height, 320.0, [UIScreen mainScreen].bounds.size.height)];
	[self.view addSubview:_usernameHolderView];
	
	UIImageView *captionImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 49.0, 320.0, 110.0)];
	captionImageView.image = [UIImage imageNamed:@"firstRunCopy_username"];
	[_usernameHolderView addSubview:captionImageView];
	
	UIImageView *inputBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(38.0, 192.0, 244.0, 44.0)];
	inputBGImageView.image = [UIImage imageNamed:@"fue_inputField_nonActive"];
	[_usernameHolderView addSubview:inputBGImageView];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(44.0, 200.0, 230.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_usernameTextField setReturnKeyType:UIReturnKeyDone];
	[_usernameTextField setTextColor:[HONAppDelegate honGrey710Color]];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_usernameTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_usernameTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:20];
	_usernameTextField.keyboardType = UIKeyboardTypeAlphabet;
	_usernameTextField.placeholder = @"@username";
	_usernameTextField.text = @"";//[NSString stringWithFormat:([[_username substringToIndex:1] isEqualToString:@"@"]) ? @"%@" : @"@%@", _username];
	_usernameTextField.delegate = self;
	[_usernameHolderView addSubview:_usernameTextField];
	
	_tutorialHolderView = [[UIView alloc] initWithFrame:self.view.bounds];
	[self.view addSubview:_tutorialHolderView];
	
	_tutorialScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height - 20.0)];
	_tutorialScrollView.contentSize = CGSizeMake(960.0, [UIScreen mainScreen].bounds.size.height - (20.0));
	_tutorialScrollView.pagingEnabled = YES;
	_tutorialScrollView.showsHorizontalScrollIndicator = NO;
	_tutorialScrollView.delegate = self;
	[_tutorialHolderView addSubview:_tutorialScrollView];
	
	UIImageView *page1ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _tutorialScrollView.frame.size.height)];
	[page1ImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", [HONAppDelegate tutorialImageForPage:0], ([HONAppDelegate isRetina5]) ? @"-568h" : @""]] placeholderImage:nil];
	[_tutorialScrollView addSubview:page1ImageView];
	
	UIImageView *page2ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(320.0, 0.0, 320.0, _tutorialScrollView.frame.size.height)];
	[page2ImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", [HONAppDelegate tutorialImageForPage:1], ([HONAppDelegate isRetina5]) ? @"-568h" : @""]] placeholderImage:nil];
	[_tutorialScrollView addSubview:page2ImageView];
	
	UIImageView *page3ImageView = [[UIImageView alloc] initWithFrame:CGRectMake(636.0, 0.0, 320.0, _tutorialScrollView.frame.size.height)];
	[page3ImageView setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@.png", [HONAppDelegate tutorialImageForPage:2], ([HONAppDelegate isRetina5]) ? @"-568h" : @""]] placeholderImage:nil];
	[_tutorialScrollView addSubview:page3ImageView];
	
	UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
	closeTutorialButton.frame = CGRectMake(682.0, _tutorialScrollView.frame.size.height - 135.0, 237.0, 67.0);
	[closeTutorialButton setBackgroundImage:[UIImage imageNamed:@"signUpButton_nonActive"] forState:UIControlStateNormal];
	[closeTutorialButton setBackgroundImage:[UIImage imageNamed:@"signUpButton_Active"] forState:UIControlStateHighlighted];
	[closeTutorialButton addTarget:self action:@selector(_goCloseTutorial) forControlEvents:UIControlEventTouchUpInside];
	[_tutorialScrollView addSubview:closeTutorialButton];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 53.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self.view addSubview:_submitButton];
	
	_pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(60.0, [UIScreen mainScreen].bounds.size.height - 48.0, 200.0, 10.0)];
	_pageControl.currentPage = 0;
	_pageControl.userInteractionEnabled = NO;
	_pageControl.pageIndicatorTintColor = [UIColor whiteColor];
	_pageControl.currentPageIndicatorTintColor = [HONAppDelegate honDarkGreenColor];
	_pageControl.numberOfPages = 3;
	[_tutorialHolderView addSubview:_pageControl];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}


#pragma mark - Navigation
- (void)_goNext {
	if ([_usernameTextField.text isEqualToString:@"@"] || [_usernameTextField.text isEqualToString:NSLocalizedString(@"register_username", nil)]) {
		[[[UIAlertView alloc] initWithTitle:@"No Username!"
											 message:@"You need to enter a username to start snapping"
										   delegate:nil
								cancelButtonTitle:@"OK"
								otherButtonTitles:nil] show];
	[_usernameTextField becomeFirstResponder];
		
	} else
		[self _submitUsername];
}

- (void)_goCloseTutorial {
	[[Mixpanel sharedInstance] track:@"Register - Close Scroll"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	[_usernameTextField becomeFirstResponder];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
	[UIView commitAnimations];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationDelay:0.33];
	_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - ((int)!([HONAppDelegate isRetina5]) * 45.0));
	[UIView commitAnimations];
}


#pragma mark - UI Presentation
- (void)_presentCamera {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		_imagePicker.cameraViewTransform = CGAffineTransformScale(_imagePicker.cameraViewTransform, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f, ([HONAppDelegate isRetina5]) ? 1.5f : 1.25f);
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
			[self _showOverlay];
		}];
		
	} else if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
		_imagePicker = [[UIImagePickerController alloc] init];
		_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
		_imagePicker.delegate = self;
		_imagePicker.allowsEditing = NO;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self.navigationController presentViewController:_imagePicker animated:NO completion:^(void) {
		}];
	}
}

- (void)_showOverlay {
	_cameraOverlayView = [[HONAvatarCameraOverlayView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_cameraOverlayView.delegate = self;
	_imagePicker.cameraOverlayView = _cameraOverlayView;
	//_focusTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(autofocusCamera) userInfo:nil repeats:YES];
}


#pragma mark - UI Presentation
- (void)_removeIris {
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_cameraIrisImageView.hidden = YES;
		[_cameraIrisImageView removeFromSuperview];
		
		_plCameraIrisAnimationView.hidden = YES;
		[_plCameraIrisAnimationView removeFromSuperview];
	}
}

- (void)_restoreIris {
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_cameraIrisImageView.hidden = NO;
		[self.view insertSubview:_cameraIrisImageView atIndex:1];
		
		_plCameraIrisAnimationView.hidden = NO;
		
		UIView *view = self.view;
		while (view.subviews.count && (view = [view.subviews objectAtIndex:2])) {
			if ([[[view class] description] isEqualToString:@"PLCropOverlay"]) {
				[view insertSubview:_plCameraIrisAnimationView atIndex:0];
				_plCameraIrisAnimationView = nil;
				break;
			}
		}
	}
}


#pragma mark - NavigationController Delegates
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSLog(@"navigationController:[%@] willShowViewController:[%@]", [navigationController description], [viewController description]);
	
	navigationController.navigationBar.barStyle = UIBarStyleDefault;
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
		_cameraIrisImageView = [[viewController.view subviews] objectAtIndex:1];
		_plCameraIrisAnimationView = [[[[viewController.view subviews] objectAtIndex:2] subviews] objectAtIndex:0];
	}
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSLog(@"navigationController:[%@] didShowViewController:[%@]", [navigationController description], [viewController description]);
	
	[self _removeIris];
}

//- (void)_didShowViewController:(NSNotification *)notification {
//	UIView *view = _imagePicker.view;
//	_plCameraIrisAnimationView = nil;
//	_cameraIrisImageView = nil;
//	
//	while (view.subviews.count && (view = [view.subviews objectAtIndex:0])) {
//		if ([[[view class] description] isEqualToString:@"PLCameraView"]) {
//			for (UIView *subview in view.subviews) {
//				if ([subview isKindOfClass:[UIImageView class]])
//					_cameraIrisImageView = (UIImageView *)subview;
//				
//				else if ([[[subview class] description] isEqualToString:@"PLCropOverlay"]) {
//					for (UIView *subsubview in subview.subviews) {
//						if ([[[subsubview class] description] isEqualToString:@"PLCameraIrisAnimationView"])
//							_plCameraIrisAnimationView = subsubview;
//					}
//				}
//			}
//		}
//	}
//	_cameraIrisImageView.hidden = YES;
//	[_cameraIrisImageView removeFromSuperview];
//	[_plCameraIrisAnimationView removeFromSuperview];
//	
//	//[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
//	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_irisAnimationDidEnd:) name:@"PLCameraViewIrisAnimationDidEndNotification" object:nil];
//}

//- (void)_irisAnimationEnded:(NSNotification *)notification {
//	_cameraIrisImageView.hidden = NO;
//	
//	UIView *view = _imagePicker.view;
//	while (view.subviews.count && (view = [view.subviews objectAtIndex:0])) {
//		if ([[[view class] description] isEqualToString:@"PLCameraView"]) {
//			for (UIView *subview in view.subviews) {
//				if ([[[subview class] description] isEqualToString:@"PLCropOverlay"]) {
//					[subview insertSubview:_plCameraIrisAnimationView atIndex:1];
//					_plCameraIrisAnimationView = nil;
//					break;
//				}
//			}
//		}
//	}
//	
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"PLCameraViewIrisAnimationDidEndNotification" object:nil];
//}

#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
	
	if (_imagePicker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
		//[self dismissViewControllerAnimated:NO completion:^(void) {
			[_cameraOverlayView showPreview:image];
		//}];
		
	} else {
		if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront)
			[_cameraOverlayView showPreviewAsFlipped:image];
		
		else
			[_cameraOverlayView showPreview:image];
	}
	
	[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	[self _uploadPhoto:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		_imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
		_imagePicker.cameraOverlayView = nil;
		_imagePicker.navigationBarHidden = YES;
		_imagePicker.toolbarHidden = YES;
		_imagePicker.wantsFullScreenLayout = NO;
		_imagePicker.showsCameraControls = NO;
		_imagePicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
		_imagePicker.navigationBar.barStyle = UIBarStyleDefault;
		
		[self _showOverlay];
		
	} else {
		[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
		
		[_imagePicker dismissViewControllerAnimated:YES completion:^(void) {
			if ([HONAppDelegate isFUEInviteEnabled])
				[self.navigationController pushViewController:[[HONVerifyMobileViewController alloc] init] animated:YES];
		}];
		
		if (![HONAppDelegate isFUEInviteEnabled])
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	textField.text = @"@";
	
	_submitButton.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
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
	}
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
	} completion:^(BOOL finished) {
		_submitButton.hidden = YES;
	}];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = ([[_usernameTextField.text substringToIndex:1] isEqualToString:@"@"]) ? [_usernameTextField.text substringFromIndex:1] : _usernameTextField.text;
	
	[[Mixpanel sharedInstance] track:@"Register - Change Username"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 _username, @"username", nil]];
	
	[self _goNext];
}


#pragma mark - ScrollView Delegates
- (void)scrollViewDidScroll:(UIScrollView *)sender {
	NSInteger page = _tutorialScrollView.contentOffset.x / _tutorialScrollView.frame.size.width;
	_pageControl.currentPage = page;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
	[[Mixpanel sharedInstance] track:@"Register - Scroll Page"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d", (int)(scrollView.contentOffset.x / 320.0) + 1], @"page", nil]];
}


#pragma mark - CameraOverlayView Delegates
- (void)cameraOverlayViewCloseCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[_imagePicker dismissViewControllerAnimated:NO completion:^(void) {
		[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
		
		if ([HONAppDelegate isFUEInviteEnabled])
			[self.navigationController pushViewController:[[HONVerifyMobileViewController alloc] init] animated:YES];
		
		else
			[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:nil];
	}];
}

- (void)cameraOverlayViewChangeCamera:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Register - Switch Camera"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if (_imagePicker.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
		//overlay.flashButton.hidden = NO;
		
	} else {
		_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
		//overlay.flashButton.hidden = YES;
	}
}

- (void)cameraOverlayViewShowCameraRoll:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Register - Camera Roll"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
	_imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
}

- (void)cameraOverlayViewRetake:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Register - Retake"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
}

- (void)cameraOverlayViewTakePicture:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Register - Take Photo"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_imagePicker takePicture];
}

- (void)cameraOverlayViewSubmit:(HONAvatarCameraOverlayView *)cameraOverlayView {
	[[Mixpanel sharedInstance] track:@"Register - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _finalizeUser];
}



#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	[_progressHUD hide:YES];
	_progressHUD = nil;
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	//NSLog(@"AWS didFailWithError:\n%@", error);
}
@end
