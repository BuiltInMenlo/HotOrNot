//
//  NSString+Validate.m
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)

- (BOOL)isValidEmailAddress {
	BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
	
	return ([[NSPredicate predicateWithFormat:@"SELF MATCHES %@", (stricterFilter) ? @"^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,4})$" : @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*"]
			 evaluateWithObject:self]);
}

@end
