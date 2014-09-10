//
//  HONEmoticonPickerItemView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/21/2014 @ 20:44 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIImageView+AFNetworking.h"

#import "HONEmoticonPickerItemView.h"
#import "HONImageLoadingView.h"

//const CGRect kLargeNormalFrame = {0.0f, 0.0f, 150.0f, 150.0f};
//const CGRect kLargeActiveFrame = {-5.0f, -5.0f, 160.0f, 160.0f};
//
////const CGRect kNormalFrame = {15.0f, 15.0f, 44.0f, 44.0f};
////const CGRect kActiveFrame = {10.0f, 10.0f, 54.0f, 54.0f};
//
//const CGRect kNormalFrame = {-1.0f, -1.0f, 76.0f, 76.0f};
//const CGRect kActiveFrame = {-6.0f, -6.0f, 86.0f, 86.0f};

@interface HONEmoticonPickerItemView ()
@property (nonatomic, strong) HONEmotionVO *emotionVO;
@property (nonatomic, strong) PicoSticker *picoSticker;
@property (nonatomic, strong) UIImageView *selectedImageView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic) BOOL isSelected;
@property (nonatomic) BOOL isLarge;
@end

@implementation HONEmoticonPickerItemView
- (id)initAtLargePosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO withDelay:(CGFloat)delay {
	if ((self = [super initWithFrame:CGRectMake(position.x, position.y, 154.0, 149.0)])) {
		_emotionVO = emotionVO;
		_isSelected = NO;
		_isLarge = YES;
		
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_imageView.image = [UIImage imageNamed:@"emojiLargeButtonBG"];
		_imageView.contentMode = UIViewContentModeRedraw;
		_imageView.layer.borderColor = [UIColor clearColor].CGColor;
		_imageView.layer.borderWidth = 2.5f;
		_imageView.layer.shouldRasterize = YES;
		_imageView.layer.rasterizationScale = 3.0f;
		[self addSubview:_imageView];
		
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageView asLargeLoader:NO];
		_imageLoadingView.alpha = 0.667;
		[_imageLoadingView startAnimating];
		[_imageView addSubview:_imageLoadingView];
		
//		NSLog(@"EMOTION STICKER:[%@]", emotionVO.pcContent);
		[self performSelector:@selector(_loadImage) withObject:nil afterDelay:delay];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _imageView.frame;
//		[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:selectButton];
				
		UILabel *stickerPackLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 160.0, 154.0, 18.0)];
		stickerPackLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:15];
		stickerPackLabel.textColor = [UIColor blackColor];
		stickerPackLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:stickerPackLabel];
		
		[[HONStickerAssistant sharedInstance] nameForContentGroupID:_emotionVO.contentGroupID completion:^(NSString *name) {
			if ([[name lowercaseString] rangeOfString:@" - free"].location != NSNotFound)
				name = [name substringToIndex:[[name lowercaseString] rangeOfString:@" - free"].location];
			
			stickerPackLabel.text = name;
		}];
		
//		if (delay == 0.0) {
//			UIImageView *badgeImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"emojiPaidBadge"]];
//			badgeImageView.frame = CGRectOffset(badgeImageView.frame, 120.0, 5.0);
//			[self addSubview:badgeImageView];
//		}
	}
	
	return (self);
}

- (id)initAtPosition:(CGPoint)position withEmotion:(HONEmotionVO *)emotionVO withDelay:(CGFloat)delay {
	if ((self = [super initWithFrame:CGRectMake(position.x, position.y, 75.0, 75.0)])) {
		_emotionVO = emotionVO;
		_isSelected = NO;
		_isLarge = NO;
		_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		_imageView.image = [UIImage imageNamed:@"emojiButtonBG"];
		_imageView.contentMode = UIViewContentModeRedraw;
		_imageView.layer.borderColor = [UIColor clearColor].CGColor;
		_imageView.layer.borderWidth = 2.5f;
		_imageView.layer.shouldRasterize = YES;
		_imageView.layer.rasterizationScale = 3.0f;
		[self addSubview:_imageView];
		
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:_imageView asLargeLoader:NO];
		_imageLoadingView.alpha = 0.667;
		[_imageLoadingView startAnimating];
		[_imageView addSubview:_imageLoadingView];
		
//		NSLog(@"EMOTION STICKER:[%@]", emotionVO.pcContent);
		[self performSelector:@selector(_loadImage) withObject:nil afterDelay:delay];
		
		UIButton *selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
		selectButton.frame = _imageView.frame;
//		[selectButton addTarget:self action:@selector(_goSelect) forControlEvents:UIControlEventTouchUpInside];
		[self addSubview:selectButton];
	}
	
	return (self);
}


