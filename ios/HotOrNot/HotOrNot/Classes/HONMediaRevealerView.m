//
//  HONMediaRevealerView.m
//  HotOrNot
//
//  Created by BIM  on 3/19/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"
#import "UIView+BuiltInMenlo.h"

#import "HONMediaRevealerView.h"
#import "HONLoadingOverlayView.h"

@interface HONMediaRevealerView () <HONLoadingOverlayViewDelegate>
@property (nonatomic, strong) HONCommentVO *commentVO;
@property (nonatomic, strong) HONLoadingOverlayView *loadingOverlayView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *usernameLabel;
@end

@implementation HONMediaRevealerView
@synthesize delegate = _delegate;

- (id)initWithComment:(HONCommentVO *)commentVO {
	if ((self = [super initWithFrame:[UIScreen mainScreen].bounds])) {
		_commentVO = commentVO;
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectFromSize([[HONDeviceIntrinsics sharedInstance] scaledScreenSize])];
//		[_imageView centerAlignWithRect:self.frame];
		_imageView.backgroundColor = [UIColor redColor];
		_imageView.alpha = 0.0;
		[self addSubview:_imageView];
		
		void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			NSLog(@"SOURCE IMAGE:[%@] (%.06f)", NSStringFromCGSize(image.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
			
//			UIImage *scaledImage = [[HONImageBroker sharedInstance] scaleImage:image toSize:[[HONDeviceIntrinsics sharedInstance] scaledScreenSize] preserveRatio:YES];
//			NSLog(@"SCALED IMAGE:[%@] (%.06f)", NSStringFromCGSize(scaledImage.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
//
			UIImage *croppedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:[[HONDeviceIntrinsics sharedInstance] scaledScreenSize] preserveRatio:YES] toFillSize:[[HONDeviceIntrinsics sharedInstance] scaledScreenSize]];
			NSLog(@"CROPPED IMAGE:[%@] (%.06f)", NSStringFromCGSize(croppedImage.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
			
			_imageView.image = croppedImage;
			_imageView.frame = CGRectResize(_imageView.frame, self.frame.size);
			
			[_loadingOverlayView outro];
			[self intro];
		};
		
		void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
			NSLog(@"ERROR:[%@]", error.description);
			
			_imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"placeholderClubPhoto_%dx%d", (int)[[HONDeviceIntrinsics sharedInstance] scaledScreenWidth], (int)[[HONDeviceIntrinsics sharedInstance] scaledScreenHeight]]];
			[_loadingOverlayView outro];
			[self intro];
		};
		
		_loadingOverlayView = [[HONLoadingOverlayView alloc] init];
		_loadingOverlayView.delegate = self;
		
		NSLog(@"URL:[%@]", [_commentVO.imagePrefix stringByAppendingString:kPhotoHDSuffix]);
		[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_commentVO.imagePrefix stringByAppendingString:kPhotoHDSuffix]]
															   cachePolicy:kOrthodoxURLCachePolicy
														   timeoutInterval:[HONAPICaller timeoutInterval]]
							 placeholderImage:nil
									  success:imageSuccessBlock
									  failure:imageFailureBlock];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)intro {
	[UIView animateKeyframesWithDuration:0.125
								   delay:0.000
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							  animations:^(void) {
								  _imageView.alpha = 1.0;
								  
							  } completion:^(BOOL finished) {
								  if ([self.delegate respondsToSelector:@selector(mediaRevealerViewDidIntro:)])
									  [self.delegate mediaRevealerViewDidIntro:self];
							  }];
}

- (void)outro {
	[self _decompose];
}


#pragma mark - UI Presentation
- (void)_decompose {
	NSLog(@"::|> _decompose <|::");
	
	[UIView animateKeyframesWithDuration:0.125 * ((int)(_imageView.alpha > 0.0))
								   delay:0.000
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							  animations:^(void) {
								  _imageView.alpha = 0.0;
								  
							  } completion:^(BOOL finished) {
								  [self removeFromSuperview];
								  
								  if ([self.delegate respondsToSelector:@selector(mediaRevealerViewDidOutro:)])
									  [self.delegate mediaRevealerViewDidOutro:self];
							  }];
}


#pragma mark - LoadingOverlay Delegates
- (void)loadingOverlayViewDidIntro:(HONLoadingOverlayView *)loadingOverlayView {
	NSLog(@"[*:*] loadingOverlayViewDidIntro [*:*]");
}

- (void)loadingOverlayViewDidOutro:(HONLoadingOverlayView *)loadingOverlayView {
	NSLog(@"[*:*] loadingOverlayViewDidOutro [*:*]");
}

@end
