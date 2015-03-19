//
//  HONButton.m
//  HotOrNot
//
//  Created by BIM  on 3/18/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "HONButton.h"

@implementation HONButton

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state {
	[super setBackgroundImage:image forState:state];
	
//	CGPoint offset = CGPointMake((self.frame.size.width - image.size.width) * 0.5, (self.frame.size.height - image.size.height) * 0.5);
	CGPoint offset = CGPointMake(0.0, 0.0);
//	NSLog(@"setBackgroundImage:[%@] -[%@]- [%@]\n\n\n", NSStringFromCGRect(self.frame), NSStringFromCGSize(image.size), NSStringFromCGRect(CGRectMake(self.frame.origin.x + offset.x, self.frame.origin.y + offset.y, round(image.size.width), round(image.size.height))));
	[super setFrame:CGRectMake(round(self.frame.origin.x + offset.x), round(self.frame.origin.y + offset.y), round(image.size.width), round(image.size.height))];
}

@end
