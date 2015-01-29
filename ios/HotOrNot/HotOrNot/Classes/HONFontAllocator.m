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

- (UIFont *)cartoGothicBookItalic {
	return ([UIFont fontWithName:@"CartoGothicStd-BookItalic" size:24.0]);
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

- (UIFont *)helveticaNeueFontRegularItalic {
	return ([UIFont fontWithName:@"HelveticaNeue-Italic" size:18.0]);
}


- (NSShadow *)orthodoxShadowAttribute {
	NSShadow *shadow = [[NSShadow alloc] init];
	[shadow setShadowColor:[UIColor colorWithWhite:0.0 alpha:0.875]];
	[shadow setShadowOffset:CGSizeMake(0.0, 1.0)];
	[shadow setShadowBlurRadius:0.5];
	
	return (shadow);
}


- (NSParagraphStyle *)doubleLineSpacingParagraphStyleForFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.lineHeight;
	paragraphStyle.maximumLineHeight *= 2.0;
	
	return (paragraphStyle);
}

- (NSParagraphStyle *)forceLineSpacingParagraphStyle:(CGFloat)spacing forFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.lineHeight + spacing;
	
	return (paragraphStyle);
}

- (NSParagraphStyle *)halfLineSpacingParagraphStyleForFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.capHeight + font.descender;
	paragraphStyle.maximumLineHeight += font.ascender;
	
	return (paragraphStyle);
}

- (NSParagraphStyle *)orthodoxLineSpacingParagraphStyleForFont:(UIFont *)font {
	NSMutableParagraphStyle *paragraphStyle  = [[NSMutableParagraphStyle alloc] init];
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight = font.lineHeight;
//	paragraphStyle.maximumLineHeight *= 0.5;
	
	return (paragraphStyle);
}


@end
