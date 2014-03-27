//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImage+ImageEffects.h"
#import "UIImageView+AFNetworking.h"

#import "HONCreateChallengePreviewView.h"
#import "HONColorAuthority.h"
#import "HONDeviceTraits.h"
#import "HONFontAllocator.h"
#import "HONImagingDepictor.h"
#import "HONUserVO.h"
#import "HONTrivialUserVO.h"
#import "HONVolleyEmotionsPickerView.h"

@interface HONCreateChallengePreviewView () <HONVolleyEmotionsPickerViewDelegate>
@property (readonly, nonatomic, assign) HONSelfieSubmitType selfieSubmitType;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) NSString *creatorSubjectName;
@property (nonatomic, strong) UILabel *toGroupLabel;
@property (nonatomic, strong) UIView *emotionBGView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *emotionTextField;
@property (nonatomic, strong) UIImageView *blurredImageView;
@property (nonatomic, strong) NSArray *recipients;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *controlsButton;
@property (nonatomic, strong) UIButton *previewBackButton;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) HONVolleyEmotionsPickerView *emotionsPickerView;
@property (nonatomic, strong) UIImageView *tutorialImageView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIImageView *previewImageView;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withPreviewImage:(UIImage *)image asSubmittingType:(HONSelfieSubmitType)selfieSubmitType withSubject:(NSString *)subject withRecipients:(NSArray *)recipients {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor whiteColor];
		
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:([UIScreen mainScreen].bounds.size.height / 1280.0) * 2.0];
		_selfieSubmitType = selfieSubmitType;
		
		NSLog(@"PREVIEW -- SRC IMAGE:[%@]\nZOOMED IMAGE:[%@]", NSStringFromCGSize(image.size), NSStringFromCGSize(_previewImage.size));
		
		_subjectName = subject;
		_creatorSubjectName = (_selfieSubmitType == HONSelfieSubmitTypeReplyChallenge) ? [NSString stringWithFormat:@"%@ : ", _subjectName] : @"";
		_recipients = recipients;
		
		[self _adoptUI];
	}
	
	return (self);
}


#pragma mark - Puplic APIs
- (void)uploadComplete {
	NSLog(@"uploadComplete");
//	[self _raiseKeyboard];
	[_cancelButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchDown];
}


#pragma mark - UI Presentation
- (void)_adoptUI {
	
	_previewImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ABS(self.frame.size.width - (_previewImage.size.width * 0.5)) * -0.5, ABS(self.frame.size.height - (_previewImage.size.height * 0.5)) * ((self.frame.size.height < (_previewImage.size.height * 0.5)) ? -0.5 : 0.0), _previewImage.size.width * 0.5, _previewImage.size.height * 0.5)];
	_previewImageView.image = _previewImage;
	[self addSubview:_previewImageView];
	
	_controlsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_controlsButton.frame = self.frame;
	[_controlsButton addTarget:self action:@selector(_raiseKeyboard) forControlEvents:UIControlEventTouchDown];
	[self addSubview:_controlsButton];
	
//	_blurredImageView = [[UIImageView alloc] initWithImage:[_previewImage applyBlurWithRadius:8.0 tintColor:[UIColor clearColor] saturationDeltaFactor:1.0 maskImage:nil]];
//	_blurredImageView.frame = _previewImageView.frame;
//	_blurredImageView.alpha = 0.0;
//	[self addSubview:_blurredImageView];
	
	// !]~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~[¡]~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~=~[! //
	
	[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerFadeBackground"]]];
	
	_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
	_blackMatteView.backgroundColor = [UIColor blackColor];
	_blackMatteView.alpha = 0.0;
	[self addSubview:_blackMatteView];
	
//	_previewBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_previewBackButton.frame = self.frame;
//	[_previewBackButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchDown];
	
	_headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
	_headerView.alpha = 0.0;
	_headerView.backgroundColor = [UIColor whiteColor];
	[self addSubview:_headerView];
	
	UILabel *toLabel = [[UILabel alloc] initWithFrame:CGRectMake(44.0, 12.0, 20.0, 18.0)];
	toLabel.backgroundColor = [UIColor clearColor];
	toLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	toLabel.textColor = [[HONColorAuthority sharedInstance] honDarkGreyTextColor];
	toLabel.text = @"To:";
	[_headerView addSubview:toLabel];
	
	NSString *recipientNames = (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge) ? @"All my followers" : @"";
	for (HONTrivialUserVO *vo in _recipients)
		recipientNames = [[recipientNames stringByAppendingString:vo.username] stringByAppendingString:@", "];
	
	if ([[recipientNames substringFromIndex:[recipientNames length] - 2] isEqualToString:@", "])
		recipientNames = [recipientNames substringToIndex:[recipientNames length] - 2];
	
	_toGroupLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 12.0, 170.0, 18.0)];
	_toGroupLabel.backgroundColor = [UIColor clearColor];
	_toGroupLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:14];
	_toGroupLabel.textColor = [[HONColorAuthority sharedInstance] honBlueTextColor];
	_toGroupLabel.text = recipientNames;
	[_headerView addSubview:_toGroupLabel];
	
	
	UIButton *toGroupButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toGroupButton.frame = _toGroupLabel.frame;
	[toGroupButton addTarget:self action:@selector(_goSelectRecipients) forControlEvents:UIControlEventTouchDown];
	[_headerView addSubview:toGroupButton];
	
