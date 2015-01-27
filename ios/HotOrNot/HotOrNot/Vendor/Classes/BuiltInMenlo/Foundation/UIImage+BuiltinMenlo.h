//
//  NSDate+Operations.m.h
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface UIImage (BuiltInMenlo)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

- (UIImage *)imageWithMosaic:(CGFloat)scale;
- (UIImage *)mirrorImage;

- (UIImage *)fixOrientation;

-(unsigned char*) grayscalePixels;
-(unsigned char*) rgbaPixels;
@end