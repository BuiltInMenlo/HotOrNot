//
//  HONImageLoadingView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 6/13/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

const NSInteger kTotalDots;
const CGFloat kDotWidth;
const CGFloat kDotSpacing;
const CGFloat kAnimationTime;
const CGFloat kDelay;


@interface HONImageLoadingView : UIView
- (id)initAtPos:(CGPoint)pos;

- (void)startAnimating;
- (void)stopAnimating;
- (void)toggleAnimating:(BOOL)isAnimating;
@end
