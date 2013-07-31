//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONCreateChallengePreviewView.h"
#import "HONImagingDepictor.h"


@interface HONCreateChallengePreviewView () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UILabel *usernamesLabel;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UIView *subjectBGView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic, strong) UIButton *privateToggleButton;
@property (nonatomic, strong) UIButton *addFriendsButton;
@property (nonatomic, strong) UIButton *backButton;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;
@synthesize isPrivate = _isPrivate;


- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];
		//NSLog(@"NORMAL");
		//NSLog(@"SRC IMAGE:[%@]", NSStringFromCGSize(image.size));
		
		_previewImage = image;
		_subjectName = subject;
		
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:(([HONAppDelegate isRetina5]) ? 1.25f : 1.125f) * (self.frame.size.width / image.size.width)];
		//NSLog(@"ZOOMED IMAGE:[%@]", NSStringFromCGSize(_previewImage.size));
		
		UIImageView *previewImageView = [[UIImageView alloc] initWithImage:_previewImage];
		[self addSubview:previewImageView];

		[self _makeUI];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withMirroredImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];
		//NSLog(@"MIRRORED");
		//NSLog(@"SRC IMAGE:[%@]", NSStringFromCGSize(image.size));
		
		_previewImage = image;
		_subjectName = subject;
		
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:([HONAppDelegate isRetina5]) ? 0.55f : 0.83333f];
		//NSLog(@"ZOOMED IMAGE:[%@]", NSStringFromCGSize(_previewImage.size));
		
		UIImageView *previewImageView = [[UIImageView alloc] initWithImage:_previewImage];
		previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, (-22.0 + (-24.0 * [HONAppDelegate isRetina5])) + (ABS(self.frame.size.height - _previewImage.size.height) * -0.5) - [[UIApplication sharedApplication] statusBarFrame].size.height);
		previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
		[self addSubview:previewImageView];
		
		[self _makeUI];
	}
	
	return (self);
}


#pragma mark - Puplic APIs
- (void)setUsernames:(NSArray *)usernameList {
	NSString *usernames = @"";
	for (NSString *username in usernameList)
		usernames = [usernames stringByAppendingFormat:@"@%@, ", username];
	
	//NSLog(@"USERNAMES:[%@][%@]", usernameList, usernames);
	_usernamesLabel.text = ([usernames length] == 0) ? @"add friends" : [usernames substringToIndex:[usernames length] - 2];
}

- (void)showKeyboard {
	[_subjectTextField becomeFirstResponder];
	[self _raiseKeyboard];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	UIView *overlayView = [[UIView alloc] initWithFrame:self.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	[self addSubview:overlayView];
	
	_addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_addFriendsButton.frame = CGRectMake(12.0, 11.0, 44.0, 44.0);
	[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
	[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
	[_addFriendsButton addTarget:self action:@selector(_goAddChallengers) forControlEvents:UIControlEventTouchUpInside];
	_addFriendsButton.alpha = 0.0;
	[self addSubview:_addFriendsButton];
	
	_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_backButton.frame = CGRectMake(253.0, 11.0, 44.0, 44.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	_backButton.alpha = 0.0;
	[self addSubview:_backButton];
	
	_usernamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 21.0, 210.0, 24.0)];
	_usernamesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_usernamesLabel.textColor = [UIColor whiteColor];
	_usernamesLabel.backgroundColor = [UIColor clearColor];
	_usernamesLabel.text = @"";
	[self addSubview:_usernamesLabel];
	
	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
	usernameButton.frame = _usernamesLabel.frame;
	[usernameButton addTarget:self action:@selector(_goAddChallengers) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:usernameButton];
	
	
	_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, ((self.frame.size.height - 230.0) - 44.0) * 0.5, 320.0, 44.0)];
	_captionLabel.backgroundColor = [UIColor clearColor];
	_captionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:22];
	_captionLabel.textColor = [UIColor whiteColor];
	_captionLabel.textAlignment = NSTextAlignmentCenter;
	_captionLabel.text = @"Tap to retake photo";
	_captionLabel.alpha = 0.0;
	//[self addSubview:_captionLabel];
	
	_privateToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_privateToggleButton.frame = CGRectMake(184.0, self.frame.size.height - 335.0, 134.0, 44.0);
	[_privateToggleButton setBackgroundImage:[UIImage imageNamed:(_isPrivate) ? @"privateOn_nonActive" : @"privateOff_nonActive"] forState:UIControlStateNormal];
	[_privateToggleButton setBackgroundImage:[UIImage imageNamed:(_isPrivate) ? @"privateOn_Active" : @"privateOff_Active"] forState:UIControlStateHighlighted];
	[_privateToggleButton addTarget:self action:@selector(_goPrivateToggle) forControlEvents:UIControlEventTouchUpInside];
	_privateToggleButton.alpha = 0.0;
	[self addSubview:_privateToggleButton];
	
	_subjectBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 67.0, 320.0, 47.0)];
	_subjectBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.93];
	_subjectBGView.hidden = YES;
	[self addSubview:_subjectBGView];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(13.0, 7.0, 298.0, 30.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:22];;
	_placeholderLabel.textColor = [HONAppDelegate honGrey455Color];
	_placeholderLabel.text = ([_subjectName length] == 0) ? @"what's on your mind?" : @"";
	[_subjectBGView addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 7.0, 298.0, 30.0)];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:22];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = _subjectName;
	_subjectTextField.delegate = self;
	[_subjectBGView addSubview:_subjectTextField];
	
	UIButton *sendButton = [UIButton buttonWithType:UIButtonTypeCustom];
	sendButton.frame = CGRectMake(255.0, 2.0, 64.0, 44.0);
	[sendButton setBackgroundImage:[UIImage imageNamed:@"sendButton_nonActive"] forState:UIControlStateNormal];
	[sendButton setBackgroundImage:[UIImage imageNamed:@"sendButton_Active"] forState:UIControlStateHighlighted];
	[sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sendButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_subjectBGView addSubview:sendButton];
}


