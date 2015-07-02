//
//  NSData+GameShare.h
//  GameShare
//
//  Created by Matt Holcombe on 11/4/14.
//  Copyright (c) 2014. All rights reserved.
//

void *base64Decode(
	const char *inputBuffer,
	size_t length,
	size_t *outputLength);

char *base64Encode(
	const void *inputBuffer,
	size_t length,
	bool separateLines,
	size_t *outputLength);

@interface NSData (GameShare)

+ (NSData *)dataFromBase64String:(NSString *)aString;
- (NSString *)base64EncodedString;

- (NSString *)base64EncodedStringWithSeparateLines:(BOOL)separateLines;

@end

