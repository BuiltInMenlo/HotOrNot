//
//  HONImageLoadingView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 6/13/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

const NSInteger kTotalDots;
const CGFloat kDotDimensions;
const CGFloat kDotSpacing;
const CGFloat kAnimationTime;
const CGFloat kDelay;


@interface HONImageLoadingView : UIView
- (id)initInViewCenter:(UIView *)view;
- (id)initAtPos:(CGPoint)pos;

- (void)startAnimating;
- (void)stopAnimating;
@end
