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
//const CGSize kUploadBaseSize = {960.0, 1280.0};
//const CGSize kUploadBaseSize = {852.0, 1136.0};
const CGSize kUploadBaseSize = {640.0, 1136.0};


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

- (CGFloat)aspectRatioForImage:(UIImage *)image {
	return (image.size.width / image.size.height);
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
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectFromSize(size)];
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
	
//	[image drawInRect:CGRectMake(0.0, 0.0, size.width, size.height)];
//	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
	
	UIGraphicsBeginImageContext(size);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, size.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
	
	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size preserveRatio:(BOOL)isRatio {
	
	UIImage *scaledImage = nil;
	CGFloat ratio = [[HONImageBroker sharedInstance] aspectRatioForImage:image];
	
	CGSize scaledSize = CGSizeMake(size.width, size.height);
	CGSize multSize = CGSizeMake(size.width / image.size.width, size.height / image.size.height);
	CGFloat scaledRatio = scaledSize.width / scaledSize.height;
	
	NSLog(@"ORG_RATIO:[%f] SCALE_RATIO:[%f]", ratio, scaledRatio);
	
	if (isRatio) {
		if (ratio == scaledRatio) {
			if (CGSizeEqualToSize(image.size, kUploadBaseSize))
				return (image);
			
			else
				scaledSize = CGSizeMake(size.width, size.height);
		
		} else {
			scaledSize = (multSize.width > multSize.height) ? CGSizeMake(image.size.width * multSize.width, image.size.height * multSize.width) : CGSizeMake(image.size.width * multSize.height, image.size.height * multSize.height);
		}
	
	} else {
		scaledSize = CGSizeMake(size.width, size.height);
	}
	
	
	UIGraphicsBeginImageContext(scaledSize);
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextTranslateCTM(context, 0.0f, scaledSize.height);
	CGContextScaleCTM(context, 1.0f, -1.0f);
	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, scaledSize.width, scaledSize.height), image.CGImage);
	scaledImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return (scaledImage);
}


