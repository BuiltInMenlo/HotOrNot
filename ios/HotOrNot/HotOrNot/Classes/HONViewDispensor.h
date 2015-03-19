//
//  HONViewDispensor.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "UIViewController+BuiltInMenlo.h"

#import "HONViewController.h"

@interface HONViewDispensor : NSObject
+ (HONViewDispensor *)sharedInstance;

- (void)appWindowAdoptsView:(UIView *)view;
- (UIView *)matteViewWithSize:(CGSize)size usingColor:(UIColor *)color;
- (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor;
- (void)flipLayer:(CALayer *)layer horizontally:(BOOL)xAxisFlipped;
- (CGRect)frameAtViewOriginAndSize:(UIView *)view;
- (void)maskView:(UIView *)imageView withMask:(UIImage *)maskImage;
- (CGFloat)screenHeight;
- (CGFloat)screenWidth;
- (void)tintView:(UIView *)view withColor:(UIColor *)color;
- (CGAffineTransform)affineTransformView:(UIView *)view byPercentage:(CGFloat)percent;
- (CGAffineTransform)affineTransformView:(UIView *)view toSize:(CGSize)size;

- (void)updateCurrentViewController:(HONViewController *)viewController;
+ (HONViewController *)currentViewController;
@end