//	UIImageView *replyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"replyArrow"]];
//	replyImageView.frame = CGRectOffset(_replyImageView.frame, 8.0, 12.0 + (45.0 * (_recipients != nil)));
//	replyImageView.hidden = (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge || _selfieSubmitType == HONSelfieSubmitTypeCreateMessage);
//	[_headerView addSubview:replyImageView];
	
	UIView *avatarHolderView = [[UIView alloc] initWithFrame:CGRectMake(38.0, 5.0, 203.0, 34.0)];
	avatarHolderView.clipsToBounds = YES;
	avatarHolderView.hidden = YES;//(_recipients == nil);
	[_headerView addSubview:avatarHolderView];
	
	int offset = 0;
	for (HONTrivialUserVO *vo in _recipients) {
		UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(offset, 0.0, 34.0, 34.0)];
		[avatarImageView setImageWithURL:[NSURL URLWithString:[vo.avatarPrefix stringByAppendingString:kSnapThumbSuffix]] placeholderImage:nil];
		[avatarHolderView addSubview:avatarImageView];
		offset += 39;
	}
	
	_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cancelButton.frame = CGRectMake(249.0, 0.0, 64.0, 44.0);
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	_cancelButton.alpha = 0.75;
	[_headerView addSubview:_cancelButton];
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_emotionBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 45.0, 320.0, 134.0)];
	_emotionBGView.backgroundColor = [UIColor colorWithRed:0.796 green:0.314 blue:0.329 alpha:1.0];
	_emotionBGView.alpha = 0.0;
	[self addSubview:_emotionBGView];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 39.0, 280.0, 50.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontLight] fontWithSize:28];
	_placeholderLabel.textColor = [UIColor whiteColor];
	_placeholderLabel.textAlignment = NSTextAlignmentCenter;
	_placeholderLabel.text = (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge || _selfieSubmitType == HONSelfieSubmitTypeCreateMessage) ? @"how do you feel?" : @"reply how you feel";
	[_emotionBGView addSubview:_placeholderLabel];
	
	_emotionTextField = [[UITextField alloc] initWithFrame:_placeholderLabel.frame];
	[_emotionTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_emotionTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_emotionTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_emotionTextField setReturnKeyType:UIReturnKeyDone];
	_emotionTextField.keyboardType = UIKeyboardTypeDefault;
	[_emotionTextField setTextColor:[UIColor whiteColor]];
	_emotionTextField.font = _placeholderLabel.font;
	_emotionTextField.text = @"";
	_emotionTextField.delegate = self;
	[_emotionTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	[_emotionBGView addSubview:_emotionTextField];
	
	//]~=~=~=~=~=~=~=~=~=~=~=~=~=~[]~=~=~=~=~=~=~=~=~=~=~=~=~=~[
	
	_emotionsPickerView = [[HONVolleyEmotionsPickerView alloc] initWithFrame:CGRectMake(0.0, 178.0, 320.0, [UIScreen mainScreen].bounds.size.height - 178.0) AsComposeSubjects:(_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge)];
	_emotionsPickerView.hidden = YES;
	_emotionsPickerView.delegate = self;
	_emotionsPickerView.isJoinVolley = _selfieSubmitType;
//	[self addSubview:_emotionsPickerView];
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 48.0, 320.0, 48.0)];
	_buttonHolderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.667];
	_buttonHolderView.userInteractionEnabled = YES;
	_buttonHolderView.alpha = 0.0;
	[self addSubview:_buttonHolderView];
	
	UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
	retakeButton.frame = CGRectMake(10.0, 2.0, 64.0, 44.0);
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_nonActive"] forState:UIControlStateNormal];
	[retakeButton setBackgroundImage:[UIImage imageNamed:@"cameraReTakeButton_Active"] forState:UIControlStateHighlighted];
	[retakeButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderView addSubview:retakeButton];
	
	UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previewButton.frame = CGRectMake(91.0, 2.0, 64.0, 44.0);
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_nonActive"] forState:UIControlStateNormal];
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_Active"] forState:UIControlStateHighlighted];
	[previewButton addTarget:self action:@selector(_goTogglePreview) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderView addSubview:previewButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(236.0, 1.0, 74.0, 44.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"cameraSubmitButton_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchDown];
	[_buttonHolderView addSubview:submitButton];
}


#pragma mark - Navigation
- (void)_goSelectRecipients {
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@""
															 delegate:self
													cancelButtonTitle:@"Cancel"
											   destructiveButtonTitle:nil
													otherButtonTitles:@"All My Followers", @"Club Members", @"DM Recipients", nil];
	[actionSheet showInView:self];
}

