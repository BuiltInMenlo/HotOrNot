//
//  HONImagingDepictor.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFImageRequestOperation.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Pixels.h"
#import "UIImageView+AFNetworking.h"

#import "HONImagingDepictor.h"

@implementation HONImagingDepictor

+ (UIImage *)createImageFromView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (viewImage);
}

+ (UIImage *)createImageFromScreen {
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    
	else
        UIGraphicsBeginImageContext(imageSize);
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen]) {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
			
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
			
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
			
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
			
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
			
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
	
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	
    UIGraphicsEndImageContext();
	
	return (image);
}

+ (UIImage *)createBlurredScreenShot {
	return ([[HONImagingDepictor createImageFromScreen] applyBlurWithRadius:16.0 tintColor:[UIColor colorWithWhite:1.0 alpha:0.75] saturationDeltaFactor:1.0 maskImage:nil]);
}

+ (UIImage *)defaultShareImage {
	return ([UIImage imageNamed:@"share_defaultTemplate"]);
}

+ (double)totalLuminance:(UIImage *)image {
	unsigned char* pixels = [image rgbaPixels];
	
	double luminance = 0.0;
	for (int p=0; p<image.size.width * image.size.height * 4; p+=4)
		luminance += pixels[p] * 0.299 + pixels[p+1] * 0.587 + pixels[p+2] * 0.114;
	
	luminance /= (image.size.width * image.size.height);
	luminance /= 255.0;
	
	return (luminance);
}

+ (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key {
	VolleyJSONLog(@"%@ —/> (%@)", [[self class] description], url);
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: Failed Request - %@", [[self class] description], [error localizedDescription]);
	}];
	
	[operation start];
}

+ (void)writeImageFromWeb:(NSString *)url withDimensions:(CGSize)size withUserDefaultsKey:(NSString *)key {
	VolleyJSONLog(@"%@ —/> (%@)", [[self class] description], url);
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
		imageView.image = image;
		
		[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(imageView.image) forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		VolleyJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], url, [error localizedDescription]);
	}];
	
	[operation start];
}

+ (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor {
	CATextLayer *layer = [[CATextLayer alloc] init];
	
	CGSize size;
	if ([HONAppDelegate isIOS7])
		size = [caption sizeWithAttributes:@{NSFontAttributeName:font}];
	
	else
		size = [caption sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
	[layer setString:caption];
	[layer setFont:CFBridgingRetain(font.fontName)];
	[layer setFontSize:font.pointSize];
	[layer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[layer setAlignmentMode:kCAAlignmentCenter];
	[layer setForegroundColor:[textColor CGColor]];
	[layer setPosition:CGPointMake(frame.origin.x, frame.origin.y)];
	[layer setBounds:CGRectMake(0.0, 0.0, size.width, size.height)];
	layer.needsDisplayOnBoundsChange = YES;
		
	return (layer);
}

+ (void)flipLayer:(CALayer *)layer horizontally:(BOOL)xAxisFlipped{
	CGRect bounds = layer.bounds;
	CATransform3D translate = CATransform3DMakeTranslation(0.0, (xAxisFlipped) ? -bounds.size.height : -bounds.size.width, 0.0);
	CATransform3D scale = CATransform3DMakeScale((xAxisFlipped) ? 1.0 : -1.0, (xAxisFlipped) ? -1.0 : 1.0, 1.0);
	CATransform3D transform = CATransform3DConcat(translate, scale);
	layer.transform = transform;
}

+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}


+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor {
	CGSize size = CGSizeMake(image.size.width * factor, image.size.height * factor);
	
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}

+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return (croppedImage);
}

+ (UIImage *)editImage:(UIImage *)image toSize:(CGSize)size thenCrop:(CGRect)rect {
	CGContextRef                context;
	CGImageRef                  imageRef;
	CGSize                      inputSize;
	UIImage                     *outputImage = nil;
	CGFloat                     scaleFactor, width;
	
	
	// resize, maintaining aspect ratio:
	inputSize = image.size;
	scaleFactor = size.height / inputSize.height;
	width = roundf(inputSize.width * scaleFactor);
	
	if (width > size.width) {
		scaleFactor = size.width / inputSize.width;
		size.height = roundf(inputSize.height * scaleFactor);
		
	} else {
		size.width = width;
	}
	
	UIGraphicsBeginImageContext(size);
	
	context = UIGraphicsGetCurrentContext();
	CGContextDrawImage(context, CGRectMake(0.0, 0.0, size.width, size.height), image.CGImage);
	outputImage = UIGraphicsGetImageFromCurrentImageContext();
	
	UIGraphicsEndImageContext();
	
	inputSize = size;
	
	// constrain crop rect to legitimate bounds
	if (rect.origin.x >= inputSize.width || rect.origin.y >= inputSize.height) return (outputImage);
	if (rect.origin.x + rect.size.width >= inputSize.width) rect.size.width = inputSize.width - rect.origin.x;
	if (rect.origin.y + rect.size.height >= inputSize.height) rect.size.height = inputSize.height - rect.origin.y;
	
	// crop
	if ((imageRef = CGImageCreateWithImageInRect(outputImage.CGImage, rect))) {
		outputImage = [[UIImage alloc] initWithCGImage: imageRef];
		CGImageRelease(imageRef);
	}
	
	return (outputImage);
}

+ (UIImage *)mirrorImage:(UIImage *)image {
	NSLog(@"ORIENTATION:[%d]", image.imageOrientation);
	
//	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//	imageView.transform = CGAffineTransformScale(imageView.transform, -1.0f, 1.0f);
//	return ([HONImagingDepictor createImageFromView:imageView]);
	
	return ([UIImage imageWithCGImage:image.CGImage scale:image.scale orientation:(image.imageOrientation == UIImageOrientationUp) ? UIImageOrientationUpMirrored : UIImageOrientationUp]);
}

+ (UIImage *)prepImageForSharing:(UIImage *)baseImage avatarImage:(UIImage *)avatar username:(NSString *)handle {
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 612.0, 612.0)];
	canvasView.backgroundColor = [UIColor blackColor];
	
	//UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, -237.0, 612.0, 1086.0)];
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, (612.0 - avatar.size.height) * 0.5, avatar.size.width, avatar.size.height)];
	avatarImageView.image = avatar;
	[canvasView addSubview:avatarImageView];
	
	[canvasView addSubview:[[UIImageView alloc] initWithImage:baseImage]];
	
	return ([HONImagingDepictor createImageFromView:canvasView]);
}

@end
