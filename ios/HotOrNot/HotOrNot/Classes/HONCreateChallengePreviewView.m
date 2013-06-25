//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONCreateChallengePreviewView.h"
#import "HONAppDelegate.h"
#import "HONImagingDepictor.h"

@interface HONCreateChallengePreviewView () <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *usernamesLabel;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UIView *subjectBGView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UILabel *captionLabel;
@property (nonatomic) BOOL isEnabled;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;


- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];
		NSLog(@"FRAME:[%@]", NSStringFromCGRect(self.frame));
		NSLog(@"SRC IMAGE:[%@]", NSStringFromCGSize(image.size));
		
		_isEnabled = NO;
		_previewImage = image;
		_subjectName = subject;
		
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:self.frame.size.width / image.size.width];
		NSLog(@"ZOOMED IMAGE:[%@]", NSStringFromCGSize(_previewImage.size));
		
		UIImageView *previewImageView = [[UIImageView alloc] initWithImage:_previewImage];
		[self addSubview:previewImageView];

		[self _makeUI];
	}
	
	return (self);
}

- (id)initWithFrame:(CGRect)frame withSubject:(NSString *)subject withMirroredImage:(UIImage *)image {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [UIColor blackColor];
		NSLog(@"FRAME:[%@]", NSStringFromCGRect(self.frame));
		NSLog(@"SRC IMAGE:[%@]", NSStringFromCGSize(image.size));
		
		_isEnabled = NO;
		_previewImage = image;
		_subjectName = subject;
		
		_previewImage = [HONImagingDepictor scaleImage:image byFactor:([HONAppDelegate isRetina5]) ? 0.83333f : 0.83333f];
		NSLog(@"ZOOMED IMAGE:[%@]", NSStringFromCGSize(_previewImage.size));
		
		UIImageView *previewImageView = [[UIImageView alloc] initWithImage:_previewImage];
		previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, (ABS(self.frame.size.height - _previewImage.size.height) * -0.5) - [[UIApplication sharedApplication] statusBarFrame].size.height);
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
	
	_usernamesLabel.text = ([usernames length] == 0) ? @"" : [usernames substringToIndex:[usernames length] - 2];
}

- (void)showKeyboard {
	[_subjectTextField becomeFirstResponder];
	[self _raiseKeyboard];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	//self.frame = CGRectOffset(self.frame, 0.0, -[[UIApplication sharedApplication] statusBarFrame].size.height);
	self.alpha = 0.0;
	
	UIImageView *addFriendsButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"addButton_nonActive"]];
	addFriendsButtonImageView.frame = CGRectOffset(addFriendsButtonImageView.frame, 12.0, 11.0);
	[self addSubview:addFriendsButtonImageView];
	
	UIImageView *closeButtonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closeButton_nonActive"]];
	closeButtonImageView.frame = CGRectOffset(closeButtonImageView.frame, 263.0, 11.0);
	[self addSubview:closeButtonImageView];
	
	_usernamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(66.0, 21.0, 210.0, 24.0)];
	_usernamesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:18];
	_usernamesLabel.textColor = [UIColor whiteColor];
	_usernamesLabel.backgroundColor = [UIColor clearColor];
	_usernamesLabel.text = @"";
	[self addSubview:_usernamesLabel];
	
	UIView *overlayView = [[UIView alloc] initWithFrame:self.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.25];
	[self addSubview:overlayView];
	
	_captionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, ((self.frame.size.height - 230.0) - 44.0) * 0.5, 320.0, 44.0)];
	_captionLabel.backgroundColor = [UIColor clearColor];
	_captionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:22];
	_captionLabel.textColor = [UIColor whiteColor];
	_captionLabel.textAlignment = NSTextAlignmentCenter;
	_captionLabel.text = @"Tap to retake photo";
	_captionLabel.alpha = 0.0;
	[self addSubview:_captionLabel];
	
	UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	backButton.frame = self.frame;
	[backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:backButton];
	
	_subjectBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 47.0, 320.0, 47.0)];
	_subjectBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.93];
	_subjectBGView.hidden = YES;
	[self addSubview:_subjectBGView];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 7.0, 298.0, 30.0)];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor colorWithRed:0.376 green:0.365 blue:0.365 alpha:1.0]];
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
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		self.alpha = 1.0;
	}];
}


#pragma mark - Navigation
- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_subjectTextField resignFirstResponder];
	[self _dropKeyboardAndRemove:YES];
	
	[self.delegate previewViewBackToCamera:self];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[_subjectTextField resignFirstResponder];
	[self _dropKeyboardAndRemove:YES];
	
	[self.delegate previewView:self changeSubject:_subjectName];
	[self.delegate previewViewSubmit:self];
}

- (void)_onTextDoneEditingOnExit:(id)sender {
	NSLog(@"_onTextDoneEditingOnExit");
	[self _goSubmit];
}


#pragma mark - UI Presentation
- (void)_raiseKeyboard {
	_isEnabled = YES;
	
	_subjectBGView.hidden = NO;
	[UIView animateWithDuration:0.25 animations:^(void) {
		_subjectBGView.frame = CGRectOffset(_subjectBGView.frame, 0.0, -216.0);
		_captionLabel.alpha = 0.875;
	}];
}

- (void)_dropKeyboardAndRemove:(BOOL)isRemoved {
	_isEnabled = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_subjectBGView.frame = CGRectOffset(_subjectBGView.frame, 0.0, 216.0);
		_captionLabel.alpha = 0.0;
	} completion:^(BOOL finished) {
		if (isRemoved)
			[self removeFromSuperview];
	}];
}

#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
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
