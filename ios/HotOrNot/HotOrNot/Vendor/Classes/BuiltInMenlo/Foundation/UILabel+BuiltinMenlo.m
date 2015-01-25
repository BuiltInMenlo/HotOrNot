//
//  UILabel+BoundingRect.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (BoundingRect)
- (CGRect)boundingRectForAllCharacters;
- (CGRect)boundingRectForCharacterRange:(NSRange)range;
- (CGRect)boundingRectForSubstring:(NSString *)substring;
- (void)resizeWidthUsingCaption:(NSString *)caption boundedBySize:(CGSize)maxSize;
@end
//
//  UILabel+BoundingRect.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "UILabel+BoundingRect.h"


@implementation UILabel (BoundingRect)

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
													 attributes:@{NSFontAttributeName:self.font}
														context:nil].size;
	self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, MIN(maxSize.width, size.width), self.frame.size.height);
}


@end
//
//  UILabel+FormattedText.h
//  UILabel+FormattedText
//
//  Created by Joao Costa on 3/1/13.
//  Copyright (c) 2013 none. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (FormattedText)

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;

@end
//
//  UILabel+FormattedText.m
//  UILabel+FormattedText
//
//  Created by Joao Costa on 3/1/13.
//  Copyright (c) 2013 none. All rights reserved.
//

#import "UILabel+FormattedText.h"

@implementation UILabel (FormattedText)

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
