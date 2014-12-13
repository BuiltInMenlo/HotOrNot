//
//  HONBaseVO.m
//  HotOrNot
//
//  Created by BIM  on 12/12/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONBaseVO.h"

@implementation HONBaseVO
@synthesize dictionary;
@synthesize formattedProperties;

- (NSString *)toString {
	return ([NSString stringWithFormat:@"\n%@:\n[=-=-=-=-=-=-=-=+=-=-=-=-=-=-=-=]\n%@\n[=-=-=-=-=-=-=-=|=-=-=-=-=-=-=-=]", self.class, self.formattedProperties]);
}

@end
