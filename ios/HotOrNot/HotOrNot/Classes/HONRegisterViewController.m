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

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "MBProgressHUD.h"
#import "UIImage+fixOrientation.h"
#import "UIImageView+AFNetworking.h"

#import "HONRegisterViewController.h"
#import "HONHeaderView.h"
#import "HONImagingDepictor.h"


@interface HONRegisterViewController () <AmazonServiceRequestDelegate>
@property (nonatomic, strong) UIImagePickerController *splashImagePickerController;
@property (nonatomic, strong) UIImagePickerController *profileImagePickerController;
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) UIView *plCameraIrisAnimationView;  // view that animates the opening/closing of the iris
@property (nonatomic, strong) UIImageView *cameraIrisImageView;  // static image of the closed iris
@property (nonatomic, strong) UIView *usernameHolderView;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, retain) UIButton *usernameButton;
@property (nonatomic, retain) UIButton *emailButton;
@property (nonatomic, retain) UIButton *birthdayButton;
@property (nonatomic, strong) UIView *tutorialHolderView;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UILabel *birthdayLabel;
@property (nonatomic, strong) NSString *birthday;
@property (nonatomic, strong) UIView *profileCameraOverlayView;
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *whySelfieView;
@property (nonatomic, strong) NSString *splashImageURL;

@property (nonatomic) int selfieAttempts;
@property (nonatomic) int uploadCounter;
@property (nonatomic) BOOL isFirstAppearance;
@end

@implementation HONRegisterViewController

