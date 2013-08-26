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
#import "HONCameraPreviewSubscriberViewCell.h"

@interface HONCreateChallengePreviewView () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextFieldDelegate, HONCameraPreviewSubscriberViewCellDelegate>
@property (nonatomic, strong) UILabel *actionLabel;
@property (nonatomic, strong) UIImage *previewImage;
@property (nonatomic, strong) NSString *subjectName;
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, retain) UIButton *submitButton;
@property (nonatomic, strong) UIImageView *uploadingImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *opponents;
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
		
		_opponents = [NSArray array];
		
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
		
		_opponents = [NSArray array];
		
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
	_opponents = users;
	_actionLabel.text = (isJoining) ? [NSString stringWithFormat:@"joining %d of your friends", [_opponents count]] : [NSString stringWithFormat:@"sending to %d of your subscribers", [_opponents count]];
	
	
	if (isRedraw)
		[_tableView reloadData];
}

- (void)showKeyboard {
	[_subjectTextField becomeFirstResponder];
	[self _raiseKeyboard];
}


#pragma mark - UI Presentation
- (void)_makeUI {
	UIView *overlayView = [[UIView alloc] initWithFrame:self.frame];
	overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.85];
	[self addSubview:overlayView];
	
	UIButton *toggleKeyboardButton = [UIButton buttonWithType:UIButtonTypeCustom];
	toggleKeyboardButton.frame = self.frame;
	[toggleKeyboardButton addTarget:self action:@selector(_goToggleKeyboard) forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:toggleKeyboardButton];
	
	_backButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_backButton.frame = CGRectMake(276.0, 10.0, 37.0, 37.0);
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_nonActive"] forState:UIControlStateNormal];
	[_backButton setBackgroundImage:[UIImage imageNamed:@"closeButton_Active"] forState:UIControlStateHighlighted];
	[_backButton addTarget:self action:@selector(_goClose) forControlEvents:UIControlEventTouchUpInside];
	_backButton.alpha = 0.0;
	[self addSubview:_backButton];
	
	_placeholderLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0, 9.0, 268.0, 30.0)];
	_placeholderLabel.backgroundColor = [UIColor clearColor];
	_placeholderLabel.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:22];
	_placeholderLabel.textColor = [HONAppDelegate honGrey518Color];
	_placeholderLabel.text = ([_subjectName length] == 0) ? @"What's happening?" : @"";
	_placeholderLabel.alpha = 0.0;
	[self addSubview:_placeholderLabel];
	
	_subjectTextField = [[UITextField alloc] initWithFrame:_placeholderLabel.frame];
	_subjectTextField.frame = CGRectOffset(_subjectTextField.frame, -10.0, 0.0);
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
	
	_actionLabel = [[UILabel alloc] initWithFrame:CGRectMake(24.0, 53.0, 200.0, 38.0)];
	_actionLabel.font = [[HONAppDelegate helveticaNeueFontLight] fontWithSize:16];
	_actionLabel.textColor = [UIColor whiteColor];
	_actionLabel.backgroundColor = [UIColor clearColor];
	_actionLabel.numberOfLines = 2;
	[self addSubview:_actionLabel];
	
	_uploadingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(237.0, 70.0, 54.0, 14.0)];
	_uploadingImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"cameraUpload_001"],
										   [UIImage imageNamed:@"cameraUpload_002"],
										   [UIImage imageNamed:@"cameraUpload_003"], nil];
	_uploadingImageView.animationDuration = 0.5f;
	_uploadingImageView.animationRepeatCount = 0;
	_uploadingImageView.alpha = 0.0;
	[_uploadingImageView startAnimating];
	[self addSubview:_uploadingImageView];
	
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0, 108.0, 320.0, [UIScreen mainScreen].bounds.size.height - 110.0) style:UITableViewStylePlain];
	[_tableView setBackgroundColor:[UIColor clearColor]];
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_tableView.alpha = 0.0;
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.scrollsToTop = NO;
	_tableView.showsVerticalScrollIndicator = YES;
	[self addSubview:_tableView];
		
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
	
	if ([_subjectTextField.text length] > 0) {
		int friend_total = [[[NSUserDefaults standardUserDefaults] objectForKey:@"friend_total"] intValue];
		[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:++friend_total] forKey:@"friend_total"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
//		[self _dropKeyboardAndRemove:YES];
		[self.delegate previewView:self changeSubject:_subjectName];
		[self.delegate previewViewSubmit:self];
		
		[_subjectTextField resignFirstResponder];
		[UIView animateWithDuration:0.25 animations:^(void) {
			_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, 216.0);
			_uploadingImageView.alpha = 0.0;
			_placeholderLabel.alpha = 0.0;
			_subjectTextField.alpha = 0.0;
			_backButton.alpha = 0.0;
			_tableView.alpha = 0.0;
			_tableView.frame = CGRectOffset(_tableView.frame, 0.0, -100.0);
		} completion:^(BOOL finished) {
			_submitButton.hidden = YES;
		}];
	
	} else {
		[self _dropKeyboardAndRemove:NO];
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
	_submitButton.hidden = NO;
//	_subjectBGView.hidden = NO;
	[_subjectTextField becomeFirstResponder];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_uploadingImageView.alpha = 1.0;
		_submitButton.frame = CGRectOffset(_submitButton.frame, 0.0, -216.0);
		_placeholderLabel.alpha = 1.0;
		_subjectTextField.alpha = 1.0;
		_backButton.alpha = 1.0;
		_tableView.alpha = 0.0;
		_tableView.frame = CGRectOffset(_tableView.frame, 0.0, 100.0);
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
		_backButton.alpha = 0.0;
		_tableView.alpha = 1.0;
		_tableView.frame = CGRectOffset(_tableView.frame, 0.0, -100.0);
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


#pragma mark - SubscriberViewCell Delegates
- (void)subscriberViewCell:(HONCameraPreviewSubscriberViewCell *)cameraPreviewSubscriberViewCell removeOpponent:(HONUserVO *)userVO {
	int row = 0;
	for (HONUserVO *vo in _opponents) {
		if (vo.userID == userVO.userID)
			break;
		
		row++;
	}
	
	//[_tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
	
	
	[self.delegate previewView:self removeChallenger:userVO];
}

#pragma mark - TableView DataSource Delegates
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return ([_opponents count]);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	HONCameraPreviewSubscriberViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
	
	if (cell == nil)
		cell = [[HONCameraPreviewSubscriberViewCell alloc] init];
	
	cell.delegate = self;
	[cell setUserVO:(HONUserVO *)[_opponents objectAtIndex:indexPath.row]];
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	
	return (cell);
}


#pragma mark - TableView Delegates
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return (kOrthodoxTableCellHeight - 8.0);
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	return (nil);
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
