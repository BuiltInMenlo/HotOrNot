//
//  UILabel+BuiltInMenlo.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface UILabel (BuiltInMenlo)
- (CGRect)boundingRectForAllCharacters;
- (CGRect)boundingRectForCharacterRange:(NSRange)range;
- (CGRect)boundingRectForSubstring:(NSString *)substring;
- (int)numberOfLinesNeeded;
- (void)resizeFrameForText;
- (void)resizeWidthUsingCaption:(NSString *)caption boundedBySize:(CGSize)maxSize;
- (CGSize)sizeForText;

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;

@end
