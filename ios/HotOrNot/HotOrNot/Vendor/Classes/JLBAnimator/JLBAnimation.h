//
//  JLBAnimation.h
//  JLBAnimator
//
//  Created by Jesse Boley on 11/12/13.
//  Copyright (c) 2013 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

@class JLBAnimator;
@class JLBAnimationKeyFrame;

typedef NS_ENUM(NSUInteger, JLBAnimationCurve)
{
	kJLBAnimationCurveLinear = 0,
	kJLBAnimationCurveEaseInOut,
	kJLBAnimationCurveEaseIn,
	kJLBAnimationCurveEaseOut,
};

@interface JLBAnimation : NSObject
+ (instancetype)animationWithKeyPath:(NSString *)keyPath;
@property(nonatomic, strong) NSString *keyPath;

@property(nonatomic, readonly) NSTimeInterval startTime;
@property(nonatomic, readonly) NSTimeInterval endTime;
@property(nonatomic, readonly) NSTimeInterval duration;
@property(nonatomic) JLBAnimationCurve curve;

- (void)applyValueForTime:(NSTimeInterval)time toView:(UIView *)view;

// A 'key frame' maps a specific animatable property value to a time on the animation timeline.
- (void)addKeyFrame:(JLBAnimationKeyFrame *)keyFrame;
- (void)addKeyFrames:(NSArray *)keyFrames;
@end

@interface JLBGroupAnimation : JLBAnimation
+ (instancetype)groupAnimationWithAnimations:(NSArray *)animations;
@property(nonatomic, strong) NSArray *animations;
@end

@interface JLBAnimationKeyFrame : NSObject
+ (instancetype)keyFrameWithTime:(NSTimeInterval)time value:(NSValue *)value;
@property(nonatomic) NSTimeInterval time;
@property(nonatomic, strong) NSValue *value;
@end
