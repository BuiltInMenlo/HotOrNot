//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"

#import "HONCreateChallengePreviewView.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"
#import "HONUserVO.h"
#import "HONCameraSubjectsView.h"

@interface HONCreateChallengePreviewView () <UIAlertViewDelegate, UITextFieldDelegate, HONCameraSubjectsViewDelegate>
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *previewBackButton;
@property (nonatomic, strong) UIButton *subscribersBackButton;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONCameraSubjectsView *subjectsView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *headerBGView;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;
@synthesize isFirstCamera = _isFirstCamera;


- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];
		
		_subjectName = subject;
		//_previewImage = [HONImagingDepictor scaleImage:image byFactor:0.3333333];
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:([UIScreen mainScreen].bounds.size.height / 1280.0)];
		NSLog(@"NORMAL -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
		float mult = (self.frame.size.height < _previewImage.size.height) ? -0.5 : 0.0;
		UIImageView *previewImageView = [[UIImageView alloc] initWithImage:_previewImage];
		previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, ABS(self.frame.size.height - _previewImage.size.height) * mult);
		[self addSubview:previewImageView];
		
		_blurredImageView = [[UIImageView alloc] initWithImage:[_previewImage applyBlurWithRadius:8.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil]];
		_blurredImageView.frame = CGRectOffset(_blurredImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, ABS(self.frame.size.height - _previewImage.size.height) * mult);
		_blurredImageView.alpha = 0.0;
		[self addSubview:_blurredImageView];

		[self _makeUI];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withMirroredImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];;
		
		_subjectName = subject;
		
		//_previewImage = [HONImagingDepictor scaleImage:image byFactor:0.3333333];
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:([UIScreen mainScreen].bounds.size.height / 1280.0)];
		NSLog(@"MIRRORED -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
		float mult = (self.frame.size.height < _previewImage.size.height) ? -0.5 : 0.0;
		UIImageView *previewImageView = [[UIImageView alloc] initWithImage:_previewImage];
		previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, ABS(self.frame.size.height - _previewImage.size.height) * mult);
		previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
		[self addSubview:previewImageView];
		
		_blurredImageView = [[UIImageView alloc] initWithImage:[_previewImage applyBlurWithRadius:8.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil]];
		_blurredImageView.frame = CGRectOffset(_blurredImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, ABS(self.frame.size.height - _previewImage.size.height) * mult);
		_blurredImageView.transform = CGAffineTransformScale(_blurredImageView.transform, -1.0f, 1.0f);
		_blurredImageView.alpha = 0.0;
		[self addSubview:_blurredImageView];
		
		[self _makeUI];
	}
	
	return (self);
}


#pragma mark - Puplic APIs
- (void)setIsFirstCamera:(BOOL)isFirstCamera {
	_isFirstCamera = isFirstCamera;
}

