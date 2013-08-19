//
//  HONCreateChallengePreviewView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.15.13 @ 17:17 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONCreateChallengePreviewView.h"
#import "HONImagingDepictor.h"
#import "HONImageLoadingView.h"

@interface HONCreateChallengePreviewView () <UIAlertViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@property (nonatomic, strong) UILabel *usernamesLabel;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *privateToggleButton;
@property (nonatomic, strong) UIButton *addFriendsButton;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, strong) UIImageView *uploadingImageView;
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
		previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - _previewImage.size.width) * -0.5, (-26.0 + (-24.0 * [HONAppDelegate isRetina5])) + (ABS(self.frame.size.height - _previewImage.size.height) * -0.5) - [[UIApplication sharedApplication] statusBarFrame].size.height);
		previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
		[self addSubview:previewImageView];
		
		[self _makeUI];
	}
	
	return (self);
}


#pragma mark - Puplic APIs
- (void)uploadComplete {
	[_uploadingImageView stopAnimating];
	[_uploadingImageView removeFromSuperview];
}

- (void)setUsernames:(NSArray *)usernameList {
	NSString *usernames = @"";
	for (NSString *username in usernameList)
		usernames = [usernames stringByAppendingFormat:@"@%@, ", username];
	
	NSLog(@"USERNAMES:[%@][%@]", usernameList, usernames);
	
	//_usernamesLabel.text = ([usernames length] == 0) ? @"add friends" : [usernames substringToIndex:[usernames length] - 2];
	CGSize size = [usernames sizeWithFont:_usernamesLabel.font constrainedToSize:CGSizeMake(300.0, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	_usernamesLabel.frame = CGRectMake(_usernamesLabel.frame.origin.x, _usernamesLabel.frame.origin.y, size.width, size.height);
	_usernamesLabel.text = ([usernames length] >= 2) ? [usernames substringToIndex:[usernames length] - 2] : usernames;
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
	
	UIButton *toggleKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleKeyboardButton.frame = self.frame;
	[toggleKeyboardButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:toggleKeyboardButton];
	
	_addFriendsButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_addFriendsButton.frame = CGRectMake(12.0, 11.0, 44.0, 44.0);
	[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_nonActive"] forState:UIControlStateNormal];
	[_addFriendsButton setBackgroundImage:[UIImage imageNamed:@"addButton_Active"] forState:UIControlStateHighlighted];
	[_addFriendsButton addTarget:self action:@selector(_goAddChallengers) forControlEvents:UIControlEventTouchUpInside];
	_addFriendsButton.alpha = 0.0;
	//[self addSubview:_addFriendsButton];
	
	_avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0, 10.0, kSnapThumbDim, kSnapThumbDim)];
	[_avatarImageView setImageWithURL:[NSURL URLWithString:[[HONAppDelegate infoForUser] objectForKey:@"avatar_url"]] placeholderImage:nil];
	_avatarImageView.alpha = 0.0;
	[self addSubview:_avatarImageView];
	
	_usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 22.0, 220.0, 16.0)];
	_usernameLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	_usernameLabel.textColor = [UIColor whiteColor];
	_usernameLabel.backgroundColor = [UIColor clearColor];
	_usernameLabel.text = [NSString stringWithFormat:@"@%@", [[HONAppDelegate infoForUser] objectForKey:@"username"]];
	_usernameLabel.alpha = 0.0;
	[self addSubview:_usernameLabel];
	
	_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_backButton.frame = CGRectMake(263.0, 11.0, 44.0, 44.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_backButton addTarget:self action:@selector(_goBack) forControlEvents:UIControlEventTouchUpInside];
	_backButton.alpha = 0.0;
	[self addSubview:_backButton];
	
//	UIButton *usernameButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	usernameButton.frame = _usernamesLabel.frame;
//	[usernameButton addTarget:self action:@selector(_goAddChallengers) forControlEvents:UIControlEventTouchUpInside];
//	[self addSubview:usernameButton];
	
