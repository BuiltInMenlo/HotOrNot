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
#import "HONUserVO.h"
#import "HONCameraPreviewSubscribersView.h"

@interface HONCreateChallengePreviewView () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, HONCameraPreviewSubscribersViewDelegate>
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UIView *subjectHolderView;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *previewBackButton;
@property (nonatomic, strong) UIButton *subscribersBackButton;
@property (nonatomic, strong) UIButton *subscribersButton;
@property (nonatomic, strong) UIView *buttonHolderView;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) HONCameraPreviewSubscribersView *subscribersView;
@end

@implementation HONCreateChallengePreviewView
@synthesize delegate = _delegate;


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

- (void)setOpponents:(NSArray *)users asJoining:(BOOL)isJoining redrawTable:(BOOL)isRedraw {
	_subscribersView.opponents = [users mutableCopy];
	_actionLabel.text = (isJoining) ? [NSString stringWithFormat:@"Joining %d other%@", [users count], ([users count] != 1 ? @"s" : @"")] : [NSString stringWithFormat:@"Sending to %d subscriber%@", [users count], ([users count] != 1 ? @"s" : @"")];
	
	
//	if (isRedraw)
//		[_tableView reloadData];
}

- (void)showKeyboard {
	[_subjectTextField becomeFirstResponder];
	[self _raiseKeyboard];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
	_blackMatteView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.65];
	[self addSubview:_blackMatteView];
	
	_previewBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_previewBackButton.frame = self.frame;
	[_previewBackButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchUpInside];
	
	_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 16.0, 200.0, 20.0)];
	_actionLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:17];
	_actionLabel.textColor = [UIColor whiteColor];
	_actionLabel.backgroundColor = [UIColor clearColor];
	[self addSubview:_actionLabel];
	
	_subscribersButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_subscribersButton.frame = CGRectMake(13.0, 27.0, 44.0, 44.0);
	[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_nonActive"] forState:UIControlStateNormal];
	[_subscribersButton setBackgroundImage:[UIImage imageNamed:@"cameraMoreButton_Active"] forState:UIControlStateHighlighted];
	[_subscribersButton addTarget:self action:@selector(_goSubscribers) forControlEvents:UIControlEventTouchUpInside];
	//_subscribersButton.alpha = 0.0;
	[self addSubview:_subscribersButton];
	
	_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_backButton.frame = CGRectMake(262.0, 14.0, 44.0, 44.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_backButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	//_backButton.alpha = 0.0;
	[self addSubview:_backButton];
	
	_subjectHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, ([UIScreen mainScreen].bounds.size.height * 0.5) - 35.0, 320.0, 53.0)];
	_subjectHolderView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
	_subjectHolderView.alpha = 0.0;
	[self addSubview:_subjectHolderView];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0, 9.0, 268.0, 30.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:23];
	_placeholderLabel.textColor = [HONAppDelegate honGrey518Color];
	_placeholderLabel.text = ([_subjectName length] == 0) ? @"What's happening?" : @"";
	[_subjectHolderView addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:_placeholderLabel.frame];
	_subjectTextField.frame = CGRectOffset(_subjectTextField.frame, -10.0, 0.0);
	[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
	[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
	[_subjectTextField setReturnKeyType:UIReturnKeyDone];
	[_subjectTextField setTextColor:[UIColor whiteColor]];
	[_subjectTextField addTarget:self action:@selector(_onTextDoneEditingOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
	_subjectTextField.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:23];
	_subjectTextField.keyboardType = UIKeyboardTypeDefault;
	_subjectTextField.text = _subjectName;
	_subjectTextField.delegate = self;
	[_subjectHolderView addSubview:_subjectTextField];
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(133.0, 177.0 + ([HONAppDelegate isRetina5] * 65.0), 54.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	_uploadingImageView.alpha = 0.0;
	[_uploadingImageView startAnimating];
	[self addSubview:_uploadingImageView];
	
	_buttonHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 53.0, 320.0, 53.0)];
	_buttonHolderView.alpha = 0.0;
	[self addSubview:_buttonHolderView];
	
	UIButton *previewButton = [UIButton buttonWithType:UIButtonTypeCustom];
	previewButton.frame = CGRectMake(0.0, 0.0, 160.0, 53.0);
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_nonActive"] forState:UIControlStateNormal];
	[previewButton setBackgroundImage:[UIImage imageNamed:@"previewButttonCamera_Active"] forState:UIControlStateHighlighted];
	[previewButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:previewButton];
	
	UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	submitButton.frame = CGRectMake(160.0, 0.0, 160.0, 53.0);
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButttonCamera_nonActive"] forState:UIControlStateNormal];
	[submitButton setBackgroundImage:[UIImage imageNamed:@"submitButttonCamera_Active"] forState:UIControlStateHighlighted];
	[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
	[_buttonHolderView addSubview:submitButton];
	
	_subscribersView = [[HONCameraPreviewSubscribersView alloc] initWithFrame:CGRectMake(0.0, 50.0, 320.0, [UIScreen mainScreen].bounds.size.height + 50.0)];
	_subscribersView.hidden = YES;
	_subscribersView.alpha = 0.0;
	_subscribersView.delegate = self;
	[self addSubview:_subscribersView];
	
	_subscribersBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_subscribersBackButton.frame = CGRectMake(9.0, 14.0, 44.0, 44.0);
	[_subscribersBackButton setBackgroundImage:[UIImage imageNamed:@"backCameraButton_nonActive"] forState:UIControlStateNormal];
	[_subscribersBackButton setBackgroundImage:[UIImage imageNamed:@"backCameraButton_Active"] forState:UIControlStateHighlighted];
	[_subscribersBackButton addTarget:self action:@selector(_goSubscribersClose) forControlEvents:UIControlEventTouchUpInside];
	_subscribersBackButton.alpha = 0.0;
	[self addSubview:_subscribersBackButton];
}


#pragma mark - Navigation
- (void)_goToggleKeyboard {
	if ([_subjectTextField isFirstResponder])
		[self _dropKeyboardAndRemove:NO];
	
	else
		[self _raiseKeyboard];
}

- (void)_goSubscribers {
	_subscribersView.hidden = NO;
	
	[_subjectTextField resignFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_actionLabel.frame = CGRectOffset(_actionLabel.frame, 48.0, 0.0);
		_subscribersButton.frame = CGRectOffset(_subscribersButton.frame, 48.0, 0.0);
		_subscribersButton.alpha = 0.5;
		
		_subjectHolderView.frame = CGRectOffset(_subjectHolderView.frame, 0.0, 100);
		_subjectHolderView.alpha = 0.0;
		_backButton.alpha = 0.0;
		_uploadingImageView.alpha = 0.0;
		
		_subscribersView.alpha = 1.0;
		_subscribersView.frame = CGRectOffset(_subscribersView.frame, 0.0, -100.0);
		
		_buttonHolderView.alpha = 0.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_subscribersBackButton.alpha = 1.0;
		}];
	}];
}

