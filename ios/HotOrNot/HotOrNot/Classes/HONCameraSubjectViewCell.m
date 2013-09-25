//
//  HONCameraSubjectViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 8/24/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "UIImageView+AFNetworking.h"

#import "HONCameraSubjectViewCell.h"

@implementation HONCameraSubjectViewCell

@synthesize subject = _subject;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initAsEvenRow:(BOOL)isEven {
	if ((self = [super init])) {
		self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:(0.15 * isEven)];
	}
	
	return (self);
}

- (void)setSubject:(NSDictionary *)subject {
	_subject = subject;
	
	UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(3.0, 9.0, 44.0, 44.0)];
	[imageView setImageWithURL:[NSURL URLWithString:[_subject objectForKey:@"img"]] placeholderImage:nil];
	[self.contentView addSubview:imageView];
	
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50.0, 19.0, 200.0, 24.0)];
	label.font = [[HONAppDelegate helveticaNeueFontRegular] fontWithSize:19];
	label.textColor = [HONAppDelegate honGrey608Color];
	label.backgroundColor = [UIColor clearColor];
	label.text = [_subject objectForKey:@"text"];
	[self.contentView addSubview:label];
}

- (void)showTapOverlay {
	UIView *tappedOverlayView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 320.0, self.frame.size.height)];
	tappedOverlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.67];
	[self.contentView addSubview:tappedOverlayView];
	
	[UIView animateWithDuration:0.125 animations:^(void) {
		tappedOverlayView.alpha = 0.0;
	} completion:^(BOOL finished) {
		[tappedOverlayView removeFromSuperview];
	}];
}

@end
