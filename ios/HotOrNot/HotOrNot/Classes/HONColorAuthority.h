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

- (UIColor *)honPercentGreyscaleColor:(CGFloat)percent;
- (UIColor *)honKhakiColor;
- (UIColor *)honBGLightGreyColor;
- (UIColor *)honBlueTextColor;
- (UIColor *)honBlueTextColorHighlighted;
- (UIColor *)honGreenTextColor;
- (UIColor *)honGreyTextColor;
- (UIColor *)honDarkGreyTextColor;
- (UIColor *)honLightGreyTextColor;
- (UIColor *)honPlaceholderTextColor;

- (NSShadow *)orthodoxUIShadowAttribute;

- (UIColor *)honDebugDefaultColor;
- (UIColor *)honDebugColor:(HONDebugColor)debugColor;

@end
