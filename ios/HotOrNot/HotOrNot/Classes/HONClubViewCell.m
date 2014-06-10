//
//  HONClubViewCell.m
//  HotOrNot
//
//  Created by Matt Holcombe on 06/09/2014 @ 20:10 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


#import "HONClubViewCell.h"


@interface HONClubViewCell ()
@end

@implementation HONClubViewCell
@synthesize clubVO = _clubVO;

+ (NSString *)cellReuseIdentifier {
	return (NSStringFromClass(self));
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		self.backgroundColor = [[HONColorAuthority sharedInstance] honDebugColor:HONDebugOrangeColor];
	}
	
	return (self);
}

- (void)setClubVO:(HONUserClubVO *)clubVO {
	_clubVO = clubVO;
}


#pragma mark - Navigation



@end
