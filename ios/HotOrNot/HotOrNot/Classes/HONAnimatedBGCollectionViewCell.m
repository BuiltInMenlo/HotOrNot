//
//  HONAnimatedBGCollectionViewCell.m
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONAnimatedBGCollectionViewCell.h"
#import "HONImageLoadingView.h"

@interface HONAnimatedBGCollectionViewCell ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
//@property (nonatomic, strong) UILabel *label;
@end

@implementation HONAnimatedBGCollectionViewCell
@synthesize  delegate = _delegate;
@synthesize emotionVO = _emotionVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		_imageLoadingView = [[HONImageLoadingView alloc] initInViewCenter:self asLargeLoader:NO];
		_imageLoadingView.alpha = 0.75;
		[self.contentView addSubview:_imageLoadingView];
		
		_animatedImageView = [[FLAnimatedImageView alloc] init];
		_animatedImageView.frame = CGRectFromSize(self.frame.size);
		_animatedImageView.contentMode = UIViewContentModeScaleToFill; // stretches w/o ratio -- UIViewContentModeScaleAspectFit; // centers in frame
		_animatedImageView.clipsToBounds = YES;
		_animatedImageView.alpha = 0.5;
		[self.contentView addSubview:_animatedImageView];
		
//		_label = [[UILabel alloc] initWithFrame:CGRectMakeFromSize(CGSizeMake(100.0, 26.0))];
//		_label.backgroundColor = [UIColor clearColor];
//		_label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
//		_label.textColor = [UIColor blackColor];
//		[self.contentView addSubview:_label];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setEmotionVO:(HONEmotionVO *)emotionVO {
	_emotionVO = emotionVO;
	_emotionVO.imageType = HONEmotionImageTypeGIF;
	_emotionVO.smallImageURL = @"http://s3.amazonaws.com/hotornot-challenges/BigSmiley11.gif";
	_emotionVO.mediumImageURL = _emotionVO.smallImageURL;
	_emotionVO.largeImageURL = _emotionVO.smallImageURL;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURL *url = [NSURL URLWithString:_emotionVO.smallImageURL];
		FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_animatedImageView.animatedImage = animatedImage;
			
			FLAnimatedImageView *animatedImageView = [[FLAnimatedImageView alloc] init];
			animatedImageView.frame = [UIScreen mainScreen].bounds;
			animatedImageView.contentMode = UIViewContentModeScaleToFill; // stretches w/o ratio
			animatedImageView.clipsToBounds = YES;
			animatedImageView.animatedImage = animatedImage;
			_emotionVO.animatedImageView = animatedImageView;
			
			[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
				_animatedImageView.alpha = 1.0;
				
			} completion:^(BOOL finished) {
				_imageLoadingView.hidden = YES;
				[_imageLoadingView stopAnimating];
			}];
		});
	});
	
//	_label.text = _emotionVO.emotionName;
}


#pragma mark - Navigation
- (void)_goSelect {
	if ([self.delegate respondsToSelector:@selector(animatedBGCollectionViewCell:didSelectEmotion:)])
		[self.delegate animatedBGCollectionViewCell:self didSelectEmotion:_emotionVO];
}


@end
