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
#import "HONUserVO.h"
#import "HONVolleyEmotionsPickerView.h"

@interface HONCreateChallengePreviewView () <HONVolleyEmotionsPickerViewDelegate>
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *creatorSubjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *previewBackButton;
@property (nonatomic, strong) UIImageView *buttonHolderImageView;
@property (nonatomic, strong) HONVolleyEmotionsPickerView *subjectsView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIImageView *headerBGImageView;
@property (nonatomic, strong) UIImageView *replyImageView;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;
@synthesize isFirstCamera = _isFirstCamera;
@synthesize isJoinChallenge = _isJoinChallenge;


- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		_subjectName = subject;
		
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
		self.backgroundColor = [UIColor whiteColor];;
		_subjectName = subject;
		
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

- (void)setIsJoinChallenge:(BOOL)isJoinChallenge {
	_isJoinChallenge = isJoinChallenge;
	
	_placeholderLabel.frame = CGRectOffset(_placeholderLabel.frame, ((int)_isJoinChallenge) * 25.0, 0.0);//(10.0 + ((int)_isJoinChallenge) * 25.0, _placeholderLabel.frame.origin.y, _placeholderLabel.frame.size.width - (((int)_isJoinChallenge) * 25.0), _placeholderLabel.frame.size.height);
	_subjectTextField.frame = _placeholderLabel.frame;
	
	_replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"replyArrow"]];
	_replyImageView.frame = CGRectOffset(_replyImageView.frame, 8.0, 12.0);
	_replyImageView.hidden = !_isJoinChallenge;
	[_headerBGImageView addSubview:_replyImageView];
	
	_creatorSubjectName = (_isJoinChallenge) ? [NSString stringWithFormat:@"%@ : ", _subjectName] : @"";
	_subjectTextField.text = @"";//(_isJoinChallenge) ? [NSString stringWithFormat:@"%@ : ", _subjectName] : _subjectName;
	
	_subjectsView.isJoinVolley = _isJoinChallenge;
}

