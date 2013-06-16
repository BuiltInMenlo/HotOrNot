//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"

#import "HONCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"
#import "HONCreateChallengeOptionsView.h"
#import "HONCreateChallengePreviewView.h"

@interface HONCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) UIImageView *subjectBGImageView;
@property (nonatomic, strong) HONCreateChallengeOptionsView *optionsView;
@property (nonatomic, strong) HONCreateChallengePreviewView *previewView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *captureHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *randomSubjectButton;
@property (nonatomic, strong) UIButton *addFriendsButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *optionsButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *subjectName;
@end

@implementation HONCameraOverlayView

@synthesize subjectName = _subjectName;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withUsername:(NSString *)username {
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
		
		UIButton *subjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		subjectButton.frame = CGRectMake(0.0, 12.0, 320.0, 24.0);
		[subjectButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
		//[_headerView addSubview:subjectButton];
		
		_addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_addFriendsButton.frame = CGRectMake(5.0, 5.0, 44.0, 44.0);
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
		[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
		[_addFriendsButton addTarget:self action:@selector(_goAddFriends) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_addFriendsButton];
		
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
		//[self addSubview:_randomSubjectButton];
				
		UILabel *usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 18.0, 210.0, 20.0)];
		usernameLabel.font = [[HONAppDelegate helveticaNeueFontBold] fontWithSize:14];
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
- (void)showPreviewImage:(UIImage *)image asMirrored:(BOOL)isMirrored {
	NSLog(@"IMAGE:[%@][%d]", NSStringFromCGSize(image.size), image.imageOrientation);
	
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	//previewImageView.transform = CGAffineTransformScale(previewImageView.transform, 1.0f, -1.0f);
	
	_previewView = [[HONCreateChallengePreviewView alloc] initWithFrame:self.frame withSubject:_subjectName withImage:image];
	[self addSubview:_previewView];
	
	previewImageView = nil;
}

- (void)hidePreview {
	//- [self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)enablePreview {
	[_previewView showKeyboard];
}


#pragma mark - UI Presentation
- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}


#pragma mark - Navigation
- (void)_goBack {
	[self hidePreview];
	
	//- [self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)_goSubmit {
	//- [self.delegate cameraOverlayViewSubmitChallenge:self];
}

- (void)_goAddFriends {
	[self.delegate cameraOverlayViewAddChallengers:self];
}

- (void)_goEditSubject {
	[_subjectTextField becomeFirstResponder];
}

- (void)_goRandomSubject {
	_subjectName = [HONAppDelegate rndDefaultSubject];
	_subjectTextField.text = _subjectName;
	
	[[Mixpanel sharedInstance] track:@"Create Snap - Random Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
											 _subjectName, @"subject", nil]];
	
	//- [self.delegate cameraOverlayViewChangeSubject:self subject:_subjectName];
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
	//[_headerView setTitle:_subjectTextField.text];
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
			_subjectBGImageView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - (kNavBarHeaderHeight + 216.0), _subjectBGImageView.frame.size.width, _subjectBGImageView.frame.size.height);
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
			//- [self.delegate cameraOverlayViewChangeSubject:self subject:_subjectName];
		}
		
	}
}

@end
