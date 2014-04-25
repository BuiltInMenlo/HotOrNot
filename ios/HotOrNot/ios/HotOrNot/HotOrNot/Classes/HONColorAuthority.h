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
	HONDebugFuschiaColor,
	HONDebugGreenColor,
	HONDebugRedColor
} HONDebugColor;


@interface HONColorAuthority : NSObject
+ (HONColorAuthority *)sharedInstance;

- (UIColor *)honPercentGreyscaleColor:(CGFloat)percent;
- (UIColor *)honBlueTextColor;
- (UIColor *)honBlueTextColorHighlighted;
- (UIColor *)honGreenTextColor;
- (UIColor *)honGreyTextColor;
- (UIColor *)honDarkGreyTextColor;
- (UIColor *)honLightGreyTextColor;
- (UIColor *)honPlaceholderTextColor;
- (UIColor *)honDebugDefaultColor;
- (UIColor *)honDebugColor:(HONDebugColor)debugColor;
- (UIColor *)honDebugColor:(HONDebugColor)debugColor underFlagDiscretion:(BOOL)flagDiscretion;
@end
