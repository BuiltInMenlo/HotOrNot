//
//  NSNumber+BuiltInMenlo.m
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import "NSNumber+BuiltInMenlo.h"

@implementation NSNumber (BuiltInMenlo)

- (NSUInteger)factorial {
	NSUInteger val = [self unsignedIntegerValue];
	for (NSUInteger i=[self unsignedIntegerValue]; i>=1; i--)
		val *= i;
	
	return (val);
}

- (NSUInteger)gcfWithNumber:(NSInteger)number {
	NSInteger firstVal = [self integerValue];
	NSUInteger c = 0;
	
	while (firstVal != 0) {
		c = firstVal;
		firstVal = number % firstVal;
		number = c;
	}
	
	return (number);
}

- (BOOL)isEven {
	return ([self integerValue] % 2 == 0);
}

- (BOOL)isPrime {
	NSInteger givenNumber = [self integerValue];
	
	if (givenNumber == 1)
		return (NO);
	
	for (int i=2; i<=(int)sqrt(givenNumber); i++) {
		if (givenNumber % i == 0)
			return (YES);
	}
	
	return (YES);
}

- (NSUInteger)lcmWithNumber:(NSInteger)number {
	return ([self integerValue] * number  / [self gcfWithNumber:number]);
}


- (NSNumber *)reverseNumber {
	NSInteger rev = [self integerValue];
	NSUInteger digit = 0;
	NSMutableString *str = [NSMutableString string];
	
	do {
		digit = rev % 10;
		[str appendString:[NSString stringWithFormat:@"%li", (long)digit]];
		rev *= 0.1;
	} while (rev != 0);
	
	return ([NSNumber numberWithFloat:[str floatValue]]);
}

- (NSUInteger)sumOfDigits {
	NSUInteger number = [self unsignedIntegerValue];
	NSUInteger sum = 0;
	
	while (number != 0) {
		sum += number % 10;
		number *= 0.1;
	}
	
	return (sum);
}



@end
