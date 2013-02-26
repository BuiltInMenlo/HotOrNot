//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"
#import "Mixpanel.h"
#import "UIImageView+AFNetworking.h"

#import "HONCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONCameraOverlayView() <UITextFieldDelegate, UITextViewDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) UIButton *randomSubjectButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *itunesURL;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) NSString *comments;
@property (nonatomic, strong) UIView *trackBGView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
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
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:@"TAKE PHOTO"];
		[self addSubview:_headerView];
		
		_randomSubjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_randomSubjectButton.frame = CGRectMake(0.0, 0.0, 84.0, 44.0);
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"random_nonActive"] forState:UIControlStateNormal];
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"random_Active"] forState:UIControlStateHighlighted];
		[_randomSubjectButton addTarget:self action:@selector(_goRandomSubject) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_randomSubjectButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cancelButton];
		
		UIImageView *subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(23.0, 60.0, 274.0, 44.0)];
		subjectBGImageView.image = [UIImage imageNamed:@"cameraInputField_nonActive"];
		subjectBGImageView.userInteractionEnabled = YES;
		subjectBGImageView.alpha = 0.0;
		[_bgImageView addSubview:subjectBGImageView];
		
		[UIView animateWithDuration:0.5 delay:0.25 options:UIViewAnimationOptionCurveLinear animations:^(void) {
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
		
		_trackBGView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 278.0, 306.0, 80.0)];
		_trackBGView.userInteractionEnabled = YES;
		_trackBGView.alpha = 0.0;
		[self addSubview:_trackBGView];
		
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
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 367.0, 640.0, 105.0)];
		[_bgImageView addSubview:_footerHolderView];
		 
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
		
		_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(340.0, 0.0, 270.0, 20.0)];
		//[_commentTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_commentTextField setReturnKeyType:UIReturnKeyGo];
		_commentTextField.backgroundColor = [UIColor whiteColor];
		[_commentTextField setTextColor:[UIColor blackColor]];
		//[_commentTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_commentTextField.font = [[HONAppDelegate freightSansBlack] fontWithSize:16];
		_commentTextField.keyboardType = UIKeyboardTypeDefault;
		_commentTextField.text = @"DERP";
		_commentTextField.delegate = self;
		[_footerHolderView addSubview:_commentTextField];
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
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_submitButton];
	
	[_headerView setTitle:@"PREVIEW"];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
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
	
	[_randomSubjectButton removeFromSuperview];
	[_cancelButton removeFromSuperview];
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(5.0, 5.0, 74.0, 34.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"cameraBackButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(253.0, 5.0, 64.0, 34.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
	//[_submitButton addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_submitButton];
	
	[_headerView setTitle:@"PREVIEW"];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
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
	
	[_submitButton removeFromSuperview];
	_submitButton = nil;
	
	[_headerView addSubview:_randomSubjectButton];
	[_headerView addSubview:_cancelButton];
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(0.0, _footerHolderView.frame.origin.y, 640.0, 70.0);
	} completion:nil];
	
	[self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)artistName:(NSString *)artist songName:(NSString *)songName artworkURL:(NSString *)artwork storeURL:(NSString *)itunesURL {
	_itunesURL = [itunesURL stringByReplacingOccurrencesOfString:@"https://" withString:@"itms://"];
	_artistName = artist;
	_songName = songName;
	
	UIImageView *bgTrackImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 30.0, 306.0, 50.0)];
	bgTrackImageView.image = [UIImage imageNamed:@"artistInfoOverlay"];
	bgTrackImageView.userInteractionEnabled = YES;
	[_trackBGView addSubview:bgTrackImageView];
	
	UIImageView *albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(5.0, 35.0, 40.0, 40.0)];
	[albumImageView setImageWithURL:[NSURL URLWithString:artwork] placeholderImage:nil];
	[_trackBGView addSubview:albumImageView];
	
	UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buyButton.frame = albumImageView.frame;
	[buyButton addTarget:self action:@selector(_goBuyTrack) forControlEvents:UIControlEventTouchUpInside];
	[_trackBGView addSubview:buyButton];
	
	UILabel *songLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 41.0, 170.0, 14.0)];
	songLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	songLabel.textColor = [UIColor whiteColor];
	songLabel.backgroundColor = [UIColor clearColor];
	songLabel.text = _songName;
	[_trackBGView addSubview:songLabel];
	
	UILabel *artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(60.0, 56.0, 170.0, 14.0)];
	artistLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	artistLabel.textColor = [UIColor whiteColor];
	artistLabel.backgroundColor = [UIColor clearColor];
	artistLabel.text = _artistName;
	[_trackBGView addSubview:artistLabel];
	
	UIButton *buyTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	buyTrackButton.frame = CGRectMake(0.0, 0.0, 64.0, 34.0);
	[buyTrackButton setBackgroundImage:[UIImage imageNamed:@"downloadOniTunes"] forState:UIControlStateNormal];
	[buyTrackButton setBackgroundImage:[UIImage imageNamed:@"downloadOniTunes"] forState:UIControlStateHighlighted];
	[buyTrackButton addTarget:self action:@selector(_goBuyTrack) forControlEvents:UIControlEventTouchUpInside];
	[_trackBGView addSubview:buyTrackButton];
	
	_muteButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_muteButton.frame = CGRectMake(260.0, 33.0, 44.0, 44.0);
	[_muteButton setBackgroundImage:[UIImage imageNamed:@"audio_nonActive"] forState:UIControlStateNormal];
	[_muteButton setBackgroundImage:[UIImage imageNamed:@"audio_Active"] forState:UIControlStateHighlighted];
	[_muteButton addTarget:self action:@selector(_goMuteToggle) forControlEvents:UIControlEventTouchUpInside];
	[_trackBGView addSubview:_muteButton];
	
	_activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	_activityIndicatorView.frame = CGRectMake(190.0, 320.0, 24.0, 24.0);
	[_activityIndicatorView startAnimating];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		_trackBGView.alpha = 1.0;
	
	} completion:^(BOOL finished) {
		if (_activityIndicatorView != nil)
		[self addSubview:_activityIndicatorView];
	}];
	
	UIImageView *ptsImageView = [[UIImageView alloc] initWithFrame:CGRectMake(88.0, 150.0, 144.0, 54.0)];
	ptsImageView.image = [UIImage imageNamed:@"bonusPoints"];
	ptsImageView.alpha = 0.0;
	[self addSubview:ptsImageView];
	
	[UIView animateWithDuration:0.5 animations:^(void) {
		ptsImageView.frame = CGRectOffset(ptsImageView.frame, 0.0, -25.0);
		ptsImageView.alpha = 1.0;
		
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.67 animations:^(void) {
			ptsImageView.alpha = 0.0;
			
		} completion:^(BOOL finished) {
			[ptsImageView removeFromSuperview];
		}];
	}];
}

