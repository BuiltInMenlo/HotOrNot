//
//  HONLoadingOverlayView.m
//  HotOrNot
//
//  Created by BIM  on 1/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "MBProgressHUD.h"

#import "UILabel+BuiltinMenlo.h"
#import "UIView+BuiltinMenlo.h"

#import "HONLoadingOverlayView.h"

@interface HONLoadingOverlayView()
@property (nonatomic, strong) MBProgressHUD *progressHUD;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) BOOL isAnimated;
@end

@implementation HONLoadingOverlayView
@synthesize delegate = _delegate;

- (id)init {
	if ((self = [self initWithCaption:@""])) {
	}
	
	return (self);
}


- (id)initAsAnimated:(BOOL)isAnimated {
	if ((self = [self initAsAnimated:isAnimated withCaption:@""])) {
	}
	
	return (self);
}

- (id)initAsAnimated:(BOOL)isAnimated withCaption:(NSString *)caption {
	if ((self = [self initWithinView:[[UIApplication sharedApplication] delegate].window isAnimated:isAnimated withCaption:caption])) {
	}
	
	return (self);
}


- (id)initWithCaption:(NSString *)caption {
	if ((self = [self initAsAnimated:YES withCaption:caption])) {
	}
	
	return (self);
}


- (id)initWithinView:(UIView *)view {
	if ((self = [self initWithinView:view isAnimated:YES])) {
	}
	
	return (self);
}

- (id)initWithinView:(UIView *)view isAnimated:(BOOL)isAnimated {
	if ((self = [self initWithinView:view isAnimated:isAnimated withCaption:@""])) {
	}
	
	return (self);
}

- (id)initWithinView:(UIView *)view withCaption:(NSString *)caption {
	if ((self = [self initWithinView:view isAnimated:YES withCaption:caption])) {
	}
	
	return (self);
}

- (id)initWithinView:(UIView *)view isAnimated:(BOOL)isAnimated withCaption:(NSString *)caption {
	if ((self = [super initWithFrame:view.bounds])) {
		_caption = caption;
		_isAnimated = isAnimated;
		
		self.alpha = 0.0;
		self.backgroundColor = [UIColor colorWithWhite:0.00 alpha:0.90];
		[view addSubview:self];
		
		_label = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 260.0, 280.0, 20.0)];
		_label.backgroundColor = [UIColor clearColor];
		_label.textColor = [UIColor whiteColor];
		_label.font = [[[HONFontAllocator sharedInstance] cartoGothicBook] fontWithSize:17];
		_label.text = _caption;
		[_label resizeFrameForText];
		[self addSubview:_label];
		[_label centerAlignWithinParentView];
		
		if ([_caption length] == 0) {
			if (_progressHUD == nil)
				_progressHUD = [MBProgressHUD showHUDAddedTo:self animated:YES];
			_progressHUD.labelText = @"";
			_progressHUD.mode = MBProgressHUDModeIndeterminate;
			_progressHUD.minShowTime = kProgressHUDMinDuration;
			_progressHUD.taskInProgress = YES;
		}
		
		[UIView animateKeyframesWithDuration:((int)_isAnimated) * 0.125
									   delay:0.000
									 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
								  animations:^(void) {
									  self.alpha = 1.0;
									  
								  } completion:^(BOOL finished) {
									  _timer = [NSTimer timerWithTimeInterval:[HONAPICaller timeoutInterval] target:self
																	 selector:@selector(_goTimeout)
																	 userInfo:nil repeats:NO];
									  
									  if ([self.delegate respondsToSelector:@selector(loadingOverlayViewDidIntro:)])
										  [self.delegate loadingOverlayViewDidIntro:self];
								  }];
	}
	
	return (self);
}

#pragma mark - Public APIs
- (void)outro {
	if ([_timer isValid])
		[_timer invalidate];
	
	if (_timer != nil);
	_timer = nil;
	
	[self _decompose];
}


#pragma mark - UI Presentation
- (void)_goTimeout {
	if ([_timer isValid])
		[_timer invalidate];
	
	if (_timer != nil);
	_timer = nil;
	
	[self _decompose];
}

- (void)_decompose {
	NSLog(@"::|> _decompose <|::");
	
	[UIView animateKeyframesWithDuration:(((int)_isAnimated) * 0.125) * ((int)(self.alpha > 0.0))
								   delay:0.000
								 options:(UIViewAnimationOptionAllowAnimatedContent|UIViewAnimationOptionAllowUserInteraction|UIViewAnimationCurveEaseOut)
							   animations:^(void) {
		self.alpha = 0.0;
		
	} completion:^(BOOL finished) {
		if (_progressHUD != nil) {
			[_progressHUD hide:YES];
			_progressHUD = nil;
		}
		
		[self removeFromSuperview];
		
		if ([self.delegate respondsToSelector:@selector(loadingOverlayViewDidOutro:)])
			[self.delegate loadingOverlayViewDidOutro:self];
	}];
}

@end
