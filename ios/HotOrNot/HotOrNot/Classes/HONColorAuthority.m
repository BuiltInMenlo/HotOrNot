//
//  HONColorAuthority.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/16/2014 @ 17:53 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <CoreImage/CoreImage.h>
#import <QuartzCore/QuartzCore.h>

#import "HONColorAuthority.h"


NSString * const kColorComponentAlphaKey		= @"alpha";
NSString * const kColorComponentBlueKey			= @"blue";
NSString * const kColorComponentBrightnessKey	= @"brightness";
NSString * const kColorComponentGreenKey		= @"green";
NSString * const kColorComponentHueKey			= @"hue";
NSString * const kColorComponentLuminanceKey	= @"luminance";
NSString * const kColorComponentRedKey			= @"red";
NSString * const kColorComponentSaturationKey	= @"saturation";


const CGFloat kBlueLuminanceMultipier = 0.114;
const CGFloat kGreenLuminanceMultipier = 0.587;
const CGFloat kRedLuminanceMultipier = 0.299;

@implementation HONColorAuthority
static HONColorAuthority *sharedInstance = nil;

+ (HONColorAuthority *)sharedInstance {
	static HONColorAuthority *s_sharedInstance = nil;
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

- (NSShadow *)orthodoxUIShadowAttribute {
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[UIColor colorWithWhite:0.000 alpha:0.875]];
	[shadow setShadowOffset:CGSizeMake(0.0, 1.0)];
	[shadow setShadowBlurRadius:0.500];
	
	return (shadow);
}


- (UIColor *)percentGreyscaleColor:(CGFloat)percent {
	return ([UIColor colorWithWhite:percent
							  alpha:1.000]);
}

- (UIColor *)honLightGreyBGColor {
	return ([[HONColorAuthority sharedInstance] percentGreyscaleColor:0.957]);
}

- (UIColor *)honKhakiColor {
	return ([UIColor colorWithRed:0.769
							green:0.682
							 blue:0.529
							alpha:1.000]);
}

- (UIColor *)honBlueTextColor {
	return ([UIColor colorWithRed:0.000
							green:0.471
							 blue:1.000
							alpha:1.000]);
}

- (UIColor *)honBlueTextColorHighlighted {
	return ([UIColor colorWithRed:0.580
							green:0.729
							 blue:0.973
							alpha:1.000]);
}

- (UIColor *)honGreenTextColor {
	return ([UIColor colorWithRed:0.384
							green:0.902
							 blue:0.635
							alpha:1.000]);
}

- (UIColor *)honGreyTextColor {
	return ([[HONColorAuthority sharedInstance] percentGreyscaleColor:0.600]);
}

- (UIColor *)honDarkGreyTextColor {
	return ([[HONColorAuthority sharedInstance] percentGreyscaleColor:0.400]);
}

- (UIColor *)honLightGreyTextColor {
	return ([[HONColorAuthority sharedInstance] percentGreyscaleColor:0.671]);
}

- (UIColor *)honGrey80TextColor {
	return ([[HONColorAuthority sharedInstance] percentGreyscaleColor:0.800]);
}

- (UIColor *)honPlaceholderTextColor {
	return ([[HONColorAuthority sharedInstance] percentGreyscaleColor:0.4790]);
}

- (UIColor *)honRandomColor {
	return ([[HONColorAuthority sharedInstance] honRandomColorWithStartingBrightness:0.500
																	   andSaturation:0.500]);
}

- (UIColor *)honRandomColorWithStartingBrightness:(CGFloat)offset {
	return ([[HONColorAuthority sharedInstance] honRandomColorWithStartingBrightness:MIN(MAX(offset, 0.00), 1.00)
																	   andSaturation:0.500]);
}

- (UIColor *)honRandomColorWithStartingSaturation:(CGFloat)offset {
	return ([[HONColorAuthority sharedInstance] honRandomColorWithStartingBrightness:0.500
																	   andSaturation:MIN(MAX(offset, 0.00), 1.00)]);
}

- (UIColor *)honRandomColorWithStartingBrightness:(CGFloat)brightness andSaturation:(CGFloat)saturation {
	brightness = MIN(MAX(brightness, 0.00), 1.00);
	saturation = MIN(MAX(saturation, 0.00), 1.00);
	
	return ([UIColor colorWithHue:(arc4random() % 256 / 256.0)
					   saturation:((arc4random() % ((int)(256.0 * saturation)) / 256.0) + saturation)
					   brightness:((arc4random() % ((int)(256.0 * brightness)) / 256.0) + brightness)
							alpha:1.000]);
}

- (CGFloat)luminanceFromColor:(UIColor *)color {
	if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
		CGFloat wVal, aVal;
		if ([color getWhite:&wVal alpha:&aVal]) {
			color = [UIColor colorWithRed:wVal
									green:wVal
									 blue:wVal
									  alpha:aVal];
		}
	}
	
	NSDictionary *components = [[HONColorAuthority sharedInstance] hsbComponentsFromColor:color];
	CGFloat rLuminance = ([[components objectForKey:kColorComponentRedKey] floatValue] / 255.0) * kRedLuminanceMultipier;
	CGFloat gLuminance = ([[components objectForKey:kColorComponentGreenKey] floatValue] / 255.0) * kGreenLuminanceMultipier;
	CGFloat bLuminance = ([[components objectForKey:kColorComponentBlueKey] floatValue] / 255.0) * kBlueLuminanceMultipier;
	
	return((rLuminance > 0.0 && gLuminance > 0.0 && bLuminance > 0.0) ? rLuminance + gLuminance + bLuminance : -1.0);
}

