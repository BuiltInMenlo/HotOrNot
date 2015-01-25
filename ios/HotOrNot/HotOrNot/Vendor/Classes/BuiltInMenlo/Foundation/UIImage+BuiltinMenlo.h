#import <UIKit/UIKit.h>

/**
        UIImage (AnimatedGIF)
        
    This category adds class methods to `UIImage` to create an animated `UIImage` from an animated GIF.
*/
@interface UIImage (AnimatedGIF)

/*
        UIImage *animation = [UIImage animatedImageWithAnimatedGIFData:theData];
    
    I interpret `theData` as a GIF.  I create an animated `UIImage` using the source images in the GIF.
    
    The GIF stores a separate duration for each frame, in units of centiseconds (hundredths of a second).  However, a `UIImage` only has a single, total `duration` property, which is a floating-point number.
    
    To handle this mismatch, I add each source image (from the GIF) to `animation` a varying number of times to match the ratios between the frame durations in the GIF.
    
    For example, suppose the GIF contains three frames.  Frame 0 has duration 3.  Frame 1 has duration 9.  Frame 2 has duration 15.  I divide each duration by the greatest common denominator of all the durations, which is 3, and add each frame the resulting number of times.  Thus `animation` will contain frame 0 3/3 = 1 time, then frame 1 9/3 = 3 times, then frame 2 15/3 = 5 times.  I set `animation.duration` to (3+9+15)/100 = 0.27 seconds.
*/
+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)theData;

/*
        UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:theURL];
    
    I interpret the contents of `theURL` as a GIF.  I create an animated `UIImage` using the source images in the GIF.
    
    I operate exactly like `+[UIImage animatedImageWithAnimatedGIFData:]`, except that I read the data from `theURL`.  If `theURL` is not a `file:` URL, you probably want to call me on a background thread or GCD queue to avoid blocking the main thread.
*/
+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)theURL;

@end
#import "UIImage+AnimatedGIF.h"
#import <ImageIO/ImageIO.h>

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif

@implementation UIImage (AnimatedGIF)

static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i) {
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gifProperties) {
            NSNumber *number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (number == NULL || [number doubleValue] == 0) {
                number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            }
            if ([number doubleValue] > 0) {
                // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
                delayCentiseconds = (int)lrint([number doubleValue] * 100);
            }
        }
        CFRelease(properties);
    }
    return delayCentiseconds;
}

static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count]) {
    for (size_t i = 0; i < count; ++i) {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
    }
}

static int sum(size_t const count, int const *const values) {
    int theSum = 0;
    for (size_t i = 0; i < count; ++i) {
        theSum += values[i];
    }
    return theSum;
}

static int pairGCD(int a, int b) {
    if (a < b)
        return pairGCD(b, a);
    while (true) {
        int const r = a % b;
        if (r == 0)
            return b;
        a = b;
        b = r;
    }
}

static int vectorGCD(size_t const count, int const *const values) {
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i) {
        // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
        gcd = pairGCD(values[i], gcd);
    }
    return gcd;
}

static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds) {
    int const gcd = vectorGCD(count, delayCentiseconds);
    size_t const frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i) {
        UIImage *const frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
            frames[f++] = frame;
        }
    }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

static void releaseImages(size_t const count, CGImageRef const images[count]) {
    for (size_t i = 0; i < count; ++i) {
        CGImageRelease(images[i]);
    }
}

static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source) {
    size_t const count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    createImagesAndDelays(source, count, images, delayCentiseconds);
    int const totalDurationCentiseconds = sum(count, delayCentiseconds);
    NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    releaseImages(count, images);
    return animation;
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef CF_RELEASES_ARGUMENT source) {
    if (source) {
        UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL));
}

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
//	return animatedImageWithAnimatedGIFImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
}

