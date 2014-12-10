//
//  HONCameraOverlayView.m
//  HotOrNot
//
//  Created by BIM  on 9/26/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "HONCameraOverlayView.h"
#import "HONHeaderView.h"

@interface HONCameraOverlayView()
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *takePhotoButton;
@end

@implementation HONCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.hidden = YES;
		[self addSubview:_blackMatteView];
		
		[self addSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraGradientOverlay"]]];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(7.0, -12.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cameraX_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cameraX_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		
		HONHeaderView *headerView = [[HONHeaderView alloc] initWithTitle:@""];
		[headerView removeBackground];
		[headerView addButton:_cancelButton];
		[self addSubview:headerView];
		
		_takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_takePhotoButton.frame = CGRectMake(0.0, [UIScreen mainScreen].bounds.size.height - 44.0, 320.0, 44.0);
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		[_takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_takePhotoButton];
		
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(self.frame.size.width - 48.0, self.frame.size.height - 44.0, 44.0, 44.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_flipButton];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraRollButton.frame = CGRectMake(4.0, self.frame.size.height - 40.0, 36.0, 36.0);
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRollBG"] forState:UIControlStateNormal];
		[_cameraRollButton setBackgroundImage:[UIImage imageNamed:@"cameraRollBG"] forState:UIControlStateHighlighted];
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_cameraRollButton];
		
		UIImageView *cameraRollImageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(CGSizeMake(36.0, 36.0))];
		[_cameraRollButton addSubview:cameraRollImageView];
		
		[[HONViewDispensor sharedInstance] maskView:cameraRollImageView withMask:[UIImage imageNamed:@"cameraRollMask"]];
		[[HONImageBroker sharedInstance] fetchLastCameraRollImageWithCompletion:^(UIImage *result) {
			cameraRollImageView.image = result;
		}];
	}
	
	return (self);
}


#pragma mark - Public API


#pragma mark - Navigation
- (void)_goFlipCamera {
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewChangeCamera:)])
		[self.delegate cameraOverlayViewChangeCamera:self];
}

- (void)_goToggleFlash {
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewChangeFlash:)])
		[self.delegate cameraOverlayViewChangeFlash:self];
}

- (void)_goCameraRoll {
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewShowCameraRoll:)])
		[self.delegate cameraOverlayViewShowCameraRoll:self];
}

- (void)_goCloseCamera {
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewCloseCamera:)])
		[self.delegate cameraOverlayViewCloseCamera:self];
}

- (void)_goTakePhoto {
	_blackMatteView.hidden = NO;
	[UIView animateWithDuration:0.125 animations:^(void) {
		_blackMatteView.alpha = 1.0;
	} completion:^(BOOL finished) {
		[UIView animateWithDuration:0.25 animations:^(void) {
			_blackMatteView.alpha = 0.0;
		}];
	}];
	
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewTakePhoto:)])
		[self.delegate cameraOverlayViewTakePhoto:self];
}

@end
