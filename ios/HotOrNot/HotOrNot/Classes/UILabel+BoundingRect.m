//
//  UILabel+BoundingRect.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UILabel+BoundingRect.h"


@implementation UILabel (BoundingRect)

- (CGRect)boundingRectForCharacterRange:(NSRange)range {
	NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:(self.attributedText == nil) ? [[NSAttributedString alloc] initWithString:self.text] : self.attributedText];
	NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
	[textStorage addLayoutManager:layoutManager];
	
	NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.frame.size];
	[layoutManager addTextContainer:textContainer];
	
	NSRange glyphRange;
	[layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
	
	CGRect charBounds = [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
	CGRect adjBounds = CGRectOffset(charBounds, self.frame.origin.x - 5.0, self.frame.origin.y + ((self.font.lineHeight - self.font.capHeight) * 0.5));
	
//	NSLog(@"LINE HEIGHT:[%f]", self.font.lineHeight);
//	NSLog(@"CAP:[%f]", self.font.capHeight);
//	NSLog(@"|--|--|--|--|--|--|:|--|--|--|--|--|--|");
//	
//	NSLog(@"--SELF:[%@]--", NSStringFromCGRect(self.frame));
//	NSLog(@"--CHAR:[%@]--", NSStringFromCGRect(charBounds));
//	NSLog(@"--ADDJ:[%@]--\n\n", NSStringFromCGRect(adjBounds));
	return (adjBounds);
}

- (void)resizeWidthUsingCaption:(NSString *)caption boundedBySize:(CGSize)maxSize {
	CGSize size = [caption boundingRectWithSize:maxSize
														options:NSStringDrawingTruncatesLastVisibleLine
													 attributes:@{NSFontAttributeName:self.font}
														context:nil].size;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, MIN(maxSize.width, size.width), self.frame.size.height);
}


@end
