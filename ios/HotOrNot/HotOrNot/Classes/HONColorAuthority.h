//
//  HONColorAuthority.h
//  HotOrNot
//
//  Created by Matt Holcombe on 01/16/2014 @ 17:53 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HONColorAuthority : NSObject
+ (HONColorAuthority *)sharedInstance;

- (UIColor *)honPercentGreyscaleColor:(CGFloat)percent;
- (UIColor *)honBlueTextColor;
- (UIColor *)honBlueTextColorHighlighted;
- (UIColor *)honGreenTextColor;
- (UIColor *)honGreyTextColor;
- (UIColor *)honDarkGreyTextColor;
- (UIColor *)honLightGreyTextColor;
- (UIColor *)honPlaceholderTextColor;
- (UIColor *)honDebugColor;
- (UIColor *)honDebugColorByName:(NSString *)colorName atOpacity:(CGFloat)percent;
@end