- (void)_goSubscribersClose {
	_subscribersView.hidden = NO;
	
	[_subjectTextField becomeFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_subscribersBackButton.alpha = 0.0;
		
		_actionLabel.frame = CGRectOffset(_actionLabel.frame, -48.0, 0.0);
		_subscribersButton.frame = CGRectOffset(_subscribersButton.frame, -48.0, 0.0);
		_subscribersButton.alpha = 1.0;
		
		_subjectHolderView.frame = CGRectOffset(_subjectHolderView.frame, 0.0, -100);
		_subjectHolderView.alpha = 1.0;
		_backButton.alpha = 1.0;
		_uploadingImageView.alpha = 1.0;
		
		_subscribersView.alpha = 0.0;
		_subscribersView.frame = CGRectOffset(_subscribersView.frame, 0.0, 100.0);
		
		_buttonHolderView.alpha = 1.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, -216.0);
	} completion:nil];
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

- (void)_goClose {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Close"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _dropKeyboardAndRemove:YES];
	[self.delegate previewViewClose:self];
}

- (void)_goSubmit {
	[[Mixpanel sharedInstance] track:@"Camera Preview - Submit"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _dropKeyboardAndRemove:NO];
	if ([_subjectTextField.text length] > 0) {
		_subjectName = _subjectTextField.text;
		
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
//		[self _dropKeyboardAndRemove:YES];
		[self.delegate previewView:self changeSubject:_subjectName];
		[self.delegate previewViewSubmit:self];
		
		[_subjectTextField resignFirstResponder];
		[UIView animateWithDuration:0.25 animations:^(void) {
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


#pragma mark - UI Presentation
- (void)_raiseKeyboard {
	[_subjectTextField becomeFirstResponder];
	[_previewBackButton removeFromSuperview];;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.65;
		_actionLabel.alpha = 1.0;
		_uploadingImageView.alpha = 1.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, -216.0);
		_buttonHolderView.alpha = 1.0;
		_subjectHolderView.frame = CGRectOffset(_subjectHolderView.frame, 0.0, -100);
		_subjectHolderView.alpha = 1.0;
		_backButton.alpha = 1.0;
		_subscribersButton.alpha = 1.0;
	}completion:^(BOOL finished) {
	}];
}

- (void)_dropKeyboardAndRemove:(BOOL)isRemoved {
	[_subjectTextField resignFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
		_actionLabel.alpha = 0.0;
		_buttonHolderView.frame = CGRectOffset(_buttonHolderView.frame, 0.0, 216.0);
		_uploadingImageView.alpha = 0.0;
		_subjectHolderView.frame = CGRectOffset(_subjectHolderView.frame, 0.0, 100);
		_subjectHolderView.alpha = 0.0;
		_backButton.alpha = 0.0;
		_subscribersButton.alpha = 0.0;
	} completion:^(BOOL finished) {
		if (isRemoved)
			[self removeFromSuperview];
		
		else
			[self addSubview:_previewBackButton];
	}];
}

#pragma mark - Notifications
- (void)_textFieldTextDidChangeChange:(NSNotification *)notification {
	_placeholderLabel.text = ([_subjectTextField.text length] == 0) ? @"what's on your mind?" : @"";
	
}

#pragma mark - SubscriberView Delegates
- (void)subscriberView:(HONCameraPreviewSubscribersView *)cameraPreviewSubscribersView removeOpponent:(HONUserVO *)userVO {
	[self.delegate previewView:self removeChallenger:userVO];
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