//#pragma mark - Navigation
//- (void)_goSelect {
//	CGSize scaleSize = (_isLarge) ? CGSizeMake(kLargeActiveFrame.size.width / kLargeNormalFrame.size.width, kLargeActiveFrame.size.height / kLargeNormalFrame.size.height) : CGSizeMake(kActiveFrame.size.width / kNormalFrame.size.width, kActiveFrame.size.height / kNormalFrame.size.height);;
//	CGPoint offsetPt = (_isLarge) ? CGPointMake(CGRectGetMidX(kLargeActiveFrame) - CGRectGetMidX(kLargeNormalFrame), CGRectGetMidY(kLargeActiveFrame) - CGRectGetMidY(kLargeNormalFrame)) : CGPointMake(CGRectGetMidX(kActiveFrame) - CGRectGetMidX(kNormalFrame), CGRectGetMidY(kActiveFrame) - CGRectGetMidY(kNormalFrame));
//	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
//	
//	[UIView animateWithDuration:0.0625 delay:0.000
//		 usingSpringWithDamping:0.875 initialSpringVelocity:0.000
//						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
//	 
//					 animations:^(void) {
//						 _imageView.transform = transform;
//					 } completion:^(BOOL finished) {
//						 CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);//CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
//						 
//						 NSLog(@"TRANS:[%@]", NSStringFromCGAffineTransform(transform));
//						 
//						 [UIView animateWithDuration:0.125 delay:0.000
//							  usingSpringWithDamping:0.875 initialSpringVelocity:0.333
//											 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
//						  
//										  animations:^(void) {
//											  _imageView.transform = transform;
//										  } completion:^(BOOL finished) {
//											  if(_isLarge){
//												  if ([self.delegate respondsToSelector:@selector(emotionItemView:selectedLargeEmotion:)])
//													  [self.delegate emotionItemView:self selectedLargeEmotion:_emotionVO];
//											  } else{
//												  if ([self.delegate respondsToSelector:@selector(emotionItemView:selectedEmotion:)])
//													  [self.delegate emotionItemView:self selectedEmotion:_emotionVO];
//												  
//											  }
//											  
//										  }];
//					 }];
//}


#pragma mark - UI Presentation
- (void)_loadImage {
//	_picoSticker = [[PicoSticker alloc] initWithPCContent:_emotionVO.pcContent];
//	_picoSticker.frame = kNormalFrame;
//	_picoSticker.alpha = 0.0;
//	[_imageView addSubview:_picoSticker];
	//
//	[UIView animateWithDuration:0.25 animations:^(void) {
//		_picoSticker.alpha = 1.0;
//		_imageLoadingView.alpha = 0.0;
//	} completion:^(BOOL finished) {
//		[_imageLoadingView removeFromSuperview];
//		_imageLoadingView = nil;
//	}];
	
//	
//	UIImageView *emojiImageView = [[UIImageView alloc] initWithFrame:CGRectInset((_isLarge) ? kLargeNormalFrame : kNormalFrame, 5.0, 5.0)];
//	emojiImageView.alpha = 0.0;
//	[_imageView addSubview:emojiImageView];
//	
//	void (^imageSuccessBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//		emojiImageView.image = image;
//		
//		[UIView animateWithDuration:0.25 animations:^(void) {
//			emojiImageView.alpha = 1.0;
//			_imageLoadingView.alpha = 0.0;
//		} completion:nil];
//	};
//	
//	void (^imageFailureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
//		_imageLoadingView.alpha = 0.0;
//	};
//	
//	[emojiImageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:_emotionVO.largeImageURL]
//															cachePolicy:NSURLRequestReturnCacheDataElseLoad
//														timeoutInterval:[HONAppDelegate timeoutInterval]]
//						  placeholderImage:nil
//								   success:imageSuccessBlock
//								   failure:imageFailureBlock];
}


@end
