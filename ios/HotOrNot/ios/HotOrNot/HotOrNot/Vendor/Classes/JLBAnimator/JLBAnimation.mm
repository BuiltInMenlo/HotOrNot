//
//  JLBAnimation.m
//  JLBAnimator
//
//  Created by Jesse Boley on 11/12/13.
//  Copyright (c) 2013 Jesse Boley. All rights reserved.
//

#import "JLBAnimation.h"

inline float jlbClampf(float val, float low, float high) { return val < low ? low : (val > high ? high : val); }
inline float jlbSmooth(float t)
{
	return ((t) * (t) * (3.0f - 2.0f * (t)));
}

double const jlbEpsilon = 0.00001;

@implementation JLBAnimation
{
	NSInteger _duration;
	NSMutableArray *_keyFrames;
}

+ (instancetype)animationWithKeyPath:(NSString *)keyPath
{
	NSParameterAssert(keyPath != nil);
	
	JLBAnimation *animation = [[JLBAnimation alloc] init];
	animation.keyPath = keyPath;
	return animation;
}

- (id)init
{
	if ((self = [super init])) {
		_keyFrames = [NSMutableArray new];
	}
	return self;
}

- (NSTimeInterval)duration
{
	return _duration;
}

- (void)applyValueForTime:(NSTimeInterval)time toView:(UIView *)view
{
	// Clamp the time value
	if (time <= (_startTime + jlbEpsilon)) {
		// Apply the first keyframe
		[self _applyKeyFrame:[_keyFrames firstObject] toView:view];
		return;
	}

	if (time >= (_endTime - jlbEpsilon)) {
		// Apply the last keyframe
		[self _applyKeyFrame:[_keyFrames lastObject] toView:view];
	}
	
	JLBAnimationKeyFrame *startKeyFrame = nil;
	JLBAnimationKeyFrame *finalKeyFrame = nil;
	for (JLBAnimationKeyFrame *keyFrame in _keyFrames) {
		NSTimeInterval keyFrameTime = keyFrame.time;
		if (fabs(time - keyFrameTime) < jlbEpsilon) {
			// Apply this keyframe directly
			[self _applyKeyFrame:keyFrame toView:view];
			return;
		}
		
		// Otherwise we need to scale between two keyframes
		if (time < keyFrame.time)
			finalKeyFrame = keyFrame;
		else if (time > keyFrame.time)
			startKeyFrame = keyFrame;

		if ((startKeyFrame != nil) && (finalKeyFrame != nil)) {
			[self _interpolateFrameForTime:time fromKeyFrame:startKeyFrame toKeyFrame:finalKeyFrame withView:view];
			return;
		}
	}
}

- (void)_applyKeyFrame:(JLBAnimationKeyFrame *)keyFrame toView:(UIView *)view
{
	[view setValue:keyFrame.value forKeyPath:_keyPath];
}

- (CGFloat)_interpolateValueForStartTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime startValue:(CGFloat)startValue endValue:(CGFloat)endValue atTime:(CGFloat)time curve:(JLBAnimationCurve)curve
{
	CGFloat dv = (endValue - startValue);
	CGFloat dt = endTime - startTime;
	CGFloat t = (time - startTime);
	CGFloat x = t / dt;
	
	switch (_curve) {
		case kJLBAnimationCurveEaseInOut:
			x = jlbSmooth(jlbClampf(x, 0.0, 1.0));
			break;
			
		case kJLBAnimationCurveEaseIn:
			x = x * x * x;
			break;
			
		case kJLBAnimationCurveEaseOut: {
			CGFloat inverse = 1.0 - x;
			x = 1.0 - (inverse * inverse * inverse);
			break;
		}
			
		case kJLBAnimationCurveLinear:
			break;
	}
	
	return dv * x + startValue;
}

