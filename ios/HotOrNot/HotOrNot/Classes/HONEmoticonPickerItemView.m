//
//  HONEmoticonPickerItemView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/21/2014 @ 20:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "UIImageView+AFNetworking.h"

#import "HONEmoticonPickerItemView.h"
#import "HONImageLoadingView.h"

const CGRect kNormalFrame = {15.0f, 15.0f, 44.0f, 44.0f};
const CGRect kActiveFrame = {10.0f, 10.0f, 54.0f, 54.0f};

@interface HONEmoticonPickerItemView ()
@property (nonatomic, strong) HONEmotionVO *emotionVO;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic) BOOL isSelected;
@end

@implementation HONEmoticonPickerItemView

- (id)initAtPosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO withDelay:(CGFloat)delay {
	if ((self = [super initWithFrame:CGRectMake(position.x, position.y, 75.0, 75.0)])) {
		_emotionVO = emotionVO;
		_isSelected = NO;
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_imageView.image = [UIImage imageNamed:@"emojiButtonBG"];
		_imageView.contentMode = UIViewContentModeScaleAspectFit;
		[self addSubview:_imageView];
		
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageView asLargeLoader:NO];
		_imageLoadingView.alpha = 0.667;
		[_imageLoadingView startAnimating];
		[_imageView addSubview:_imageLoadingView];
		
		[self performSelector:@selector(_loadImage) withObject:nil afterDelay:delay];

		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _imageView.frame;
		[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:selectButton];
	}
	
	return (self);
}


#pragma mark - Navigation
- (void)_goSelect {
	
	CGSize scaleSize = CGSizeMake(kActiveFrame.size.width / kNormalFrame.size.width, kActiveFrame.size.height / kNormalFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kActiveFrame) - CGRectGetMidX(kNormalFrame), CGRectGetMidY(kActiveFrame) - CGRectGetMidY(kNormalFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	NSLog(@"TRANS:[%@]", NSStringFromCGAffineTransform(transform));
	
	[UIView animateWithDuration:0.0625 delay:0.000
		 usingSpringWithDamping:0.875 initialSpringVelocity:0.000
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 _imageView.transform = transform;
					 } completion:^(BOOL finished) {
						 
						 if ([self.delegate respondsToSelector:@selector(emotionItemView:selectedEmotion:)])
							 [self.delegate emotionItemView:self selectedEmotion:_emotionVO];

						 
//						 CGSize scaleSize = CGSizeMake(kNormalFrame.size.width / kActiveFrame.size.width, kNormalFrame.size.height / kActiveFrame.size.height);
//						 CGPoint offsetPt = CGPointMake(CGRectGetMidX(kNormalFrame) - CGRectGetMidX(kActiveFrame), CGRectGetMidY(kNormalFrame) - CGRectGetMidY(kActiveFrame));
						 CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);//CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
						 
						 NSLog(@"TRANS:[%@]", NSStringFromCGAffineTransform(transform));
						 
						 [UIView animateWithDuration:0.125 delay:0.000
							  usingSpringWithDamping:0.875 initialSpringVelocity:0.333
											 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
						  
										  animations:^(void) {
											  _imageView.transform = transform;
										  } completion:^(BOOL finished) {
										  }];
					 }];
}


#pragma mark - UI Presentation
- (void)_loadImage {
	UIImageView *emojiImageView = [[UIImageView alloc] initWithFrame:kNormalFrame];
	emojiImageView.alpha = 0.0;
	[_imageView addSubview:emojiImageView];
	
	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		emojiImageView.image = image;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			emojiImageView.alpha = 1.0;
			_imageLoadingView.alpha = 0.0;
		} completion:nil];
	};
	
	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		_imageLoadingView.alpha = 0.0;
	};
	
	[emojiImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_emotionVO.largeImageURL]
															cachePolicy:NSURLRequestReturnCacheDataElseLoad
														timeoutInterval:[HONAppDelegate timeoutInterval]]
						  placeholderImage:nil
								   success:imageSuccessBlock
								   failure:imageFailureBlock];
}


@end
