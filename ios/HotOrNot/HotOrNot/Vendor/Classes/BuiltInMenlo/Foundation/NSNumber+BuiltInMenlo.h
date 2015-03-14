//
//  NSNumber+BuiltInMenlo.h
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

@interface NSNumber (BuiltInMenlo)

+ (instancetype)randomIntegerWithinRange:(NSRange)range;

- (NSUInteger)factorial;
- (NSUInteger)gcfWithNumber:(NSInteger)number;
- (BOOL)isEven;
- (BOOL)isPrime;
- (NSUInteger)lcmWithNumber:(NSInteger)number;
- (NSNumber *)reverseNumber;
- (NSUInteger)sumOfDigits;
@end
