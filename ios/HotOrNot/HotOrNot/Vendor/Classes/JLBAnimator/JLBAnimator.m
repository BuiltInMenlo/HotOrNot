//
//  JLBAnimator.h
//  JLBAnimator
//
//  Created by Jesse Boley on 11/12/13.
//  Copyright (c) 2013 Jesse Boley. All rights reserved.
//

#import "JLBAnimator.h"

@interface _JLBDisplayLinkAnimator : NSObject
@property(nonatomic, strong, readonly) CADisplayLink *displayLink;
@property(nonatomic, copy, readonly) void (^completion)(BOOL finished);
@property(nonatomic, weak, readonly) JLBAnimator *animator;
@property(nonatomic, readonly) double duration;

@property(nonatomic, readonly) NSTimeInterval fromTime; // The starting time frame for the animation
@property(nonatomic, readonly) NSTimeInterval toTime; // The ending time frame for the animation

@property(nonatomic) NSTimeInterval lastTime; // The time of the keyframes at last rendering
@property(nonatomic, readonly) NSTimeInterval startingClock; // The time on the system clock at the beginning of the animation

- (id)initWithAnimator:(JLBAnimator *)animator duration:(NSTimeInterval)duration fromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime completion:(void(^)(BOOL finished))completion;
- (BOOL)isRunning;
- (void)cancel;
@end

@implementation JLBAnimator
{
	NSMapTable *_viewAnimations;
	NSTimeInterval _lastTime;
	_JLBDisplayLinkAnimator *_displayLinkAnimator;
}

- (id)init
{
	if ((self = [super init])) {
		_lastTime = HUGE_VALF;
	}
	return self;
}

- (void)dealloc
{
    [_displayLinkAnimator cancel];
}

- (NSTimeInterval)currentTime
{
	return _lastTime;
}

- (void)addAnimation:(JLBAnimation *)animation withKey:(NSString *)key toView:(UIView *)view
{
	NSParameterAssert(animation != nil);
	NSParameterAssert(key != nil);
	NSParameterAssert(view != nil);
	
	if (_viewAnimations == nil)
		_viewAnimations = [NSMapTable weakToStrongObjectsMapTable];
	
	NSMutableDictionary *animations = [_viewAnimations objectForKey:view];
	if (animations == nil) {
		animations = [NSMutableDictionary new];
		[_viewAnimations setObject:animations forKey:view];
	}
	[animations setObject:animation forKey:key];
}

- (void)removeAnimationWithKey:(NSString *)key fromView:(UIView *)view
{
	NSMutableDictionary *animations = [_viewAnimations objectForKey:view];
	[animations removeObjectForKey:key];
}

- (void)updateAnimationTime:(NSTimeInterval)time
{
	_displayLinkAnimator = nil; // cancel any current animator
	if (time != _lastTime)
		[self _internalUpdateAnimationTime:time];
}

- (void)_internalUpdateAnimationTime:(NSTimeInterval)time
{
	for (UIView *view in [_viewAnimations keyEnumerator]) {
		NSDictionary *animations = [_viewAnimations objectForKey:view];
		for (JLBAnimation *animation in [animations allValues])
			[animation applyValueForTime:time toView:view];
	}
	_lastTime = time;
}

- (void)runToTime:(NSTimeInterval)time withDuration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion
{
	if (_lastTime == HUGE_VALF)
		_lastTime = 0.0;
	
	[self runFromTime:_lastTime toTime:time withDuration:duration completion:completion];
}

- (void)runFromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime withDuration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion
{
	_displayLinkAnimator = nil; // cancel any current animator

	if (_lastTime == toTime) {
		completion(YES);
		return;
	}
	
	__weak JLBAnimator *weakSelf = self;
	_displayLinkAnimator = [[_JLBDisplayLinkAnimator alloc] initWithAnimator:self duration:duration fromTime:fromTime toTime:toTime completion:^(BOOL finished) {
		__strong JLBAnimator *strongSelf = weakSelf;
		strongSelf->_displayLinkAnimator = nil;
		completion(finished);
	}];
}

- (void)removeAllAnimations
{
	_displayLinkAnimator = nil;
	_viewAnimations = nil;
}

@end

@implementation _JLBDisplayLinkAnimator

- (id)initWithAnimator:(JLBAnimator *)animator duration:(NSTimeInterval)duration fromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime completion:(void(^)(BOOL finished))completion
{
	NSParameterAssert(fromTime != toTime);
	NSParameterAssert(duration > 0.0f);
	NSParameterAssert(animator != nil);
	
	if ((self = [super init])) {
		_animator = animator;
		_duration = duration;
		_fromTime = fromTime;
		_toTime = toTime;
		_lastTime = fromTime;
		_completion = completion;
		_displayLink = [[UIScreen mainScreen] displayLinkWithTarget:self selector:@selector(_updateAnimationFromDisplayLink)];
		_startingClock = CACurrentMediaTime();
		[_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
	return self;
}

- (void)dealloc
{
    [self cancel];
}

- (BOOL)isRunning
{
	return (_displayLink != nil);
}

- (void)_updateAnimationFromDisplayLink
{
	// New animation time = seconds since start / duration * total time change
	NSTimeInterval newTime = _fromTime + ((CACurrentMediaTime() - _startingClock) / _duration * (_toTime - _fromTime));

	// Don't go past toTime
	if (((_lastTime < _toTime) && (newTime > _toTime)) || ((_lastTime > _toTime) && (newTime < _toTime)))
		newTime = _toTime;
	[_animator _internalUpdateAnimationTime:newTime];
	_lastTime = newTime;


	if (newTime == _toTime) { // Finished!
		[_displayLink invalidate];
		_displayLink = nil;
		if (_completion != nil)
			_completion(YES);
	}
}

- (void)cancel
{
	if (_displayLink != nil) {
		[_displayLink invalidate];
		_displayLink = nil;
		if (_completion != nil)
			_completion(NO);
	}
}

@end
