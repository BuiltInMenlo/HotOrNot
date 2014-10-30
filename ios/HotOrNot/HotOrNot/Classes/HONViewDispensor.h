//
//  HONViewDispensor.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface HONViewDispensor : NSObject
+ (HONViewDispensor *)sharedInstance;

- (void)appWindowAdoptsView:(UIView *)view;
- (UIView *)matteViewWithSize:(CGSize)size usingColor:(UIColor *)color;
- (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor;
- (void)flipLayer:(CALayer *)layer horizontally:(BOOL)xAxisFlipped;
- (void)maskView:(UIView *)imageView withMask:(UIImage *)maskImage;
- (CGFloat)screenHeight;
- (CGFloat)screenWidth;
- (void)tintView:(UIView *)view withColor:(UIColor *)color;
@end
