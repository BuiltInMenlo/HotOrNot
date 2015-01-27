//
//  UIView+Snapshot.m
//  HotOrNot
//
//  Created by Jesse Boley on 3/6/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImage+BuiltinMenlo.h"
#import "UIView+HONSnapshot.h"

@implementation UIView (HONSnapshot)

- (UIImage *)blurRect:(CGRect)rect withRadius:(CGFloat)radius andSaturationBoost:(CGFloat)saturationBoost andOverlayColor:(UIColor *)color
{
	UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0);
	[self drawViewHierarchyInRect:CGRectMake(-rect.origin.x, -rect.origin.y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) afterScreenUpdates:NO];

	UIImage *viewHierarchyImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	UIImage *blurredImage = [viewHierarchyImage applyBlurWithRadius:radius tintColor:color saturationDeltaFactor:(1.0 + saturationBoost) maskImage:nil];
	return blurredImage;
}

- (UIImage *)snapshotImage
{
	return [self snapshotImageWithMargin:0.0 afterScreenUpdates:YES];
}

- (UIImage *)snapshotImageWithMargin:(CGFloat)marginSize afterScreenUpdates:(BOOL)afterUpdates
{
	CGSize imageSize = CGSizeMake(self.bounds.size.width + marginSize * 2.0, self.bounds.size.height + marginSize * 2.0);
	UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0.0);
	if (marginSize > 0.0) {
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
		CGContextFillRect(context, CGRectMake(0, 0, imageSize.width, imageSize.height));
	}

	[self drawViewHierarchyInRect:CGRectMake(marginSize, marginSize, self.bounds.size.width, self.bounds.size.height) afterScreenUpdates:afterUpdates];
	UIImage *viewHierarchyImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return viewHierarchyImage;
}

@end
