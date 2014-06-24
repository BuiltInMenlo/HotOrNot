//
//  HONTableView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/16/2014 @ 20:57 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONTableView.h"


@interface HONTableView ()
@end

@implementation HONTableView

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
	if ((self = [super initWithFrame:frame style:style])) {
		[self setBackgroundColor:[UIColor clearColor]];
		self.separatorStyle = UITableViewCellSeparatorStyleNone;
		self.showsHorizontalScrollIndicator = YES;
		self.alwaysBounceVertical = YES;
	}
	
	return (self);
}


#pragma mark - Overrides
- (void)setContentInset:(UIEdgeInsets)contentInset {
	if (self.tracking) {
//		CGFloat diff = contentInset.top - self.contentInset.top;
		
		CGPoint translation = [self.panGestureRecognizer translationInView:self];
		translation.y -= ((contentInset.top - self.contentInset.top) * 1.5);
		[self.panGestureRecognizer setTranslation:translation inView:self];
	}
	
	[super setContentInset:contentInset];
}


#pragma mark - Navigation



@end
