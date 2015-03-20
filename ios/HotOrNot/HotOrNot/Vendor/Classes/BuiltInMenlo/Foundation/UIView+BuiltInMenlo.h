//
//  UIView+BuiltInMenlo.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/20/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface UIView (BuiltInMenlo)
+ (instancetype)viewAtSize:(CGSize)size;
+ (instancetype)viewAtSize:(CGSize)size withBGColor:(UIColor *)bgColor;

- (id)initAtSize:(CGSize)size;
- (id)initAtSize:(CGSize)size withBGColor:(UIColor *)bgColor;

- (UIImage *)createImageFromView;
- (void)reverseSubviews;

- (void)centerAlignWithinParentView;
- (void)centerHorizontalAlignWithinParentView;
- (void)centerVerticalAlignWithinParentView;

- (void)centerAlignWithRect:(CGRect)rect;
- (void)centerHorizontalAlignWithRect:(CGRect)rect;
- (void)centerVerticalAlignWithRect:(CGRect)rect;


@property (nonatomic, readonly) UIEdgeInsets frameEdges;
@end
