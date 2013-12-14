//
//  HONImagingDepictor.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "AFImageRequestOperation.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Pixels.h"
#import "UIImageView+AFNetworking.h"

#import "HONImagingDepictor.h"


const CGFloat kSnapRatio = 1.775;//1.853125f;
const CGSize kInstagramSize = {612.0, 612.0};

@implementation HONImagingDepictor

+ (UIImage *)createImageFromView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (image);
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

+ (UIImage *)shareTemplateImageForType:(HONImagingDepictorShareTemplateType)shareTemplateType {
	NSString *keySuffix = @"";
	
	switch (shareTemplateType) {
		case HONImagingDepictorShareTemplateTypeDefault:
			keySuffix = @"default";
			break;
			
		case HONImagingDepictorShareTemplateTypeInstagram:
			keySuffix = @"instagram";
			break;
			
		case HONImagingDepictorShareTemplateTypeTwitter:
			keySuffix = @"twitter";
			break;
			
		case HONImagingDepictorShareTemplateTypeFacebook:
			keySuffix = @"facebook";
			break;
			
		case HONImagingDepictorShareTemplateTypeKik:
			keySuffix = @"kik";
			break;
			
		case HONImagingDepictorShareTemplateTypeSMS:
			keySuffix = @"sms";
			break;
			
		case HONImagingDepictorShareTemplateTypeEmail:
			keySuffix = @"email";
			break;
			
		default:
			keySuffix = @"default";
			break;
	}
	
	return ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[@"share_template-" stringByAppendingString:keySuffix]]]);
}

+ (UIImage *)defaultAvatarImageAtSize:(CGSize)size {
	UIImage *lImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"default_avatar"]];
	float scale = (kSnapLargeSize.width / size.width);
	
	if (CGSizeEqualToSize(size, kSnapLargeSize))
		return (lImage);
	
	else if (CGSizeEqualToSize(size, kSnapTabSize))
		return ([HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:lImage toSize:CGSizeMake(kSnapTabSize.width, kSnapTabSize.width * kSnapRatio)] toRect:CGRectMake(0.0, ((kSnapTabSize.height / scale) - kSnapTabSize.height) * 0.5, kSnapTabSize.width, kSnapTabSize.height)]);
	
	else if (CGSizeEqualToSize(size, kSnapMediumSize))
		return ([HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:lImage toSize:CGSizeMake(kSnapMediumSize.width, kSnapMediumSize.width * kSnapRatio)] toRect:CGRectMake(0.0, ((kSnapLargeSize.height / scale) - kSnapMediumSize.height) * 0.5, kSnapMediumSize.width, kSnapMediumSize.height)]);
	
	else if (CGSizeEqualToSize(size, kSnapThumbSize))
		return ([HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:lImage toSize:CGSizeMake(kSnapThumbSize.width, kSnapThumbSize.width * kSnapRatio)] toRect:CGRectMake(0.0, ((kSnapLargeSize.height / scale) - kSnapThumbSize.height) * 0.5, kSnapThumbSize.width, kSnapThumbSize.height)]);
	
	else {
		CGPoint sizeRatio = CGPointMake((kSnapLargeSize.width / size.width), (kSnapLargeSize.height / size.height));
		CGSize scaledSize = CGSizeMake(kSnapLargeSize.width * sizeRatio.x, kSnapLargeSize.height * sizeRatio.y);
		
		return ([HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:lImage toSize:scaledSize] toRect:CGRectMake((MAX(scaledSize.width, size.width) - MIN(scaledSize.width, size.width) * 0.5), (MAX(scaledSize.height, size.height) - MIN(scaledSize.height, size.height) * 0.5), size.width, size.height)]);
	}
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
		[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation([UIImage imageNamed:key]) forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
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
		
		[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation([UIImage imageNamed:key]) forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}];
	
	[operation start];
}

