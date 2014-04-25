//
//  JLBAnimator.h
//  JLBAnimator
//
//  Created by Jesse Boley on 11/12/13.
//  Copyright (c) 2013 Jesse Boley. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JLBAnimation.h"

@interface JLBAnimator : NSObject
- (void)addAnimation:(JLBAnimation *)animation withKey:(NSString *)key toView:(UIView *)view;
- (void)removeAnimationWithKey:(NSString *)key fromView:(UIView *)view;

// Updates all animations to the specified time
- (void)updateAnimationTime:(NSTimeInterval)time;

// Runs the animation between the specified times over duration. This operation is aborted if there's a call to -updateAnimationTime.
- (void)runFromTime:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime withDuration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion;

// Similar to the above method but runs from the last animation time to the specified time.
- (void)runToTime:(NSTimeInterval)time withDuration:(NSTimeInterval)duration completion:(void(^)(BOOL finished))completion;

// Removes all animations
- (void)removeAllAnimations;

// Returns the animator's current time
- (NSTimeInterval)currentTime;
@end
