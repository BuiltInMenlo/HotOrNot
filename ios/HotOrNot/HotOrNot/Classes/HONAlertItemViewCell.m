//
//  HONAlertItemViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 12/02/2013 @ 20:11 .
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONAlertItemViewCell.h"

@interface HONAlertItemViewCell ()
@end

@implementation HONAlertItemViewCell

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
