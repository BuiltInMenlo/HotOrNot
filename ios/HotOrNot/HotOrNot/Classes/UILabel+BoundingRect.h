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