- (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor {
	return ([[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMult(image.size, factor) preserveRatio:YES]);
	
//	return ([[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(image.size.width * factor, image.size.height * factor)]);
	
//	CGSize size = CGSizeMake(image.size.width * factor, image.size.height * factor);
//	UIGraphicsBeginImageContext(size);
//	
//	CGContextRef context = UIGraphicsGetCurrentContext();
//	CGContextTranslateCTM(context, 0.0f, size.height);
//	CGContextScaleCTM(context, 1.0f, -1.0f);
//	CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, size.width, size.height), image.CGImage);
//	
//	UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
//	UIGraphicsEndImageContext();
//	
//	return (scaledImage);
}

- (CGRect)rectForCroppedImage:(UIImage *)image toSize:(CGSize)size {
	CGFloat ratio = size.width / size.height; //[[HONImageBroker sharedInstance] aspectRatioForImage:image];
	
	// w > h : w < h : w = h
//	CGPoint pos = (ratio < 1.0) ? CGPointMake(0.0, ((image.size.width / ratio) - size.height) * 0.5) : (ratio > 1.0) ? CGPointMake(((image.size.height * ratio) - size.width) * 0.5, 0.0) : CGPointZero;
	CGPoint pos = (image.size.width == size.width) ? CGPointMake(0.0, (image.size.width - size.height) * 0.5) : (image.size.height == size.height) ? CGPointMake((image.size.width - size.width) * 0.5, 0.0) : CGPointZero;
	NSLog(@"CROPPED POS:[%@] (%@)(%@) {%f}", NSStringFromCGPoint(pos), NSStringFromCGSize(image.size), NSStringFromCGSize(size), ratio);
	
	return (CGRectMake(pos.x, pos.y, size.width, size.height));
}

- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect {
	CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
	
	UIImage *croppedImage = [UIImage imageWithCGImage:imageRef];
	CGImageRelease(imageRef);
	
	return (croppedImage);
}

- (UIImage *)cropImage:(UIImage *)image toFillSize:(CGSize)size {
	return ([[HONImageBroker sharedInstance] cropImage:image toRect:[[HONImageBroker sharedInstance] rectForCroppedImage:image toSize:size]]);
}

- (UIImage *)mirrorImage:(UIImage *)image {
	NSLog(@"MIRROR-ORIENTATION:[%@] >> [%@]", NSStringFromUIImageOrientation(image.imageOrientation), NSStringFromUIImageOrientation((image.imageOrientation + 4) % 8));
	
//	UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//	imageView.transform = CGAffineTransformScale(imageView.transform, -1.0f, 1.0f);
//	return ([[HONImageBroker sharedInstance] createImageFromView:imageView]);
	
	return ([UIImage imageWithCGImage:image.CGImage
								scale:image.scale
			 orientation:(image.imageOrientation + 4) % 8]);
//						  orientation:(image.imageOrientation + 4) % 8]);
}

- (UIImage *)imageWithMosaicFX:(CGFloat)pixelSize toImage:(UIImage *)image {
	UIImage *fxImage = image;
	
	return (fxImage);
}

- (void)fetchLastCameraRollImageWithCompletion:(void (^)(id result))completion {
	__block UIImage *lastImage = nil;
	
	ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
	[assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
		if (nil != group) {
			// be sure to filter the group so you only get photos
			[group setAssetsFilter:[ALAssetsFilter allPhotos]];
			
			[group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *asset, NSUInteger index, BOOL *stop) {
				if (asset) {
					lastImage = [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
					*stop = YES;
				}
			}];
		}
		
		if (completion)
			completion(lastImage);
		
//		*stop = NO;
	} failureBlock:^(NSError *error) {
		NSLog(@"error: %@", error);
	}];
}

- (UIImage *)prepForUploading:(UIImage *)image {
	if (image.imageOrientation != UIImageOrientationUp)
		image = [image fixOrientation];
	
	NSLog(@"PRE-PROC IMAGE:[%@] (%f)", NSStringFromCGSize(image.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
	
	UIImage *scaledImage = [[HONImageBroker sharedInstance] scaleImage:image toSize:kUploadBaseSize preserveRatio:YES];
	NSLog(@"SCALED IMAGE:[%@] (%f)", NSStringFromCGSize(scaledImage.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
	
	UIImage *croppedImage = [[HONImageBroker sharedInstance] cropImage:scaledImage toRect:[[HONImageBroker sharedInstance] rectForCroppedImage:scaledImage toSize:kUploadBaseSize]];
	NSLog(@"CROPPED IMAGE:[%@] (%f)", NSStringFromCGSize(croppedImage.size), [[HONImageBroker sharedInstance] aspectRatioForImage:image]);
	
	return (croppedImage);
	
	
//	UIImage *processedImage = image;
//	float ratio = [[HONImageBroker sharedInstance] aspectRatioForImage:image];//image.size.width / image.size.height;
//	if (ratio > 1.0)
//		processedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(1280.0 * ratio, 1280.0)] toRect:CGRectMake(((1280.0 * ratio) - 960.0) * 0.5, 0.0, 960.0, 1280.0)];
//	
//	else if (ratio == 0.75) {
//		if (CGSizeEqualToSize(image.size, CGSizeMake(960.0, 1280.0)))
//			return (image);
//		
//		else
//			processedImage = [[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(960.0, 1280.0)];
//		
//	} else if (ratio < 1.0)
//		processedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(960.0, 960.0 / ratio)] toRect:CGRectMake(0.0, ((960.0 / ratio) - 1280.0) * 0.5, 960.0, 1280.0)];
//	
//	else
//		processedImage = [[HONImageBroker sharedInstance] cropImage:[[HONImageBroker sharedInstance] scaleImage:image toSize:CGSizeMake(1280.0, 1280.0)] toRect:CGRectMake((1280.0 - 960.0) * 0.5, 0.0, 960.0, 1280.0)];
//	
//	
//	return (processedImage);
}

- (UIImage *)prepForInstagram:(UIImage *)templateImage withShareImage:(UIImage *)shareImage andUsername:(NSString *)username {
	CGSize scaledSize = CGSizeMake(kInstagramSize.width, kInstagramSize.width * (shareImage.size.height / shareImage.size.width));
	UIImage *processedImage = (CGSizeEqualToSize(shareImage.size, scaledSize) || CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? shareImage : [[HONImageBroker sharedInstance] scaleImage:shareImage toSize:scaledSize];
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectFromSize(kInstagramSize)];
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
	
	UIView *canvasView = [[UIView alloc] initWithFrame:CGRectFromSize(kInstagramSize)];
	canvasView.backgroundColor = [UIColor blackColor];
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((kInstagramSize.width - processedImage.size.width) * 0.5, (kInstagramSize.height - processedImage.size.height) * 0.5, processedImage.size.width, processedImage.size.height)];
	imageView.image = processedImage;
	[canvasView addSubview:imageView];
	[canvasView addSubview:[[UIImageView alloc] initWithImage:(CGSizeEqualToSize(shareImage.size, kInstagramSize)) ? [[UIImage alloc] init] : [[HONImageBroker sharedInstance] shareTemplateImageForType:HONImageBrokerShareTemplateTypeInstagram]]];
	
	[UIImageJPEGRepresentation([[HONImageBroker sharedInstance] createImageFromView:canvasView], 1.0f) writeToFile:path atomically:YES];
}


@end
