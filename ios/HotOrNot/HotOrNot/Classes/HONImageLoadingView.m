//
//  HONImageLoadingView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/13/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONImageLoadingView.h"


@interface HONImageLoadingView ()
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic) BOOL isLarge;
@end

const CGFloat kAnimationTime = 0.5f;

@implementation HONImageLoadingView

- (id)initInViewCenter:(UIView *)view asLargeLoader:(BOOL)isLarge {
	if ((self = [super initWithFrame:(isLarge) ? CGRectMake((view.frame.size.width - 150.0) * 0.5, (view.frame.size.height - 124.0) * 0.5, 150.0, 124.0) : CGRectMake((view.frame.size.width - 44.0) * 0.5, (view.frame.size.height - 44.0) * 0.5, 44.0, 44.0)])) {
		_isLarge = isLarge;
		
		[self _populateFrames];
		[self _goAnimate];
	}
	
	return (self);
}

- (id)initAtPos:(CGPoint)pos asLargeLoader:(BOOL)isLarge {
	if ((self = [super initWithFrame:(isLarge) ? CGRectMake(pos.x, pos.y, 150.0, 124.0) : CGRectMake(pos.x, pos.y, 44.0, 44.0)])) {
		_isLarge = isLarge;
		
		[self _populateFrames];
		[self _goAnimate];
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)startAnimating {
	if ([_animationImageView isAnimating])
		[_animationImageView stopAnimating];
	
	[self _goAnimate];
	
}

- (void)stopAnimating {
	[_animationImageView stopAnimating];
}


#pragma mark - UI Presentation
- (void)_populateFrames {
	CGRect frame = (_isLarge) ? CGRectMakeFromSize(CGSizeMake(150.0, 124.0)) : CGRectMakeFromSize(CGSizeMake(44.0, 44.0));
	_animationImageView = [[UIImageView alloc] initWithFrame:frame];
	_animationImageView.animationImages = @[[UIImage imageNamed:(_isLarge) ? @"loadDots_lg-01" : @"loadDots_sm-01"],
											[UIImage imageNamed:(_isLarge) ? @"loadDots_lg-02" : @"loadDots_sm-02"],
											[UIImage imageNamed:(_isLarge) ? @"loadDots_lg-03" : @"loadDots_sm-03"]];
	_animationImageView.animationDuration = kAnimationTime;
	_animationImageView.animationRepeatCount = 0;
	[self addSubview:_animationImageView];
}

- (void)_goAnimate {
	[_animationImageView startAnimating];
}

@end
