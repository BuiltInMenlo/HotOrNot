//
//  HONCameraSubjectViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONCreateEmotionViewCell.h"
#import "HONColorAuthority.h"
#import "HONFontAllocator.h"

@interface HONCreateEmotionViewCell()
@property (nonatomic, strong) HONEmotionVO *emotionVO;
@property (nonatomic, strong) UIImageView *priceImageView;
@end

@implementation HONCreateEmotionViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithEmotion:(HONEmotionVO *)emotionVO AsEvenRow:(BOOL)isEven {
	if ((self = [super init])) {
		//self.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5 + ((int)isEven * 0.15)];
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraRowBackground"]];
		
		_emotionVO = emotionVO;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(6.0, 14.0, 37.0, 37.0)];
		[self.contentView addSubview:imageView];
		
		void (^successBlock)(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) = ^void(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
			imageView.image = image;
		};
		
		void (^failureBlock)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) = ^void((NSURLRequest *request, NSHTTPURLResponse *response, NSError *error)) {
		};
		
		[imageView setImageWithURLRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:emotionVO.urlSmall] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:[HONAppDelegate timeoutInterval]]
						 placeholderImage:nil
								  success:successBlock
								  failure:failureBlock];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(49.0, 20.0, 200.0, 24.0)];
		label.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
		label.textColor = [[HONColorAuthority sharedInstance] honLightGreyTextColor];
		label.backgroundColor = [UIColor clearColor];
		label.text = _emotionVO.hastagName;
		[self.contentView addSubview:label];
		
		_priceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"freeButton_nonActive"]];
		_priceImageView.frame = CGRectOffset(_priceImageView.frame, 248.0, 10.0);
		[self addSubview:_priceImageView];
	}
	
	return (self);
}


#pragma mark - UI Presentation
- (void)showTapOverlay {
	_priceImageView.image = [UIImage imageNamed:@"freeButton_Active"];
	
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.67];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
		_priceImageView.image = [UIImage imageNamed:@"freeButton_nonActive"];
	}];
}

@end