@end
/*
	 File: UIImage+ImageEffects.h
 Abstract: This is a category of UIImage that adds methods to apply blur and tint effects to an image. This is the code you’ll want to look out to find out how to use vImage to efficiently calculate a blur.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import <UIKit/UIKit.h>
//@import UIKit;

@interface UIImage (ImageEffects)

- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;

- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;

@end
/*
	 File: UIImage+ImageEffects.m
 Abstract: This is a category of UIImage that adds methods to apply blur and tint effects to an image. This is the code you’ll want to look out to find out how to use vImage to efficiently calculate a blur.
  Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2013 Apple Inc. All Rights Reserved.
 
 
 Copyright © 2013 Apple Inc. All rights reserved.
 WWDC 2013 License
 
 NOTE: This Apple Software was supplied by Apple as part of a WWDC 2013
 Session. Please refer to the applicable WWDC 2013 Session for further
 information.
 
 IMPORTANT: This Apple software is supplied to you by Apple Inc.
 ("Apple") in consideration of your agreement to the following terms, and
 your use, installation, modification or redistribution of this Apple
 software constitutes acceptance of these terms. If you do not agree with
 these terms, please do not use, install, modify or redistribute this
 Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a non-exclusive license, under
 Apple's copyrights in this original Apple software (the "Apple
 Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple. Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis. APPLE MAKES
 NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION THE
 IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 EA1002
 5/3/2013
 */

#import "UIImage+ImageEffects.h"

#import <Accelerate/Accelerate.h>
//@import Accelerate;
#import <float.h>


@implementation UIImage (ImageEffects)


