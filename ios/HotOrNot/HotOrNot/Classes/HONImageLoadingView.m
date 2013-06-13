//
//  HONImageLoadingView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 6/13/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONImageLoadingView.h"

const NSInteger kTotalDots = 3;

const CGFloat kDotWidth = 24.0f;
const CGFloat kDotSpacing = 4.0f;
const CGFloat kDelay = 0.125;
const CGFloat kAnimationTime = 0.33f;

@interface HONImageLoadingView ()
@property (nonatomic, strong) NSMutableArray *dots;
@property (nonatomic, strong) NSMutableArray *timers;

@property (nonatomic) CGFloat offset;
@property (nonatomic, strong) NSTimer *timer;
@end

@implementation HONImageLoadingView

- (id)initAtPos:(CGPoint)pos {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, kDotWidth, kDotWidth)])) {
		_dots = [NSMutableArray array];
		_offset = 0.0;
		
		NSArray *animationArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"loadingDot_01"],
								   [UIImage imageNamed:@"loadingDot_02"],
								   [UIImage imageNamed:@"loadingDot_03"], nil];
		
		UIImageView *animationView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		animationView.backgroundColor = [UIColor clearColor];
		animationView.animationImages = animationArray;
		animationView.animationDuration = 0.5f;
		animationView.animationRepeatCount = 0;
		[animationView startAnimating];
		[self addSubview:animationView];
		
//		for (int i=0; i<kTotalDots; i++) {
//			UIImageView *dot = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newSnapDot"]];
//			dot.frame = CGRectOffset(dot.frame, _offset, 0.0);
//			_offset += i * (kDotWidth + kDotSpacing);
//			
//			[self addSubview:dot];
//			[_dots addObject:dot];
//		}
//		
//		[self _resgisterTimers];
	}
	
	return (self);
}


#pragma mark - public functions
- (void)startAnimating {
	[self _resgisterTimers];
}

- (void)stopAnimating {
	[self _invalidateTimers];
}

- (void)toggleAnimating:(BOOL)isAnimating {
	if (isAnimating)
		[self _resgisterTimers];
		
	else
		[self _invalidateTimers];
}

#pragma mark - Animations
- (void)_resgisterTimers {
	[self _invalidateTimers];
	_timers = [NSMutableArray array];
	
	for (int i=0; i<kTotalDots; i++) {
		NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:kAnimationTime target:self selector:@selector(_goResetDotAtIndex:) userInfo:([NSNumber numberWithInt:i]) repeats:YES];
		
		[_timers addObject:timer];
	}
	
	//_timer = [NSTimer scheduledTimerWithTimeInterval:kAnimationTime target:self selector:@selector(_goRestart) userInfo:nil repeats:YES];
}

- (void)_invalidateTimers {
	for (int i=0; i<kTotalDots; i++) {
		NSTimer *timer = (NSTimer *)[_timers objectAtIndex:i];
		[_timers removeObjectAtIndex:i];
		
		if ([timer isValid] || timer != nil) {
			[timer invalidate];
			timer = nil;
		}
		
		[self _goResetDotAtIndex:[NSNumber numberWithInt:i]];
	}
}

- (void)_goResetDotAtIndex:(NSNumber *)index {
//	[UIView animateWithDuration:kAnimationTime delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^(void) {
//		dotImageView.frame = CGRectOffset(dotImageView.frame, self.frame.size.width, 0.0);
//	} completion:^(BOOL finished) {
//		dotImageView.frame = CGRectOffset(dotImageView.frame, index * (kDotWidth + kDotSpacing), 0.0);
//	}];
	
	UIImageView *dotImageView = (UIImageView *)[_dots objectAtIndex:[index intValue]];
	dotImageView.frame = CGRectOffset(dotImageView.frame, [index intValue] * (kDotWidth + kDotSpacing), 0.0);
}

- (void)_goStart {
	NSArray *animationArray = [NSArray arrayWithObjects:[UIImage imageNamed:@"images.jpg"],
							   [UIImage imageNamed:@"images1.jpg"],
							   [UIImage imageNamed:@"images5.jpg"],
							   [UIImage imageNamed:@"index3.jpg"], nil];
	
	UIImageView *animationView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0, 0.0, 80.0, kDotWidth)];
	animationView.backgroundColor = [UIColor purpleColor];
	animationView.animationImages = animationArray;
	animationView.animationDuration = 1.5;
	animationView.animationRepeatCount = 0;
	[animationView startAnimating];
	[self addSubview:animationView];
}


@end
