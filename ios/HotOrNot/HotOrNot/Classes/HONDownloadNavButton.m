//
//  HONDownloadNavButton.m
//  HotOrNot
//
//  Created by BIM  on 2/3/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONDownloadNavButton.h"

@interface HONDownloadNavButton()
@end

@implementation HONDownloadNavButton

- (id)initWithTarget:(id)target action:(SEL)action {
	if ((self = [super initWithTarget:target action:action])) {
		[self setFrame:CGRectOffset(self.frame, 278.0, 0.0)];
		
		_button.frame = CGRectFromSize(CGSizeMake(44.0, 44.0));
		[_button setBackgroundImage:[UIImage imageNamed:@"downloadButton_nonActive"] forState:UIControlStateNormal];
		[_button setBackgroundImage:[UIImage imageNamed:@"downloadButton_Active"] forState:UIControlStateHighlighted];
	}
	
	return (self);
}

@end
