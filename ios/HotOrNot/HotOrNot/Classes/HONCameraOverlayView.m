//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//


#import "ASIFormDataRequest.h"
#import "Mixpanel.h"
#import "UIImageView+WebCache.h"

#import "HONCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONCameraOverlayView() <UITextFieldDelegate, ASIHTTPRequestDelegate>
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *itunesURL;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIImageView *trackBGImageView;
@property (nonatomic) CGSize gutterSize;
@end

@implementation HONCameraOverlayView

@synthesize subjectName = _subjectName;
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		int photoSize = 250.0;
		_gutterSize = CGSizeMake((320.0 - photoSize) * 0.5, (self.frame.size.height - photoSize) * 0.5);
		
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
		bgImageView.userInteractionEnabled = YES;
		[self addSubview:bgImageView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:@"TAKE PHOTO"];
		[self addSubview:_headerView];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:cancelButton];
		
		UIImageView *subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(23.0, 60.0, 274.0, 44.0)];
		subjectBGImageView.image = [UIImage imageNamed:@"cameraInputField_nonActive"];
		subjectBGImageView.userInteractionEnabled = YES;
		subjectBGImageView.alpha = 0.0;
		[self addSubview:subjectBGImageView];
		
		[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationCurveLinear animations:^(void) {
			subjectBGImageView.alpha = 1.0;
		} completion:nil];
		
		_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(16.0, 13.0, 240.0, 20.0)];
		//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_subjectTextField setReturnKeyType:UIReturnKeyDone];
		[_subjectTextField setTextColor:[UIColor blackColor]];
		//[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_subjectTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:16];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		_subjectTextField.text = _subjectName;
		_subjectTextField.delegate = self;
		[subjectBGImageView addSubview:_subjectTextField];
		
		_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_editButton.frame = CGRectMake(237.0, 5.0, 34.0, 34.0);
		[_editButton setBackgroundImage:[UIImage imageNamed:@"clearTextButton_nonActive"] forState:UIControlStateNormal];
		[_editButton setBackgroundImage:[UIImage imageNamed:@"clearTextButton_Active"] forState:UIControlStateHighlighted];
		[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
		[subjectBGImageView addSubview:_editButton];
		
		_trackBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, 308.0, 306.0, 50.0)];
		_trackBGImageView.image = [UIImage imageNamed:@"artistInfoOverlay"];
		_trackBGImageView.userInteractionEnabled = YES;
		_trackBGImageView.alpha = 0.0;
		[self addSubview:_trackBGImageView];
		
		UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, _gutterSize.height, 250.0, 250.0)];
		overlayImgView.image = [UIImage imageNamed:@"cameraOverlayBranding"];
		overlayImgView.userInteractionEnabled = YES;
		//[self addSubview:overlayImgView];
		
//		UIImage *buttonImageNormal;
//		if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
//			UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			flashButton = CGRectMake(10, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"flash02"];
//			[flashButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[flashButton addTarget:self action:@selector(setFlash:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:flashButton];
//		}
//		
//		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//			UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			changeCameraButton = CGRectMake(250, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"switch_button"];
//			[changeCameraButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:changeCameraButton];
//		}
		
		// Add the bottom bar
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 374.0, 640.0, 105.0)];
		[self addSubview:_footerHolderView];
		
		// Add the gallery button
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(20.0, 20.0, 75.0, 75.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:cameraRollButton];
		
		// Add the capture button
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(108.0, 0.0, 105.0, 105.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:_captureButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(220.0, 20.0, 75.0, 75.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:changeCameraButton];
		
		// Add the back button
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(335.0, 10.0, 147.0, 62.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"cancelCameraButton_nonActive"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"cancelCameraButton_Active"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:backButton];
		
		// Add the next button
		UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nextButton.frame = CGRectMake(475.0, 10.0, 147.0, 62.0);
		[nextButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_nonActive"] forState:UIControlStateNormal];
		[nextButton setBackgroundImage:[UIImage imageNamed:@"acceptCameraButton_Active"] forState:UIControlStateHighlighted];
		[nextButton addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:nextButton];
	}
	
	return (self);
}

- (void)takePicture:(id)sender {
	_captureButton.enabled = NO;
	[self.delegate cameraOverlayViewTakePicture:self];
}

- (void)setFlash:(id)sender {
	[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)changeCamera:(id)sender {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)showCameraRoll:(id)sender {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)closeCamera:(id)sender {
	[self.delegate cameraOverlayViewCloseCamera:self];
}

- (void)showPreview:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE:[%f][%f]", image.size.width, image.size.height);
	
	if (image.size.width > 480.0 && image.size.height > 640.0)
		image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(5.0, 5.0, 74.0, 34.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
	
	[_headerView setTitle:@"PREVIEW"];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	} completion:nil];
}

