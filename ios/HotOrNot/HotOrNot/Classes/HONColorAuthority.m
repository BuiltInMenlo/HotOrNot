//
//  HONColorAuthority.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/16/2014 @ 17:53 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONColorAuthority.h"

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
	[shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.875]];
	[shadow setShadowOffset:CGSizeMake(0.0, 1.0)];
	[shadow setShadowBlurRadius:0.5];
	
	return (shadow);
}


- (UIColor *)honPercentGreyscaleColor:(CGFloat)percent {
	return ([UIColor colorWithWhite:percent alpha:1.0]);
}

- (UIColor *)honBGLightGreyColor {
	return ([UIColor colorWithWhite:0.847 alpha:1.0]);
}

- (UIColor *)honKhakiColor {
	return ([UIColor colorWithRed:0.769 green:0.682 blue:0.529 alpha:1.0]);
}

- (UIColor *)honBlueTextColor {
	return ([UIColor colorWithRed:0.141 green:0.271 blue:0.925 alpha:1.0]);
}

- (UIColor *)honBlueTextColorHighlighted {
	return ([UIColor colorWithRed:0.580 green:0.729 blue:0.973 alpha:1.0]);
}

- (UIColor *)honGreenTextColor {
	return ([UIColor colorWithRed:0.451 green:0.757 blue:0.694 alpha:1.0]);
}

- (UIColor *)honGreyTextColor {
	return ([UIColor colorWithWhite:0.600 alpha:1.0]);
}

- (UIColor *)honDarkGreyTextColor {
	return ([UIColor colorWithWhite:0.400 alpha:1.0]);
}

- (UIColor *)honLightGreyTextColor {
	return ([UIColor colorWithWhite:0.671 alpha:1.0]);
}

- (UIColor *)honPlaceholderTextColor {
	return ([UIColor colorWithWhite:0.790 alpha:1.0]);
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
		return ([UIColor colorWithRed:0.697 green:0.130 blue:0.811 alpha:0.500]);
	
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
