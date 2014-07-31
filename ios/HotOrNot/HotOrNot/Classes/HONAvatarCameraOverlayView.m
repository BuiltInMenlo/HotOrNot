//
//  HONAvatarCameraOverlayView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 06.19.13 @ 09:23 AM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"

#import "HONAvatarCameraOverlayView.h"
#import "HONImageLoadingView.h"

@interface HONAvatarCameraOverlayView ()
@property (nonatomic, strong) UIView *irisView;
@property (nonatomic, strong) UIImageView *lastCameraRollImageView;
@property (nonatomic, strong) UIView *submitHolderView;
@property (nonatomic, strong) UIView *previewHolderView;
@property (nonatomic, strong) UIButton *changeTintButton;
@property (nonatomic, strong) UIButton *captureButton;
@property (nonatomic, strong) UIImageView *infoHolderImageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) UIView *blackMatteView;
@end

@implementation HONAvatarCameraOverlayView
@synthesize delegate = _delegate;


#pragma mark - View Lifecycle
- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		_previewHolderView = [[UIView alloc] initWithFrame:self.frame];
		[self addSubview:_previewHolderView];
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"headerFadeBackground"]]];
		
		_irisView = [[UIImageView alloc] initWithFrame:self.frame];
		_irisView.backgroundColor = [UIColor blackColor];
		_irisView.alpha = 0.0;
		[self addSubview:_irisView];
		
		UIView *headerBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, 50.0)];
		headerBGView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
		[self addSubview:headerBGView];
		
		UIButton *flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		flipButton.frame = CGRectMake(275.0, 0.0, 64.0, 64.0);
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[headerBGView addSubview:flipButton];
		
		UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cancelButton.frame = CGRectMake(0.0, 0.0, 93.0, 44.0);
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelbuttonwhite_nonactive"] forState:UIControlStateNormal];
		[cancelButton setBackgroundImage:[UIImage imageNamed:@"cancelbuttonwhite_active"] forState:UIControlStateHighlighted];
		[cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[headerBGView addSubview:cancelButton];
		
//		UIView *gutterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 141.0, 320.0, 141.0)];
//		gutterView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.75];
//		[self addSubview:gutterView];
		
//		_changeTintButton = [UIButton buttonWithType:UIButtonTypeCustom];
//		_changeTintButton.frame = CGRectMake(-5.0, [UIScreen mainScreen].bounds.size.height - 60.0, 64.0, 64.0);
//		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterButton_nonActive"] forState:UIControlStateNormal];
//		[_changeTintButton setBackgroundImage:[UIImage imageNamed:@"filterButton_Active"] forState:UIControlStateHighlighted];
//		[_changeTintButton addTarget:self action:@selector(_goChangeTint) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_changeTintButton];
		
		_captureButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_captureButton.frame = CGRectMake(115.0, [UIScreen mainScreen].bounds.size.height - 113.0, 94.0, 94.0);
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_captureButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		[_captureButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_captureButton];
		
		_lastCameraRollImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraRollBG"]];
		_lastCameraRollImageView.frame = CGRectOffset(_lastCameraRollImageView.frame, 257.0, [UIScreen mainScreen].bounds.size.height - 60.0);
		[self addSubview:_lastCameraRollImageView];
		
		[[HONImageBroker sharedInstance] maskImageView:_lastCameraRollImageView withMask:[UIImage imageNamed:@"cameraRollMask"]];
		[self _retrieveLastImage];
		
		UIButton *cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		cameraRollButton.frame = CGRectMake(220.0, [UIScreen mainScreen].bounds.size.height - 42.0, 93.0, 44.0);
		[cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:cameraRollButton];
		
		_submitHolderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 64.0)];
		[self addSubview:_submitHolderView];
		
		UIButton *retakeButton = [UIButton buttonWithType:UIButtonTypeCustom];
		retakeButton.frame = CGRectMake(0.0, 0.0, 106.0, 64.0);
		retakeButton.backgroundColor = [UIColor redColor];
		[retakeButton addTarget:self action:@selector(_goCameraBack) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:retakeButton];
		
		UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		skipButton.frame = CGRectMake(106.0, 0.0, 106.0, 64.0);
		retakeButton.backgroundColor = [UIColor greenColor];
		[skipButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:skipButton];
		
		UIButton *submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
		submitButton.frame = CGRectMake(256.0, 0.0, 64.0, 64.0);
		retakeButton.backgroundColor = [UIColor blueColor];
		[submitButton addTarget:self action:@selector(_goSubmit) forControlEvents:UIControlEventTouchUpInside];
		[_submitHolderView addSubview:submitButton];
		
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.alpha = 0.0;
		[self addSubview:_blackMatteView];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)addPreview:(UIImage *)image {
	image = [[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(480.0, 640.0)];
	UIImage *scaledImage = [UIImage imageWithCGImage:image.CGImage scale:1.5 orientation:UIImageOrientationUp];
	UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageWithCGImage:scaledImage.CGImage scale:1.5 orientation:UIImageOrientationUp]];
	[_previewHolderView addSubview:imgView];
	_previewHolderView.hidden = NO;
	
	if ([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) {
		CGRect frame = CGRectMake(-18.0, 0.0, 355.0, 475.0);
		imgView.frame = frame;
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}

- (void)addPreviewAsFlipped:(UIImage *)image {
	image = [[HONImageBroker sharedInstance] scaleImage:image byFactor:([[HONDeviceIntrinsics sharedInstance] isRetina4Inch]) ? 0.55f : 0.83333f];
	
	UIImageView *previewImageView = [[UIImageView alloc] initWithImage:image];
	previewImageView.frame = CGRectOffset(previewImageView.frame, ABS(self.frame.size.width - image.size.width) * -0.5, (-26.0 + (ABS(self.frame.size.height - image.size.height) * -0.5)) + (-26.0 * [[HONDeviceIntrinsics sharedInstance] isRetina4Inch]));
	previewImageView.transform = CGAffineTransformScale(previewImageView.transform, -1.0f, 1.0f);
	[_previewHolderView addSubview:previewImageView];
	_previewHolderView.hidden = NO;
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.0;
	} completion:^(BOOL finished) {
		_blackMatteView.hidden = YES;
	}];
}

