//
//  HONCollectionView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014 @ 20:21 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONCollectionView.h"


@interface HONCollectionView ()
@end

@implementation HONCollectionView

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
	}
	
	return (self);
}


#pragma mark - Overrides
- (void)setContentInset:(UIEdgeInsets)contentInset {
	if (self.tracking) {
		CGPoint translation = [self.panGestureRecognizer translationInView:self];
		translation.y -= ((contentInset.top - self.contentInset.top) * 1.25);
		[self.panGestureRecognizer setTranslation:translation inView:self];
	}
	
	[super setContentInset:contentInset];
}


@end