+ (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor {
	CATextLayer *layer = [[CATextLayer alloc] init];
	
	CGSize size = [caption sizeWithAttributes:@{NSFontAttributeName:font}];//([HONAppDelegate isIOS7]) ? [caption sizeWithAttributes:@{NSFontAttributeName:font}] : [caption sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
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
	if (rect.origin.x >= inputSize.width || rect.origin.y >= inputSize.height)
		return (outputImage);
	
	if (rect.origin.x + rect.size.width >= inputSize.width)
		rect.size.width = inputSize.width - rect.origin.x;
	
	if (rect.origin.y + rect.size.height >= inputSize.height)
		rect.size.height = inputSize.height - rect.origin.y;
	
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
	
	return ([UIImage imageWithCGImage:image.CGImage
								scale:image.scale
						  orientation:(image.imageOrientation + 4) % 8]);
}

+ (UIImage *)prepForUploading:(UIImage *)image {
	if (image.imageOrientation != 0)
		image = [image fixOrientation];
	
	
	UIImage *processedImage;
	float ratio = image.size.width / image.size.height;
	
	NSLog(@"RAW IMAGE:[%@] (%f)", NSStringFromCGSize(image.size), ratio);
	
	if (ratio > 1.0)
		processedImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(1280.0 * ratio, 1280.0)] toRect:CGRectMake(((1280.0 * ratio) - 960.0) * 0.5, 0.0, 960.0, 1280.0)];
		
	else if (ratio == 0.75) {
		if (CGSizeEqualToSize(image.size, CGSizeMake(960.0, 1280.0)))
			return (image);
		
		else
			processedImage = [HONImagingDepictor scaleImage:image toSize:CGSizeMake(960.0, 1280.0)];
	
	} else if (ratio < 1.0)
		processedImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(960.0, 960.0 / ratio)] toRect:CGRectMake(0.0, ((960.0 / ratio) - 1280.0) * 0.5, 960.0, 1280.0)];
		
	else
		processedImage = [HONImagingDepictor cropImage:[HONImagingDepictor scaleImage:image toSize:CGSizeMake(1280.0, 1280.0)] toRect:CGRectMake((1280.0 - 960.0) * 0.5, 0.0, 960.0, 1280.0)];
	
	
	return (processedImage);
}

+ (UIImage *)prepForInstagram:(UIImage *)templateImage withShareImage:(UIImage *)shareImage andUsername:(NSString *)username {
	CGSize scaledSize = CGSizeMake(kInstagramSize.width, kInstagramSize.width * (shareImage.size.height / shareImage.size.width));
	UIImage *processedImage = (CGSizeEqualToSize(shareImage.size, scaledSize) || CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? shareImage : [HONImagingDepictor scaleImage:shareImage toSize:scaledSize];
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kInstagramSize.width, kInstagramSize.height)];
	canvasView.backgroundColor = [UIColor blackColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kInstagramSize.width - processedImage.size.width) * 0.5, (kInstagramSize.height - processedImage.size.height) * 0.5, processedImage.size.width, processedImage.size.height)];
	imageView.image = processedImage;
	[canvasView addSubview:imageView];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:templateImage]];
	
	return ([HONImagingDepictor createImageFromView:canvasView]);
}

+ (void)saveForInstagram:(UIImage *)shareImage withUsername:(NSString *)username toPath:(NSString *)path {
	CGSize scaledSize = CGSizeMake(kInstagramSize.width, kInstagramSize.width * (shareImage.size.height / shareImage.size.width));
	UIImage *processedImage = (CGSizeEqualToSize(shareImage.size, scaledSize) || CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? shareImage : [HONImagingDepictor scaleImage:shareImage toSize:scaledSize];
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kInstagramSize.width, kInstagramSize.height)];
	canvasView.backgroundColor = [UIColor blackColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kInstagramSize.width - processedImage.size.width) * 0.5, (kInstagramSize.height - processedImage.size.height) * 0.5, processedImage.size.width, processedImage.size.height)];
	imageView.image = processedImage;
	[canvasView addSubview:imageView];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:(CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? [[UIImage alloc] init] : [HONImagingDepictor shareTemplateImageForType:HONImagingDepictorShareTemplateTypeInstagram]]];
	
	[UIImageJPEGRepresentation([HONImagingDepictor createImageFromView:canvasView], 1.0f) writeToFile:path atomically:YES];
}

@end
