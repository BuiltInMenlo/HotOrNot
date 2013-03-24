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

@interface HONCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *irisImageView;
@property (nonatomic, strong) HONHeaderView *headerView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *captureHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UITextField *commentTextField;
@property (nonatomic, strong) UITextField *usernameTextField;
@property (nonatomic, strong) UIButton *randomSubjectButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraBackButton;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) UIButton *muteButton;
@property (nonatomic, strong) NSString *artistName;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *itunesURL;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) NSString *username;
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
		_username = @"";
		_comments = @"";
		
		int photoSize = 250.0;
		_gutterSize = CGSizeMake((320.0 - photoSize) * 0.5, (self.frame.size.height - photoSize) * 0.5);
		
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		_irisImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, kNavHeaderHeight, 320.0, 320.0)];
		_irisImageView.image = [UIImage imageNamed:@"cameraViewShutter"];
		_irisImageView.alpha = 0.0;
		[self addSubview:_irisImageView];
		
		_bgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, ([HONAppDelegate isRetina5]) ? 568.0 : 480.0)];
		_bgImageView.image = [UIImage imageNamed:([HONAppDelegate isRetina5]) ? @"cameraExperience_Overlay-568h" : @"cameraExperience_Overlay"];
		_bgImageView.userInteractionEnabled = YES;
		[self addSubview:_bgImageView];
		
		_captureHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, self.frame.size.height)];
		_captureHolderView.userInteractionEnabled = YES;
		[_bgImageView addSubview:_captureHolderView];
		
		_headerView = [[HONHeaderView alloc] initWithTitle:@"Take Photo"];
		[_bgImageView addSubview:_headerView];
				
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[_headerView addSubview:_cancelButton];
		
		UIImageView *subjectBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 55.0, 314.0, 44.0)];
		subjectBGImageView.image = [UIImage imageNamed:@"cameraInputFieldA"];
		subjectBGImageView.userInteractionEnabled = YES;
		[_captureHolderView addSubview:subjectBGImageView];
		
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
		[_subjectTextField setTag:0];
		[subjectBGImageView addSubview:_subjectTextField];
		
		_randomSubjectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_randomSubjectButton.frame = CGRectMake(230.0, 5.0, 64.0, 34.0);
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"randonButton_nonActive"] forState:UIControlStateNormal];
		[_randomSubjectButton setBackgroundImage:[UIImage imageNamed:@"randonButton_Active"] forState:UIControlStateHighlighted];
		[_randomSubjectButton addTarget:self action:@selector(_goRandomSubject) forControlEvents:UIControlEventTouchUpInside];
		[subjectBGImageView addSubview:_randomSubjectButton];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(20.0, 310.0, 64.0, 64.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:cameraRollButton];
		
		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
			UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
			changeCameraButton.frame = CGRectMake(220.0, 310.0, 64.0, 64.0);
			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_nonActive"] forState:UIControlStateNormal];
			[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"cameraFrontBack_Active"] forState:UIControlStateHighlighted];
			[changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
			[_captureHolderView addSubview:changeCameraButton];
		}
		
//		UIImage *buttonImageNormal;
//		if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
//			UIButton *flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			flashButton = CGRectMake(10, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"flash02"];
//			[flashButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[flashButton addTarget:self action:@selector(setFlash:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:flashButton];
//		}

		// Add the capture button
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(113.0, 384.0, 94.0, 94.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraLargeButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[_captureHolderView addSubview:_captureButton];
		
		UIImageView *usernameBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(323.0, 55.0, 314.0, 44.0)];
		usernameBGImageView.image = [UIImage imageNamed:@"cameraInputFieldA"];
		usernameBGImageView.userInteractionEnabled = YES;
		[_captureHolderView addSubview:usernameBGImageView];
		
		_usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 16.0, 270.0, 25.0)];
		//[_usernameTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_usernameTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_usernameTextField setReturnKeyType:UIReturnKeyDone];
		[_usernameTextField setTextColor:[UIColor blackColor]];
		//[_usernameTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_usernameTextField.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:16];
		_usernameTextField.keyboardType = UIKeyboardTypeDefault;
		_usernameTextField.text = @"Add a username…";
		_usernameTextField.delegate = self;
		[_usernameTextField setTag:1];
		[usernameBGImageView addSubview:_usernameTextField];
		
		UIImageView *commentBGImageView = [[UIImageView alloc] initWithFrame:CGRectMake(323.0, 375.0, 314.0, 64.0)];
		commentBGImageView.image = [UIImage imageNamed:@"cameraInputFieldB"];
		commentBGImageView.userInteractionEnabled = YES;
		[_captureHolderView addSubview:commentBGImageView];
		
		_commentTextField = [[UITextField alloc] initWithFrame:CGRectMake(13.0, 16.0, 270.0, 25.0)];
		//[_commentTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_commentTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_commentTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_commentTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_commentTextField setReturnKeyType:UIReturnKeyDone];
		_commentTextField.backgroundColor = [UIColor whiteColor];
		//[_commentTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_commentTextField.font = [[HONAppDelegate honHelveticaNeueFontMedium] fontWithSize:16];
		_commentTextField.keyboardType = UIKeyboardTypeDefault;
		_commentTextField.text = @"Add a comment…";
		_commentTextField.delegate = self;
		[_commentTextField setTag:2];
		[commentBGImageView addSubview:_commentTextField];
		
		
		_trackBGView = [[UIView alloc] initWithFrame:CGRectMake(7.0, 278.0, 306.0, 80.0)];
		_trackBGView.userInteractionEnabled = YES;
		_trackBGView.alpha = 0.0;
		[self addSubview:_trackBGView];
	}
	
	return (self);
}

