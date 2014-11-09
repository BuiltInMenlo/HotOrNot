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
#import "HONUserVO.h"
#import "HONContactUserVO.h"

@interface HONCameraOverlayView()
@property (nonatomic, strong) UIImageView *infoImageView;
@property (nonatomic, strong) UIView *blackMatteView;
@property (nonatomic, strong) UIView *headerBGView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIButton *cameraRollButton;
@property (nonatomic, strong) UIButton *flipButton;
@property (nonatomic, strong) UIButton *takePhotoButton;
@property (nonatomic, strong) UIImageView *lastCameraRollImageView;
@end

@implementation HONCameraOverlayView
@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_blackMatteView = [[UIView alloc] initWithFrame:self.frame];
		_blackMatteView.backgroundColor = [UIColor blackColor];
		_blackMatteView.hidden = YES;
		[self addSubview:_blackMatteView];
		
//		UIImageView *gradientImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraGradientOverlay"]];
//		gradientImageView.frame = self.frame;
//		[self addSubview:gradientImageView];
		
		_headerBGView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(320.0, 50.0))];
		[self addSubview:_headerBGView];
		
		_flipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_flipButton.frame = CGRectMake(271.0, 7.0, 44.0, 44.0);
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_nonActive"] forState:UIControlStateNormal];
		[_flipButton setBackgroundImage:[UIImage imageNamed:@"cameraFlipButton_Active"] forState:UIControlStateHighlighted];
		[_flipButton addTarget:self action:@selector(_goFlipCamera) forControlEvents:UIControlEventTouchUpInside];
		//[_headerBGView addSubview:_flipButton];
		
		_cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cancelButton.frame = CGRectMake(7.0, 7.0, 44.0, 44.0);
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cameraX_nonActive"] forState:UIControlStateNormal];
		[_cancelButton setBackgroundImage:[UIImage imageNamed:@"cameraX_Active"] forState:UIControlStateHighlighted];
		[_cancelButton addTarget:self action:@selector(_goCloseCamera) forControlEvents:UIControlEventTouchUpInside];
		[_headerBGView addSubview:_cancelButton];
		
		_skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_skipButton.frame = CGRectMake(270.0, [UIScreen mainScreen].bounds.size.height - 51.0, 44.0, 44.0);
		[_skipButton setBackgroundImage:[UIImage imageNamed:@"skipArrow_nonActive"] forState:UIControlStateNormal];
		[_skipButton setBackgroundImage:[UIImage imageNamed:@"skipArrow_Active"] forState:UIControlStateHighlighted];
		[_skipButton addTarget:self action:@selector(_goSkipCamera) forControlEvents:UIControlEventTouchUpInside];
//		[self addSubview:_skipButton];
		
		
		_takePhotoButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_takePhotoButton.frame = CGRectMake(115.0, [UIScreen mainScreen].bounds.size.height - 113.0, 94.0, 94.0);
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_nonActive"] forState:UIControlStateNormal];
		[_takePhotoButton setBackgroundImage:[UIImage imageNamed:@"takePhotoButton_Active"] forState:UIControlStateHighlighted];
		[_takePhotoButton addTarget:self action:@selector(_goTakePhoto) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_takePhotoButton];
		
		_lastCameraRollImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraRollBG"]];
		_lastCameraRollImageView.frame = CGRectOffset(_lastCameraRollImageView.frame, 9.0, [UIScreen mainScreen].bounds.size.height - 48.0);
		[self addSubview:_lastCameraRollImageView];
		
		[[HONViewDispensor sharedInstance] maskView:_lastCameraRollImageView withMask:[UIImage imageNamed:@"cameraRollMask"]];
		[self _retrieveLastImage];
		
		_cameraRollButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_cameraRollButton.frame = _lastCameraRollImageView.frame;
		[_cameraRollButton addTarget:self action:@selector(_goCameraRoll) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:_cameraRollButton];
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

- (void)_goSkipCamera {
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewTakePhoto:includeFilter:)])
		[self.delegate cameraOverlayViewTakePhoto:self includeFilter:YES];
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
	
	if ([self.delegate respondsToSelector:@selector(cameraOverlayViewTakePhoto:includeFilter:)])
		[self.delegate cameraOverlayViewTakePhoto:self includeFilter:NO];
}

- (void)_retrieveLastImage {
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	[assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
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

@end
