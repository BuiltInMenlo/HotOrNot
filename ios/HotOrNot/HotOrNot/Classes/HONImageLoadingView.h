//
//  HONImageLoadingView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 6/13/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


const CGFloat kAnimationTime;

@interface HONImageLoadingView : UIView
- (id)initInViewCenter:(UIView *)view asLargeLoader:(BOOL)isLarge;
- (id)initAtPos:(CGPoint)pos asLargeLoader:(BOOL)isLarge;

- (void)startAnimating;
- (void)stopAnimating;
@end