- (void)_interpolateFrameForTime:(NSTimeInterval)time fromKeyFrame:(JLBAnimationKeyFrame *)fromKeyFrame toKeyFrame:(JLBAnimationKeyFrame *)toKeyFrame withView:(UIView *)view
{
	NSTimeInterval startTime = fromKeyFrame.time;
    NSTimeInterval endTime = toKeyFrame.time;
	NSValue *finalValue = nil;
	
	const char *valueType = [fromKeyFrame.value objCType];
	if (strcmp(valueType, @encode(CGRect)) == 0) {
		CGRect startFrame = [fromKeyFrame.value CGRectValue];
		CGRect endFrame = [toKeyFrame.value CGRectValue];
		CGRect frame = CGRectZero;
		frame.origin.x = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:CGRectGetMinX(startFrame) endValue:CGRectGetMinX(endFrame) atTime:time curve:_curve];
		frame.origin.y = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:CGRectGetMinY(startFrame) endValue:CGRectGetMinY(endFrame) atTime:time curve:_curve];
		frame.size.width = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:CGRectGetWidth(startFrame) endValue:CGRectGetWidth(endFrame) atTime:time curve:_curve];
		frame.size.height = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:CGRectGetHeight(startFrame) endValue:CGRectGetHeight(endFrame) atTime:time curve:_curve];
		finalValue = [NSValue valueWithCGRect:frame];
	}
	else if (strcmp(valueType, @encode(double)) == 0) {
		double start = [(NSNumber *)fromKeyFrame.value doubleValue];
		double end = [(NSNumber *)toKeyFrame.value doubleValue];
		double v = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start endValue:end atTime:time curve:_curve];
		finalValue = [NSNumber numberWithDouble:v];
	}
	else if (strcmp(valueType, @encode(float)) == 0) {
		float start = [(NSNumber *)fromKeyFrame.value floatValue];
		float end = [(NSNumber *)toKeyFrame.value floatValue];
		float v = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start endValue:end atTime:time curve:_curve];
		finalValue = [NSNumber numberWithFloat:v];
	}
	else if (strcmp(valueType, @encode(int)) == 0) {
		int start = [(NSNumber *)fromKeyFrame.value intValue];
		int end = [(NSNumber *)toKeyFrame.value intValue];
		int v = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start endValue:end atTime:time curve:_curve];
		finalValue = [NSNumber numberWithInt:v];
	}
	else if (strcmp(valueType, @encode(NSInteger)) == 0) {
		NSInteger start = [(NSNumber *)fromKeyFrame.value integerValue];
		NSInteger end = [(NSNumber *)toKeyFrame.value integerValue];
		NSInteger v = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start endValue:end atTime:time curve:_curve];
		finalValue = [NSNumber numberWithInteger:v];
	}
	else if (strcmp(valueType, @encode(CGAffineTransform)) == 0) {
		CGAffineTransform start = [(NSValue *)fromKeyFrame.value CGAffineTransformValue];
		CGAffineTransform end = [(NSValue *)toKeyFrame.value CGAffineTransformValue];
		CGFloat a = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start.a endValue:end.a atTime:time curve:_curve];
		CGFloat b = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start.b endValue:end.b atTime:time curve:_curve];
		CGFloat c = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start.c endValue:end.c atTime:time curve:_curve];
		CGFloat d = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start.d endValue:end.d atTime:time curve:_curve];
		CGFloat tx = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start.tx endValue:end.tx atTime:time curve:_curve];
		CGFloat ty = [self _interpolateValueForStartTime:startTime endTime:endTime startValue:start.ty endValue:end.ty atTime:time curve:_curve];
		finalValue = [NSValue valueWithCGAffineTransform:CGAffineTransformMake(a, b, c, d, tx, ty)];
	}
	else {
		NSAssert2(NO, @"Invalid value type %s for key frame animation %@", valueType, self);
	}
	
	[view setValue:finalValue forKeyPath:_keyPath];
}

- (void)addKeyFrame:(JLBAnimationKeyFrame *)keyFrame
{
	if (([_keyFrames count] == 0) || ([[_keyFrames lastObject] time] < keyFrame.time)) {
		[_keyFrames addObject:keyFrame];
	}
	else {
		// Insert the key frame at the correct index based on its time
		__block NSUInteger indexToInsert = 0;
		[_keyFrames enumerateObjectsUsingBlock:^(JLBAnimationKeyFrame *existingFrame, NSUInteger idx, BOOL *stop) {
			if (keyFrame.time > existingFrame.time) {
				indexToInsert = idx;
				*stop = YES;
			}
		}];
		[_keyFrames insertObject:keyFrame atIndex:indexToInsert];
	}
	
	_startTime = [[_keyFrames firstObject] time];
	_endTime = [[_keyFrames lastObject] time];
	_duration = _endTime - _startTime;
}

- (void)addKeyFrames:(NSArray *)keyFrames
{
	[keyFrames enumerateObjectsUsingBlock:^(JLBAnimationKeyFrame *keyFrame, NSUInteger idx, BOOL *stop) {
		[self addKeyFrame:keyFrame];
	}];
}

@end

@implementation JLBGroupAnimation

+ (instancetype)groupAnimationWithAnimations:(NSArray *)animations
{
	NSParameterAssert(animations != nil);
	
	JLBGroupAnimation *groupAnimation = [self new];
	groupAnimation.animations = animations;
	return groupAnimation;
}

- (void)applyValueForTime:(NSTimeInterval)time toView:(UIView *)view
{
	for (JLBAnimation *animation in _animations)
		[animation applyValueForTime:time toView:view];
}

@end

@implementation JLBAnimationKeyFrame

+ (instancetype)keyFrameWithTime:(NSTimeInterval)time value:(NSValue *)value
{
	JLBAnimationKeyFrame *keyFrame = [[self alloc] init];
	keyFrame.time = time;
	keyFrame.value = value;
	return keyFrame;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"[%.3f]: %@", _time, _value];
}

- (void)setValue:(NSValue *)value
{
	if (value != nil) {
		NSAssert1([value isKindOfClass:[NSValue class]], @"Attempting to animate property with value that isn't supported (%@). Only NSValue is supported.", value);
	}
	
	_value = value;
}

@end
