//
//  HONFontAllocator.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/17/2014 @ 01:51.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface HONFontAllocator : NSObject
+ (HONFontAllocator *)sharedInstance;

- (UIFont *)cartoGothicBold;
- (UIFont *)cartoGothicBoldItalic;
- (UIFont *)cartoGothicBook;
- (UIFont *)cartoGothicBookItalic;
- (UIFont *)cartoGothicItalic;
- (UIFont *)helveticaNeueFontBold;
- (UIFont *)helveticaNeueFontBoldItalic;
- (UIFont *)helveticaNeueFontLight;
- (UIFont *)helveticaNeueFontMedium;
- (UIFont *)helveticaNeueFontRegular;
- (UIFont *)helveticaNeueFontRegularItalic;

- (NSShadow *)orthodoxShadowAttribute;

- (NSParagraphStyle *)doubleLineSpacingParagraphStyleForFont:(UIFont *)font;
- (NSParagraphStyle *)forceLineSpacingParagraphStyle:(CGFloat)spacing forFont:(UIFont *)font;
- (NSParagraphStyle *)halfLineSpacingParagraphStyleForFont:(UIFont *)font;
- (NSParagraphStyle *)orthodoxLineSpacingParagraphStyleForFont:(UIFont *)font;

@end
