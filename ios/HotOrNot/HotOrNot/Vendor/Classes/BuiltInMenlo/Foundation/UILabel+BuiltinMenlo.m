//
//  UILabel+BoundingRect.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UILabel+BuiltInMenlo.h"

@implementation UILabel (BuiltInMenlo)

- (CGSize)sizeForText {
	NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
	paragraph.lineBreakMode = NSLineBreakByWordWrapping;
	
	return ([self.text boundingRectWithSize:CGSizeMake(self.frame.size.width, NSUIntegerMax)
									options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
								 attributes:@{NSFontAttributeName			: self.font,
											  NSParagraphStyleAttributeName	: paragraph}
									context:nil].size);
}

- (CGRect)boundingRectForAllCharacters {
	return ([self boundingRectForCharacterRange:[self.text rangeOfString:self.text]]);
}

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

- (CGRect)boundingRectForSubstring:(NSString *)substring {
	return ([self boundingRectForCharacterRange:[self.text rangeOfString:substring]]);
}

- (void)resizeWidthUsingCaption:(NSString *)caption boundedBySize:(CGSize)maxSize {
	CGSize size = [caption boundingRectWithSize:maxSize
										options:NSStringDrawingTruncatesLastVisibleLine
									 attributes:@{NSFontAttributeName	: self.font}
										context:nil].size;
	self.frame = CGRectResizeWidth(self.frame, MIN(maxSize.width, size.width));
}

- (int)numberOfLinesNeeded {
	return ((int)round(MAX(1.0, (int)round([self sizeForText].height) / (int)round(self.font.lineHeight))));
}

- (void)resizeFrameForText {
	self.frame = CGRectResize(self.frame, [self sizeForText]);
}

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range
{
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	[text addAttribute:NSForegroundColorAttributeName
				 value:textColor
				 range:range];
	
	[self setAttributedText:text];
}

- (void)setFont:(UIFont *)font range:(NSRange)range
{
	NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithAttributedString:self.attributedText];
	[text addAttribute:NSFontAttributeName
				 value:font
				 range:range];
	
	[self setAttributedText:text];
}

@end
