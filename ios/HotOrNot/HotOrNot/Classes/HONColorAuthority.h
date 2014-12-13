//
//  HONColorAuthority.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/16/2014 @ 17:53 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


typedef enum {
	HONDebugDefaultColor = 0,
	HONDebugBlueColor,
	HONDebugBrownColor,
	HONDebugFuschiaColor,
	HONDebugGreenColor,
	HONDebugGreyColor,
	HONDebugOrangeColor,
	HONDebugVioletColor,
	HONDebugRedColor
} HONDebugColor;


extern NSString * const kColorComponentAlphaKey;
extern NSString * const kColorComponentBlueKey;
extern NSString * const kColorComponentBrightnessKey;
extern NSString * const kColorComponentGreenKey;
extern NSString * const kColorComponentHueKey;
extern NSString * const kColorComponentLuminanceKey;
extern NSString * const kColorComponentRedKey;
extern NSString * const kColorComponentSaturationKey;


@interface HONColorAuthority : NSObject
+ (HONColorAuthority *)sharedInstance;

- (UIColor *)percentGreyscaleColor:(CGFloat)percent;
- (UIColor *)honKhakiColor;
- (UIColor *)honLightGreyBGColor;
- (UIColor *)honBlueTextColor;
- (UIColor *)honBlueTextColorHighlighted;
- (UIColor *)honGreenTextColor;
- (UIColor *)honGreyTextColor;
- (UIColor *)honDarkGreyTextColor;
- (UIColor *)honLightGreyTextColor;
- (UIColor *)honPlaceholderTextColor;
- (UIColor *)honRandomColor;
- (UIColor *)honRandomColorWithStartingBrightness:(CGFloat)offset;
- (UIColor *)honRandomColorWithStartingSaturation:(CGFloat)offset;
- (UIColor *)honRandomColorWithStartingBrightness:(CGFloat)brightness andSaturation:(CGFloat)saturation;

- (CGFloat)luminanceFromColor:(UIColor *)color;
- (NSDictionary *)hsbComponentsFromColor:(UIColor *)color;
- (NSDictionary *)rgbComponentsFromColor:(UIColor *)color;

- (UIColor *)darkenColor:(UIColor *)color byPercentage:(CGFloat)percent;
- (UIColor *)lightenColor:(UIColor *)color byPercentage:(CGFloat)percent;

- (NSShadow *)orthodoxUIShadowAttribute;

- (UIColor *)honDebugDefaultColor;
- (UIColor *)honDebugColor:(HONDebugColor)debugColor;

@end