- (void)_goTogglePreview {
	[[Mixpanel sharedInstance] track:[NSString stringWithFormat:@"Create Volley - Toggle Preview %@", ([_emotionTextField isFirstResponder]) ? @"Down" : @"Up"]
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"username"]], @"user", nil]];
	
	[self _dropKeyboardAndRemove:NO];
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
	if ([_emotionTextField.text length] > 0 || (_selfieSubmitType == HONSelfieSubmitTypeReplyChallenge)) {
		
		if (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge)
			_subjectName = _emotionTextField.text;
		
		[self.delegate previewView:self changeSubject:_subjectName];
		
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self.delegate previewViewSubmit:self];
		
		[_emotionTextField resignFirstResponder];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.33;
//			_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
			_placeholderLabel.alpha = 0.0;
			_emotionTextField.alpha = 0.0;
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
	//[_emotionTextField becomeFirstResponder];
//	[_previewBackButton removeFromSuperview];
	
	_emotionsPickerView.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil)
			_tutorialImageView.alpha = 1.0;
		
		_blurredImageView.alpha = 1.0;
		_headerView.alpha = 1.0;
		_emotionBGView.alpha = 1.0;
		_blackMatteView.alpha = 0.0;
		_emotionsPickerView.alpha = 1.0;
//		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, -216.0);
		_buttonHolderView.alpha = 1.0;
		_cancelButton.alpha = 1.0;
	}completion:^(BOOL finished) {
	}];
}

- (void)_dropKeyboardAndRemove:(BOOL)isRemoved {
	[_emotionTextField resignFirstResponder];
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		if (_tutorialImageView != nil) {
			_tutorialImageView.alpha = 0.0;
		}
		
		_blurredImageView.alpha = 0.0;
		_headerView.alpha = 0.0;
		_emotionBGView.alpha = 0.0;
		_blackMatteView.alpha = 0.0;
		_emotionsPickerView.alpha = 0.0;
//		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
	} completion:^(BOOL finished) {
		_emotionsPickerView.hidden = YES;
		
		if (isRemoved) {
			[self removeFromSuperview];
			
			if (_tutorialImageView != nil) {
				[_tutorialImageView removeFromSuperview];
				_tutorialImageView = nil;
			}
		}
		
//		else
//			[self addSubview:_previewBackButton];
	}];
}

#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
//	NSLog(@"UITextFieldTextDidChangeNotification:[%@]", [notification object]);	
	_placeholderLabel.text = ([_emotionTextField.text length] == 0) ? (_selfieSubmitType == HONSelfieSubmitTypeCreateChallenge) ? @"how do you feel?" : @"reply how you feel" : @"";
}


#pragma mark - EmotionsPickerView Delegates
- (void)emotionsPickerView:(HONVolleyEmotionsPickerView *)cameraSubjectsView selectEmotion:(HONEmotionVO *)emotionVO {
	_emotionTextField.text = @"";
	_placeholderLabel.text = @"";
	
	_emotionTextField.text = emotionVO.hastagName;
}


#pragma mark - ActionSheet Delegates
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
		
	
	} else if (buttonIndex == 2) {
		
	
	} else if (buttonIndex == 3) {
		
	
	} else if (buttonIndex == 4) {
		
	} else {
		
	}
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
//	NSLog(@"textField:%@shouldChangeCharactersInRange:%@ replacementString:%@", textField.text, NSStringFromRange(range), string);
	
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
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UITextFieldTextDidChangeNotification"
												  object:textField];
	_subjectName = textField.text;
}


@end