- (void)endBuffering {
	NSLog(@"END BUFFERING");
	_activityIndicatorView.hidden = YES;
	[_activityIndicatorView removeFromSuperview];
	_activityIndicatorView = nil;
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

- (void)_goRandomSubject {
	[[Mixpanel sharedInstance] track:@"Camera - Random Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[UIView animateWithDuration:0.33 animations:^(void) {
		_trackBGView.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		for (UIView *view in _trackBGView.subviews)
			[view removeFromSuperview];
		
		[_activityIndicatorView removeFromSuperview];
		_activityIndicatorView = nil;
		
		_subjectName = [HONAppDelegate rndDefaultSubject];
		[self.delegate cameraOverlayViewRandomSubject:self subject:_subjectName];
	}];
}

- (void)_goBuyTrack {
	NSLog(@"BUY TRACK '%@' (%@)", _songName, _itunesURL);
	
	[[Mixpanel sharedInstance] track:@"Camera - Buy Track"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%@ - %@:%@", _subjectName, _artistName, _songName], @"track", nil]];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:_itunesURL]];
}

- (void)_goMuteToggle {
	[[Mixpanel sharedInstance] track:@"Camera - Mute Toggle"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user",
												 [NSString stringWithFormat:@"%d", [HONAppDelegate audioMuted]], @"muted", nil]];
	

	[[NSUserDefaults standardUserDefaults] setObject:([HONAppDelegate audioMuted]) ? @"NO" : @"YES" forKey:@"audio_muted"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[[MPMusicPlayerController applicationMusicPlayer] setVolume:([HONAppDelegate audioMuted]) ? 0.0 : 0.5];
}

- (void)_goSubjectCheck {
	AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:[HONAppDelegate apiServerPath]]];
	NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:
									[NSString stringWithFormat:@"%d", 5], @"action",
									_subjectName, @"subjectName",
									nil];
	
	[httpClient postPath:kChallengesAPI parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
		NSError *error = nil;
		NSDictionary *subjectResult = [NSJSONSerialization JSONObjectWithData:responseObject options:0 error:&error];
		
		if (error != nil)
			NSLog(@"Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
		else {
			NSLog(@"AFNetworking HONCameraOverlayView: %@", subjectResult);
			
			if ([[subjectResult objectForKey:@"preview_url"] length] > 0) {
				[self artistName:[subjectResult objectForKey:@"artist"] songName:[subjectResult objectForKey:@"song_name"] artworkURL:[subjectResult objectForKey:@"img_url"] storeURL:[subjectResult objectForKey:@"itunes_url"]];
				[self.delegate cameraOverlayViewPlayTrack:self audioURL:[subjectResult objectForKey:@"preview_url"]];
			}
		}
		
		//NSString *text = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
		//NSLog(@"Response: %@", text);
		
	} failure:^(AFHTTPRequestOperation *operation, NSError *error) {
		NSLog(@"CameraOverlayView AFNetworking %@", [error localizedDescription]);
	}];
}

#pragma mark - TextField Delegates
- (void)textFieldDidBeginEditing:(UITextField *)textField {
	[[Mixpanel sharedInstance] track:@"Camera - Edit Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	//_editButton.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	if ([textField.text isEqualToString:@""])
		textField.text = @"#";
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	_editButton.hidden = NO;
	
	if ([textField.text length] == 0 || [textField.text isEqualToString:@"#"])
		textField.text = _subjectName;
	
	else {
		NSArray *hashTags = [textField.text componentsSeparatedByString:@"#"];
		
		if ([hashTags count] > 2) {
			NSString *hashTag = ([[hashTags objectAtIndex:1] hasSuffix:@" "]) ? [[hashTags objectAtIndex:1] substringToIndex:[[hashTags objectAtIndex:1] length] - 1] : [hashTags objectAtIndex:1];
			textField.text = [NSString stringWithFormat:@"#%@", hashTag];
		}
		
		_subjectName = textField.text;
	}
	
	if (_subjectName.length > 0)
		[self _goSubjectCheck];
}


#pragma mark - TextView Delegates
- (void)textViewDidBeginEditing:(UITextView *)textView {
	[[Mixpanel sharedInstance] track:@"Camera - Edit Comment"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, -215.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
	}];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
	[textView resignFirstResponder];
	_comments = textView.text;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, 0.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
	}];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
	if ([text isEqualToString:@"\n"]) {
		[textView resignFirstResponder];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, 0.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
		}];
		return (NO);
		
	} else
		return (YES);
}


#pragma mark - Accessors
- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = _subjectName;
}


@end
