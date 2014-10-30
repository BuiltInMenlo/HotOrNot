//
//  HONImageBroker.h
//  HotOrNot
//
//  Created by Matt Holcombe on 07/27/2014 @ 07:28 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

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

- (UIImage *)createImageFromView:(UIView *)view;
- (UIImage *)createImageFromScreen;
- (UIImage *)createBlurredScreenShot;

- (void)writeImageFromWeb:(NSString *)url withUserDefaultsKey:(NSString *)key;
- (void)writeImageFromWeb:(NSString *)url withDimensions:(CGSize)size withUserDefaultsKey:(NSString *)key;
- (void)writeImage:(UIImage *)image toUserDefaulsWithKey:(NSString *)key;

- (UIImage *)shareTemplateImageForType:(HONImageBrokerShareTemplateType)shareTemplateType;
- (UIImage *)defaultAvatarImageAtSize:(CGSize)size;
- (NSString *)defaultAvatarImageURL;

- (double)totalLuminance:(UIImage *)image;

- (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
- (UIImage *)scaleImage:(UIImage *)image byFactor:(float)factor;
- (UIImage *)cropImage:(UIImage *)image toRect:(CGRect)rect;
- (UIImage *)editImage:(UIImage *)image toSize:(CGSize)size thenCrop:(CGRect)rect;
- (UIImage *)mirrorImage:(UIImage *)image;

- (UIImage *)prepForUploading:(UIImage *)image;
- (UIImage *)prepForInstagram:(UIImage *)templateImage withShareImage:(UIImage *)shareImage andUsername:(NSString *)username;
- (void)saveForInstagram:(UIImage *)shareImage withUsername:(NSString *)username toPath:(NSString *)path;
@end
