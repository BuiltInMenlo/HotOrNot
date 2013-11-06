//
//  HONGenericAvatarViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 11/5/13 @ 9:56 PM.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import "HONGenericAvatarViewCell.h"

@interface HONGenericAvatarViewCell ()
@end

@implementation HONGenericAvatarViewCell

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}


- (id)init {
	if ((self = [super init])) {
		
	}
	
	return (self);
}


@end
