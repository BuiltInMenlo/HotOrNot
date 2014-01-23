//
//  HONFontAllocator.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/17/2014 @ 01:51.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONFontAllocator : NSObject
+ (HONFontAllocator *)sharedInstance;

- (UIFont *)cartoGothicBold;
- (UIFont *)cartoGothicBoldItalic;
- (UIFont *)cartoGothicBook;
- (UIFont *)cartoGothicItalic;
- (UIFont *)helveticaNeueFontBold;
- (UIFont *)helveticaNeueFontBoldItalic;
- (UIFont *)helveticaNeueFontLight;
- (UIFont *)helveticaNeueFontMedium;
- (UIFont *)helveticaNeueFontRegular;
@end