- (UIImage *)applyLightEffect
{
	UIColor *tintColor = [UIColor colorWithWhite:1.0 alpha:0.3];
	return [self applyBlurWithRadius:30 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyExtraLightEffect
{
	UIColor *tintColor = [UIColor colorWithWhite:0.97 alpha:0.82];
	return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyDarkEffect
{
	UIColor *tintColor = [UIColor colorWithWhite:0.11 alpha:0.73];
	return [self applyBlurWithRadius:20 tintColor:tintColor saturationDeltaFactor:1.8 maskImage:nil];
}


- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor
{
	const CGFloat EffectColorAlpha = 0.6;
	UIColor *effectColor = tintColor;
	int componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
	if (componentCount == 2) {
		CGFloat b;
		if ([tintColor getWhite:&b alpha:NULL]) {
			effectColor = [UIColor colorWithWhite:b alpha:EffectColorAlpha];
		}
	}
	else {
		CGFloat r, g, b;
		if ([tintColor getRed:&r green:&g blue:&b alpha:NULL]) {
			effectColor = [UIColor colorWithRed:r green:g blue:b alpha:EffectColorAlpha];
		}
	}
	return [self applyBlurWithRadius:10 tintColor:effectColor saturationDeltaFactor:-1.0 maskImage:nil];
}


- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage
{
	// Check pre-conditions.
	if (self.size.width < 1 || self.size.height < 1) {
		NSLog (@"*** error: invalid size: (%.2f x %.2f). Both dimensions must be >= 1: %@", self.size.width, self.size.height, self);
		return nil;
	}
	if (!self.CGImage) {
		NSLog (@"*** error: image must be backed by a CGImage: %@", self);
		return nil;
	}
	if (maskImage && !maskImage.CGImage) {
		NSLog (@"*** error: maskImage must be backed by a CGImage: %@", maskImage);
		return nil;
	}

	CGRect imageRect = { CGPointZero, self.size };
	UIImage *effectImage = self;
	
	BOOL hasBlur = blurRadius > __FLT_EPSILON__;
	BOOL hasSaturationChange = fabs(saturationDeltaFactor - 1.) > __FLT_EPSILON__;
	if (hasBlur || hasSaturationChange) {
		UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
		CGContextRef effectInContext = UIGraphicsGetCurrentContext();
		CGContextScaleCTM(effectInContext, 1.0, -1.0);
		CGContextTranslateCTM(effectInContext, 0, -self.size.height);
		CGContextDrawImage(effectInContext, imageRect, self.CGImage);

		vImage_Buffer effectInBuffer;
		effectInBuffer.data	 = CGBitmapContextGetData(effectInContext);
		effectInBuffer.width	= CGBitmapContextGetWidth(effectInContext);
		effectInBuffer.height   = CGBitmapContextGetHeight(effectInContext);
		effectInBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectInContext);
	
		UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
		CGContextRef effectOutContext = UIGraphicsGetCurrentContext();
		vImage_Buffer effectOutBuffer;
		effectOutBuffer.data	 = CGBitmapContextGetData(effectOutContext);
		effectOutBuffer.width	= CGBitmapContextGetWidth(effectOutContext);
		effectOutBuffer.height   = CGBitmapContextGetHeight(effectOutContext);
		effectOutBuffer.rowBytes = CGBitmapContextGetBytesPerRow(effectOutContext);

		if (hasBlur) {
			// A description of how to compute the box kernel width from the Gaussian
			// radius (aka standard deviation) appears in the SVG spec:
			// http://www.w3.org/TR/SVG/filters.html#feGaussianBlurElement
			// 
			// For larger values of 's' (s >= 2.0), an approximation can be used: Three
			// successive box-blurs build a piece-wise quadratic convolution kernel, which
			// approximates the Gaussian kernel to within roughly 3%.
			//
			// let d = floor(s * 3*sqrt(2*pi)/4 + 0.5)
			// 
			// ... if d is odd, use three box-blurs of size 'd', centered on the output pixel.
			// 
			CGFloat inputRadius = blurRadius * [[UIScreen mainScreen] scale];
			NSUInteger radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
			if (radius % 2 != 1) {
				radius += 1; // force radius to be odd so that the three box-blur methodology works.
			}
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectOutBuffer, &effectInBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
			vImageBoxConvolve_ARGB8888(&effectInBuffer, &effectOutBuffer, NULL, 0, 0, radius, radius, 0, kvImageEdgeExtend);
		}
		BOOL effectImageBuffersAreSwapped = NO;
		if (hasSaturationChange) {
			CGFloat s = saturationDeltaFactor;
			CGFloat floatingPointSaturationMatrix[] = {
				0.0722 + 0.9278 * s,  0.0722 - 0.0722 * s,  0.0722 - 0.0722 * s,  0,
				0.7152 - 0.7152 * s,  0.7152 + 0.2848 * s,  0.7152 - 0.7152 * s,  0,
				0.2126 - 0.2126 * s,  0.2126 - 0.2126 * s,  0.2126 + 0.7873 * s,  0,
								  0,					0,					0,  1,
			};
			const int32_t divisor = 256;
			NSUInteger matrixSize = sizeof(floatingPointSaturationMatrix)/sizeof(floatingPointSaturationMatrix[0]);
			int16_t saturationMatrix[matrixSize];
			for (NSUInteger i = 0; i < matrixSize; ++i) {
				saturationMatrix[i] = (int16_t)roundf(floatingPointSaturationMatrix[i] * divisor);
			}
			if (hasBlur) {
				vImageMatrixMultiply_ARGB8888(&effectOutBuffer, &effectInBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
				effectImageBuffersAreSwapped = YES;
			}
			else {
				vImageMatrixMultiply_ARGB8888(&effectInBuffer, &effectOutBuffer, saturationMatrix, divisor, NULL, NULL, kvImageNoFlags);
			}
		}
		if (!effectImageBuffersAreSwapped)
			effectImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		if (effectImageBuffersAreSwapped)
			effectImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
	}

	// Set up output context.
	UIGraphicsBeginImageContextWithOptions(self.size, NO, [[UIScreen mainScreen] scale]);
	CGContextRef outputContext = UIGraphicsGetCurrentContext();
	CGContextScaleCTM(outputContext, 1.0, -1.0);
	CGContextTranslateCTM(outputContext, 0, -self.size.height);

	// Draw base image.
	CGContextDrawImage(outputContext, imageRect, self.CGImage);

	// Draw effect image.
	if (hasBlur) {
		CGContextSaveGState(outputContext);
		if (maskImage) {
			CGContextClipToMask(outputContext, imageRect, maskImage.CGImage);
		}
		CGContextDrawImage(outputContext, imageRect, effectImage.CGImage);
		CGContextRestoreGState(outputContext);
	}

	// Add in color tint.
	if (tintColor) {
		CGContextSaveGState(outputContext);
		CGContextSetFillColorWithColor(outputContext, tintColor.CGColor);
		CGContextFillRect(outputContext, imageRect);
		CGContextRestoreGState(outputContext);
	}

	// Output image is ready.
	UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	return outputImage;
}


@end
/*
 * Copyright (c) 2011 b2cloud
 * By Will Sackfield
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for specific language governing permissions and
 * limitations under the License.
 *
 * File: UIImage+Pixels.h
 *
 * 1.0 (23/08/2011)
 */
#import <UIKit/UIKit.h>

@interface UIImage (Pixels)
-(unsigned char*) grayscalePixels;
-(unsigned char*) rgbaPixels;
@end
/*
 * Copyright (c) 2011 b2cloud
 * By Will Sackfield
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for specific language governing permissions and
 * limitations under the License.
 *
 * File: UIImage+Pixels.m
 *
 * 1.0 (23/08/2011)
 */
#import "UIImage+Pixels.h"

@implementation UIImage (Pixels)
-(unsigned char*) grayscalePixels
{
	// The amount of bits per pixel, in this case we are doing grayscale so 1 byte = 8 bits
	#define BITS_PER_PIXEL 8
	// The amount of bits per component, in this it is the same as the bitsPerPixel because only 1 byte represents a pixel
	#define BITS_PER_COMPONENT (BITS_PER_PIXEL)
	// The amount of bytes per pixel, not really sure why it asks for this as well but it's basically the bitsPerPixel divided by the bits per component (making 1 in this case)
	#define BYTES_PER_PIXEL (BITS_PER_PIXEL/BITS_PER_COMPONENT)
	
	// Define the colour space (in this case it's gray)
	CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceGray();
	
	// Find out the number of bytes per row (it's just the width times the number of bytes per pixel)
	size_t bytesPerRow = self.size.width * BYTES_PER_PIXEL;
	// Allocate the appropriate amount of memory to hold the bitmap context
	unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*self.size.height);
	
	// Create the bitmap context, we set the alpha to none here to tell the bitmap we don't care about alpha values
//	CGContextRef context = CGBitmapContextCreate(bitmapData,self.size.width,self.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,kCGImageAlphaNone);
	CGContextRef context = CGBitmapContextCreate(bitmapData,self.size.width,self.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,(CGBitmapInfo)kCGImageAlphaNone);
	
	// We are done with the colour space now so no point in keeping it around
	CGColorSpaceRelease(colourSpace);
	
	// Create a CGRect to define the amount of pixels we want
	CGRect rect = CGRectMake(0.0,0.0,self.size.width,self.size.height);
	// Draw the bitmap context using the rectangle we just created as a bounds and the Core Graphics Image as the image source
	CGContextDrawImage(context,rect,self.CGImage);
	// Obtain the pixel data from the bitmap context
	unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
	
	// Release the bitmap context because we are done using it
	CGContextRelease(context);
	
	// Test script
	/*
	for(int i=0;i<self.size.height;i++)
	{
		for(int y=0;y<self.size.width;y++)
		{
			NSLog(@"0x%X",pixelData[(i*((int)self.size.width))+y]);
		}
	}
	 */
	
	return pixelData;
	#undef BITS_PER_PIXEL
	#undef BITS_PER_COMPONENT
}

-(unsigned char*) rgbaPixels
{
	// The amount of bits per pixel, in this case we are doing RGBA so 4 byte = 32 bits
	#define BITS_PER_PIXEL 32
	// The amount of bits per component, in this it is the same as the bitsPerPixel divided by 4 because each component (such as Red) is only 8 bits
	#define BITS_PER_COMPONENT (BITS_PER_PIXEL/4)
	// The amount of bytes per pixel, in this case a pixel is made up of Red, Green, Blue and Alpha so it will be 4
	#define BYTES_PER_PIXEL (BITS_PER_PIXEL/BITS_PER_COMPONENT)
	
	// Define the colour space (in this case it's gray)
	CGColorSpaceRef colourSpace = CGColorSpaceCreateDeviceRGB();
	
	// Find out the number of bytes per row (it's just the width times the number of bytes per pixel)
	size_t bytesPerRow = self.size.width * BYTES_PER_PIXEL;
	// Allocate the appropriate amount of memory to hold the bitmap context
	unsigned char* bitmapData = (unsigned char*) malloc(bytesPerRow*self.size.height);
	
	// Create the bitmap context, we set the alpha to none here to tell the bitmap we don't care about alpha values
	CGContextRef context = CGBitmapContextCreate(bitmapData,self.size.width,self.size.height,BITS_PER_COMPONENT,bytesPerRow,colourSpace,kCGImageAlphaPremultipliedLast|kCGBitmapByteOrder32Big);
	
	// We are done with the colour space now so no point in keeping it around
	CGColorSpaceRelease(colourSpace);
	
	// Create a CGRect to define the amount of pixels we want
	CGRect rect = CGRectMake(0.0,0.0,self.size.width,self.size.height);
	// Draw the bitmap context using the rectangle we just created as a bounds and the Core Graphics Image as the image source
	CGContextDrawImage(context,rect,self.CGImage);
	// Obtain the pixel data from the bitmap context
	unsigned char* pixelData = (unsigned char*)CGBitmapContextGetData(context);
	
	// Release the bitmap context because we are done using it
	CGContextRelease(context);
	
	// Test script
	/*
	for(int i=0;i<self.size.height;i++)
	{
		for(int y=0;y<self.size.width;y++)
		{
			unsigned char r = pixelData[(i*((int)self.size.width)*4)+(y*4)];
			unsigned char g = pixelData[(i*((int)self.size.width)*4)+(y*4)+1];
			unsigned char b = pixelData[(i*((int)self.size.width)*4)+(y*4)+2];
			unsigned char a = pixelData[(i*((int)self.size.width)*4)+(y*4)+3];
			NSLog(@"r = 0x%X g = 0x%X b = 0x%X a = 0x%X",r,g,b,a);
		}
	}
	 */
	
	return pixelData;
	#undef BITS_PER_PIXEL
	#undef BITS_PER_COMPONENT
}
@end
//
//  UIImage+Transmute.h
//  HotOrNot
//
//  Created by BIM  on 11/25/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface UIImage (Transmute)
- (UIImage *)imageWithMosaic:(CGFloat)scale;
- (UIImage *)mirrorImage;
@end

//@interface UIImage ()
//@property UIImage *mirrorImage;
//@end
//
//  UIImage+Transmute.m
//  HotOrNot
//
//  Created by BIM  on 11/25/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "UIImage+Transmute.h"

@implementation UIImage (Transmute)

- (UIImage *)mirrorImage {
	return ([UIImage imageWithCGImage:self.CGImage
								scale:self.scale
						  orientation:(self.imageOrientation + UIImageOrientationUpMirrored) % 8]);
}

- (UIImage *)imageWithMosaic:(CGFloat)scale {
	
	CIFilter *filter = [CIFilter filterWithName:@"CIPixellate"];
	[filter setValue:[CIImage imageWithCGImage:self.CGImage] forKey:kCIInputImageKey];
	[filter setValue:@(scale) forKey:kCIInputScaleKey];
	
	CIImage *filterOutputImage = filter.outputImage;
	CIContext *ctx = [CIContext contextWithOptions:nil];
	
	return ([[UIImage alloc] initWithCGImage:[ctx createCGImage:filterOutputImage fromRect:filterOutputImage.extent]
									   scale:self.scale
								 orientation:self.imageOrientation]);

}

@end
//
//  UIImage+fixOrientation.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.20.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

@interface UIImage (fixOrientation)
- (UIImage *)fixOrientation;
@end
//
//  UIImage+fixOrientation.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.20.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "UIImage+fixOrientation.h"

@implementation UIImage (fixOrientation)

- (UIImage *)fixOrientation {
//	NSLog(@"PRE-ORIENTATION:[%@]", NSStringFromUIImageOrientation(self.imageOrientation));
	
	// No-op if the orientation is already correct
	if (self.imageOrientation == UIImageOrientationUp) return self;
	
	// We need to calculate the proper transformation to make the image upright.
	// We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
	CGAffineTransform transform = CGAffineTransformIdentity;
	
	switch (self.imageOrientation) {
		case UIImageOrientationDown:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
			transform = CGAffineTransformRotate(transform, M_PI);
			break;
			
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, 0);
			transform = CGAffineTransformRotate(transform, M_PI_2);
			break;
			
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, 0, self.size.height);
			transform = CGAffineTransformRotate(transform, -M_PI_2);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationUpMirrored:
			break;
	}
	
	switch (self.imageOrientation) {
		case UIImageOrientationUpMirrored:
		case UIImageOrientationDownMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.width, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
			
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRightMirrored:
			transform = CGAffineTransformTranslate(transform, self.size.height, 0);
			transform = CGAffineTransformScale(transform, -1, 1);
			break;
		case UIImageOrientationUp:
		case UIImageOrientationDown:
		case UIImageOrientationLeft:
		case UIImageOrientationRight:
			break;
	}
	
	// Now we draw the underlying CGImage into a new context, applying the transform
	// calculated above.
	CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
														  CGImageGetBitsPerComponent(self.CGImage), 0,
														  CGImageGetColorSpace(self.CGImage),
														  CGImageGetBitmapInfo(self.CGImage));
	CGContextConcatCTM(ctx, transform);
	switch (self.imageOrientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			// Grr...
			CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
			break;
			
		default:
			CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
			break;
	}
	
	// And now we just create a new UIImage from the drawing context
	CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
	UIImage *img = [UIImage imageWithCGImage:cgimg scale:1.0 orientation:UIImageOrientationUp];
	CGContextRelease(ctx);
	CGImageRelease(cgimg);
	return img;
}

@end