//	_privateToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
//	_privateToggleButton.frame = CGRectMake(184.0, self.frame.size.height - 335.0, 134.0, 44.0);
//	[_privateToggleButton setBackgroundImage:[UIImage imageNamed:(_isPrivate) ? @"privateOn_nonActive" : @"privateOff_nonActive"] forState:UIControlStateNormal];
//	[_privateToggleButton setBackgroundImage:[UIImage imageNamed:(_isPrivate) ? @"privateOn_Active" : @"privateOff_Active"] forState:UIControlStateHighlighted];
//	[_privateToggleButton addTarget:self action:@selector(_goPrivateToggle) forControlEvents:UIControlEventTouchUpInside];
//	_privateToggleButton.alpha = 0.0;
//	[self addSubview:_privateToggleButton];
	
//	_subjectBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 67.0, 320.0, 47.0)];
//	_subjectBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.93];
//	_subjectBGView.hidden = YES;
//	[self addSubview:_subjectBGView];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 70.0, 298.0, 30.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:22];;
	_placeholderLabel.textColor = [HONAppDelegate honGrey455Color];
	_placeholderLabel.text = ([_subjectName length] == 0) ? @"What's happening?" : @"";
	_placeholderLabel.alpha = 0.0;
	[self addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:_placeholderLabel.frame];
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:22];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = _subjectName;
	_subjectTextField.alpha = 0.0;
	_subjectTextField.delegate = self;
	[self addSubview:_subjectTextField];
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(128.0, 175.0, 64.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	_uploadingImageView.alpha = 0.0;
	[_uploadingImageView startAnimating];
	[self addSubview:_uploadingImageView];
	
	_usernamesLabel = [[UILabel alloc] initWithFrame:CGRectMake(22.0, 108.0, 300.0, 24.0)];
	_usernamesLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:21];
	_usernamesLabel.textColor = [UIColor whiteColor];
	_usernamesLabel.backgroundColor = [UIColor clearColor];
	_usernamesLabel.numberOfLines = 0;
	_usernamesLabel.text = @"";
	[self addSubview:_usernamesLabel];
		
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 73.0, 320.0, 53.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitUsernameButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	_submitButton.hidden = YES;
	[self addSubview:_submitButton];
}


#pragma mark - Navigation
- (void)_goToggleKeyboard {
	if ([_subjectTextField isFirstResponder])
		[self _dropKeyboardAndRemove:NO];
	
	else
		[self _raiseKeyboard];
}

- (void)_goAddChallengers {
	[self.delegate previewViewAddChallengers:self];
}

- (void)_goBack {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
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
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
		[self _dropKeyboardAndRemove:([[HONAppDelegate friendsList] count] > 1 && friend_total > 0)];
		//[self _dropKeyboardAndRemove:NO];
	
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
	_submitButton.hidden = NO;
//	_subjectBGView.hidden = NO;
	[_subjectTextField becomeFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_uploadingImageView.alpha = 1.0;
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
//		_subjectBGView.frame = CGRectOffset(_subjectBGView.frame, 0.0, -216.0);
//		_subjectBGView.alpha = 1.0;
		_placeholderLabel.alpha = 1.0;
		_subjectTextField.alpha = 1.0;
		_privateToggleButton.alpha = 1.0;
		_addFriendsButton.alpha = 1.0;
		_backButton.alpha = 1.0;
		_usernamesLabel.alpha = 1.0;
		_avatarImageView.alpha = 1.0;
		_usernameLabel.alpha = 1.0;
	}completion:^(BOOL finished) {
	}];
}

- (void)_dropKeyboardAndRemove:(BOOL)isRemoved {
	[_subjectTextField resignFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
		_uploadingImageView.alpha = 0.0;
		_placeholderLabel.alpha = 0.0;
		_subjectTextField.alpha = 0.0;
		_privateToggleButton.alpha = 0.0;
		_addFriendsButton.alpha = 0.0;
		_backButton.alpha = 0.0;
		_usernamesLabel.alpha = 0.0;
		_avatarImageView.alpha = 0.0;
		_usernameLabel.alpha = 0.0;
	} completion:^(BOOL finished) {
		_submitButton.hidden = YES;
		
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