- (void)showPreviewFlipped:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE:[%f][%f]", image.size.width, image.size.height);
	
	if (image.size.width > 480.0 && image.size.height > 640.0)
		image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUpMirrored]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(5.0, 5.0, 74.0, 34.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
	
	[_headerView setTitle:@"PREVIEW"];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(-320.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	} completion:nil];
}

- (void)hidePreview {
	_previewHolderView.hidden = YES;
	
	for (UIView *subview in _previewHolderView.subviews) {
		[subview removeFromSuperview];
	}
	
	[_headerView setTitle:@"TAKE CHALLENGE"];
	
	[_cameraBackButton removeFromSuperview];
	_cameraBackButton = nil;
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(0.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	} completion:nil];
	
	[self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)artistName:(NSString *)artist songName:(NSString *)songName artworkURL:(NSString *)artwork storeURL:(NSString *)itunesURL {
	_itunesURL = [itunesURL stringByReplacingOccurrencesOfString:@"https://" withString:@"itms://"];
	_artistName = artist;
	_songName = songName;
	
	UIImageView *albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 5.0, 40.0, 40.0)];
	[albumImageView setImageWithURL:[NSURL URLWithString:artwork] placeholderImage:nil options:SDWebImageLowPriority];
	[_trackBGImageView addSubview:albumImageView];
	
	UILabel *songLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 11.0, 170.0, 14.0)];
	songLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	songLabel.textColor = [UIColor whiteColor];
	songLabel.backgroundColor = [UIColor clearColor];
	songLabel.text = _songName;
	[_trackBGImageView addSubview:songLabel];
	
	UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 26.0, 170.0, 14.0)];
	artistLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	artistLabel.textColor = [UIColor whiteColor];
	artistLabel.backgroundColor = [UIColor clearColor];
	artistLabel.text = _artistName;
	[_trackBGImageView addSubview:artistLabel];
	
	UIButton *buyTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buyTrackButton.frame = CGRectMake(230.0, 9.0, 64.0, 34.0);
	[buyTrackButton setBackgroundImage:[UIImage imageNamed:@"downloadOniTunes"] forState:UIControlStateNormal];
	[buyTrackButton setBackgroundImage:[UIImage imageNamed:@"downloadOniTunes"] forState:UIControlStateHighlighted];
	[buyTrackButton addTarget:self action:@selector(_goBuyTrack) forControlEvents:UIControlEventTouchUpInside];
	[_trackBGImageView addSubview:buyTrackButton];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_trackBGImageView.alpha = 1.0;
	}];
}

#pragma mark -Navigation
- (void)goBack:(id)sender {
	_captureButton.enabled = YES;
	[self hidePreview];
}

- (void)goNext:(id)sender {
	[[Mixpanel sharedInstance] track:@"Image Preview - Accept"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate cameraOverlayViewClosePreview:self];
}

- (void)_goEditSubject {
	[[Mixpanel sharedInstance] track:@"Camera - Edit Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_subjectTextField.text = @"#";
	[_subjectTextField becomeFirstResponder];
}

- (void)_goBuyTrack {
	NSLog(@"BUY TRACK '%@' (%@)", _songName, _itunesURL);
	
	[[Mixpanel sharedInstance] track:@"Camera - Buy Track"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%@ - %@:%@", _subjectName, _artistName, _songName], @"track", nil]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_itunesURL]];
}

- (void)_goSubjectCheck {
	ASIFormDataRequest *subjectRequest = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [HONAppDelegate apiServerPath], kChallengesAPI]]];
	[subjectRequest setDelegate:self];
	[subjectRequest setPostValue:[NSString stringWithFormat:@"%d", 5] forKey:@"action"];
	[subjectRequest setPostValue:_subjectName forKey:@"subjectName"];
	[subjectRequest startAsynchronous];
}

#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	[[Mixpanel sharedInstance] track:@"Camers - Edit Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_editButton.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_editButton.hidden = NO;
	
	if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
		textField.text = _subjectName;
	
	else
		_subjectName = textField.text;
	
	if (_subjectName.length > 0)
		[self _goSubjectCheck];
}


#pragma mark - Accessors
- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = _subjectName;
}



#pragma mark - ASI Delegates
-(void)requestFinished:(ASIHTTPRequest *)request {
	NSLog(@"HONImagePickerViewController [_asiFormRequest responseString]=\n%@\n\n", [request responseString]);
	
	@autoreleasepool {
		NSError *error = nil;
		NSDictionary *subjectResult = [NSJSONSerialization JSONObjectWithData:[request responseData] options:0 error:&error];
		
		if (error != nil) {
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		}
		
		else {
			if ([[subjectResult objectForKey:@"preview_url"] length] > 0) {
				[self artistName:[subjectResult objectForKey:@"artist"] songName:[subjectResult objectForKey:@"song_name"] artworkURL:[subjectResult objectForKey:@"img_url"] storeURL:[subjectResult objectForKey:@"itunes_url"]];
				[self.delegate cameraOverlayViewPlayTrack:self audioURL:[subjectResult objectForKey:@"preview_url"]];
			}
		}
	}
}

@end
