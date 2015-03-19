//
//  NSCharacterSet+BuiltInMenlo.h
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

@interface NSCharacterSet (BuiltInMenlo)
+ (instancetype)invalidCharacterSet;
+ (instancetype)invalidCharacterSetWithLetters;
+ (instancetype)invalidCharacterSetWithNumbers;
+ (instancetype)invalidCharacterSetWithPunctuation;

+ (instancetype)characterSetCombiningStringChars:(NSString *)appendChars;
+ (instancetype)characterSetExcludingStringChars:(NSString *)dropChars;


- (NSCharacterSet *)addChars:(NSString *)appendChars;
- (NSCharacterSet *)dropChars:(NSString *)excludeChars;

- (NSArray *)arrayFromCharacterSet;
- (NSString *)stringFromCharacterSet;

@end
