//
//  NSCharacterSet+GameShare.h
//  GameShare
//
//  Created by Matt Holcombe on 11/24/14.
//  Copyright (c) 2014. All rights reserved.
//

@interface NSCharacterSet (GameShare)

+ (instancetype)base64CharacterSet;
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
