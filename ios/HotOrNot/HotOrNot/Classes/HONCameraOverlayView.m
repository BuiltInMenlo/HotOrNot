//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIImageView *usernameBGImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *captureHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *randomSubjectButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) NSString *username;

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic) CGSize gutterSize;
@end

@implementation HONCameraOverlayView

@synthesize subjectName = _subjectName;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withUsername:(NSString *)username withAvatar:(NSString *)avatar {
	if ((self = [super initWithFrame:frame])) {
		_username = username;
		
		int photoSize = 250.0;
		_gutterSize = CGSizeMake((320.0 - photoSize) * 0.5, (self.frame.size.height - photoSize) * 0.5);
		
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0, kNavHeaderHeight + 8.0, 306.0, 306.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		[self addSubview:_irisImageView];
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		UIImageView *footerImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, ([HONAppDelegate isRetina5]) ? 472.0 : 384.0, 320.0, 96.0)];
		footerImageView.image = [UIImage imageNamed:@"cameraFooterBackground"];
		footerImageView.userInteractionEnabled = YES;
		[_bgImageView addSubview:footerImageView];
		
		_captureHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, self.frame.size.height)];
		_captureHolderView.userInteractionEnabled = YES;
		[_bgImageView addSubview:_captureHolderView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:@""];
		[_bgImageView addSubview:_headerView];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(1.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cancelButton];
		
		_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(180.0, 12.0, 130.0, 24.0)];
		//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_subjectTextField setReturnKeyType:UIReturnKeyDone];
		[_subjectTextField setTextColor:[UIColor whiteColor]];
		//[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_subjectTextField.font = [[HONAppDelegate cartoGothicBold] fontWithSize:18];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		//subjectLabel.shadowColor = [UIColor colorWithRed:0.027 green:0.180 blue:0.302 alpha:1.0];
		//subjectLabel.shadowOffset = CGSizeMake(0.0, -1.0);
		_subjectTextField.text = _subjectName;
		_subjectTextField.textAlignment = NSTextAlignmentRight;
		_subjectTextField.delegate = self;
		[_subjectTextField setTag:0];
		[_headerView addSubview:_subjectTextField];
		
		UIImageView *userBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 32.0)];
		userBGImageView.image = [UIImage imageNamed:@"cameraKeyboardInputField_nonActive"];
		userBGImageView.userInteractionEnabled = YES;
		[self addSubview:userBGImageView];
		
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, 13.0, 20.0, 20.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
		avatarImageView.clipsToBounds = YES;
		avatarImageView.layer.cornerRadius = 2.0;
		[userBGImageView addSubview:avatarImageView];
		
		_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake((avatar != nil) ? 35.0 : 13.0, 13.0, 270.0, 20.0)];
		//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_usernameTextField setReturnKeyType:UIReturnKeyDone];
		[_usernameTextField setTextColor:[HONAppDelegate honGreyInputColor]];
		//[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_usernameTextField.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:13];
		_usernameTextField.keyboardType = UIKeyboardTypeDefault;
		_usernameTextField.text = ([_username length] > 0) ? [NSString stringWithFormat:@"@%@", _username] : NSLocalizedString(@"userPlaceholder", nil);
		_usernameTextField.delegate = self;
		[_usernameTextField setTag:1];
		[userBGImageView addSubview:_usernameTextField];
		
		UIButton *inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
		inviteButton.frame = CGRectMake(270.0, 0.0, 44.0, 32.0);
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"cameraFriendsButton_nonActive"] forState:UIControlStateNormal];
		[inviteButton setBackgroundImage:[UIImage imageNamed:@"cameraFriendsButton_Active"] forState:UIControlStateHighlighted];
		[inviteButton addTarget:self action:@selector(_goRandomSubject) forControlEvents:UIControlEventTouchUpInside];
		[userBGImageView addSubview:inviteButton];
		
		_randomSubjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_randomSubjectButton.frame = CGRectMake(233.0, 15.0, 64.0, 34.0);
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"randonButton_nonActive"] forState:UIControlStateNormal];
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"randonButton_Active"] forState:UIControlStateHighlighted];
		[_randomSubjectButton addTarget:self action:@selector(_goRandomSubject) forControlEvents:UIControlEventTouchUpInside];
		//[subjectBGImageView addSubview:_randomSubjectButton];
		
		int offset = (int)[HONAppDelegate isRetina5] * 94;
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(35.0, 409.0 + offset, 44.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:cameraRollButton];
		
		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
			UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
			changeCameraButton.frame = CGRectMake(233.0, 409.0 + offset, 44.0, 44.0);
			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
			[changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
			[_captureHolderView addSubview:changeCameraButton];
		}
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(128.0, 398.0 + offset, 64.0, 64.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:_captureButton];
		
		UIButton *fbButton = [UIButton buttonWithType:UIButtonTypeCustom];
		fbButton.frame = CGRectMake(276.0, -1.0, 44.0, 44.0);
		[fbButton setBackgroundImage:[UIImage imageNamed:@"facebookIconButton_nonActive"] forState:UIControlStateNormal];
		[fbButton setBackgroundImage:[UIImage imageNamed:@"facebookIconButton_Active"] forState:UIControlStateHighlighted];
		[fbButton addTarget:self action:@selector(_goFB) forControlEvents:UIControlEventTouchUpInside];
		//[_usernameBGImageView addSubview:fbButton];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)showPreviewImage:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE:[%f][%f]", image.size.width, image.size.height);
	image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 480 * (image.size.height / image.size.width))];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[self _showPreviewUI];
}

