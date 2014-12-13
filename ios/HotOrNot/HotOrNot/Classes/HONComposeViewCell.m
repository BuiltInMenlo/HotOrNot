//
//  HONComposeViewCell.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONComposeViewCell.h"


@interface HONComposeViewCell ()
@property (nonatomic, strong) UIImageView *loadingImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic, strong) UIButton *selectButton;
@property (nonatomic) BOOL isLoading;
@end

@implementation HONComposeViewCell
@synthesize delegate = _delegate;
@synthesize composeImageVO = _composeImageVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_isLoading = NO;
		[self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		_loadingImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"loadingArrows"]];
		[self.contentView addSubview:_loadingImageView];
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(self.frame.size)];
		[self.contentView addSubview:_imageView];
		
		_animatedImageView = [[FLAnimatedImageView alloc] init];
		_animatedImageView.frame = CGRectFromSize(self.frame.size);
		_animatedImageView.contentMode = UIViewContentModeScaleToFill; // stretches w/o ratio -- UIViewContentModeScaleAspectFit; // centers in frame
		_animatedImageView.clipsToBounds = YES;
		[self.contentView addSubview:_animatedImageView];
		
		_selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		_selectButton.frame = CGRectFromSize(self.frame.size);
		[self.contentView addSubview:_selectButton];
	}
	
	return (self);
}

- (void)dealloc {
	if (_isLoading) {
		[_imageView cancelImageRequestOperation];
	}
	
	_isLoading = NO;
}

- (void)destroy {
	[super destroy];
	
	if (_isLoading) {
		[_imageView cancelImageRequestOperation];
	}
	
	_isLoading = NO;
}


#pragma mark - Public APIs
- (void)toggleImageLoading:(BOOL)isLoading {
	if (isLoading) {
		if (!_isLoading) {
			_isLoading = YES;
			
			if (_composeImageVO.imageType == HONComposeImageTypeTypeAnimated) {
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					NSURL *url = [NSURL URLWithString:_composeImageVO.urlPrefix];
					FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
					
					dispatch_async(dispatch_get_main_queue(), ^{
						_animatedImageView.animatedImage = animatedImage;
						_composeImageVO.animatedImage = animatedImage;
						
						[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
							_animatedImageView.alpha = 1.0;
							
						} completion:^(BOOL finished) {
							[_loadingImageView removeFromSuperview];
							_loadingImageView = nil;
						}];
					});
				});
				
			} else {
				void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
					_isLoading = NO;
					_imageView.image = image;
					_composeImageVO.image = image;
					
					[_selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
				};
				
				void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
					NSLog(@"ERROR:[%@]", error.description);
					_isLoading = NO;
					_imageView.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
					_composeImageVO.image = [UIImage imageNamed:@"placeholderClubPhoto_320x320"];
				};
				
				NSLog(@"URL:[%@]", [_composeImageVO.urlPrefix stringByAppendingString:kSnapMediumSuffix]);
				[_imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[_composeImageVO.urlPrefix stringByAppendingString:kSnapMediumSuffix]]
																	cachePolicy:kOrthodoxURLCachePolicy
																timeoutInterval:[HONAppDelegate timeoutInterval]]
								  placeholderImage:[UIImage imageNamed:@"loadingArrows"]
										   success:imageSuccessBlock
										   failure:imageFailureBlock];
			}
		}
		
	} else {
		if (_isLoading) {
			_isLoading = NO;
			if (_composeImageVO.imageType == HONComposeImageTypeTypeAnimated) {
				
				
			} else {
				[_imageView cancelImageRequestOperation];
			}
		}
	}
}

- (void)setComposeImageVO:(HONComposeImageVO *)composeImageVO {
	_composeImageVO = composeImageVO;
	[self toggleImageLoading:YES];
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(composeViewCell:didSelectComposeImage:)])
		[self.delegate composeViewCell:self didSelectComposeImage:_composeImageVO];
}

@end
