//
//  HONPaginationView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/22/2014 @ 16:33 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONPaginationView.h"

@interface HONPaginationView ()
@property (nonatomic, retain) NSMutableArray *offImageViews;
@property (nonatomic, retain) NSMutableArray *onImageViews;
@property (nonatomic) BOOL isAnimating;
@end

@implementation HONPaginationView


- (id)initAtPosition:(CGPoint)pos withTotalPages:(int)totalPages {
	if ((self = [super initWithFrame:CGRectMake(pos.x, pos.y, totalPages * (DOT_DIAMETER + DOT_SPACING), DOT_DIAMETER)])) {
		self.frame = CGRectOffset(self.frame, (-self.frame.size.width * 0.5) + (DOT_SPACING * 0.5), -DOT_DIAMETER * 0.5);
		
		_isAnimating = NO;
		_currentPage = -1;
		_totalPages = totalPages;
		
		_offImageViews = [NSMutableArray arrayWithCapacity:_totalPages];
		_onImageViews = [NSMutableArray arrayWithCapacity:_totalPages];
		
		UIView *holderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
		[self addSubview:holderView];
		
		for (int i=0; i<_totalPages; i++) {
			UIImageView *offImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paginationLED_off"]];
			offImageView.frame = CGRectOffset(offImageView.frame, i * (DOT_DIAMETER + DOT_SPACING), 0.0);
			[offImageView setTag:i];
			[_offImageViews addObject:offImageView];
			[holderView addSubview:offImageView];
			
			UIImageView *onImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paginationLED_on"]];
			onImageView.frame = offImageView.frame;
			onImageView.alpha = 0.0;
			[offImageView setTag:i];
			[_onImageViews addObject:onImageView];
			[holderView addSubview:onImageView];
		}
	}
	
	return (self);
}


#pragma mark - Public APIs
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


@end
