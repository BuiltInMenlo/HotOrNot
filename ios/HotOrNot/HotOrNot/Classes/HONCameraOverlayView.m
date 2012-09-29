//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 09.27.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONCameraOverlayView.h"

#import "HONAppDelegate.h"

@interface HONCameraOverlayView() <UITextFieldDelegate>
@property (nonatomic, strong) UILabel *placeholderLabel;
@property (nonatomic, strong) UITextField *subjectTextField;
@end

@implementation HONCameraOverlayView

@synthesize delegate, flashButton, changeCameraButton, captureButton, cameraRollButton;
@synthesize placeholderLabel = _placeholderLabel;
@synthesize subjectTextField = _subjectTextField;
@synthesize subjectName = _subjectName;

- (id)initWithFrame:(CGRect)frame {
	if (self = [super initWithFrame:frame]) {
		
		self.opaque = NO;
		
		UIImageView *headerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 45.0)];
		[headerImgView setImage:[UIImage imageNamed:@"cameraInput.png"]];
		headerImgView.userInteractionEnabled = YES;
		[self addSubview:headerImgView];
				
		_subjectTextField = [[UITextField alloc] initWithFrame:CGRectMake(2.0, 8.0, 280.0, 20.0)];
		//[_subjectTextField setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[_subjectTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
		[_subjectTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
		_subjectTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
		[_subjectTextField setReturnKeyType:UIReturnKeyDone];
		[_subjectTextField setTextColor:[UIColor colorWithWhite:0.482 alpha:1.0]];
		[_subjectTextField addTarget:self action:@selector(_onTxtDoneEditing:) forControlEvents:UIControlEventEditingDidEndOnExit];
		//_subjectTextField.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_subjectTextField.keyboardType = UIKeyboardTypeDefault;
		_subjectTextField.text = @"";
		_subjectTextField.delegate = self;
		[headerImgView addSubview:_subjectTextField];
		
		_placeholderLabel = [[UILabel alloc] initWithFrame:_subjectTextField.frame];
		//_placeholderLabel.font = [[SNAppDelegate snHelveticaNeueFontBold] fontWithSize:12];
		_placeholderLabel.textColor = [UIColor colorWithWhite:0.620 alpha:1.0];
		_placeholderLabel.backgroundColor = [UIColor clearColor];
		_placeholderLabel.textAlignment = NSTextAlignmentCenter;
		_placeholderLabel.text = @"Give your challenge a #hashtag";
		[self addSubview:self.placeholderLabel];
		
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
		UIImageView *footerImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 415.0, 320.0, 65.0)];
		footerImgView.backgroundColor = [UIColor blueColor];
		footerImgView.userInteractionEnabled = YES;
		[self addSubview:footerImgView];
		
		// Add the capture button
		self.captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.captureButton.frame = CGRectMake(106.0, 5.0, 108.0, 48.0);
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"playButton_nonActive.png"] forState:UIControlStateNormal];
		[self.captureButton setBackgroundImage:[UIImage imageNamed:@"playButton_Active.png"] forState:UIControlStateHighlighted];
		[self.captureButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:self.captureButton];
				
		// Add the gallery button
		self.cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		self.cameraRollButton.frame = CGRectMake(10.0, 10.0, 44.0, 44.0);
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive.png"] forState:UIControlStateNormal];
		[self.cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active.png"] forState:UIControlStateHighlighted];
		[self.cameraRollButton addTarget:self action:@selector(showCameraRoll:) forControlEvents:UIControlEventTouchUpInside];
		[footerImgView addSubview:self.cameraRollButton];
	}
	
	return (self);
}

- (void)setSubjectName:(NSString *)subjectName {
	_subjectName = subjectName;
	_subjectTextField.text = _subjectName;
	
	_placeholderLabel.hidden = YES;
	_placeholderLabel.text = _subjectName;
}

- (void)takePicture:(id)sender {
	self.captureButton.enabled = NO;
	[self.delegate takePicture];
}

- (void)setFlash:(id)sender {
	[self.delegate changeFlash:sender];
}

- (void)changeCamera:(id)sender {
	[self.delegate changeCamera];
}

- (void)showCameraRoll:(id)sender {
	[self.delegate showLibrary];
}


#pragma mark - TextField Delegates
-(void)textFieldDidBeginEditing:(UITextField *)textField {
	self.placeholderLabel.hidden = YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
	[textField resignFirstResponder];
	
	if ([textField.text length] == 0)
		self.placeholderLabel.hidden = NO;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
