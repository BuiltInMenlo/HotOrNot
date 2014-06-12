//
//  HONImagingDepictor.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 05.02.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

typedef enum {
	HONImagingDepictorShareTemplateTypeDefault = 0,
	HONImagingDepictorShareTemplateTypeInstagram,
	HONImagingDepictorShareTemplateTypeTwitter,
	HONImagingDepictorShareTemplateTypeFacebook,
	HONImagingDepictorShareTemplateTypeKik,
	HONImagingDepictorShareTemplateTypeSMS,
	HONImagingDepictorShareTemplateTypeEmail
} HONImagingDepictorShareTemplateType;

typedef NS_ENUM(NSInteger, HONImagingDepictorImageFormat) {
	HONImagingDepictorImageFormatJPEG = 0,
	HONImagingDepictorImageFormatPNG
};


extern const CGFloat kSnapRatio;


@interface HONImagingDepictor : NSObject
+ (UIImage *)createImageFromView:(UIView *)view;
+ (UIImage *)createImageFromScreen;
+ (UIImage *)createBlurredScreenShot;

+ (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key;
+ (void)writeImageFromWeb:(NSString *)url withDimensions:(CGSize)size withUserDefaultsKey:(NSString *)key;
+ (void)writeImage:(UIImage *)image toUserDefaulsWithKey:(NSString *)key;

+ (UIImage *)shareTemplateImageForType:(HONImagingDepictorShareTemplateType)shareTemplateType;
+ (UIImage *)defaultAvatarImageAtSize:(CGSize)size;

+ (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor;
+ (void)flipLayer:(CALayer *)layer horizontally:(BOOL)xAxisFlipped;

+ (double)totalLuminance:(UIImage *)image;

+ (void)maskImageView:(UIImageView *)imageView withMask:(UIImage *)maskImage;
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
+ (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;
+ (UIImage *)editImage:(UIImage *)image toSize:(CGSize)size thenCrop:(CGRect)rect;
+ (UIImage *)mirrorImage:(UIImage *)image;

+ (UIImage *)prepForUploading:(UIImage *)image;
+ (UIImage *)prepForInstagram:(UIImage *)templateImage withShareImage:(UIImage *)shareImage andUsername:(NSString *)username;
+ (void)saveForInstagram:(UIImage *)shareImage withUsername:(NSString *)username toPath:(NSString *)path;

@end
