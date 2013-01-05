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
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *footerHolderView;
@property (nonatomic, strong) UITextField *subjectTextField;
@property (nonatomic, strong) UIImageView *albumImageView;
@property (nonatomic, strong) UIButton *buyTrackButton;
@property (nonatomic, strong) UIButton *editButton;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSString *itunesURL;
@property (nonatomic, strong) UIButton *captureButton;
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
		
//		UIView *headerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _gutterSize.height)];
//		headerGutterView.backgroundColor = [UIColor blackColor];
//		[self addSubview:headerGutterView];
//		
//		UIView *footerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - _gutterSize.height, 320.0, _gutterSize.height)];
//		footerGutterView.backgroundColor = [UIColor blackColor];
//		[self addSubview:footerGutterView];
//		
//		UIView *lGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _gutterSize.width, self.frame.size.height)];
//		lGutterView.backgroundColor = [UIColor blackColor];
//		[self addSubview:lGutterView];
//		
//		UIView *rGutterView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - _gutterSize.width, 0.0, _gutterSize.width, self.frame.size.height)];
//		rGutterView.backgroundColor = [UIColor blackColor];
//		[self addSubview:rGutterView];
		
		HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Take Challenge"];
		[self addSubview:headerView];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(247.0, 0.0, 74.0, 44.0);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_nonActive.png"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelButton_Active.png"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(closeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[headerView addSubview:cancelButton];
		
		_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(20.0, 70.0, 240.0, 20.0)];
		//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_subjectTextField.keyboardAppearance = UIKeyboardAppearanceDefault;
		[_subjectTextField setReturnKeyType:UIReturnKeyDone];
		[_subjectTextField setTextColor:[UIColor whiteColor]];
		//[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_subjectTextField.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		_subjectTextField.text = _subjectName;
		_subjectTextField.delegate = self;
		[self addSubview:_subjectTextField];
		
		_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_editButton.frame = CGRectMake(265.0, 60.0, 44.0, 44.0);
		[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_nonActive.png"] forState:UIControlStateNormal];
		[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_Active.png"] forState:UIControlStateHighlighted];
		[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_editButton];
				
		_albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(7.0, [UIScreen mainScreen].bounds.size.height - 127.0, 50.0, 50.0)];
		[self addSubview:_albumImageView];
		
		
		_buyTrackButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_buyTrackButton.frame = CGRectMake(210.0, [UIScreen mainScreen].bounds.size.height - 135.0, 106.0, 61.0);
		[_buyTrackButton setBackgroundImage:[UIImage imageNamed:@"likeButton_nonActive"] forState:UIControlStateNormal];
		[_buyTrackButton setBackgroundImage:[UIImage imageNamed:@"likeButton_Active"] forState:UIControlStateHighlighted];
		[_buyTrackButton addTarget:self action:@selector(_goBuyTrack) forControlEvents:UIControlEventTouchUpInside];
		_buyTrackButton.hidden = YES;
		[self addSubview:_buyTrackButton];
		
		UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, _gutterSize.height, 250.0, 250.0)];
		overlayImgView.image = [UIImage imageNamed:@"cameraOverlayBranding.png"];
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
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 70.0, 320.0, 70.0)];
		footerImgView.image = [UIImage imageNamed:@"cameraFooterBG.png"];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, 70.0)];
		[footerImgView addSubview:_footerHolderView];
		
		// Add the capture button
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(103.0, 3.0, 114.0, 64.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive.png"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active.png"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:_captureButton];
				
		// Add the gallery button
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(10.0, 10.0, 49.0, 49.0);
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
		[cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		//[_footerHolderView addSubview:cameraRollButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(263.0, 10.0, 49.0, 49.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive.png"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active.png"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:changeCameraButton];
		
		// Add the back button
		UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		backButton.frame = CGRectMake(360.0, 10.0, 49.0, 49.0);
		[backButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive.png"] forState:UIControlStateNormal];
		[backButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active.png"] forState:UIControlStateHighlighted];
		[backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:backButton];
		
		// Add the next button
		UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		nextButton.frame = CGRectMake(570.0, 10.0, 49.0, 49.0);
		[nextButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[nextButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
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
	
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUpMirrored]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([HONAppDelegate isRetina5]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(-320.0, 0.0, 640.0, 70.0);
	} completion:nil];
}

- (void)hidePreview {
	_previewHolderView.hidden = YES;
	
	for (UIView *subview in _previewHolderView.subviews) {
		[subview removeFromSuperview];
	}
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(0.0, 0.0, 640.0, 70.0);
	} completion:nil];
	
	[self.delegate cameraOverlayViewPreviewBack:self];
}

- (void)songName:(NSString *)songName artworkURL:(NSString *)artwork storeURL:(NSString *)itunesURL {
	_songName = songName;
	UILabel *songLabel = [[UILabel alloc] initWithFrame:CGRectMake(65.0, [UIScreen mainScreen].bounds.size.height - 100.0, 200.0, 14.0)];
	songLabel.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:12];
	songLabel.textColor = [UIColor whiteColor];
	songLabel.backgroundColor = [UIColor clearColor];
	songLabel.text = _songName;
	[self addSubview:songLabel];
	
	[_albumImageView setImageWithURL:[NSURL URLWithString:artwork] placeholderImage:nil options:SDWebImageLowPriority];
	_itunesURL = [itunesURL stringByReplacingOccurrencesOfString:@"https://" withString:@"itms://"];
	
	_buyTrackButton.hidden = NO;
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
												 [NSString stringWithFormat:@"%@ - %@", _subjectName, _songName], @"track", nil]];
	
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
	
	if ([textField.text length] == 0)
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
				[self songName:[subjectResult objectForKey:@"song_name"] artworkURL:[subjectResult objectForKey:@"img_url"] storeURL:[subjectResult objectForKey:@"itunes_url"]];
				[self.delegate cameraOverlayViewPlayTrack:self audioURL:[subjectResult objectForKey:@"preview_url"]];
			}
		}
	}
}

@end