- (NSDictionary *)hsbComponentsFromColor:(UIColor *)color {
	if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
		CGFloat wVal, aVal;
		
		if ([color getWhite:&wVal alpha:&aVal]) {
			color = [UIColor colorWithRed:wVal
									green:wVal
									 blue:wVal
									alpha:aVal];
		}
	}
	
	CGFloat hVal, sVal, bVal, aVal;
	if ([color getHue:&hVal saturation:&sVal brightness:&bVal alpha:&aVal]) {
		return (@{kColorComponentHueKey			: @(hVal),
				  kColorComponentSaturationKey	: @(sVal),
				  kColorComponentBrightnessKey	: @(bVal),
				  kColorComponentAlphaKey		: @(aVal)});
	}
	
	return (@{kColorComponentHueKey			: @(-1),
			  kColorComponentSaturationKey	: @(-1),
			  kColorComponentBrightnessKey	: @(-1),
			  kColorComponentAlphaKey		: @(-1)});
}

- (NSDictionary *)rgbComponentsFromColor:(UIColor *)color {
	if (CGColorGetNumberOfComponents(color.CGColor) == 2) {
		CGFloat wVal, aVal;
		if ([color getWhite:&wVal alpha:&aVal]) {
			color = [UIColor colorWithRed:wVal
									green:wVal
									 blue:wVal
									alpha:aVal];
		}
	}
	
	CGFloat rVal, gVal, bVal, aVal;
	if ([color getRed:&rVal green:&gVal blue:&bVal alpha:&aVal]) {
		return (@{kColorComponentRedKey		: @(rVal),
				  kColorComponentGreenKey	: @(gVal),
				  kColorComponentBlueKey	: @(bVal),
				  kColorComponentAlphaKey	: @(aVal)});
	}
	
	return (@{kColorComponentRedKey		: @(-1),
			  kColorComponentGreenKey	: @(-1),
			  kColorComponentBlueKey	: @(-1),
			  kColorComponentAlphaKey	: @(-1)});
}

- (UIColor *)darkenColor:(UIColor *)color byPercentage:(CGFloat)percent {
	NSDictionary *components = [[HONColorAuthority sharedInstance] hsbComponentsFromColor:color];
	return ([UIColor colorWithHue:[[components objectForKey:kColorComponentHueKey] floatValue]
					   saturation:[[components objectForKey:kColorComponentSaturationKey] floatValue]
					   brightness:[[components objectForKey:kColorComponentBrightnessKey] floatValue] - ([[components objectForKey:kColorComponentBrightnessKey] floatValue] * MIN(MAX(0.0, percent), 1.0))
							alpha:[[components objectForKey:kColorComponentAlphaKey] floatValue]]);
}

- (UIColor *)lightenColor:(UIColor *)color byPercentage:(CGFloat)percent {
	NSDictionary *components = [[HONColorAuthority sharedInstance] hsbComponentsFromColor:color];
	return ([UIColor colorWithHue:[[components objectForKey:kColorComponentHueKey] floatValue]
					   saturation:[[components objectForKey:kColorComponentSaturationKey] floatValue]
					   brightness:[[components objectForKey:kColorComponentBrightnessKey] floatValue] + ([[components objectForKey:kColorComponentBrightnessKey] floatValue] * MIN(MAX(0.0, percent), 1.0))
							alpha:[[components objectForKey:kColorComponentAlphaKey] floatValue]]);
}

- (UIColor *)honDebugDefaultColor {
	return ([[HONColorAuthority sharedInstance] honDebugColor:HONDebugDefaultColor]);
}

- (UIColor *)honDebugColor:(HONDebugColor)debugColor {
#if DEBUGING_COLORS == 0
	return ([UIColor clearColor]);
#else
	
	if (debugColor == HONDebugDefaultColor)
		return ([[HONColorAuthority sharedInstance] honDebugColor:HONDebugFuschiaColor]);
	
	else if (debugColor == HONDebugBlueColor)
		return ([[UIColor blueColor] colorWithAlphaComponent:0.500]);
	
	else if (debugColor == HONDebugBrownColor)
		return ([[UIColor brownColor] colorWithAlphaComponent:0.500]);
	
	else if (debugColor == HONDebugFuschiaColor)
		return ([UIColor colorWithRed:0.697
								green:0.130
								 blue:0.811
								alpha:0.500]);
	
	else if (debugColor == HONDebugGreenColor)
		return ([[UIColor greenColor] colorWithAlphaComponent:0.500]);
	
	else if (debugColor == HONDebugGreyColor)
		return ([[UIColor darkGrayColor] colorWithAlphaComponent:0.500]);
	
	else if (debugColor == HONDebugOrangeColor)
		return ([[UIColor orangeColor] colorWithAlphaComponent:0.500]);
	
	else if (debugColor == HONDebugVioletColor)
		return ([[UIColor purpleColor] colorWithAlphaComponent:0.500]);
	
	else if (debugColor == HONDebugRedColor)
		return ([[UIColor redColor] colorWithAlphaComponent:0.500]);
	
	else
		return ([[HONColorAuthority sharedInstance] honDebugDefaultColor]);
#endif
}


@end
