//
//  NSCharacterSet+AdditionalSets.h
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface NSCharacterSet (AdditionalSets)
+ (instancetype) invalidCharacterSet;
+ (instancetype) invalidCharacterSetWithLetters;
+ (instancetype) invalidCharacterSetWithNumbers;
+ (instancetype) invalidCharacterSetWithPunctuation;
@end
