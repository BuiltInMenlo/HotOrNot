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
#import "UIImageView+AFNetworking.h"

#import "HONCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"
#import "HONHeaderView.h"
#import "HONCreateChallengeOptionsView.h"

@interface HONCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIImageView *subjectBGImageView;
@property (nonatomic, strong) HONCreateChallengeOptionsView *optionsView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *captureHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *randomSubjectButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *subjectName;
@end

@implementation HONCameraOverlayView

@synthesize subjectName = _subjectName;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username withAvatar:(NSString *)avatar {
	if ((self = [super initWithFrame:frame])) {
		_subjectName = subject;
		_username = username;
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_closeOptions:) name:@"CLOSE_OPTIONS" object:nil];
		
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, ([_username length] > 0) ? kNavBarHeaderHeight + 33.0 : kNavBarHeaderHeight + 10.0, 307.0, 306.0)];
		//_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		[self addSubview:_irisImageView];
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		//_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? ([_username length] > 0) ? @"cameraExperience_Overlay-568h" : @"FUEcameraViewBackground-568h" : ([_username length] > 0) ? @"cameraExperience_Overlay" : @"FUEcameraViewBackground"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_captureHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, self.frame.size.height)];
		_captureHolderView.userInteractionEnabled = YES;
		[_bgImageView addSubview:_captureHolderView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:_subjectName];
		//[_bgImageView addSubview:_headerView];
		
		UIImageView *dotsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(148.0, 35.0, 24.0, 6.0)];
		dotsImageView.image = [UIImage imageNamed:@"cameraExperienceDots"];
		dotsImageView.userInteractionEnabled = YES;
		[_headerView addSubview:dotsImageView];
		
		UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		subjectButton.frame = CGRectMake(0.0, 12.0, 320.0, 24.0);
		[subjectButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
		//[_headerView addSubview:subjectButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(270.0, 5.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cancelButton];
		
		_randomSubjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_randomSubjectButton.frame = CGRectMake(244.0, 0.0, 74.0, 44.0);
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"randomButton_nonActive"] forState:UIControlStateNormal];
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"randomButton_Active"] forState:UIControlStateHighlighted];
		[_randomSubjectButton addTarget:self action:@selector(_goRandomSubject) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_randomSubjectButton];
				
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(11.0, kNavBarHeaderHeight + 7.0, 37.0, 37.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:avatar] placeholderImage:nil];
		[self addSubview:avatarImageView];
		
		UIImageView *arrowImageView = [[UIImageView alloc] initWithFrame:CGRectMake(55.0, kNavBarHeaderHeight + 16.0, 18.0, 18.0)];
		arrowImageView.image = [UIImage imageNamed:@"outboundArrow"];
		arrowImageView.hidden = ([_username length] == 0);
		[self addSubview:arrowImageView];
		
		UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, kNavBarHeaderHeight + 18.0, 270.0, 20.0)];
		usernameLabel.font = [[HONAppDelegate cartoGothicBook] fontWithSize:14];
		usernameLabel.textColor = [UIColor whiteColor];
		usernameLabel.backgroundColor = [UIColor clearColor];
		usernameLabel.text = ([_username length] > 0) ? [NSString stringWithFormat:@"@%@", _username] : @"";
		[self addSubview:usernameLabel];
		
//		int opsOffset = ([_username length] > 0) ? 40 : ([HONAppDelegate isRetina5]) ? 55 : 0;
//		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		cameraRollButton.frame = CGRectMake(15.0, 267.0 + opsOffset, 64.0, 44.0);
//		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
//		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
//		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//		[_captureHolderView addSubview:cameraRollButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(15.0, 267.0, 64.0, 44.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:cameraRollButton];
//
//		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//			UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			changeCameraButton.frame = CGRectMake(233.0, 267.0 + opsOffset, 74.0, 44.0);
//			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
//			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
//			[changeCameraButton addTarget:self action:@selector(_goChangeCamera) forControlEvents:UIControlEventTouchUpInside];
//			[_captureHolderView addSubview:changeCameraButton];
//		}
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(115.0, ([HONAppDelegate isRetina5]) ? 479 : 390, 90.0, 80.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:_captureButton];
		
		_optionsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_optionsButton.frame = CGRectMake(15.0, [UIScreen mainScreen].bounds.size.height - 60, 44.0, 44.0);
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"timeButton_nonActive"] forState:UIControlStateNormal];
		[_optionsButton setBackgroundImage:[UIImage imageNamed:@"timeButton_Active"] forState:UIControlStateHighlighted];
		[_optionsButton addTarget:self action:@selector(_goOptions) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:_optionsButton];
		
		
		_subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 44.0, 320.0, 44.0)];
		_subjectBGImageView.image = [UIImage imageNamed:@"searchBackground_B"];
		_subjectBGImageView.userInteractionEnabled = YES;
		_subjectBGImageView.hidden = YES;
		[self addSubview:_subjectBGImageView];
		
		_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(14.0, 12.0, 320.0, 24.0)];
		//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_subjectTextField setReturnKeyType:UIReturnKeyDone];
		[_subjectTextField setTextColor:[HONAppDelegate honGrey518Color]];
		//[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_subjectTextField.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:15];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		_subjectTextField.text = _subjectName;
		_subjectTextField.delegate = self;
		[_subjectTextField setTag:0];
		[_subjectBGImageView addSubview:_subjectTextField];
	}
	
	return (self);
}


