//
//  HONImagingDepictor.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONImagingDepictor : NSObject
+ (UIImage *)createImageFromView:(UIView *)view;
+ (UIImage *)createImageFromScreen;
+ (UIImage *)createBlurredScreenShot;

+ (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key;
+ (void)writeImageFromWeb:(NSString *)url withDimensions:(CGSize)size withUserDefaultsKey:(NSString *)key;

+ (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor;
+ (void)flipLayer:(CALayer *)layer horizontally:(BOOL)xAxisFlipped;

+ (double)totalLuminance:(UIImage *)image;

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;
+ (UIImage *)editImage:(UIImage *)image toSize:(CGSize)size thenCrop:(CGRect)rect;
+ (UIImage *)mirrorImage:(UIImage *)image;

+ (UIImage *)prepImageForSharing:(UIImage *)baseImage avatarImage:(UIImage *)avatar username:(NSString *)handle;

@end