- (void)uploadComplete {
	[_uploadingImageView stopAnimating];
	[_uploadingImageView removeFromSuperview];
	
	[_backButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
}

- (void)setOpponents:(NSArray *)users asJoining:(BOOL)isJoining redrawTable:(BOOL)isRedraw {
//	_actionLabel.text = [NSString stringWithFormat:@"%d", [users count]];//(isJoining) ? [NSString stringWithFormat:@"Joining %d other%@", [users count], ([users count] != 1 ? @"s" : @"")] : [NSString stringWithFormat:@"Sending to %d subscriber%@", [users count], ([users count] != 1 ? @"s" : @"")];
}

- (void)showKeyboard {
	[_subjectTextField becomeFirstResponder];
	[self _raiseKeyboard];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerFadeBackground"]]];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
	_blackMatteView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
	_blackMatteView.alpha = 0.0;
	[self addSubview:_blackMatteView];
	
	_previewBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_previewBackButton.frame = self.frame;
	[_previewBackButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchDown];
	
	_headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
	_headerBGView.backgroundColor = [UIColor blackColor];
	[self addSubview:_headerBGView];
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 14.0, 54.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	_uploadingImageView.alpha = 0.0;
	[_uploadingImageView startAnimating];
//	[self addSubview:_uploadingImageView];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -3.0, 180.0, 50.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_placeholderLabel.textColor = [UIColor whiteColor];
	_placeholderLabel.text = ([_subjectName length] == 0) ? @"how are you feeling?" : @"";
	[_headerBGView addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(10.0, -2.0, 180.0, 50.0)];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = _subjectName;
	_subjectTextField.delegate = self;
	[_headerBGView addSubview:_subjectTextField];
	
	_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_backButton.frame = CGRectMake(253.0, 0.0, 64.0, 44.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"doneButton_nonActive"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"doneButton_Active"] forState:UIControlStateHighlighted];
	[_headerBGView addSubview:_backButton];
	
	_subjectsView = [[HONCameraSubjectsView alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, 215.0 + ([HONAppDelegate isRetina5] * 88.0))];
	_subjectsView.hidden = YES;
	_subjectsView.delegate = self;
	[self addSubview:_subjectsView];
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 50.0, 320.0, 50.0)];
	_buttonHolderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
	_buttonHolderView.alpha = 0.0;
	[self addSubview:_buttonHolderView];
	
	UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	retakeButton.frame = CGRectMake(10.0, 3.0, 64.0, 44.0);
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_nonActive"] forState:UIControlStateNormal];
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_Active"] forState:UIControlStateHighlighted];
	[retakeButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderView addSubview:retakeButton];
	
	UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previewButton.frame = CGRectMake(91.0, 3.0, 64.0, 44.0);
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_nonActive"] forState:UIControlStateNormal];
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_Active"] forState:UIControlStateHighlighted];
	[previewButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderView addSubview:previewButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(256.0, 3.0, 64.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"findalSubmitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderView addSubview:submitButton];
	
	_subscribersBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_subscribersBackButton.frame = CGRectMake(9.0, 14.0, 44.0, 44.0);
	[_subscribersBackButton setBackgroundImage:[UIImage imageNamed:@"backCameraButton_nonActive"] forState:UIControlStateNormal];
	[_subscribersBackButton setBackgroundImage:[UIImage imageNamed:@"backCameraButton_Active"] forState:UIControlStateHighlighted];
	[_subscribersBackButton addTarget:self action:@selector(_goSubscribersClose) forControlEvents:UIControlEventTouchDown];
	_subscribersBackButton.alpha = 0.0;
	[self addSubview:_subscribersBackButton];
}


#pragma mark - Navigation
- (void)_goToggleKeyboard {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Create Volley - Toggle Preview %@", ([_subjectTextField isFirstResponder]) ? @"Down" : @"Up"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ([_subjectTextField isFirstResponder])
		[self _dropKeyboardAndRemove:NO];
	
	else
		[self _raiseKeyboard];
}

- (void)_goSubscribers {
	[[Mixpanel sharedInstance] track:@"Create Volley - Show Opponents"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_subjectsView.hidden = NO;
	
	[_subjectTextField resignFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.65;
		
//		_subjectHolderView.frame = CGRectOffset(_subjectHolderView.frame, 0.0, 100);
//		_subjectHolderView.alpha = 0.0;
		_uploadingImageView.alpha = 0.0;
		
		_subjectsView.alpha = 1.0;
		_subjectsView.frame = CGRectOffset(_subjectsView.frame, 0.0, -100.0);
		
		_buttonHolderView.alpha = 0.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_subscribersBackButton.alpha = 1.0;
		}];
	}];
}

- (void)_goSubscribersClose {
	[[Mixpanel sharedInstance] track:@"Create Volley - Hide Opponents"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_subjectsView.hidden = NO;
	
	[_subjectTextField becomeFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		_subscribersBackButton.alpha = 0.0;
		
//		_subjectHolderView.frame = CGRectOffset(_subjectHolderView.frame, 0.0, -100);
//		_subjectHolderView.alpha = 1.0;
		_uploadingImageView.alpha = 1.0;
		
		_subjectsView.alpha = 0.0;
		_subjectsView.frame = CGRectOffset(_subjectsView.frame, 0.0, 100.0);
		
		_buttonHolderView.alpha = 1.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, -216.0);
	} completion:nil];
}


- (void)_goBack {
	[self _dropKeyboardAndRemove:YES];
	[self.delegate previewViewBackToCamera:self];
}