#pragma mark - Accessors
- (void)showPreviewImage:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE:[%f][%f]", image.size.width, image.size.height);
	image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 480 * (image.size.height / image.size.width))];
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
	

	image = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
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
	
	[_cameraBackButton removeFromSuperview];
	_cameraBackButton = nil;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_submitButton.frame = CGRectMake(330.0, _submitButton.frame.origin.y, _submitButton.frame.size.width, _submitButton.frame.size.height);
	} completion:^(BOOL finished) {
		[_submitButton removeFromSuperview];
		_submitButton = nil;
	}];
	
	_randomSubjectButton.hidden = NO;
	[_headerView addSubview:_cancelButton];
	_captureHolderView.frame = CGRectMake(0.0, _captureHolderView.frame.origin.y, 640.0, self.frame.size.height);
	
	[self.delegate cameraOverlayViewPreviewBack:self];
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
	_submitButton.frame = CGRectMake(330.0, 0.0, 64.0, 44.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_submitButton];
	
	[UIView animateWithDuration:0.25 delay:0.33 options:UIViewAnimationOptionCurveLinear animations:^{
		_submitButton.frame = CGRectMake(253.0, _submitButton.frame.origin.y, _submitButton.frame.size.width, _submitButton.frame.size.height);
	} completion:nil];
	
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
	[self hidePreview];
	
	[self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)_goSubmit {
	[self.delegate cameraOverlayViewSubmitChallenge:self];
}

- (void)_goEditSubject {
	[_subjectTextField becomeFirstResponder];
}

- (void)_goRandomSubject {
	_subjectName = [HONAppDelegate rndDefaultSubject];
	[_headerView setTitle:_subjectName];
	_subjectTextField.text = _subjectName;
	
	[[Mixpanel sharedInstance] track:@"Create Snap - Random Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											 _subjectName, @"subject", nil]];
	
	[self.delegate cameraOverlayViewChangeSubject:self subject:_subjectName];
}

- (void)_goOptions {
	[[Mixpanel sharedInstance] track:@"Create Snap - Options"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_optionsView = [[HONCreateChallengeOptionsView alloc] initWithFrame:self.frame];
	_optionsView.frame = CGRectOffset(_optionsView.frame, 0.0, self.frame.size.height);
	[self addSubview:_optionsView];
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.25];
	[UIView setAnimationDelay:0.0];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	_optionsView.frame = self.frame;
	[UIView commitAnimations];
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


#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	[_headerView setTitle:_subjectTextField.text];
}

- (void)_closeOptions:(NSNotification *)notification {
	[UIView animateWithDuration:0.25 delay:0.125 options:UIViewAnimationOptionCurveEaseIn animations:^(void) {
		_optionsView.frame = CGRectOffset(_optionsView.frame, 0.0, self.frame.size.height);
	} completion:^(BOOL finished) {
		[_optionsView removeFromSuperview];
		_optionsView = nil;
	}];
}


#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	
	if (textField.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Camera - Edit Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[[NSNotificationCenter defaultCenter] addObserver:self
															  selector:@selector(_textFieldTextDidChangeChange:)
																	name:UITextFieldTextDidChangeNotification
																 object:textField];
		
		_subjectBGImageView.hidden = NO;
		[UIView animateWithDuration:0.25 animations:^(void){
			_subjectBGImageView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (44.0 + 216.0), _subjectBGImageView.frame.size.width, _subjectBGImageView.frame.size.height);
		}];
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
		
		//[_headerView setTitle:[textField.text stringByAppendingString:string]];
	}
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.tag == 0) {
		[[NSNotificationCenter defaultCenter] removeObserver:self
																		name:@"UITextFieldTextDidChangeNotification"
																	 object:textField];
		
		_subjectBGImageView.hidden = YES;
		[UIView animateWithDuration:0.25 animations:^(void){
			_subjectBGImageView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 44.0, _subjectBGImageView.frame.size.width, _subjectBGImageView.frame.size.height);
		}];
		
		if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
			textField.text = _subjectName;
		
		else {
			NSArray *hashTags = [textField.text componentsSeparatedByString:@"#"];
			
			if ([hashTags count] > 2) {
				NSString *hashTag = ([[hashTags objectAtIndex:1] hasSuffix:@" "]) ? [[hashTags objectAtIndex:1] substringToIndex:[[hashTags objectAtIndex:1] length] - 1] : [hashTags objectAtIndex:1];
				textField.text = [NSString stringWithFormat:@"#%@", hashTag];
			}
			
			_subjectName = textField.text;
			[_headerView setTitle:_subjectName];
			[self.delegate cameraOverlayViewChangeSubject:self subject:_subjectName];
		}
		
	}
}

@end
