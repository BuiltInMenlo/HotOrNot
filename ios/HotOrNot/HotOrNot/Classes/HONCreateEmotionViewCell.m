//
//  HONCameraSubjectViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONCreateEmotionViewCell.h"


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
		self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cameraRow"]];
		self.backgroundView.alpha = 0.90 + ((int)isEven * 0.10);
		
		_emotionVO = emotionVO;
		
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 9.0, 44.0, 44.0)];
		[imageView setImageWithURL:[NSURL URLWithString:_emotionVO.imageSmallURL] placeholderImage:nil];
		[self.contentView addSubview:imageView];
		
		UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 19.0, 200.0, 24.0)];
		label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:19];
		label.textColor = [HONAppDelegate honBlueTextColor];
		label.backgroundColor = [UIColor clearColor];
		label.text = _emotionVO.hastagName;
		[self.contentView addSubview:label];
		
		_priceImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"freeButton_nonActive"]];
		_priceImageView.frame = CGRectOffset(_priceImageView.frame, 245.0, 10.0);
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
