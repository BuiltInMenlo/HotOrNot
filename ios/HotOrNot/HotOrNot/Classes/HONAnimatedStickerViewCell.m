//
//  HONAnimatedStickerViewCell.m
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"
#import "UIImageView+AFNetworking.h"

#import "FLAnimatedImage.h"
#import "FLAnimatedImageView.h"

#import "HONAnimatedStickerViewCell.h"
#import "HONImageLoadingView.h"

@interface HONAnimatedStickerViewCell ()
@property (nonatomic, strong) HONImageLoadingView *imageLoadingView;
@property (nonatomic, strong) FLAnimatedImageView *animatedImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONAnimatedStickerViewCell
@synthesize  delegate = _delegate;
@synthesize emotionVO = _emotionVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		_imageLoadingView = [[HONImageLoadingView alloc] initAtPos:CGPointZero asLargeLoader:NO];
		_imageLoadingView.frame = CGRectMake(17.0, 17.0, 42.0, 44.0);
		_imageLoadingView.alpha = 0.75;
		[self.contentView addSubview:_imageLoadingView];
		
		_animatedImageView = [[FLAnimatedImageView alloc] init];
		_animatedImageView.contentMode = UIViewContentModeScaleAspectFit; // centers in frame
		_animatedImageView.clipsToBounds = YES;
		_animatedImageView.alpha = 0.5;
		_animatedImageView.frame = CGRectMake(17.0, 11.0, 50.0, 50.0);
		[self.contentView addSubview:_animatedImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(81.0, 13.0, 230.0, 26.0)];
		_titleLabel.backgroundColor = [[HONColorAuthority sharedInstance] honDebugDefaultColor];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:18];
		_titleLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:_titleLabel];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setEmotionVO:(HONEmotionVO *)emotionVO {
	_emotionVO = emotionVO;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		NSURL *url = [NSURL URLWithString:emotionVO.smallImageURL];
		FLAnimatedImage *animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfURL:url]];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			_animatedImageView.animatedImage = animatedImage;
			
			[UIView animateWithDuration:0.125 delay:0.000 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut) animations:^(void) {
				_animatedImageView.alpha = 1.0;
				
			} completion:^(BOOL finished) {
				_imageLoadingView.hidden = YES;
				[_imageLoadingView stopAnimating];
			}];
		});
	});
	
	_titleLabel.text = _emotionVO.emotionName;
}


@end
