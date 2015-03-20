//
//  HONImageBroker.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/27/2014 @ 07:28 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <QuartzCore/QuartzCore.h>

// image sizes
extern const CGSize kSnapAvatarSize;
extern const CGSize kSnapThumbSize;
extern const CGSize kSnapTabSize;
extern const CGSize kSnapMediumSize;
extern const CGSize kSnapLargeSize;

extern const CGSize kPhotoHDSize;

// image size suffixes
extern NSString * const kSnapThumbSuffix;
extern NSString * const kSnapMediumSuffix;
extern NSString * const kSnapTabSuffix;
extern NSString * const kSnapLargeSuffix;

extern NSString * const kPhotoHDSuffix;

typedef NS_ENUM(NSUInteger, HONImageBrokerShareTemplateType) {
	HONImageBrokerShareTemplateTypeDefault = 0,
	HONImageBrokerShareTemplateTypeInstagram,
	HONImageBrokerShareTemplateTypeTwitter,
	HONImageBrokerShareTemplateTypeFacebook,
	HONImageBrokerShareTemplateTypeKik,
	HONImageBrokerShareTemplateTypeSMS,
	HONImageBrokerShareTemplateTypeEmail
};

typedef NS_ENUM(NSUInteger, HONImageBrokerImageFormat) {
	HONImageBrokerImageFormatJPEG = 0,
	HONImageBrokerImageFormatPNG
};


@interface HONImageBroker : NSObject
+ (HONImageBroker *)sharedInstance;

+ (CGFloat)compressJPEGPercentage;

- (UIImage *)createImageFromScreen;
- (UIImage *)createBlurredScreenShot;

- (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key;
- (void)writeImage:(UIImage *)image toUserDefaultsWithKey:(NSString *)key;

- (UIImage *)shareTemplateImageForType:(HONImageBrokerShareTemplateType)shareTemplateType;
- (UIImage *)defaultAvatarImageAtSize:(CGSize)size;
- (NSString *)defaultAvatarImageURL;

- (double)totalLuminance:(UIImage *)image;
- (CGFloat)aspectRatioForImage:(UIImage *)image;

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size preserveRatio:(BOOL)isRatio;
- (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;
- (UIImage *)cropImage:(UIImage *)image toFillSize:(CGSize)size;
- (CGRect)rectForCroppedImage:(UIImage *)image toSize:(CGSize)size;
- (UIImage *)mirrorImage:(UIImage *)image;
- (UIImage *)imageWithMosaicFX:(CGFloat)pixelSize toImage:(UIImage *)image;
- (void)fetchLastCameraRollImageWithCompletion:(void (^)(id result))completion;

- (UIImage *)prepForUploading:(UIImage *)image;
- (UIImage *)prepForInstagram:(UIImage *)templateImage withShareImage:(UIImage *)shareImage andUsername:(NSString *)username;
- (void)saveForInstagram:(UIImage *)shareImage withUsername:(NSString *)username toPath:(NSString *)path;
@end
