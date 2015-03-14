//
//  HONHeaderView.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import "HONHeaderView.h"

#import "HONActivityNavButtonView.h"
#import "HONBackNavButtonView.h"
#import "HONCloseNavButtonView.h"
#import "HONComposeNavButtonView.h"
#import "HONDoneNavButtonView.h"
#import "HONDownloadNavButton.h"
#import "HONFlagNavButtonView.h"
#import "HONMoreNavButtonView.h"
#import "HONNextNavButtonView.h"
#import "HONSettingsNavButtonView.h"

@interface HONHeaderView()
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *titleImageView;
@property (nonatomic, strong) UIButton *titleButton;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) HONActivityNavButtonView *activityNavButtonView;
@end

@implementation HONHeaderView
@synthesize title = _title;

- (id)initWithBranding {
	if ((self = [self initWithTitleImage:[UIImage imageNamed:@"branding"]])) {
		_titleImageView.frame = CGRectOffset(_titleImageView.frame, 84.0, 21.0);
	}
	
	return (self);
}

- (id)init {
	if ((self = [super initWithFrame:CGRectFromSize(CGSizeMake(320.0, kNavHeaderHeight))])) {
		UIView *statusBarBGView = [[UIView alloc] initWithFrame:CGRectMake(0.0, -20.0, 320.0, 20.0)];
		statusBarBGView.backgroundColor = [UIColor colorWithRed:0.361 green:0.898 blue:0.576 alpha:1.00];
		[self addSubview:statusBarBGView];
		
		self.frame = CGRectOffset(self.frame, 0.0, 20.0);
		_bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navHeaderBackground"]];
		_bgImageView.frame = CGRectOffset(_bgImageView.frame, 0.0, -20.0);
		[self addSubview:_bgImageView];
		
		_title = @"";
		_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(55.0, 10.0, 210.0, 22.0)];
		_titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontMedium] fontWithSize:17];
		_titleLabel.textColor = [UIColor blackColor];
		_titleLabel.shadowOffset = CGSizeMake(0.0, 1.0);
		_titleLabel.textAlignment = NSTextAlignmentCenter;
		_titleLabel.hidden = YES;
		[self addSubview:_titleLabel];
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title {
	if ((self = [self init])) {
		_title = title;
		_titleLabel.text = _title;
		
		_titleLabel.hidden = ([_title length] == 0);
	}
	
	return (self);
}

- (id)initWithTitle:(NSString *)title asLightStyle:(BOOL)isLightStyle {
	if ((self = [self initWithTitle:title])) {
		_titleLabel.textColor = [UIColor whiteColor];
	}
	
	return (self);
}

- (id)initWithTitleImage:(UIImage *)image {
	if ((self = [self init])) {
		[self addTitleImage:image];
	}
	
	return (self);
}


- (void)addButton:(UIView *)buttonView {
//	buttonView.frame = CGRectOffset(buttonView.frame, 0.0, 20.0);
	[self addSubview:buttonView];
}

- (void)addActivityButtonWithTarget:(id)target action:(SEL)action {
	_activityNavButtonView = [[HONActivityNavButtonView alloc] initWithTarget:target action:action];
	[self addButton:_activityNavButtonView];
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

- (void)addDownloadButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONDownloadNavButton alloc] initWithTarget:target action:action]];
}

- (void)addFlagButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONFlagNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addMoreButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONMoreNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addNextButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONNextNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addSettingsButtonWithTarget:(id)target action:(SEL)action {
	[self addButton:[[HONSettingsNavButtonView alloc] initWithTarget:target action:action]];
}

- (void)addTitleButtonWithTarget:(id)target action:(SEL)action {
	_titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
	_titleButton.frame = _titleLabel.frame;
	[_titleButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	[self addSubview:_titleButton];
}


- (void)setTitle:(NSString *)title {
	_title = title;
	
	_titleLabel.text = _title;
	_titleLabel.hidden = ([_title length] == 0);
	_titleImageView.hidden = ([_title length] > 0);
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
	[self setTitle:@""];
	
	_titleImageView = [[UIImageView alloc] initWithImage:image];
	_titleImageView.frame = CGRectOffset(_titleImageView.frame, (self.frame.size.width - image.size.width) * 0.5, 22.0);
	[self addSubview:_titleImageView];
}

- (void)updateActivityScore:(int)score {
	if (_activityNavButtonView != nil)
		[_activityNavButtonView updateBadgeWithScore:score];
}

- (void)removeBackground {
	_bgImageView.hidden = YES;
}


- (void)tappedTitle {
	UIColor *orgColor = _titleLabel.textColor;
	
	_titleLabel.textColor = [[HONColorAuthority sharedInstance] darkenColor:_titleLabel.textColor byPercentage:0.33];
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kButtonSelectDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^(void) {
		_titleLabel.textColor = orgColor;
	});
}

@end
