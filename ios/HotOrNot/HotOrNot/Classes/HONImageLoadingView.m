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
@end

@implementation HONImageLoadingView

- (id)initInViewCenter:(UIView *)view {
	if ((self = [super initWithFrame:CGRectMake((view.frame.size.width - 44.0) * 0.5, (view.frame.size.height - 44.0) * 0.5, 44.0, 44.0)])) {
		[self _populateFrames];
		[self _goAnimate];
	}
	
	return (self);
}

- (id)initAtPos:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, 44.0, 44.0)])) {
		[self _populateFrames];
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
- (void)_populateFrames {
	_animationImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 44.0, 44.0)];
	_animationImageView.animationImages = @[[UIImage imageNamed:@"imageLoader_001"],
										   [UIImage imageNamed:@"imageLoader_002"],
										   [UIImage imageNamed:@"imageLoader_003"]];
	_animationImageView.animationDuration = 0.5f;
	_animationImageView.animationRepeatCount = 0;
	[self addSubview:_animationImageView];
}

- (void)_goAnimate {
	[_animationImageView startAnimating];
}

@end
