//
//  HONImageBroker.m
//  HotOrNot
//
//  Created by Matt Holcombe on 07/27/2014 @ 07:28 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UIImage+fixOrientation.h"
#import "UIImage+ImageEffects.h"
#import "UIImage+Pixels.h"
#import "UIImageView+AFNetworking.h"

#import "AFImageRequestOperation.h"

#import "HONImageBroker.h"

const CGFloat kSnapRatio = 1.775;//1.853125f;
const CGSize kInstagramSize = {612.0, 612.0};

@implementation HONImageBroker
static HONImageBroker *sharedInstance = nil;

+ (HONImageBroker *)sharedInstance {
	static HONImageBroker *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}


- (UIImage *)createImageFromView:(UIView *)view {
	UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0f);
	[view.layer renderInContext:UIGraphicsGetCurrentContext()];
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (image);
}

- (UIImage *)createImageFromScreen {
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

- (UIImage *)createBlurredScreenShot {
	return ([[[HONImageBroker sharedInstance] createImageFromScreen] applyBlurWithRadius:16.0
																			   tintColor:[UIColor colorWithWhite:1.0 alpha:0.75]
																   saturationDeltaFactor:1.0
																			   maskImage:nil]);
}

- (UIImage *)shareTemplateImageForType:(HONImageBrokerShareTemplateType)shareTemplateType {
	NSString *keySuffix = @"";
	
	switch (shareTemplateType) {
		case HONImageBrokerShareTemplateTypeDefault:
			keySuffix = @"default";
			break;
			
		case HONImageBrokerShareTemplateTypeInstagram:
			keySuffix = @"instagram";
			break;
			
		case HONImageBrokerShareTemplateTypeTwitter:
			keySuffix = @"twitter";
			break;
			
		case HONImageBrokerShareTemplateTypeFacebook:
			keySuffix = @"facebook";
			break;
			
		case HONImageBrokerShareTemplateTypeKik:
			keySuffix = @"kik";
			break;
			
		case HONImageBrokerShareTemplateTypeSMS:
			keySuffix = @"sms";
			break;
			
		case HONImageBrokerShareTemplateTypeEmail:
			keySuffix = @"email";
			break;
			
		default:
			keySuffix = @"default";
			break;
	}
	
	return ([UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:[@"share_template-" stringByAppendingString:keySuffix]]]);
}

- (UIImage *)defaultAvatarImageAtSize:(CGSize)size {
	UIImage *lImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"default_avatar"]];
	float scale = (kSnapLargeSize.width / size.width);
	
	if (CGSizeEqualToSize(size, kSnapLargeSize))
		return (lImage);
	
	else if (CGSizeEqualToSize(size, kSnapTabSize))
		return ([[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:lImage toSize:CGSizeMake(kSnapTabSize.width, kSnapTabSize.width * kSnapRatio)] toRect:CGRectMake(0.0, ((kSnapTabSize.height / scale) - kSnapTabSize.height) * 0.5, kSnapTabSize.width, kSnapTabSize.height)]);
	
	else if (CGSizeEqualToSize(size, kSnapMediumSize))
		return ([[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:lImage toSize:CGSizeMake(kSnapMediumSize.width, kSnapMediumSize.width * kSnapRatio)] toRect:CGRectMake(0.0, ((kSnapLargeSize.height / scale) - kSnapMediumSize.height) * 0.5, kSnapMediumSize.width, kSnapMediumSize.height)]);
	
	else if (CGSizeEqualToSize(size, kSnapThumbSize))
		return ([[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:lImage toSize:CGSizeMake(kSnapThumbSize.width, kSnapThumbSize.width * kSnapRatio)] toRect:CGRectMake(0.0, ((kSnapLargeSize.height / scale) - kSnapThumbSize.height) * 0.5, kSnapThumbSize.width, kSnapThumbSize.height)]);
	
	else {
		CGPoint sizeRatio = CGPointMake((kSnapLargeSize.width / size.width), (kSnapLargeSize.height / size.height));
		CGSize scaledSize = CGSizeMake(kSnapLargeSize.width * sizeRatio.x, kSnapLargeSize.height * sizeRatio.y);
		
		return ([[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:lImage toSize:scaledSize] toRect:CGRectMake((MAX(scaledSize.width, size.width) - MIN(scaledSize.width, size.width) * 0.5), (MAX(scaledSize.height, size.height) - MIN(scaledSize.height, size.height) * 0.5), size.width, size.height)]);
	}
}

- (NSString *)defaultAvatarImageURL {
	return ([[[NSUserDefaults standardUserDefaults] objectForKey:@"defualt_imgs"] objectForKey:@"avatar"]);
}

- (double)totalLuminance:(UIImage *)image {
	unsigned char* pixels = [image rgbaPixels];
	
	double luminance = 0.0;
	for (int p=0; p<image.size.width * image.size.height * 4; p+=4)
		luminance += pixels[p] * 0.299 + pixels[p+1] * 0.587 + pixels[p+2] * 0.114;
	
	luminance /= (image.size.width * image.size.height);
	luminance /= 255.0;
	
	return (luminance);
}

- (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key {
	SelfieclubJSONLog(@"%@ —/> (%@)", [[self class] description], url);
	
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		image = (image != nil) ? image : [UIImage imageNamed:key];
		[[HONImageBroker sharedInstance] writeImage:image toUserDefaulsWithKey:key];
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: Failed Request - %@", [[self class] description], [error localizedDescription]);
		[[HONImageBroker sharedInstance] writeImage:[UIImage imageNamed:key] toUserDefaulsWithKey:key];
	}];
	
	[operation start];
}

