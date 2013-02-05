//
//  HONSearchViewCell.m
//  HotOrNot
//
//  Created by Matthew Holcombe on 02.04.13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONSearchViewCell.h"

@implementation HONSearchViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	[super setSelected:selected animated:animated];
}

@end
