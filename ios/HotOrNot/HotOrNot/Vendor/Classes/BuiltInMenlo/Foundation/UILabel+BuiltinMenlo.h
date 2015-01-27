//
//  UILabel+BoundingRect.h
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface UILabel (BuiltInMenlo)
- (CGRect)boundingRectForAllCharacters;
- (CGRect)boundingRectForCharacterRange:(NSRange)range;
- (CGRect)boundingRectForSubstring:(NSString *)substring;
- (void)resizeWidthUsingCaption:(NSString *)caption boundedBySize:(CGSize)maxSize;

- (void)setTextColor:(UIColor *)textColor range:(NSRange)range;
- (void)setFont:(UIFont *)font range:(NSRange)range;

@end
