//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

#import "HONBackNavButtonView.h"
#import "HONCloseNavButtonView.h"
#import "HONComposeNavButtonView.h"
#import "HONDoneNavButtonView.h"
#import "HONNextNavButtonView.h"

@interface HONHeaderView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation HONHeaderView
@synthesize title = _title;


- (id)init {
	if ((self = [super initWithFrame:CGRectMakeFromSize(CGSizeMake(320.0, kNavHeaderHeight))])) {
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navHeaderBackground"]];
		[self addSubview:_bgImageView];
		
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(75.0, 27.0, 170.0, 26.0)];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:20];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [self init])) {
		_title = title;
		_titleLabel.text = _title;
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title asLightStyle:(BOOL)isLightStyle {
	if ((self = [self initWithTitle:title])) {
		_titleLabel.textColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (id)initWithTitleUsingCartoGothic:(NSString *)title {
	if ((self = [self initWithTitle:title])) {
		_titleLabel.font = [[[HONFontAllocator sharedInstance] cartoGothicBold] fontWithSize:22];
		_titleLabel.frame = CGRectOffset(_titleLabel.frame, 0.0, 5.0);
		_titleLabel.shadowOffset = CGSizeZero;
		_titleLabel.shadowColor = [UIColor clearColor];
	}
	
	return (self);
}

- (id)initWithTitleUsingCartoGothic:(NSString *)title asLightStyle:(BOOL)isLightStyle {
	if ((self = [self initWithTitleUsingCartoGothic:title])) {
		_titleLabel.textColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (id)initWithTitleImage:(UIImage *)image {
	if ((self = [self init])) {
		_title = @"";
		
		[self addTitleImage:image];
	}
	
	return (self);
}


- (void)addButton:(UIView *)buttonView {
	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 20.0);
	[self addSubview:buttonView];
}

- (void)addBackButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONBackNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addCloseButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONCloseNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addComposeButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONComposeNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addDoneButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONDoneNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addNextButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONNextNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)setTitle:(NSString *)title {
	_title = title;
	_titleLabel.text = _title;
}

- (void)leftAlignTitle {
	_titleLabel.textAlignment = NSTextAlignmentLeft;
}

- (void)transitionTitle:(NSString *)title {
	if (![_title isEqualToString:title]) {
		UILabel *outroLabel = [[UILabel alloc] initWithFrame:_titleLabel.frame];
		outroLabel.font = _titleLabel.font;
		outroLabel.textColor = _titleLabel.textColor;
		outroLabel.shadowColor = _titleLabel.shadowColor;
		outroLabel.shadowOffset = _titleLabel.shadowOffset;
		outroLabel.textAlignment = _titleLabel.textAlignment;
		[self addSubview:outroLabel];
		
		_titleLabel.alpha = 0.0;
		_title = title;
		_titleLabel.text = _title;
		
		[UIView animateWithDuration:0.25 animations:^(void) {
			outroLabel.alpha = 0.0;
			_titleLabel.alpha = 1.0;
		} completion:^(BOOL finished) {
			[outroLabel removeFromSuperview];
		}];
	}
}


- (void)addTitleImage:(UIImage *)image {
	_title = @"";
	
	UIImageView *titleImageView = [[UIImageView alloc] initWithImage:image];
	titleImageView.frame = CGRectOffset(titleImageView.frame, (self.frame.size.width - image.size.width) * 0.5, 22.0);
	[self addSubview:titleImageView];
}

- (void)removeBackground {
	_bgImageView.hidden = YES;
}

- (void)toggleLightStyle:(BOOL)isLightStyle {
	if (isLightStyle) {
		_titleLabel.textColor = [UIColor whiteColor];
	
	} else {
		_titleLabel.textColor = [UIColor blackColor];
	}
}

@end