#pragma mark - Navigation
- (void)_goAddChallengers {
	[self.delegate previewViewAddChallengers:self];
}

- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_subjectTextField resignFirstResponder];
	[self _dropKeyboardAndRemove:YES];
	
	[self.delegate previewViewBackToCamera:self];
}

- (void)_goPrivateToggle {
	_isPrivate = !_isPrivate;
	
	[_privateToggleButton setBackgroundImage:[UIImage imageNamed:(_isPrivate) ? @"privateOn_nonActive" : @"privateOff_nonActive"] forState:UIControlStateNormal];
	[_privateToggleButton setBackgroundImage:[UIImage imageNamed:(_isPrivate) ? @"privateOn_Active" : @"privateOff_Active"] forState:UIControlStateHighlighted];
	
	[self.delegate previewView:self challengeIsPublic:!_isPrivate];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	if ((_isPrivate && ![_usernamesLabel.text isEqualToString:@"add friends"]) || !_isPrivate) {
		[_subjectTextField resignFirstResponder];
		[self _dropKeyboardAndRemove:YES];
	
		[self.delegate previewView:self changeSubject:_subjectName];
		[self.delegate previewViewSubmit:self];
	
	} else {
		[self _dropKeyboardAndRemove:NO];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Send Private Message"
															message:@"You must select a friend to send a private photo message."
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


#pragma mark - UI Presentation
- (void)_raiseKeyboard {
	_subjectBGView.hidden = NO;
	[_subjectTextField becomeFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_subjectBGView.frame = CGRectOffset(_subjectBGView.frame, 0.0, -216.0);
		_captionLabel.alpha = 0.875;
		_privateToggleButton.alpha = 1.0;
		_addFriendsButton.alpha = 1.0;
		_backButton.alpha = 1.0;
		_usernamesLabel.alpha = 1.0;
	}completion:^(BOOL finished) {
	}];
}

- (void)_dropKeyboardAndRemove:(BOOL)isRemoved {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_subjectBGView.frame = CGRectOffset(_subjectBGView.frame, 0.0, 216.0);
		_captionLabel.alpha = 0.0;
		_privateToggleButton.alpha = 0.0;
		_addFriendsButton.alpha = 0.0;
		_backButton.alpha = 0.0;
		_usernamesLabel.alpha = 0.0;
	} completion:^(BOOL finished) {
		_subjectBGView.hidden = YES;
		
		if (isRemoved)
			[self removeFromSuperview];
	}];
}

#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	_placeholderLabel.text = ([_subjectTextField.text length] == 0) ? @"what's on your mind?" : @"";
	
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
