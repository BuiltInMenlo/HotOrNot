//
//  HONImagingDepictor.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "AFImageRequestOperation.h"
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

+ (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key {
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(image) forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
	
	[operation start];
}

+ (void)writeImageFromWeb:(NSString *)url withDimensions:(CGSize)size withUserDefaultsKey:(NSString *)key {
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, size.width, size.height)];
		imageView.image = image;
		
		[[NSUserDefaults standardUserDefaults] setObject:UIImagePNGRepresentation(imageView.image) forKey:key];
		[[NSUserDefaults standardUserDefaults] synchronize];
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		NSLog(@"%@", [error localizedDescription]);
	}];
	
	[operation start];
}

+ (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor {
	CATextLayer *layer = [[CATextLayer alloc] init];
	
	CGSize size = [caption sizeWithFont:font constrainedToSize:CGSizeMake(frame.size.width, CGFLOAT_MAX) lineBreakMode:NSLineBreakByClipping];
	
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

+ (UIImage *)prepImageForInstagram:(UIImage *)baseImage avatarImage:(UIImage *)avatar username:(NSString *)handle {
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 612.0, 612.0)];
	canvasView.backgroundColor = [UIColor blackColor];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:baseImage]];
	
	UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(213.0, 213.0, 185.0, 185.0)];
	avatarImageView.image = avatar;
	[canvasView addSubview:avatarImageView];
	
	UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(23.0, 542.0, 370.0, 60.0)];
	nameLabel.font = [[HONAppDelegate cartoGothicBold] fontWithSize:42];
	nameLabel.textColor = [UIColor whiteColor];
	nameLabel.backgroundColor = [UIColor clearColor];
	nameLabel.text = [NSString stringWithFormat:@"@%@", handle];
	//[canvasView addSubview:nameLabel];
	
	[canvasView.layer addSublayer:[HONImagingDepictor drawTextToLayer:[NSString stringWithFormat:@"@%@", handle] inFrame:CGRectMake(23.0, 542.0, 370.0, 60.0) withFont:[[HONAppDelegate cartoGothicBold] fontWithSize:42.0] textColor:[UIColor whiteColor]]];
	
	return ([HONImagingDepictor createImageFromView:canvasView]);
}

@end
