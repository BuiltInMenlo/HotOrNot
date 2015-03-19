//
//  NSCharacterSet+BuiltInMenlo.m
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSCharacterSet+BuiltinMenlo.h"

@implementation NSCharacterSet (BuiltInMenlo)

+ (instancetype)invalidCharacterSet {
	return ([NSCharacterSet characterSetWithCharactersInString:[[[[NSUserDefaults standardUserDefaults] objectForKey:@"invalid_chars"] componentsJoinedByString:@""] stringByAppendingString:@"\\"]]);
}

+ (instancetype)invalidCharacterSetWithLetters {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet letterCharacterSet]];
	
	return ([charSet copy]);
}

+ (instancetype)invalidCharacterSetWithNumbers {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet decimalDigitCharacterSet]];
	
	return ([charSet copy]);
}

+ (instancetype)invalidCharacterSetWithPunctuation {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
	
	return ([charSet copy]);
}


+ (instancetype)characterSetCombiningStringChars:(NSString *)appendChars {
	return ([self characterSetCombiningStringChars:appendChars]);
}

+ (instancetype)characterSetExcludingStringChars:(NSString *)dropChars {
	return ([self characterSetExcludingStringChars:dropChars]);
}

- (NSCharacterSet *)addChars:(NSString *)appendChars {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet formUnionWithCharacterSet:[NSCharacterSet characterSetWithCharactersInString:appendChars]];
	
	return ([charSet copy]);
}

- (NSCharacterSet *)dropChars:(NSString *)excludeChars; {
	NSMutableCharacterSet *charSet = [[NSCharacterSet invalidCharacterSet] mutableCopy];
	[charSet removeCharactersInString:excludeChars];
	
	return ([charSet copy]);
}

- (NSArray *)arrayFromCharacterSet {
	unichar unicharBuffer[20];
	int index = 0;
	
	NSString *characters = [NSString stringWithCharacters:unicharBuffer length:index];
	for (unichar uc=0; uc<(0xFFFF); uc++) {
		if ([self characterIsMember:uc]) {
			unicharBuffer[index] = uc;
			index++;
			
			if (index == 20) {
				characters = [NSString stringWithCharacters:unicharBuffer length:index];
				index = 0;
			}
		}
	}
	
//	if (index != 0) {
//		NSString *characters = [NSString stringWithCharacters:unicharBuffer length:index];
//	}
	
	return ([characters componentsSeparatedByString:@""]);
}

- (NSString *)stringFromCharacterSet {
	return ([[self arrayFromCharacterSet] componentsJoinedByString:@""]);
}

@end
