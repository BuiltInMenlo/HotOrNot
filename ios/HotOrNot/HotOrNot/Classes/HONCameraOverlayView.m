//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "Mixpanel.h"

#import "HONCameraOverlayView.h"
#import "HONAppDelegate.h"
#import "HONHeaderView.h"

@interface HONCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIView *footerHolderView;
@property(nonatomic, strong) UITextField *subjectTextField;
@property(nonatomic, strong) UIButton *editButton;
@property(nonatomic) CGSize gutterSize;
@end

@implementation HONCameraOverlayView

@synthesize delegate, flashButton, captureButton, cameraRollButton;
@synthesize previewHolderView = _previewHolderView;
@synthesize footerHolderView = _footerHolderView;
@synthesize subjectTextField = _subjectTextField;
@synthesize editButton = _editButton;
@synthesize nextButton = _nextButton;
@synthesize backButton = _backButton;
@synthesize subjectName = _subjectName;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		
		int photoSize = 250.0;
		_gutterSize = CGSizeMake((320.0 - photoSize) * 0.5, (self.frame.size.height - photoSize) * 0.5);
		
		_previewHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:_previewHolderView];
		
		UIView *headerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, _gutterSize.height)];
		headerGutterView.backgroundColor = [UIColor blackColor];
		//[self addSubview:headerGutterView];
		
		UIView *footerGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - _gutterSize.height, 320.0, _gutterSize.height)];
		footerGutterView.backgroundColor = [UIColor blackColor];
		//[self addSubview:footerGutterView];
		
		UIView *lGutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, _gutterSize.width, self.frame.size.height)];
		lGutterView.backgroundColor = [UIColor blackColor];
		//[self addSubview:lGutterView];
		
		UIView *rGutterView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width - _gutterSize.width, 0.0, _gutterSize.width, self.frame.size.height)];
		rGutterView.backgroundColor = [UIColor blackColor];
		//[self addSubview:rGutterView];
		
		HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@"Take Photo"];
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
		[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		_subjectTextField.font = [[HONAppDelegate honHelveticaNeueFontBold] fontWithSize:16];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		_subjectTextField.text = self.subjectName;
		_subjectTextField.delegate = self;
		[self addSubview:_subjectTextField];
		
		_editButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_editButton.frame = CGRectMake(265.0, 60.0, 44.0, 44.0);
		[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_nonActive.png"] forState:UIControlStateNormal];
		[_editButton setBackgroundImage:[UIImage imageNamed:@"closeXButton_Active.png"] forState:UIControlStateHighlighted];
		[_editButton addTarget:self action:@selector(_goEditSubject) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_editButton];
		
		
		UIImageView *overlayImgView = [[UIImageView alloc] initWithFrame:CGRectMake(35.0, headerGutterView.frame.size.height, 250.0, 250.0)];
		overlayImgView.image = [UIImage imageNamed:@"cameraOverlayBranding.png"];
		overlayImgView.userInteractionEnabled = YES;
		//[self addSubview:overlayImgView];
		
//		UIImage *buttonImageNormal;
//		if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]) {
//			self.flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			self.flashButton.frame = CGRectMake(10, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"flash02"];
//			[self.flashButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[self.flashButton addTarget:self action:@selector(setFlash:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:self.flashButton];
//		}
//		
//		if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
//			self.changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
//			self.changeCameraButton.frame = CGRectMake(250, 30, 57.5, 57.5);
//			buttonImageNormal = [UIImage imageNamed:@"switch_button"];
//			[self.changeCameraButton setImage:buttonImageNormal forState:UIControlStateNormal];
//			[self.changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
//			[self addSubview:self.changeCameraButton];
//		}
		
		// Add the bottom bar
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 70.0, 320.0, 70.0)];
		footerImgView.image = [UIImage imageNamed:@"cameraFooterBG.png"];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		_footerHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 640.0, 70.0)];
		[footerImgView addSubview:_footerHolderView];
		
		// Add the capture button
		self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.captureButton.frame = CGRectMake(103.0, 3.0, 114.0, 64.0);
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_nonActive.png"] forState:UIControlStateNormal];
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"cameraButton_Active.png"] forState:UIControlStateHighlighted];
		[self.captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:self.captureButton];
				
		// Add the gallery button
		self.cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.cameraRollButton.frame = CGRectMake(10.0, 10.0, 49.0, 49.0);
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
		[self.cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:self.cameraRollButton];
		
		UIButton *changeCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		changeCameraButton.frame = CGRectMake(263.0, 10.0, 49.0, 49.0);
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive.png"] forState:UIControlStateNormal];
		[changeCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active.png"] forState:UIControlStateHighlighted];
		[changeCameraButton addTarget:self action:@selector(changeCamera:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:changeCameraButton];
		
		// Add the capture button
		self.backButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.backButton.frame = CGRectMake(360.0, 10.0, 49.0, 49.0);
		[self.backButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive.png"] forState:UIControlStateNormal];
		[self.backButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active.png"] forState:UIControlStateHighlighted];
		[self.backButton addTarget:self action:@selector(goBack:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:self.backButton];
		
		// Add the gallery button
		self.nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.nextButton.frame = CGRectMake(570.0, 10.0, 49.0, 49.0);
		[self.nextButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[self.nextButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
		[self.nextButton addTarget:self action:@selector(goNext:) forControlEvents:UIControlEventTouchUpInside];
		[_footerHolderView addSubview:self.nextButton];
	}
	
	return (self);
}

- (void)takePicture:(id)sender {
	self.captureButton.enabled = NO;
	[self.delegate takePicture];
}

- (void)setFlash:(id)sender {
	//[self.delegate changeFlash:sender];
}

- (void)changeCamera:(id)sender {
	[self.delegate changeCamera];
}

- (void)showCameraRoll:(id)sender {
	[self.delegate showLibrary];
}

- (void)closeCamera:(id)sender {
	[self.delegate closeCamera];
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
	[[Mixpanel sharedInstance] track:@"Image Preview - Back"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_previewHolderView.hidden = YES;
	
	for (UIView *subview in _previewHolderView.subviews) {
		[subview removeFromSuperview];
	}
	
	[UIView animateWithDuration:0.33 delay:0.0 options:UIViewAnimationCurveLinear animations:^{
		_footerHolderView.frame = CGRectMake(0.0, 0.0, 640.0, 70.0);
	} completion:nil];
	
	[self.delegate previewBack];
}

- (void)goBack:(id)sender {
	self.captureButton.enabled = YES;
	[self hidePreview];
}

- (void)goNext:(id)sender {
	[[Mixpanel sharedInstance] track:@"Image Preview - Accept"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate closePreview];
}

- (void)_goEditSubject {
	[[Mixpanel sharedInstance] track:@"Camera - Edit Hashtag"
								 properties:[NSDictionary dictionaryWithObjectsAndKeys:
												 [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	_subjectTextField.text = @"";
	[_subjectTextField becomeFirstResponder];
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
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = _subjectName;
}

@end