- (void)showPreviewImageFlipped:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE FLIPPED:[%f][%f]", image.size.width, image.size.height);
	
	//if (image.size.width > 480.0 && image.size.height > 640.0)
		image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUpMirrored]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[self _showPreviewUI];
}

- (void)hidePreview {
	_previewHolderView.hidden = YES;
	
	for (UIView *subview in _previewHolderView.subviews) {
		[subview removeFromSuperview];
	}
	
	_subjectTextField.frame = CGRectMake(180.0, 12.0, 130.0, 24.0);
	[_cameraBackButton removeFromSuperview];
	_cameraBackButton = nil;
	
	[_submitButton removeFromSuperview];
	_submitButton = nil;
	
	_randomSubjectButton.hidden = NO;
	[_headerView addSubview:_cancelButton];
	_captureHolderView.frame = CGRectMake(0.0, _captureHolderView.frame.origin.y, 640.0, self.frame.size.height);
	
	[self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = _subjectName;
}


#pragma mark - UI Presentation
- (void)_showPreviewUI {
	_randomSubjectButton.hidden = YES;
	[_cancelButton removeFromSuperview];
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(243.0, 0.0, 74.0, 44.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goNext) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_submitButton];
	
	CGSize size = [_subjectName sizeWithFont:[[HONAppDelegate cartoGothicBold] fontWithSize:18] constrainedToSize:CGSizeMake(130.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	_subjectTextField.frame = CGRectMake(160 - (size.width * 0.5), 12.0, size.width, 24.0);
	_captureHolderView.frame = CGRectMake(-320.0, _captureHolderView.frame.origin.y, 640.0, self.frame.size.height);
}

- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}


#pragma mark - Navigation
- (void)_goBack {
	_captureButton.enabled = YES;
	[_usernameTextField resignFirstResponder];
	[self hidePreview];
	
	[self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)_goNext {
	if ([_usernameTextField.text isEqualToString:@"@user"])
		_usernameTextField.text = @"@";
	
	[self.delegate cameraOverlayViewSubmitChallenge:self username:_usernameTextField.text];
}

- (void)_goFB {
	[self.delegate cameraOverlayViewPickFBFriends:self];
}

- (void)_goEditSubject {
	_subjectTextField.text = @"#";
	[_subjectTextField becomeFirstResponder];
}

- (void)_goRandomSubject {
	_subjectName = [HONAppDelegate rndDefaultSubject];
	_subjectTextField.text = _subjectName;
	
	[[Mixpanel sharedInstance] track:@"Camera - Random Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											 _subjectName, @"subject", nil]];
}

- (void)_goTakePhoto {
	_captureButton.enabled = NO;
	[self _animateShutter];
	[self.delegate cameraOverlayViewTakePicture:self];
}

- (void)_goToggleFlash {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goChangeCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCloseCamera {
	[self.delegate cameraOverlayViewCloseCamera:self];
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (textField.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Camera - Edit Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	} else if (textField.tag == 1) {
		[[Mixpanel sharedInstance] track:@"Camera - Enter Username"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
		textField.text = ([_username isEqualToString:@""]) ? @"@" : [NSString stringWithFormat:@"@%@", _username];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_usernameBGImageView.frame = CGRectMake(_usernameBGImageView.frame.origin.x, _usernameBGImageView.frame.origin.y - 215.0, _usernameBGImageView.frame.size.width, _usernameBGImageView.frame.size.height);
		}];
	
	} else if (textField.tag == 2) {
		[[Mixpanel sharedInstance] track:@"Camera - Edit Comment"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, -215.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
		}];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_previewHolderView.frame = CGRectMake(_previewHolderView.frame.origin.x, -215.0, _previewHolderView.frame.size.width, _previewHolderView.frame.size.height);
		}];
		
		textField.text = @"";
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (textField.tag == 0) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"#";
	
	} else if (textField.tag == 1) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"@";
	}
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.tag == 0) {
		if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
			textField.text = _subjectName;
		
		else {
			NSArray *hashTags = [textField.text componentsSeparatedByString:@"#"];
			
			if ([hashTags count] > 2) {
				NSString *hashTag = ([[hashTags objectAtIndex:1] hasSuffix:@" "]) ? [[hashTags objectAtIndex:1] substringToIndex:[[hashTags objectAtIndex:1] length] - 1] : [hashTags objectAtIndex:1];
				textField.text = [NSString stringWithFormat:@"#%@", hashTag];
			}
			
			_subjectName = textField.text;
		}
		
	} else if (textField.tag == 1) {
		if ([textField.text length] == 0 || [textField.text isEqualToString:@"@"])
			textField.text = NSLocalizedString(@"userPlaceholder", nil);
		
		else
			_username = textField.text;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_usernameBGImageView.frame = CGRectMake(_usernameBGImageView.frame.origin.x, _usernameBGImageView.frame.origin.y + 215.0, _usernameBGImageView.frame.size.width, _usernameBGImageView.frame.size.height);
		}];
		
		[[Mixpanel sharedInstance] track:@"Create Snap - Edit Username"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
										  _username, @"username", nil]];
	}
}

@end