- (id)init {
	if ((self = [super init])) {
		//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_didShowViewController:) name:@"UINavigationControllerDidShowViewControllerNotification" object:nil];
		_username = [[HONAppDelegate infoForUser] objectForKey:@"username"];
		
		[[Mixpanel sharedInstance] track:@"Register - Show"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
		
		_filename = @"";
		_isFirstAppearance = YES;
		_selfieAttempts = 0;
		
		_splashImageURL = [NSString stringWithFormat:@"%@%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"splash_image"], ([HONAppDelegate isRetina4Inch] ? @"-568h@2x.png" : @"@2x.png")];
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
- (void)_uploadPhoto:(UIImage *)image {
	AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:[[HONAppDelegate s3Credentials] objectForKey:@"key"] withSecretKey:[[HONAppDelegate s3Credentials] objectForKey:@"secret"]];
	
	_uploadCounter = 0;
	_filename = [NSString stringWithFormat:@"%@_%@-%d", [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], [[HONAppDelegate identifierForVendorWithoutSeperators:YES] lowercaseString], (int)[[NSDate date] timeIntervalSince1970]];
	
	@try {
		UIImage *largeImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, 1136.0)] toRect:CGRectMake(106.0, 0.0, 640.0, 1136.0)];
		[s3 createBucket:[[S3CreateBucketRequest alloc] initWithName:@"hotornot-avatars"]];
		
		S3PutObjectRequest *por1 = [[S3PutObjectRequest alloc] initWithKey:[NSString stringWithFormat:@"%@Large_640x1136.jpg", _filename] inBucket:@"hotornot-avatars"];
		por1.contentType = @"image/jpeg";
		por1.data = UIImageJPEGRepresentation(largeImage, kSnapJPEGCompress);
		por1.delegate = self;
		[s3 putObject:por1];
		
	} @catch (AmazonClientException *exception) {
		[[[UIAlertView alloc] initWithTitle:@"Upload Error"
									message:exception.message
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		if (_progressHUD == nil)
			_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_uploadFail", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
		
		_filename = @"";
	}
}

- (void)_checkUsername {
	NSDictionary *params = @{@"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: _username,
							 @"password"	: _email};
	
	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPICheckNameAndEmail);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPICheckNameAndEmail parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			
			if ([[userResult objectForKey:@"result"] intValue] == 0) {
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				if ([HONAppDelegate switchEnabledForKey:@"firstrun_camera"])
					[self _goCamera];
				
				else {
					[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
					[[NSUserDefaults standardUserDefaults] synchronize];
					
					[self _finalizeUser];
				}
				
			} else {
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				
				[_progressHUD setYOffset:-80.0];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = ([[userResult objectForKey:@"result"] intValue] == 1) ? @"Username taken!" : ([[userResult objectForKey:@"result"] intValue] == 2) ? @"Email taken!" : @"Username & email taken!";
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
				[_usernameTextField becomeFirstResponder];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
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

- (void)_finalizeUser {
	NSDictionary *params = @{@"action"		: [NSString stringWithFormat:@"%d", 9],
							 @"userID"		: [[HONAppDelegate infoForUser] objectForKey:@"id"],
							 @"username"	: _username,
							 @"password"	: _email,
							 @"age"			: _birthday,
							 @"token"		: [HONAppDelegate deviceToken],
							 @"imgURL"		: ([_filename length] == 0) ? [NSString stringWithFormat:@"%@/defaultAvatar.png", [HONAppDelegate s3BucketForType:@"avatars"]] : [NSString stringWithFormat:@"%@/%@Large_640x1136.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename]};
	
	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsersFirstRunComplete);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIUsersFirstRunComplete parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
			
			if ([userResult count] != 0) {
				if (_progressHUD != nil) {
					[_progressHUD hide:YES];
					_progressHUD = nil;
				}
				
				[HONAppDelegate writeUserInfo:userResult];
				[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
				
				[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run"
									  properties:[NSDictionary dictionaryWithObjectsAndKeys:
												  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
				[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_PROFILE" object:nil];
				
				[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
				[[NSUserDefaults standardUserDefaults] synchronize];
				
				[self _retreiveSubscribees];
				
				if (!NSLocationInRange([[NSDate date] timeIntervalSinceDate:_datePicker.date], [HONAppDelegate ageRangeAsSeconds:YES])) {
					UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@""
																		message:[NSString stringWithFormat:@"Volley is intended for young adults %d to %d. You may get flagged by the community.", [HONAppDelegate ageRangeAsSeconds:NO].location, [HONAppDelegate ageRangeAsSeconds:NO].length]
																	   delegate:self
															  cancelButtonTitle:@"OK"
															  otherButtonTitles:nil];
					[alertView setTag:2];
					[alertView show];
				
				} else {
					[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
						NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
						[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
						
						[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
						[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
					}];
				}
				
			} else {
				int errorCode = [[userResult objectForKey:@"result"] intValue];
				
				if (_progressHUD == nil)
					_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
				
				[_progressHUD setYOffset:-80.0];
				_progressHUD.minShowTime = kHUDTime;
				_progressHUD.mode = MBProgressHUDModeCustomView;
				_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
				_progressHUD.labelText = (errorCode == 1) ? @"Username taken!" : (errorCode == 2) ? @"Email taken!" : (errorCode == 3) ? @"Username & email taken!" : @"Unknown Error";
				[_progressHUD show:NO];
				[_progressHUD hide:YES afterDelay:kHUDErrorTime];
				_progressHUD = nil;
				
				if (errorCode == 2)
					[_emailTextField becomeFirstResponder];
				
				else
					[_usernameTextField becomeFirstResponder];
			}
		}
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@ ) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
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

- (void)_retreiveSubscribees {
	NSDictionary *params = @{@"userID"	: [[HONAppDelegate infoForUser] objectForKey:@"id"]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIGetSubscribees);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIGetSubscribees parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSArray *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
			[HONAppDelegate writeSubscribeeList:result];
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

- (void)_finalizeUpload {
	NSDictionary *params = @{@"imgURL"	: ([_filename length] == 0) ? [NSString stringWithFormat:@"%@/defaultAvatar.png", [HONAppDelegate s3BucketForType:@"avatars"]] : [NSString stringWithFormat:@"%@/%@Large_640x1136.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename]};
	
	VolleyJSONLog(@"%@ —/> (%@/%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIProcessUserImage);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	[httpClient postPath:kAPIProcessUserImage parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
		} else {
//			NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
//			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], result);
		}
		
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[self _finalizeUser];
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@/%@) Failed Request - %@", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [error localizedDescription]);
		
		_progressHUD.minShowTime = kHUDTime;
		_progressHUD.mode = MBProgressHUDModeCustomView;
		_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
		_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
		[_progressHUD show:NO];
		[_progressHUD hide:YES afterDelay:kHUDErrorTime];
		_progressHUD = nil;
	}];
}

- (void)_recreateUser {
	NSDictionary *params = @{@"action"	: [NSString stringWithFormat:@"%d", 1]};
	
//	NSLog(@"PARAMS:[%@]", params);
	VolleyJSONLog(@"%@ —/> (%@/%@?action=%@)", [[self class] description], [HONAppDelegate apiServerPath], kAPIUsers, [params objectForKey:@"action"]);
	AFHTTPClient *httpClient = [HONAppDelegate getHttpClientWithHMAC];
	
	[httpClient postPath:kAPIUsers parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *userResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil) {
			VolleyJSONLog(@"AFNetworking [-] %@ - Failed to parse JSON: %@", [[self class] description], [error localizedFailureReason]);
			
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
			_progressHUD.minShowTime = kHUDTime;
			_progressHUD.mode = MBProgressHUDModeCustomView;
			_progressHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"error"]];
			_progressHUD.labelText = NSLocalizedString(@"hud_loadError", nil);
			[_progressHUD show:NO];
			[_progressHUD hide:YES afterDelay:kHUDErrorTime];
			_progressHUD = nil;
			
		} else {
			VolleyJSONLog(@"AFNetworking [-] %@: %@", [[self class] description], userResult);
			
			if ([userResult objectForKey:@"id"] != [NSNull null] || [userResult count] > 0) {
				[HONAppDelegate writeUserInfo:userResult];
				[HONImagingDepictor writeImageFromWeb:[userResult objectForKey:@"avatar_url"] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];
			}
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


#pragma mark - View Lifecycle
- (void)loadView {
	[super loadView];
	self.view.backgroundColor = [UIColor whiteColor];
	
	_headerView = [[HONHeaderView alloc] initAsModalWithTitle:@"Register for Volley"];
	_headerView.backgroundColor = [UIColor blackColor];
	[self.view addSubview:_headerView];
	
	_usernameHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -[UIScreen mainScreen].bounds.size.height, 320.0, [UIScreen mainScreen].bounds.size.height)];
	[self.view addSubview:_usernameHolderView];
	
	_usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_usernameButton.frame = CGRectMake(0.0, 64.0, 320.0, 64.0);
	[_usernameButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_usernameButton addTarget:self action:@selector(_goUsername) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_usernameButton];
	
	_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
	_usernameLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_usernameLabel.textColor = [HONAppDelegate honPercentGreyscaleColor:0.710];
	_usernameLabel.backgroundColor = [UIColor clearColor];
	[self.view addSubview:_usernameLabel];
	
	_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 82.0, 308.0, 30.0)];
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
	_usernameTextField.placeholder = @"Enter username";
	_usernameTextField.text = @"";//@"snap";//[[HONAppDelegate infoForUser] objectForKey:@"username"];//
	[_usernameTextField setTag:0];
	_usernameTextField.delegate = self;
	[self.view addSubview:_usernameTextField];
	
	UIImageView *divider1ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider1ImageView.frame = CGRectOffset(divider1ImageView.frame, 0.0, 128.0);
	[self.view addSubview:divider1ImageView];
	
	_emailButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_emailButton.frame = CGRectMake(0.0, 129.0, 320.0, 64.0);
	[_emailButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_emailButton addTarget:self action:@selector(_goEmail) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_emailButton];
	
	_emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 147.0, 230.0, 30.0)];
	//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
	[_emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emailTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emailTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emailTextField setReturnKeyType:UIReturnKeyDone];
	[_emailTextField setTextColor:[UIColor blackColor]];
	[_emailTextField addTarget:self action:@selector(_onTextEditingDidEnd:) forControlEvents:UIControlEventEditingDidEnd];
	[_emailTextField addTarget:self action:@selector(_onTextEditingDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_emailTextField.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
	_emailTextField.placeholder = @"Enter email";
	_emailTextField.text = @"";//@"snap@snap.com";
	[_emailTextField setTag:1];
	_emailTextField.delegate = self;
	[self.view addSubview:_emailTextField];
	
	UIImageView *divider2ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider2ImageView.frame = CGRectOffset(divider2ImageView.frame, 0.0, 193.0);
	[self.view addSubview:divider2ImageView];
	
	_birthdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(12.0, 212.0, 296.0, 30.0)];
	_birthdayLabel.font = [[HONAppDelegate helveticaNeueFontMedium] fontWithSize:18];
	_birthdayLabel.textColor = [HONAppDelegate honPercentGreyscaleColor:0.710];
	_birthdayLabel.backgroundColor = [UIColor clearColor];
	_birthdayLabel.text = @"What is your birthday?";
	[self.view addSubview:_birthdayLabel];
	
	_birthdayButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_birthdayButton.frame = CGRectMake(0.0, 194.0, 320.0, 64.0);
	[_birthdayButton setBackgroundImage:[UIImage imageNamed:@"registerSelected"] forState:UIControlStateSelected];
	[_birthdayButton addTarget:self action:@selector(_goPicker) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:_birthdayButton];
	
	UIImageView *divider3ImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"firstRunDivider"]];
	divider3ImageView.frame = CGRectOffset(divider3ImageView.frame, 0.0, 258.0);
	[self.view addSubview:divider3ImageView];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0)];
	_datePicker.date = (![[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] || [[[HONAppDelegate infoForUser] objectForKey:@"age"] isEqualToString:@"0000-00-00 00:00:00"]) ? [dateFormat dateFromString:@"1970-01-01"] : [dateFormat dateFromString:[[[[HONAppDelegate infoForUser] objectForKey:@"age"]componentsSeparatedByString:@" "] objectAtIndex:0]];
	_datePicker.datePickerMode = UIDatePickerModeDate;
	_datePicker.minimumDate = [dateFormat dateFromString:@"1970-01-01"];
	_datePicker.maximumDate = [NSDate date];
	[_datePicker addTarget:self action:@selector(_pickerValueChanged) forControlEvents:UIControlEventValueChanged];
	[self.view addSubview:_datePicker];
	
	_birthday = [dateFormat stringFromDate:_datePicker.date];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = ([HONAppDelegate isRetina4Inch]) ? CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 269.0, 320.0, 53.0) : CGRectMake(257.0, 28.0, 59.0, 24.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"submitUsernameButton_nonActive" : @"smallSubmit_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:([HONAppDelegate isRetina4Inch]) ? @"submitUsernameButton_Active" : @"smallSubmit_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[self.view addSubview:submitButton];
	
	_tutorialHolderView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_tutorialHolderView.backgroundColor = [UIColor blackColor];
	_tutorialHolderView.alpha = 0.0;
	[self.view addSubview:_tutorialHolderView];
}

- (void)viewDidLoad {
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	if ([HONAppDelegate switchEnabledForKey:@"splash_camera"]) {
		if (_isFirstAppearance) {
			_isFirstAppearance = NO;
			
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
				UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
				imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
				imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
				imagePickerController.delegate = nil;
				imagePickerController.showsCameraControls = NO;
				imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f);
				imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
				
				UIView *cameraOverlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
				cameraOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
				cameraOverlayView.alpha = 0.0;
				
				UIImageView *overlayImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
				[overlayImageView setImageWithURL:[NSURL URLWithString:_splashImageURL] placeholderImage:nil];
				overlayImageView.userInteractionEnabled = YES;
				[cameraOverlayView addSubview:overlayImageView];
				
				UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
				signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (114.0 + (![HONAppDelegate isRetina4Inch] * 30.0)), 320.0, 64.0);
				[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_nonActive"] forState:UIControlStateNormal];
				[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_Active"] forState:UIControlStateHighlighted];
				[signupButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
				[cameraOverlayView addSubview:signupButton];
				
				imagePickerController.cameraOverlayView = cameraOverlayView;
				self.splashImagePickerController = imagePickerController;
				
				[self presentViewController:self.splashImagePickerController animated:NO completion:^(void) {
					[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
						cameraOverlayView.alpha = 1.0;
					} completion:^(BOOL finished) {
					}];
				}];
				
			} else {
				UIImageView *splashImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
				[splashImageView setImageWithURL:[NSURL URLWithString:_splashImageURL] placeholderImage:nil];
				splashImageView.userInteractionEnabled = YES;
				[_tutorialHolderView addSubview:splashImageView];
				
				UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
				signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (114.0 + (![HONAppDelegate isRetina4Inch] * 30.0)), 320.0, 64.0);
				[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_nonActive"] forState:UIControlStateNormal];
				[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_Active"] forState:UIControlStateHighlighted];
				[signupButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
				[_tutorialHolderView addSubview:signupButton];
				
				[UIView animateWithDuration:0.33
								 animations:^(void) {
									 _tutorialHolderView.alpha = 1.0;}];
				
				UIButton *fillFormButton = [UIButton buttonWithType:UIButtonTypeCustom];
				fillFormButton.frame = CGRectMake(148.0, 205.0, 24.0, 8.0);
				//fillFormButton.backgroundColor = [HONAppDelegate honDebugColorByName:@"red" atOpacity:0.5];
				[fillFormButton addTarget:self action:@selector(_goFillForm) forControlEvents:UIControlEventTouchUpInside];
				[_tutorialHolderView addSubview:fillFormButton];
			}
		}
	
	} else {
		UIImageView *splashImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
		[splashImageView setImageWithURL:[NSURL URLWithString:_splashImageURL] placeholderImage:nil];
		splashImageView.userInteractionEnabled = YES;
		[_tutorialHolderView addSubview:splashImageView];
		
		UIButton *signupButton = [UIButton buttonWithType:UIButtonTypeCustom];
		signupButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (114.0 + (![HONAppDelegate isRetina4Inch] * 30.0)), 320.0, 64.0);
		[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_nonActive"] forState:UIControlStateNormal];
		[signupButton setBackgroundImage:[UIImage imageNamed:@"registerButton_Active"] forState:UIControlStateHighlighted];
		[signupButton addTarget:self action:@selector(_goCloseSplash) forControlEvents:UIControlEventTouchUpInside];
		[_tutorialHolderView addSubview:signupButton];
		
		[UIView animateWithDuration:0.33 animations:^(void) {
			_tutorialHolderView.alpha = 1.0;
		}];
	}
	
	
}


#pragma mark - Navigation
- (void)_goFillForm {
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	
	_usernameTextField.text = @"snap";
	_emailTextField.text = @"snap@snap.com";
	_datePicker.date = [dateFormat dateFromString:@"1996-07-10"];
	
	_birthdayLabel.text = [dateFormat stringFromDate:_datePicker.date];
	[self _goCloseSplash];
}


- (void)_goCloseSplash {
	[[Mixpanel sharedInstance] track:@"Register - Close Splash"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.splashImagePickerController dismissViewControllerAnimated:NO completion:^(void) {}];
	_filename = @"";
	
	if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user_info"] == nil)
		[self _recreateUser];
	
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

- (void)_goCamera {
	[[Mixpanel sharedInstance] track:@"Register - Camera"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	
	if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
		UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
		imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
		imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
		imagePickerController.delegate = self;
		
		imagePickerController.showsCameraControls = NO;
		imagePickerController.cameraViewTransform = CGAffineTransformScale(imagePickerController.cameraViewTransform, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f, ([HONAppDelegate isRetina4Inch]) ? 1.65f : 1.0f);
		imagePickerController.cameraDevice = ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) ? UIImagePickerControllerCameraDeviceFront : UIImagePickerControllerCameraDeviceRear;
		
		_profileCameraOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, [UIScreen mainScreen].bounds.size.height)];
		_profileCameraOverlayView.alpha = 0.0;
		
		imagePickerController.cameraOverlayView = _profileCameraOverlayView;
		self.profileImagePickerController = imagePickerController;
		
		
		[UIView animateWithDuration:0.33 delay:0.125 options:UIViewAnimationOptionCurveEaseOut animations:^(void) {
			_profileCameraOverlayView.alpha = 1.0;
		} completion:^(BOOL finished) {
		}];
		
		[self presentViewController:self.profileImagePickerController animated:NO completion:^(void) {
		}];
		
		
//		[UIView animateWithDuration:0.5 animations:^(void) {
//			_overlayImageView.frame = CGRectOffset(_overlayImageView.frame, 0.0, -self.view.frame.size.height * 0.5);
//			_overlayImageView.alpha = 0.0;
//		} completion:^(BOOL finished) {
			UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 142.0, 320.0, 142.0)];
			gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
			[_profileCameraOverlayView addSubview:gutterView];
			
			_tutorialImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tutorial_1stRun"]];
			_tutorialImageView.frame = CGRectOffset(_tutorialImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height - 185.0);
			_tutorialImageView.alpha = 0.0;
			[_profileCameraOverlayView addSubview:_tutorialImageView];
			
			UIButton *takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
			takePhotoButton.frame = CGRectMake(113.0, [UIScreen mainScreen].bounds.size.height - 119.0, 94.0, 94.0);
			[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
			[takePhotoButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
			[takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
			takePhotoButton.alpha = 0.0;
			[_profileCameraOverlayView addSubview:takePhotoButton];
			
			UIImageView *headerBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraBackgroundHeader"]];
			headerBGImageView.frame = CGRectOffset(headerBGImageView.frame, 0.0, -20.0);
			[_profileCameraOverlayView addSubview:headerBGImageView];
			
			UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
			skipButton.frame = CGRectMake(228.0, 10.0, 84.0, 24.0);
			[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
			[skipButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
			[skipButton addTarget:self action:@selector(_goSkip) forControlEvents:UIControlEventTouchUpInside];
			[_profileCameraOverlayView addSubview:skipButton];
			
			UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
			cancelButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
			[cancelButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
			[cancelButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//			[cancelButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
			[_profileCameraOverlayView addSubview:cancelButton];
			
			UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
			retakeButton.frame = CGRectMake(106.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
			[retakeButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
			[retakeButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//			[retakeButton addTarget:self action:@selector(_goRetake) forControlEvents:UIControlEventTouchUpInside];
			[_profileCameraOverlayView addSubview:retakeButton];
			
			UIButton *acceptButton = [UIButton buttonWithType:UIButtonTypeCustom];
			acceptButton.frame = CGRectMake(212.0, [UIScreen mainScreen].bounds.size.height + 300.0, 106.0, 24.0);
			[acceptButton setBackgroundImage:[UIImage imageNamed:@"skipThis_nonActive"] forState:UIControlStateNormal];
			[acceptButton setBackgroundImage:[UIImage imageNamed:@"skipThis_Active"] forState:UIControlStateHighlighted];
//			[acceptButton addTarget:self action:@selector(_goAccept) forControlEvents:UIControlEventTouchUpInside];
			[_profileCameraOverlayView addSubview:acceptButton];
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				takePhotoButton.alpha = 1.0;
			} completion:^(BOOL finished) {
				[UIView animateWithDuration:0.33 animations:^(void) {
					_tutorialImageView.alpha = 1.0;
				}];
			}];
//		}];
	
	} else {
		_filename = @"";
		
		// selfie pass-thru if simulator
//		[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"skipped_selfie"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self _finalizeUser];
	}
}

- (void)_goSkip {
	[[Mixpanel sharedInstance] track:@"Register - Skip Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_filename = @"";
	[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"skipped_selfie"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[self _finalizeUser];
}

- (void)_goTakePhoto {
	[[Mixpanel sharedInstance] track:@"Register - Take Photo"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_irisView = [[UIView alloc] initWithFrame:_profileCameraOverlayView.frame];
	_irisView.backgroundColor = [UIColor blackColor];
	_irisView.alpha = 0.0;
	[_profileCameraOverlayView addSubview:_irisView];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_irisView.alpha = 1.0;
	}];
	
	_progressHUD = [MBProgressHUD showHUDAddedTo:[[UIApplication sharedApplication] delegate].window animated:YES];
	_progressHUD.labelText = @"Verifying Selfie…";
	_progressHUD.mode = MBProgressHUDModeIndeterminate;
	_progressHUD.minShowTime = kHUDTime;
	_progressHUD.taskInProgress = YES;
	
	[self.profileImagePickerController takePicture];
	
	[[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"skipped_selfie"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_goUsername {
	[_usernameTextField becomeFirstResponder];
}

- (void)_goEmail {
	[_emailTextField becomeFirstResponder];
}

- (void)_goPicker {
	[_usernameButton setSelected:NO];
	[_emailButton setSelected:NO];
	[_birthdayButton setSelected:YES];
	[_usernameTextField resignFirstResponder];
	[_emailTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
		NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
		[dateFormatter setDateStyle:NSDateFormatterLongStyle];
		[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
		_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	}];
}

- (BOOL)_isValidEmail:(NSString *)checkString {
	BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	
	NSString *stricterFilterString = @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$";
	NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
	NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", (stricterFilter) ? stricterFilterString : laxString];
	
	return ([emailTest evaluateWithObject:checkString]);
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Register - Submit Username & Email"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	BOOL isUsernameValid = ([_usernameTextField.text length] > 0);
	BOOL isEmailValid = [self _isValidEmail:_emailTextField.text];
	
	_username = _usernameTextField.text;
	_email = _emailTextField.text;
	
	if (!isUsernameValid && !isEmailValid) {
		[[[UIAlertView alloc] initWithTitle:@"No Username & Email!"
									message:@"You need to enter a username and email address to start snapping"
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		[_usernameTextField becomeFirstResponder];
	
	} else {
		if (!isUsernameValid) {
			[[[UIAlertView alloc] initWithTitle:@"No Username!"
										message:@"You need to enter a username to start snapping"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			[_usernameTextField becomeFirstResponder];
		}
		
		if (!isEmailValid) {
			[[[UIAlertView alloc] initWithTitle:@"No email!"
										message:@"You need to enter a valid email address to use Volley"
									   delegate:nil
							  cancelButtonTitle:@"OK"
							  otherButtonTitles:nil] show];
			[_emailTextField becomeFirstResponder];
		}
	}
	
	if ([_birthdayLabel.text isEqualToString:@"What is your birthday?"]) {
		[[[UIAlertView alloc] initWithTitle:@"No Birthday!"
									message:@"You need to a birthday to keep the communty safe."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		[self _goPicker];
	
	} else {
		if (isUsernameValid && isEmailValid)
			[self _checkUsername];
	}
}


#pragma mark - UI Presentation
- (void)_pickerValueChanged {
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateStyle:NSDateFormatterLongStyle];
	[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
	_birthdayLabel.text = [dateFormatter stringFromDate:_datePicker.date];
	
	NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
	[dateFormat setDateFormat:@"yyyy-MM-dd"];
	_birthday = [dateFormat stringFromDate:_datePicker.date];
}


#pragma mark - ImagePicker Delegates
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
	UIImage *image = [[info objectForKey:UIImagePickerControllerOriginalImage] fixOrientation];
	NSLog(@"imagePickerController:didFinishPickingMediaWithInfo:[%f]", [HONImagingDepictor totalLuminance:image]);
	
	if ([HONImagingDepictor totalLuminance:image] > kMinLuminosity) {
		CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
		CIDetector *detctor = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyHigh forKey:CIDetectorAccuracy]];
		NSArray *features = [detctor featuresInImage:ciImage];
		
		if ([features count] > 0 || [HONAppDelegate isPhoneType5s]) {
			[self _uploadPhoto:image];
//			[self dismissViewControllerAnimated:YES completion:^(void) {}];
			
			_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			
			[_usernameTextField becomeFirstResponder];
			[_usernameButton setSelected:YES];
			
//			[UIView animateWithDuration:0.1 animations:^(void) {
//				_cameraOverlayView.frame = CGRectOffset(_cameraOverlayView.frame, 0.0, -[UIScreen mainScreen].bounds.size.height);
//			} completion:^(BOOL finished) {
//				UIImageView *previewImageView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//				previewImageView.frame = CGRectOffset(previewImageView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
//				previewImageView.image = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(852.0, 1136.0)] toRect:CGRectMake(106.0, 0.0, 640.0, 1136.0)];
//				[_cameraOverlayView addSubview:previewImageView];
//			}];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationDelay:0.33];
			_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			[UIView commitAnimations];
		
		} else {
			[[Mixpanel sharedInstance] track:@"Register - Face Detection Failed"
								  properties:[NSDictionary dictionaryWithObjectsAndKeys:
											  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
			
			UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"NO SELFIE DETECTED!"
																message:@"Please retry taking your selfie photo, good lighting helps!"
															   delegate:self
													  cancelButtonTitle:@"OK"
													  otherButtonTitles:nil];
			[alertView setTag:0];
			[alertView show];
			
			[_progressHUD hide:YES];
			_progressHUD = nil;
			
			[UIView animateWithDuration:0.25 animations:^(void) {
				_irisView.alpha = 0.0;
			} completion:^(BOOL finished) {
				[_irisView removeFromSuperview];
				_irisView = nil;
			}];
		}
		
	} else {
		[[Mixpanel sharedInstance] track:@"Register - Photo Luminosity Failed"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[[[UIAlertView alloc] initWithTitle:@"Light Level Too Low!"
									message:@"You need better lighting in your photo."
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		[_progressHUD hide:YES];
		_progressHUD = nil;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_irisView.alpha = 0.0;
		} completion:^(BOOL finished) {
			[_irisView removeFromSuperview];
			_irisView = nil;
		}];
	}
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	NSLog(@"imagePickerControllerDidCancel");
	
	[self dismissViewControllerAnimated:YES completion:^(void) {
//		[TestFlight passCheckpoint:@"PASSED REGISTRATION"];
//		
//		[[Mixpanel sharedInstance] track:@"Register - Pass Fist Run"
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
//		
//		[[NSUserDefaults standardUserDefaults] setObject:@"YES" forKey:@"passed_registration"];
//		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
		}];
	}];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	if (textField.tag == 0) {
		[_usernameButton setSelected:YES];
		[_emailButton setSelected:NO];
		[_birthdayButton setSelected:NO];
	
	} else {
		[_usernameButton setSelected:NO];
		[_emailButton setSelected:YES];
		[_birthdayButton setSelected:NO];
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 216.0);
	} completion:^(BOOL finished) {
	}];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if (textField.tag == 0) {
//		if ([textField.text isEqualToString:@""])
//			textField.text = @"@";
		
		_usernameLabel.hidden = (textField.tag == 0);
	}
	
	return (YES);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_usernameLabel.hidden = ([_usernameTextField.text length] > 0);
	
	_username = _usernameTextField.text;
	_email = _emailTextField.text;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_datePicker.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 216.0, 320.0, 216.0);
	} completion:^(BOOL finished) {
	}];
}

- (void)_onTextEditingDidEnd:(id)sender {
	_username = _usernameTextField.text;
	_email = _emailTextField.text;
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
		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Register - Skip Photo %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		if (buttonIndex == 1) {
			_filename = @"";
			[self.profileImagePickerController dismissViewControllerAnimated:NO completion:^(void) {}];
			
			_tutorialHolderView.frame = CGRectOffset(_tutorialHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			
			[_usernameTextField becomeFirstResponder];
			[_usernameButton setSelected:YES];
			
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.5];
			[UIView setAnimationDelay:0.33];
			_usernameHolderView.frame = CGRectOffset(_usernameHolderView.frame, 0.0, [UIScreen mainScreen].bounds.size.height);
			[UIView commitAnimations];
		}
	
	} else if (alertView.tag == 2) {
		[[[UIApplication sharedApplication] delegate].window.rootViewController dismissViewControllerAnimated:YES completion:^(void) {
			NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
			[dateFormat setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
			
			[[NSNotificationCenter defaultCenter] postNotificationName:@"REFRESH_VOTE_TAB" object:nil];
//			if ([HONAppDelegate ageForDate:[dateFormat dateFromString:[[HONAppDelegate infoForUser] objectForKey:@"age"]]] < 19)
			[[NSNotificationCenter defaultCenter] postNotificationName:@"SHOW_INVITE" object:nil];
		}];
	}
}

#pragma mark - AWS Delegates
- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response {
	//NSLog(@"\nAWS didCompleteWithResponse:\n%@", response);
	
	_uploadCounter++;
	if (_uploadCounter == 1) {
		[_progressHUD hide:YES];
		_progressHUD = nil;
		
		[self _finalizeUpload];
		
//		NSMutableString *avatarURL = [[params objectForKey:@"imgURL"] mutableCopy];
//		[avatarURL replaceOccurrencesOfString:@"Large_640x1136" withString:@"_o" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [avatarURL length])];
		[HONImagingDepictor writeImageFromWeb:([_filename length] == 0) ? [NSString stringWithFormat:@"%@/defaultAvatar.png", [HONAppDelegate s3BucketForType:@"avatars"]] : [NSString stringWithFormat:@"%@/%@Large_640x1136.jpg", [HONAppDelegate s3BucketForType:@"avatars"], _filename] withDimensions:CGSizeMake(612.0, 1086.0) withUserDefaultsKey:@"avatar_image"];

	}
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"AWS didFailWithError:\n%@", error);
}
@end
