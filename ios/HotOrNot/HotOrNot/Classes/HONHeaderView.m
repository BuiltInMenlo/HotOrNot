//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

const CGRect kNormalFrame = {75.0f, 33.0f, 170.0f, 19.0f};
const CGRect kActiveFrame = {-95.0f, 14.0f, 510.0f, 57.0f};

@interface HONHeaderView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONHeaderView
@synthesize title = _title;

- (id)initWithBranding {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavHeaderHeight)])) {
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navHeaderBrandingBG"]];
		[self addSubview:_bgImageView];
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [super initWithFrame:CGRectMake(0.0, 0.0, 320.0, kNavHeaderHeight)])) {
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navHeaderBG"]];
		[self addSubview:_bgImageView];
		
		_title = title;
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 33.0, 170.0, 19.0)];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontBold] fontWithSize:17];
		_titleLabel.textColor = [UIColor whiteColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.text = _title;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

//- (id)initWithTitle:(NSString *)title hasBackground:(BOOL)withBG {
//	if ((self = [self initWithTitle:title])) {
//	}
//	
//	return (self);
//}


- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
	
	
	CGSize scaleSize = CGSizeMake(kActiveFrame.size.width / kNormalFrame.size.width, kActiveFrame.size.height / kNormalFrame.size.height);
	CGPoint offsetPt = CGPointMake(CGRectGetMidX(kActiveFrame) - CGRectGetMidX(kNormalFrame), CGRectGetMidY(kActiveFrame) - CGRectGetMidY(kNormalFrame));
	CGAffineTransform transform = CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
	
	[UIView animateWithDuration:0.0625 delay:0.000
		 usingSpringWithDamping:0.875 initialSpringVelocity:0.000
						options:(UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent)
	 
					 animations:^(void) {
						 _titleLabel.transform = transform;
					 } completion:^(BOOL finished) {
						 CGAffineTransform transform = CGAffineTransformMake(1.0, 0.0, 0.0, 1.0, 0.0, 0.0);//CGAffineTransformMake(scaleSize.width, 0.0, 0.0, scaleSize.height, offsetPt.x, offsetPt.y);
						 
						 NSLog(@"TRANS:[%@]", NSStringFromCGAffineTransform(transform));
						 
						 [UIView animateWithDuration:0.125 delay:0.000
							  usingSpringWithDamping:0.875 initialSpringVelocity:0.333
											 options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
						  
										  animations:^(void) {
											  _titleLabel.transform = transform;
										  } completion:^(BOOL finished) {
										  }];
					 }];
}


- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 19.0);
	[self addSubview:buttonView];
}

- (void)leftAlignTitle {
	_titleLabel.textAlignment = NSTextAlignmentLeft;
}


@end
