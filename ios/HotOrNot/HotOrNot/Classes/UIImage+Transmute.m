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
