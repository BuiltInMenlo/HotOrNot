//
//  UIImage+HONSnapshot.h
//  HotOrNot
//
//  Created by Jesse Boley on 3/6/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIView (HONSnapshot)

- (UIImage *)blurRect:(CGRect)rect withRadius:(CGFloat)radius andSaturationBoost:(CGFloat)saturationBoost andOverlayColor:(UIColor *)color;

- (UIImage *)snapshotImage;
- (UIImage *)snapshotImageWithMargin:(CGFloat)marginSize afterScreenUpdates:(BOOL)afterUpdates;

@end