- (void)takePicture:(id)sender {
	_captureButton.enabled = NO;
	[self _animateShutter];
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

- (void)showPreviewImage:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE:[%f][%f]", image.size.width, image.size.height);
	image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[self _showPreviewUI];
}

- (void)showPreviewImageFlipped:(UIImage *)image {
	[[Mixpanel sharedInstance] track:@"Image Preview"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	NSLog(@"IMAGE FLIPPED:[%f][%f]", image.size.width, image.size.height);
	
	//if (image.size.width > 480.0 && image.size.height > 640.0)
		image = [HONAppDelegate scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUpMirrored]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[self _showPreviewUI];
}

- (void)_showPreviewUI {
	_randomSubjectButton.hidden = YES;
	[_cancelButton removeFromSuperview];
	
	_cameraBackButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_cameraBackButton.frame = CGRectMake(0.0, 0.0, 64.0, 44.0);
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_nonActive"] forState:UIControlStateNormal];
	[_cameraBackButton setBackgroundImage:[UIImage imageNamed:@"backButton_Active"] forState:UIControlStateHighlighted];
	[_cameraBackButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_cameraBackButton];
	
	_submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_submitButton.frame = CGRectMake(243.0, 0.0, 74.0, 44.0);
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_nonActive"] forState:UIControlStateNormal];
	[_submitButton setBackgroundImage:[UIImage imageNamed:@"submitButton_Active"] forState:UIControlStateHighlighted];
	[_submitButton addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
	[_headerView addSubview:_submitButton];
	
	[_headerView setTitle:_subjectName];
	_captureHolderView.frame = CGRectMake(-320.0, _captureHolderView.frame.origin.y, 640.0, self.frame.size.height);
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
	
	_randomSubjectButton.hidden = NO;
	[_headerView addSubview:_cancelButton];
	_captureHolderView.frame = CGRectMake(0.0, _captureHolderView.frame.origin.y, 640.0, self.frame.size.height);
	
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

- (void)_animateShutter {
	_irisImageView.alpha = 1.0;
	[UIView animateWithDuration:0.33 animations:^(void) {
		_irisImageView.alpha = 0.0;
	} completion:^(BOOL finished){}];
}


#pragma mark - Navigation
- (void)goBack:(id)sender {
	_captureButton.enabled = YES;
	[self hidePreview];
}

- (void)goNext:(id)sender {
	[[Mixpanel sharedInstance] track:@"Image Preview - Accept"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate cameraOverlayViewSubmitChallenge:self username:_usernameTextField.text comments:_commentTextField.text];
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
		[self.delegate cameraOverlayViewChangeSubject:self subject:_subjectName];
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
			NSLog(@"AFNetworking HONCameraOverlayView - Failed to parse job list JSON: %@", [error localizedFailureReason]);
		
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
	
	if (textField.tag == 0) {
		[[Mixpanel sharedInstance] track:@"Camera - Edit Hashtag"
									 properties:[NSDictionary dictionaryWithObjectsAndKeys:
													 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	} else if (textField.tag == 1) {
		[[Mixpanel sharedInstance] track:@"Camera - Enter Username"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
				
		textField.text = @"";
	
	} else if (textField.tag == 2) {
		[[Mixpanel sharedInstance] track:@"Camera - Edit Comment"
							  properties:[NSDictionary dictionaryWithObjectsAndKeys:
										  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, -215.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
		}];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_previewHolderView.frame = CGRectMake(_previewHolderView.frame.origin.x, -215.0, _previewHolderView.frame.size.width, _previewHolderView.frame.size.height);
		}];
		
		textField.text = @"";
	}
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return (YES);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	
	if (textField.tag == 0) {
		if ([textField.text isEqualToString:@""])
			textField.text = @"#";
	}
	
	return (YES);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if (textField.tag == 0) {
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
		
//		if (_subjectName.length > 0)
//			[self _goSubjectCheck];
	
	} else if (textField.tag == 1) {
		if ([textField.text length] == 0)
			textField.text = @"Add a username…";
		
		_username = textField.text;
			
	} else if (textField.tag == 2) {
		if ([textField.text length] == 0)
			textField.text = @"Add a comment…";
		
		_comments = textField.text;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_bgImageView.frame = CGRectMake(_bgImageView.frame.origin.x, 0.0, _bgImageView.frame.size.width, _bgImageView.frame.size.height);
		}];
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			_previewHolderView.frame = CGRectMake(_previewHolderView.frame.origin.x, 0.0, _previewHolderView.frame.size.width, _previewHolderView.frame.size.height);
		}];
	}
}


#pragma mark - Accessors
- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = _subjectName;
}


@end
