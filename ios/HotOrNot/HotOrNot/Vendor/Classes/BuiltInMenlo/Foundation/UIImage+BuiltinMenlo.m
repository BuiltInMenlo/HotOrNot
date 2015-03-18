//
//  UIImage+Operations.m.h
//  HotOrNot
//
//  Created by BIM  on 11/4/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.

#import <Accelerate/Accelerate.h>
#import <float.h>

#import "UIImage+BuiltinMenlo.h"


@implementation UIImage (BuiltInMenlo)

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
	size_t componentCount = CGColorGetNumberOfComponents(tintColor.CGColor);
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
			uint32_t radius = floor(inputRadius * 3. * sqrt(2 * M_PI) / 4 + 0.5);
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

- (UIImage *) convertToGreyscale {
	int colors = ColorMaskGreen;
	int m_width = self.size.width;
	int m_height = self.size.height;
	
	uint32_t *rgbImage = (uint32_t *) malloc(m_width * m_height * sizeof(uint32_t));
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rgbImage, m_width, m_height, 8, m_width * 4, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
	CGContextSetShouldAntialias(context, NO);
	CGContextDrawImage(context, CGRectMake(0, 0, m_width, m_height), [self CGImage]);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	
	// now convert to grayscale
	uint8_t *m_imageData = (uint8_t *) malloc(m_width * m_height);
	for (int y=0; y<m_height; y++) {
		for(int x=0; x<m_width; x++) {
			uint32_t rgbPixel=rgbImage[y*m_width+x];
			uint32_t sum=0,count=0;
			
			if (colors & ColorMaskRed)
				sum += (rgbPixel>>24)&255; count++;
			
			if (colors & ColorMaskGreen)
				sum += (rgbPixel>>16)&255; count++;
			
			if (colors & ColorMaskBlue)
				sum += (rgbPixel>>8)&255; count++;
			
			m_imageData[y*m_width+x]=sum/count;
		}
	}
	
	free(rgbImage);
	
	// convert from a gray scale image back into a UIImage
	uint8_t *result = (uint8_t *) calloc(m_width * m_height *sizeof(uint32_t), 1);
	
	// process the image back to rgb
	for(int i=0; i<m_height * m_width; i++) {
		result[i * 4] = 0;
		int val = m_imageData[i];
		result[i * 4 + 1] = val;
		result[i * 4 + 2] = val;
		result[i * 4 + 3] = val;
	}
	
	// create a UIImage
	colorSpace = CGColorSpaceCreateDeviceRGB();
	context = CGBitmapContextCreate(result, m_width, m_height, 8, m_width * sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
	CGImageRef image = CGBitmapContextCreateImage(context);
	CGContextRelease(context);
	CGColorSpaceRelease(colorSpace);
	UIImage *resultUIImage = [UIImage imageWithCGImage:image];
	CGImageRelease(image);
	
	// make sure the data will be released by giving it to an autoreleased NSData
	[NSData dataWithBytesNoCopy:result length:m_width * m_height];
	
	return (resultUIImage);
}

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