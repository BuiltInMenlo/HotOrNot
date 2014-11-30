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

- (NSShadow *)orthodoxUIShadowAttribute;

- (UIColor *)honDebugDefaultColor;
- (UIColor *)honDebugColor:(HONDebugColor)debugColor;

@end