- (void)_goClose {
	[self _dropKeyboardAndRemove:YES];
	[self.delegate previewViewClose:self];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _dropKeyboardAndRemove:NO];
	if ([_subjectTextField.text length] > 0 && ![_subjectTextField.text isEqualToString:@"how are you feeling?"]) {
		_subjectName = _subjectTextField.text;
		[self.delegate previewView:self changeSubject:_subjectName];
		
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
//		[self _dropKeyboardAndRemove:YES];
		[self.delegate previewViewSubmit:self];
		
		[_subjectTextField resignFirstResponder];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.33;
			_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
			_uploadingImageView.alpha = 0.0;
			_placeholderLabel.alpha = 0.0;
			_subjectTextField.alpha = 0.0;
			_backButton.alpha = 0.0;
		} completion:^(BOOL finished) {
		}];
	
	} else {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Need to enter a hashtag"
															message:@"Enter hashtag before submitting!"
														   delegate:self
												  cancelButtonTitle:@"OK"
												  otherButtonTitles:nil];
		[alertView setTag:0];
		[alertView show];
	}
}

- (void)_onTextDoneEditingOnExit:(id)sender {
	NSLog(@"_onTextDoneEditingOnExit");
	[self _goSubmit];
}

- (void)_goCloseTutorial {
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
	} completion:^(BOOL finished) {
		if (_tutorialImageView != nil) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}
	}];
}


#pragma mark - UI Presentation
- (void)_raiseKeyboard {
	[_subjectTextField becomeFirstResponder];
	[_previewBackButton removeFromSuperview];
	
	_subjectsView.hidden = NO;
	if (_isFirstCamera) {
		_isFirstCamera = NO;
		_tutorialImageView = [[UIImageView alloc] initWithFrame:self.frame];
		_tutorialImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"tutorial_emotion-568h@2x" : @"tutorial_emotion"];
		_tutorialImageView.userInteractionEnabled = YES;
		_tutorialImageView.alpha = 0.0;
		[self addSubview:_tutorialImageView];
		
		UIButton *closeTutorialButton = [UIButton buttonWithType:UIButtonTypeCustom];
		closeTutorialButton.frame = _tutorialImageView.frame;
		[closeTutorialButton addTarget:self action:@selector(_goCloseTutorial) forControlEvents:UIControlEventTouchUpInside];
		[_tutorialImageView addSubview:closeTutorialButton];
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 1.0;
		}
		
		_blurredImageView.alpha = 1.0;
		_headerBGView.alpha = 1.0;
		_blackMatteView.alpha = 0.0;
		_uploadingImageView.alpha = 1.0;
		_subjectsView.alpha = 1.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, -216.0);
		_buttonHolderView.alpha = 1.0;
		_backButton.alpha = 1.0;
	}completion:^(BOOL finished) {
	}];
}

- (void)_dropKeyboardAndRemove:(BOOL)isRemoved {
	[_subjectTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
		
		_blurredImageView.alpha = 0.0;
		_headerBGView.alpha = 0.0;
		_blackMatteView.alpha = 0.0;
		_subjectsView.alpha = 0.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
		_uploadingImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_subjectsView.hidden = YES;
		
		if (isRemoved) {
			[self removeFromSuperview];
			
			if (_tutorialImageView != nil) {
				[_tutorialImageView removeFromSuperview];
				_tutorialImageView = nil;
			}
		}
		
		else
			[self addSubview:_previewBackButton];
	}];
}

#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	_placeholderLabel.text = ([_subjectTextField.text length] == 0) ? @"how are you feeling?" : @"";
}


#pragma mark - SubjectsView Delegates
- (void)subjectsView:(HONCameraSubjectsView *)cameraSubjectsView selectSubject:(NSString *)subject {
	_subjectName = subject;
	_subjectTextField.text = _subjectName;
	_placeholderLabel.text = ([_subjectTextField.text length] == 0) ? @"how are you feeling?" : @"";
	
	[self.delegate previewView:self changeSubject:_subjectName];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[self _raiseKeyboard];
	}
}

#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(_textFieldTextDidChangeChange:)
												 name:UITextFieldTextDidChangeNotification
											   object:textField];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField.text isEqualToString:@""])
		textField.text = @"#";
	
	if (_tutorialImageView != nil) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tutorialImageView.alpha = 0.0;
			
		} completion:^(BOOL finished) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}];
	}
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];
	
	if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
		textField.text = _subjectName;
	
	else {
		NSArray *hashTags = [textField.text componentsSeparatedByString:@"#"];
		
		if ([hashTags count] > 2) {
			NSString *hashTag = ([[hashTags objectAtIndex:1] hasSuffix:@" "]) ? [[hashTags objectAtIndex:1] substringToIndex:[[hashTags objectAtIndex:1] length] - 1] : [hashTags objectAtIndex:1];
			textField.text = [NSString stringWithFormat:@"#%@", hashTag];
		}
	}
	
	_subjectName = textField.text;
}


@end