- (void)removePreview {
	_previewHolderView.hidden = YES;
	for (UIView *subview in _previewHolderView.subviews)
		[subview removeFromSuperview];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		_submitHolderView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height, 320.0, 64.0);
	}];
}

- (void)uploadComplete {
}

- (void)animateAccept {
	[UIView animateWithDuration:0.125 animations:^(void) {
		_submitHolderView.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 64.0, 320.0, 64.0);
	}];
}

- (void)resetControls {
	[self removePreview];
	
	_captureButton.hidden = NO;
}


#pragma mark - Navigation
- (void)_goOKInfo {
	[UIView animateWithDuration:0.25 animations:^(void){
		_infoHolderImageView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[_infoHolderImageView removeFromSuperview];
	}];
}

- (void)_goTakePhoto {
	_captureButton.hidden = YES;
	
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		}];
	}];
	
	[self.delegate cameraOverlayViewTakePicture:self];
}

- (void)_goCancel {
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
														message:@"Your profile photo helps the Selfieclub community know your real."
													   delegate:self
											  cancelButtonTitle:@"No Thanks"
											  otherButtonTitles:@"Take Photo", nil];
	[alertView setTag:0];
	[alertView show];
}

- (void)_goSubmit {
	[UIView animateWithDuration:0.25 animations:^(void) {
		_blackMatteView.alpha = 0.65;
	} completion:^(BOOL finished) {
		_submitHolderView.hidden = YES;
		[self.delegate cameraOverlayViewSubmit:self];
	}];
}

- (void)_goFlipCamera {
	[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goCameraRoll {
	[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCameraBack {
	[self removePreview];
	
	_captureButton.hidden = NO;
	[self.delegate cameraOverlayViewRetake:self];
}


#pragma mark - UI Presentation
- (void)_verifyOverlay:(BOOL)isIntro {
	if (isIntro) {
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:[[UIApplication sharedApplication] delegate].window asLargeLoader:YES];
		_imageLoadingView.alpha = 0.0;
		[self addSubview:_imageLoadingView];
	}
	
	[UIView animateWithDuration:0.25 animations:^(void) {
		_imageLoadingView.alpha = ((int)isIntro);
	} completion:nil];
}

- (void)_retrieveLastImage {
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	[assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos
								 usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
									 if (nil != group) {
										 // be sure to filter the group so you only get photos
										 [group setAssetsFilter:[ALAssetsFilter allPhotos]];
										 [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
											 if (asset) {
												 _lastCameraRollImageView.image = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
												 *stop = YES;
											 }
										 }];
									 }
									 
									 *stop = NO;
								 } failureBlock:^(NSError *error) {
									 NSLog(@"error: %@", error);
								 }];
}



#pragma mark - AlertView Delegates
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (alertView.tag == 0) {
		
		switch(buttonIndex) {
			case 0:
				[self.delegate cameraOverlayViewCloseCamera:self];
				break;
				
			case 1:
				[self _goCameraBack];
				break;
		}
	}
}

@end
