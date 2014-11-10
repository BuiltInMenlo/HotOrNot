//
//  HONPaginationView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/22/2014 @ 16:33 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONPaginationView.h"

@interface HONPaginationView ()
@property (nonatomic, retain) NSMutableArray *dotImageViews;
@property (nonatomic, retain) NSMutableArray *offImageViews;
@property (nonatomic, retain) NSMutableArray *onImageViews;
@property (nonatomic) BOOL isAnimating;
@end

@implementation HONPaginationView
@synthesize diameter = _diameter;
@synthesize padding = _padding;

- (id)initAtPosition:(CGPoint)pos withTotalPages:(int)totalPages usingDiameter:(CGFloat)diameter andPadding:(CGFloat)padding {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, totalPages * (diameter + padding), diameter)])) {
		self.frame = CGRectOffset(self.frame, (-self.frame.size.width * 0.5) + (padding * 0.5), -diameter * 0.5);
		
		_diameter = diameter;
		_padding = padding;
		
		_isAnimating = NO;
		_currentPage = -1;
		_totalPages = totalPages;
		
		_dotImageViews = [NSMutableArray arrayWithCapacity:_totalPages];
		_offImageViews = [NSMutableArray arrayWithCapacity:_totalPages];
		_onImageViews = [NSMutableArray arrayWithCapacity:_totalPages];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectFromSize(self.frame.size)];
		[self addSubview:holderView];
		
		for (int i=0; i<_totalPages; i++) {
			UIImageView *offImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paginationLED_off"]];
			offImageView.frame = CGRectMake(i * (_diameter + _padding), 0.0, _diameter, _diameter);
			[offImageView setTag:i];
			[_offImageViews addObject:offImageView];
			[holderView addSubview:offImageView];
			
			UIImageView *onImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paginationLED_on"]];
			onImageView.frame = offImageView.frame;
			onImageView.alpha = 0.0;
			[offImageView setTag:i];
			[_onImageViews addObject:onImageView];
			[holderView addSubview:onImageView];
			
			[_dotImageViews addObject:@[offImageView, onImageView]];
		}
	}
	
	return (self);
}


#pragma mark - Public APIs
- (void)setDiameter:(CGFloat)diameter {
	_diameter = diameter;
	[self _updateLayout];
}

- (void)setPadding:(CGFloat)padding {
	_padding = padding;
	[self _updateLayout];
}

- (void)updateToPage:(int)page {
	if (page != _currentPage) {
		_currentPage = page;
		
		for (UIImageView *onImageView in _onImageViews) {
			[UIView animateWithDuration:OFF_DURATION
							 animations:^(void) {
								 onImageView.alpha = 0.0;
							 } completion:^(BOOL finished) {
							 }];
		}
		
		[UIView animateWithDuration:ON_DURATION delay:OFF_DURATION options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionAllowAnimatedContent
						 animations:^(void) {
							 ((UIImageView *)[_onImageViews objectAtIndex:_currentPage]).alpha = 1.0;
						 } completion:^(BOOL finished) {
						 }];
	}
}


#pragma mark - UI Presentation
- (void)_updateLayout {
	self.frame = CGRectOffset(self.frame, (-self.frame.size.width * 0.5) + (_padding * 0.5), -_diameter * 0.5);
	
	[_dotImageViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSArray *dots = (NSArray *)obj;
		
		for (UIImageView *dotImageView in dots)
			dotImageView.frame = CGRectMake(idx * (_diameter + _padding), 0.0, _diameter, _diameter);
	}];
}


@end
