//
//  HONSnapCameraOptionsView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/30/13 @ 10:31 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONSnapCameraOptionsView.h"


@interface HONSnapCameraOptionsView ()
@property (nonatomic, strong) UIButton *flipCameraButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *cancelButton;
@end

@implementation HONSnapCameraOptionsView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"moreOverlay"]];
		bgImageView.frame = CGRectOffset(bgImageView.frame, 0.0, self.frame.size.height - 344.0);
		bgImageView.userInteractionEnabled = YES;
		[self addSubview:bgImageView];
		
		float offset = 30.0;
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraRollButton.frame = CGRectMake(28.0, offset, 264.0, 64.0);
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_nonActive"] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRoll_Active"] forState:UIControlStateHighlighted];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_cameraRollButton];
		
		_flipCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipCameraButton.frame = CGRectMake(28.0, offset + 80.0, 264.0, 64.0);
		[_flipCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_nonActive"] forState:UIControlStateNormal];
		[_flipCameraButton setBackgroundImage:[UIImage imageNamed:@"flipCamera_Active"] forState:UIControlStateHighlighted];
		[_flipCameraButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		_flipCameraButton.hidden = !([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]);
		[bgImageView addSubview:_flipCameraButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(28.0, offset + 190.0, 264.0, 64.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cancel_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCancel) forControlEvents:UIControlEventTouchUpInside];
		[bgImageView addSubview:_cancelButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goFlipCamera {
	[self.delegate cameraOptionsViewFlipCamera:self];
	[self _goClose];
}

- (void)_goCameraRoll {
	[[Mixpanel sharedInstance] track:@"Create Snap Camera Options - Camera Roll"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self.delegate cameraOptionsViewCameraRoll:self];
	[self _goClose];
}

- (void)_goCancel {
	[[Mixpanel sharedInstance] track:@"Create Snap Camera Options - Cancel"
						  properties:[NSDictionary dictionaryWithObjectsAndKeys:
									  [NSString stringWithFormat:@"%@ - %@", [[HONAppDelegate infoForUser] objectForKey:@"id"], [[HONAppDelegate infoForUser] objectForKey:@"name"]], @"user", nil]];
	
	[self _goClose];
}


#pragma mark - UI Presentation
- (void)_goClose {
	[self.delegate cameraOptionsViewClose:self];
}


@end
