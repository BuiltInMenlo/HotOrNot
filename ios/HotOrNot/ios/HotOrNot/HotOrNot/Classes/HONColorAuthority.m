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


- (UIColor *)honPercentGreyscaleColor:(CGFloat)percent {
	return ([UIColor colorWithWhite:percent alpha:1.0]);
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
	return ([[HONColorAuthority sharedInstance] honDebugColor:debugColor underFlagDiscretion:YES]);
}


- (UIColor *)honDebugColor:(HONDebugColor)debugColor underFlagDiscretion:(BOOL)flagDiscretion {
	
	if (!flagDiscretion) {
#if ENDORSE_DEBUGING_COLORS == 1
		if (debugColor == HONDebugDefaultColor)
			return ([[HONColorAuthority sharedInstance] honDebugColor:HONDebugFuschiaColor]);
		
		else if (debugColor == HONDebugBlueColor)
			return ([UIColor colorWithRed:0.000 green:0.000 blue:1.000 alpha:0.500]);
		
		else if (debugColor == HONDebugFuschiaColor)
			return ([UIColor colorWithRed:0.697 green:0.130 blue:0.811 alpha:0.500]);
		
		else if (debugColor == HONDebugGreenColor)
			return ([UIColor colorWithRed:0.000 green:1.000 blue:0.000 alpha:0.500]);
		
		else if (debugColor == HONDebugRedColor)
			return ([UIColor colorWithRed:1.000 green:0.000 blue:0.000 alpha:0.500]);
		
		else
			return ([[HONColorAuthority sharedInstance] honDebugDefaultColor]);
		
	} else
		return ([UIColor clearColor]);
	
#else
	return ([UIColor clearColor]);
#endif
}

@end
