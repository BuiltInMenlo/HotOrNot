//
//  HONImageLoadingView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/13/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONImageLoadingView.h"

const CGFloat kDotDimensions = 24.0f;

@interface HONImageLoadingView ()
@property (nonatomic, strong) UIImageView *animationImageView;
@end

@implementation HONImageLoadingView

- (id)initAtPos:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, kDotDimensions, kDotDimensions)])) {
		_animationImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, kDotDimensions, kDotDimensions)];
		_animationImageView.animationImages = [NSArray arrayWithObjects:[UIImage imageNamed:@"loadingDot_01"],
											   [UIImage imageNamed:@"loadingDot_02"],
											   [UIImage imageNamed:@"loadingDot_03"], nil];
		_animationImageView.animationDuration = 0.5f;
		_animationImageView.animationRepeatCount = 0;
		[self addSubview:_animationImageView];
		
		[self _goAnimate];
	}
	
	return (self);
}


#pragma mark - public functions
- (void)startAnimating {
	if ([_animationImageView isAnimating])
		[_animationImageView stopAnimating];
	
	[self _goAnimate];
	
}

- (void)stopAnimating {
	[_animationImageView stopAnimating];
}


#pragma mark - UI Presentation
- (void)_goAnimate {
	[_animationImageView startAnimating];
}

@end
