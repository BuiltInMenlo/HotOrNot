//
//  HONFontAllocator.m
//  HotOrNot
//
//  Created by Matt Holcombe on 01/17/2014 @ 01:51.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONFontAllocator.h"

@implementation HONFontAllocator
static HONFontAllocator *sharedInstance = nil;

+ (HONFontAllocator *)sharedInstance {
	static HONFontAllocator *s_sharedInstance = nil;
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


- (UIFont *)cartoGothicBold {
	return ([UIFont fontWithName:@"CartoGothicStd-Bold" size:24.0]);
}

- (UIFont *)cartoGothicBoldItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-BoldItalic" size:24.0]);
}

- (UIFont *)cartoGothicBook {
	return ([UIFont fontWithName:@"CartoGothicStd-Book" size:24.0]);
}

- (UIFont *)cartoGothicItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-Italic" size:24.0]);
}


- (UIFont *)helveticaNeueFontBold {
	return ([UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]);
}

- (UIFont *)helveticaNeueFontBoldItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-BoldItalic" size:18.0]);
}

- (UIFont *)helveticaNeueFontLight {
	return ([UIFont fontWithName:@"HelveticaNeue-Light" size:18.0]);
}

- (UIFont *)helveticaNeueFontMedium {
	return ([UIFont fontWithName:@"HelveticaNeue-Medium" size:18.0]);
}

- (UIFont *)helveticaNeueFontRegular {
	return ([UIFont fontWithName:@"HelveticaNeue" size:18.0]);
}

@end