- (void)uploadComplete {
	NSLog(@"uploadComplete");
	[_cancelButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
}

- (void)showKeyboard {
	[_subjectTextField becomeFirstResponder];
	[self _raiseKeyboard];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerFadeBackground"]]];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
	_blackMatteView.backgroundColor = [UIColor blackColor];
	_blackMatteView.alpha = 0.0;
	[self addSubview:_blackMatteView];
	
	_previewBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_previewBackButton.frame = self.frame;
	[_previewBackButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchDown];
	
	_headerBGImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraInputField"]];
	_headerBGImageView.userInteractionEnabled = YES;
	[self addSubview:_headerBGImageView];
		
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(15.0, -2.0, 230.0, 50.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_placeholderLabel.textColor = [HONAppDelegate honGreyTextColor];
	_placeholderLabel.text = (_isJoinChallenge) ? @"reply how you feel" : @"how are you feeling?"; //([_subjectName length] == 0) ? (_isJoinChallenge) ? @"reply how you feel" : @"how are you feeling?" : @"";
	[_headerBGImageView addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:_placeholderLabel.frame];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[HONAppDelegate honBlueTextColor]];
	[_subjectTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = @"";//(_isJoinChallenge) ? [NSString stringWithFormat:@"%@ : ", _subjectName] : _subjectName;
	_subjectTextField.delegate = self;
	[_headerBGImageView addSubview:_subjectTextField];
	
	_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelButton.frame = CGRectMake(248.0, 0.0, 64.0, 44.0);
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	_cancelButton.alpha = 0.75;
	[_headerBGImageView addSubview:_cancelButton];
	
	_subjectsView = [[HONVolleyEmotionsPickerView alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, 215.0 + ([HONAppDelegate isRetina4Inch] * 88.0)) AsComposeSubjects:!_isJoinChallenge];
	_subjectsView.hidden = YES;
	_subjectsView.delegate = self;
	[self addSubview:_subjectsView];
	
	_buttonHolderImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 50.0, 320.0, 50.0)];
	_buttonHolderImageView.image = [UIImage imageNamed:@"sendBackground"];
	_buttonHolderImageView.userInteractionEnabled = YES;
	_buttonHolderImageView.alpha = 0.0;
	[self addSubview:_buttonHolderImageView];
	
	UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	retakeButton.frame = CGRectMake(10.0, 3.0, 64.0, 44.0);
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_nonActive"] forState:UIControlStateNormal];
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_Active"] forState:UIControlStateHighlighted];
	[retakeButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderImageView addSubview:retakeButton];
	
	UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previewButton.frame = CGRectMake(91.0, 3.0, 64.0, 44.0);
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_nonActive"] forState:UIControlStateNormal];
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_Active"] forState:UIControlStateHighlighted];
	[previewButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderImageView addSubview:previewButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(239.0, 3.0, 74.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderImageView addSubview:submitButton];
}


#pragma mark - Navigation
- (void)_goToggleKeyboard {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Create Volley - Toggle Preview %@", ([_subjectTextField isFirstResponder]) ? @"Down" : @"Up"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	if ([_subjectTextField isFirstResponder])
		[self _dropKeyboardAndRemove:NO];
	
	else
		[self _raiseKeyboard];
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
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _dropKeyboardAndRemove:NO];
	if ([_subjectTextField.text length] > 0 || _isJoinChallenge) {
		
		if (!_isJoinChallenge)
			_subjectName = _subjectTextField.text;
		
		[self.delegate previewView:self changeSubject:_subjectName];
		
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self.delegate previewViewSubmit:self];
		
		[_subjectTextField resignFirstResponder];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.33;
			_buttonHolderImageView.frame = CGRectOffset(_buttonHolderImageView.frame, 0.0, 216.0);
			_placeholderLabel.alpha = 0.0;
			_subjectTextField.alpha = 0.0;
			_cancelButton.alpha = 0.0;
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
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil)
			_tutorialImageView.alpha = 1.0;
		
		_blurredImageView.alpha = 1.0;
		_headerBGImageView.alpha = 1.0;
		_blackMatteView.alpha = 0.0;
		_subjectsView.alpha = 1.0;
		_buttonHolderImageView.frame = CGRectOffset(_buttonHolderImageView.frame, 0.0, -216.0);
		_buttonHolderImageView.alpha = 1.0;
		_cancelButton.alpha = 1.0;
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
		_headerBGImageView.alpha = 0.0;
		_blackMatteView.alpha = 0.0;
		_subjectsView.alpha = 0.0;
		_buttonHolderImageView.frame = CGRectOffset(_buttonHolderImageView.frame, 0.0, 216.0);
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
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);
	
	if ([[_subjectTextField.text componentsSeparatedByString:@"#"] count] > (2 + (_isJoinChallenge))) {
		[[[UIAlertView alloc] initWithTitle:(_isJoinChallenge) ? @"Two emoticons only allowed" : @"One emotion only allowed"
									message:@""
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
		
		_subjectTextField.text = @"";//(_isJoinChallenge) ? [NSString stringWithFormat:@"%@ : ", _subjectName] : @"";
		_placeholderLabel.text = (_isJoinChallenge) ? @"reply how you feel" : @"how are you feeling?";//([_subjectTextField.text length] == 0) ? (_isJoinChallenge) ? @"reply how you feel" : @"how are you feeling?" : @"";
	}
	
//	NSString *enteredCharacter = [_subjectTextField.text substringFromIndex:[_creatorSubjectName length]];
//	if ([[_subjectTextField.text substringToIndex:[_subjectTextField.text length] - 1] isEqualToString:_creatorSubjectName])
//		_subjectTextField.text = [_creatorSubjectName stringByAppendingFormat:@" : #%@", enteredCharacter];
}


#pragma mark - EmotionsPickerView Delegates
- (void)emotionsPickerView:(HONVolleyEmotionsPickerView *)cameraSubjectsView selectEmotion:(HONEmotionVO *)emotionVO {
	_subjectTextField.text = @"";//(_isJoinChallenge) ? _creatorSubjectName : @"#";
	_placeholderLabel.text = @"";
	
	NSLog(@"join_total:[%d]", [HONAppDelegate totalForCounter:@"join"]);
//	if (_isJoinChallenge && [HONAppDelegate incTotalForCounter:@"join"] == 0) {
//		[[[UIAlertView alloc] initWithTitle:@"You are about to add a second emoticon to this selfie"
//									message:@""
//								   delegate:nil
//						  cancelButtonTitle:@"OK"
//						  otherButtonTitles:nil] show];
//	
//	} else
		_subjectTextField.text = emotionVO.hastagName;//(!_isJoinChallenge) ? emotionVO.hastagName : [NSString stringWithFormat:@"%@%@", _creatorSubjectName, emotionVO.hastagName];
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[self _raiseKeyboard];
	}
}

#pragma mark - TextField Delegates
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
	return (YES);
}

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
	NSLog(@"textField:%@shouldChangeCharactersInRange:%@ replacementString:%@", textField.text, NSStringFromRange(range), string);
	
	if (_tutorialImageView != nil) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_tutorialImageView.alpha = 0.0;
			
		} completion:^(BOOL finished) {
			[_tutorialImageView removeFromSuperview];
			_tutorialImageView = nil;
		}];
	}
	
//	NSString *orgState = (_isJoinChallenge) ? [NSString stringWithFormat:@"%@%@", _creatorSubjectName, _subjectDelimiter] : @"#";
	NSLog(@"ORG:[%@]\nTXT:[%@]\nCHG:[%@]", _creatorSubjectName, textField.text, string);
	
	_placeholderLabel.text = ([textField.text length] == 1) ? (_isJoinChallenge) ? @"reply how you feel" : @"how are you feeling?" : @"";
	
	// at starting pt for create, set to # and allow change
	if ([textField.text length] == 0 && [string length] == 1) {
		textField.text = @"#";
		return (YES);
	}
	
//	// at the starting pt for join and tapped a letter, append delimeter
//	if ([textField.text isEqualToString:_creatorSubjectName] && range.length == 0 && [string length] != 0) {
//		textField.text = [NSString stringWithFormat:@"%@#", _creatorSubjectName];
//		return (YES);
//	}
//	
//	// at starting pt, and tapped backspace
//	if ([textField.text isEqualToString:_creatorSubjectName] && range.length == 1) {
//		return (NO);
//	}

	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	_subjectName = textField.text;
}


@end