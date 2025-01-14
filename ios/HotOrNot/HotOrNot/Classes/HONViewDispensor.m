//
//  HONViewDispensor.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014 @ 22:48 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewDispensor.h"

@implementation HONViewDispensor
static HONViewDispensor *sharedInstance = nil;

+ (HONViewDispensor *)sharedInstance {
	static HONViewDispensor *s_sharedInstance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		s_sharedInstance = [[self alloc] init];
	});
	
	return (s_sharedInstance);
}

- (id)init {
	if ((self = [super init])) {
	}
	
	return (self);
}

- (void)appWindowAdoptsView:(UIView *)view {
	[[[UIApplication sharedApplication] delegate].window addSubview:view];
}

- (UIView *)matteViewWithSize:(CGSize)size usingColor:(UIColor *)color {
	UIView *view = [[UIView alloc] initWithFrame:CGRectMakeFromSize(size)]; //CGRectMake(0.0, 0.0, size.width, size.height)];
	view.backgroundColor = color;
	
	return (view);
}

- (CATextLayer *)drawTextToLayer:(NSString *)caption inFrame:(CGRect)frame withFont:(UIFont *)font textColor:(UIColor *)textColor {
	CATextLayer *layer = [[CATextLayer alloc] init];
	
	CGSize size = [caption sizeWithAttributes:@{NSFontAttributeName:font}];
	[layer setString:caption];
	[layer setFont:CFBridgingRetain(font.fontName)];
	[layer setFontSize:font.pointSize];
	[layer setAnchorPoint:CGPointMake(0.0, 0.0)];
	[layer setAlignmentMode:kCAAlignmentCenter];
	[layer setForegroundColor:[textColor CGColor]];
	[layer setPosition:CGPointMake(frame.origin.x, frame.origin.y)];
	[layer setBounds:CGRectMakeFromSize(size)];//CGRectMake(0.0, 0.0, size.width, size.height)];
	layer.needsDisplayOnBoundsChange = YES;
	
	return (layer);
}

- (void)flipLayer:(CALayer *)layer horizontally:(BOOL)xAxisFlipped{
	CGRect bounds = layer.bounds;
	CATransform3D translate = CATransform3DMakeTranslation(0.0, (xAxisFlipped) ? -bounds.size.height : -bounds.size.width, 0.0);
	CATransform3D scale = CATransform3DMakeScale((xAxisFlipped) ? 1.0 : -1.0, (xAxisFlipped) ? -1.0 : 1.0, 1.0);
	CATransform3D transform = CATransform3DConcat(translate, scale);
	layer.transform = transform;
}

- (CGRect)frameAtViewOriginAndSize:(UIView *)view {
	return (CGRectMakeFromSize(view.frame.size));
}

- (void)maskView:(UIView *)view withMask:(UIImage *)maskImage {
	CALayer *maskLayer = [CALayer layer];
	maskLayer.contents = (id)[maskImage CGImage];
	maskLayer.frame = CGRectMakeFromSize(view.frame.size);//(0.0, 0.0, //CGRectMake(0.0, 0.0, view.frame.size.width, view.frame.size.height);
	
	view.layer.mask = maskLayer;
	view.layer.masksToBounds = YES;
}

- (void)tintView:(UIView *)view withColor:(UIColor *)color {
	color = (color == nil) ? [[HONColorAuthority sharedInstance] honRandomColor] : color;
	view.layer.backgroundColor = color.CGColor;
}

- (CGAffineTransform)affineTransformView:(UIView *)view byPercentage:(CGFloat)percent {
	return (CGAffineTransformMakeScalePercent(view.frame, percent));
}

- (CGAffineTransform)affineTransformView:(UIView *)view toSize:(CGSize)size {
	return (CGAffineTransformMakeScalePercent(view.frame, MIN(MAX(0.00, view.frame.size.width / size.width), view.frame.size.height / size.height)));
}

- (CGFloat)screenHeight {
	return (CGRectGetHeight([UIScreen mainScreen].bounds));
}

- (CGFloat)screenWidth {
	return (CGRectGetWidth([UIScreen mainScreen].bounds));
}


@end
