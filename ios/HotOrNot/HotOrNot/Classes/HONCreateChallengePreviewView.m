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
#import "HONVolleyEmotionsPickerView.h"

@interface HONCreateChallengePreviewView () <HONVolleyEmotionsPickerViewDelegate>
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *previewBackButton;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONVolleyEmotionsPickerView *subjectsView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *headerBGView;
@property (nonatomic, strong) UIImageView *replyImageView;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;
@synthesize isFirstCamera = _isFirstCamera;
@synthesize isJoinChallenge = _isJoinChallenge;


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
	
	_placeholderLabel.frame = CGRectMake(10.0 + ((int)_isJoinChallenge) * 25.0, -2.0, 180.0, 50.0);
	_subjectTextField.frame = _placeholderLabel.frame;
	
	_replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallReplyArrow_nonActive"]];
	_replyImageView.frame = CGRectOffset(_replyImageView.frame, 5.0, 10.0);
	_replyImageView.hidden = !_isJoinChallenge;
	[_headerBGView addSubview:_replyImageView];
	
	_subjectsView.isJoinVolley = _isJoinChallenge;
}

- (void)uploadComplete {
	[_uploadingImageView stopAnimating];
	[_uploadingImageView removeFromSuperview];
	
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
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, -2.0, 180.0, 50.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_placeholderLabel.textColor = [UIColor whiteColor];
	_placeholderLabel.text = ([_subjectName length] == 0) ? @"how are you feeling?" : @"";
//	[_headerBGView addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:_placeholderLabel.frame];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.placeholder = @"how are you feeling?";
	_subjectTextField.text = _subjectName;
	_subjectTextField.delegate = self;
	[_headerBGView addSubview:_subjectTextField];
	
	_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelButton.frame = CGRectMake(248.0, 0.0, 64.0, 44.0);
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	_cancelButton.alpha = 0.75;
	[_headerBGView addSubview:_cancelButton];
	
	_subjectsView = [[HONVolleyEmotionsPickerView alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, 215.0 + ([HONAppDelegate isRetina4Inch] * 88.0)) AsComposeSubjects:!_isJoinChallenge];
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
	if ([_subjectTextField.text length] > 0 && ![_subjectTextField.text isEqualToString:@"how are you feeling?"]) {
		_subjectName = _subjectTextField.text;
		[self.delegate previewView:self changeSubject:_subjectName];
		
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self.delegate previewViewSubmit:self];
		
		[_subjectTextField resignFirstResponder];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.33;
			_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
			_uploadingImageView.alpha = 0.0;
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
//- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//}


#pragma mark - EmotionsPickerView Delegates
- (void)emotionsPickerView:(HONVolleyEmotionsPickerView *)cameraSubjectsView selectEmotion:(HONEmotionVO *)emotionVO {
	
//	int total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"join_total"] intValue];
//	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++total] forKey:@"join_total"];
//	[[NSUserDefaults standardUserDefaults] synchronize];
	NSLog(@"join_total:[%d]", [HONAppDelegate totalForCounter:@"join"]);
	
	if (_isJoinChallenge && [HONAppDelegate totalForCounter:@"join"] == 0) {
		[HONAppDelegate incTotalForCounter:@"join"];
		[[[UIAlertView alloc] initWithTitle:@"You are about to add a second emoticon to this Volley"
									message:@""
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	
	} else {
		_subjectName = ([_subjectName length] == 0) ? emotionVO.hastagName : [NSString stringWithFormat:@"%@ : %@", _subjectName, emotionVO.hastagName];
		
		_subjectTextField.text = _subjectName;
		_placeholderLabel.text = ([_subjectTextField.text length] == 0) ? @"how are you feeling?" : @"";
	}
}


#pragma mark - AlertView Delegates
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		[self _raiseKeyboard];
	
//	} else if (alertView.tag == 1) {
//		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Camera Preview - Create New Volley %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
//		
//		if (buttonIndex == 0) {
//			_replyImageView.hidden = YES;
//			
//			_subjectName = _tmpSubjectName;
//			_placeholderLabel.frame = CGRectMake(10.0, -2.0, 180.0, 50.0);
//			_subjectTextField.frame = _placeholderLabel.frame;
//			_subjectTextField.text = _subjectName;
//			
//		} else {
//			[self _goSubmit];
//		}
//	
//	} else if (alertView.tag == 2) {
//		[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Camera Preview - Create New Volley %@", (buttonIndex == 0) ? @"Cancel" : @"Confirm"]
//							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
//										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
//		
//		if (buttonIndex == 0) {
//			_replyImageView.hidden = YES;
//			
//			_subjectName = @"";
//			_placeholderLabel.frame = CGRectMake(10.0, -2.0, 180.0, 50.0);
//			_subjectTextField.frame = _placeholderLabel.frame;
//			
//			_subjectTextField.text = _subjectName;
//			_placeholderLabel.text = ([_subjectTextField.text length] == 0) ? @"how are you feeling?" : @"";
//			
//		} else {
//			_subjectTextField.text = _subjectName;
//			[self _goSubmit];
//		}
	}
}

#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//	[[NSNotificationCenter defaultCenter] addObserver:self
//											 selector:@selector(_textFieldTextDidChangeChange:)
//												 name:UITextFieldTextDidChangeNotification
//											   object:textField];
	
	if (_isJoinChallenge && [HONAppDelegate totalForCounter:@"join"] == 0) {
		[HONAppDelegate incTotalForCounter:@"join"];
		[[[UIAlertView alloc] initWithTitle:@"You are about to add a second emoticon to this Volley"
									message:@""
								   delegate:nil
						  cancelButtonTitle:@"OK"
						  otherButtonTitles:nil] show];
	} else {
		[_subjectName stringByAppendingString:@" : "];
	}
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
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:textField];
	
//	if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
//		textField.text = _subjectName;
//	
//	else {
//		NSArray *hashTags = [textField.text componentsSeparatedByString:@"#"];
//		
//		if ([hashTags count] > 2) {
//			NSString *hashTag = ([[hashTags objectAtIndex:1] hasSuffix:@" "]) ? [[hashTags objectAtIndex:1] substringToIndex:[[hashTags objectAtIndex:1] length] - 1] : [hashTags objectAtIndex:1];
//			textField.text = [NSString stringWithFormat:@"#%@", hashTag];
//		}
//	}
	
	_placeholderLabel.text = ([textField.text length] == 0) ? @"how are you feeling?" : @"";
	_subjectName = textField.text;
}


@end