- (void)writeImageFromWeb:(NSString *)url withDimensions:(CGSize)size withUserDefaultsKey:(NSString *)key {
	SelfieclubJSONLog(@"%@ —/> (%@)", [[self class] description], url);
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMakeFromSize(size)];
	AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
		imageView.image = (image != nil) ? image : [UIImage imageNamed:key];
		[[HONImageBroker sharedInstance] writeImage:imageView.image toUserDefaulsWithKey:key];
		
	} failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
		SelfieclubJSONLog(@"AFNetworking [-] %@: (%@) Failed Request - %@", [[self class] description], url, [error localizedDescription]);
		[[HONImageBroker sharedInstance] writeImage:[UIImage imageNamed:key] toUserDefaulsWithKey:key];
	}];
	
	[operation start];
}

- (void)writeImage:(UIImage *)image toUserDefaulsWithKey:(NSString *)key {
	if ([[NSUserDefaults standardUserDefaults] objectForKey:key] != nil)
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	
	NSData *data = UIImagePNGRepresentation(image);
//	NSLog(@"WRITING IMAGE:(%@)\nFOR KEY:(%@)", [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength], key);
	
	[[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size {
	UIGraphicsBeginImageContext(size);
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}


- (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor {
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

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return (croppedImage);
}

- (UIImage *)editImage:(UIImage *)image toSize:(CGSize)size thenCrop:(CGRect)rect {
	CGContextRef				context;
	CGImageRef				  imageRef;
	CGSize					  inputSize;
	UIImage					 *outputImage = nil;
	CGFloat					 scaleFactor, width;
	
	
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
	CGContextDrawImage(context, CGRectMakeFromSize(size), image.CGImage);
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

- (UIImage *)mirrorImage:(UIImage *)image {
	NSLog(@"ORIENTATION:[%d]", image.imageOrientation);
	
//	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//	imageView.transform = CGAffineTransformScale(imageView.transform, -1.0f, 1.0f);
//	return ([[HONImageBroker sharedInstance] createImageFromView:imageView]);
	
	return ([UIImage imageWithCGImage:image.CGImage
								scale:image.scale
						  orientation:(image.imageOrientation + 4) % 8]);
}

- (UIImage *)prepForUploading:(UIImage *)image {
	if (image.imageOrientation != 0)
		image = [image fixOrientation];
	
	
	UIImage *processedImage;
	float ratio = image.size.width / image.size.height;
	
	NSLog(@"RAW IMAGE:[%@] (%f)", NSStringFromCGSize(image.size), ratio);
	
	if (ratio > 1.0)
		processedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(1280.0 * ratio, 1280.0)] toRect:CGRectMake(((1280.0 * ratio) - 960.0) * 0.5, 0.0, 960.0, 1280.0)];
	
	else if (ratio == 0.75) {
		if (CGSizeEqualToSize(image.size, CGSizeMake(960.0, 1280.0)))
			return (image);
		
		else
			processedImage = [[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(960.0, 1280.0)];
		
	} else if (ratio < 1.0)
		processedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(960.0, 960.0 / ratio)] toRect:CGRectMake(0.0, ((960.0 / ratio) - 1280.0) * 0.5, 960.0, 1280.0)];
	
	else
		processedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(1280.0, 1280.0)] toRect:CGRectMake((1280.0 - 960.0) * 0.5, 0.0, 960.0, 1280.0)];
	
	
	return (processedImage);
}

- (UIImage *)prepForInstagram:(UIImage *)templateImage withShareImage:(UIImage *)shareImage andUsername:(NSString *)username {
	CGSize scaledSize = CGSizeMake(kInstagramSize.width, kInstagramSize.width * (shareImage.size.height / shareImage.size.width));
	UIImage *processedImage = (CGSizeEqualToSize(shareImage.size, scaledSize) || CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? shareImage : [[HONImageBroker sharedInstance] scaleImage:shareImage toSize:scaledSize];
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(kInstagramSize)];
	canvasView.backgroundColor = [UIColor blackColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kInstagramSize.width - processedImage.size.width) * 0.5, (kInstagramSize.height - processedImage.size.height) * 0.5, processedImage.size.width, processedImage.size.height)];
	imageView.image = processedImage;
	[canvasView addSubview:imageView];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:templateImage]];
	
	return ([[HONImageBroker sharedInstance] createImageFromView:canvasView]);
}

- (void)saveForInstagram:(UIImage *)shareImage withUsername:(NSString *)username toPath:(NSString *)path {
	CGSize scaledSize = CGSizeMake(kInstagramSize.width, kInstagramSize.width * (shareImage.size.height / shareImage.size.width));
	UIImage *processedImage = (CGSizeEqualToSize(shareImage.size, scaledSize) || CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? shareImage : [[HONImageBroker sharedInstance] scaleImage:shareImage toSize:scaledSize];
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectMakeFromSize(kInstagramSize)];
	canvasView.backgroundColor = [UIColor blackColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kInstagramSize.width - processedImage.size.width) * 0.5, (kInstagramSize.height - processedImage.size.height) * 0.5, processedImage.size.width, processedImage.size.height)];
	imageView.image = processedImage;
	[canvasView addSubview:imageView];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:(CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? [[UIImage alloc] init] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeInstagram]]];
	
	[UIImageJPEGRepresentation([[HONImageBroker sharedInstance] createImageFromView:canvasView], 1.0f) writeToFile:path atomically:YES];
}


@end
