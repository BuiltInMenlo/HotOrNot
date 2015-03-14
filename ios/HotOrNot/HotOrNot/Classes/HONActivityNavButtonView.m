//
//  HONActivityNavButtonView.m
//  HotOrNot
//
//  Created by Matt Holcombe on 9/1/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//


#import "HONActivityNavButtonView.h"

@interface HONActivityNavButtonView ()
@property (nonatomic, strong) UIImageView *bgImageView;
@end

@implementation HONActivityNavButtonView

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 10.0, 0.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(128.0, 44.0));
		[_button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
		[_button setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
		_button.titleLabel.font = [[[HONFontAllocator sharedInstance] helveticaNeueFontRegular] fontWithSize:17];
		_button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[_button setTitle:[NSString stringWithFormat:@"Score: %d", 0] forState:UIControlStateNormal];
		[_button setTitle:[NSString stringWithFormat:@"Score: %d", 0] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

- (void)updateBadgeWithScore:(int)score {
	[_button setTitle:[NSString stringWithFormat:@"Score: %d", score] forState:UIControlStateNormal];
	[_button setTitle:[NSString stringWithFormat:@"Score: %d", score] forState:UIControlStateHighlighted];
}

@end
