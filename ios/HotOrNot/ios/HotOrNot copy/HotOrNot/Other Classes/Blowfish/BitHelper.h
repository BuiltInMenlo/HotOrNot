//
//  BitHelper.h
//  BlowfishTest
//
//  Created by Prabu Arumugam on 15/03/13.
//  Copyright (c) 2013 CODEDING. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BitHelper : NSObject

//helper-methods
+ (unsigned char)getByte0:(UInt32)w;
+ (unsigned char)getByte1:(UInt32)w;
+ (unsigned char)getByte2:(UInt32)w;
+ (unsigned char)getByte3:(UInt32)w;
+ (void)getBytesFromUInt32:(UInt32)val bytes:(unsigned char*)bytes;
+ (UInt32)getUInt32FromBytes:(unsigned char*)bytes;
+ (NSString*)bytesToHex:(unsigned char*)bytes length:(int)length;
+ (NSData*)hexToBytes:(NSString*)hex;
+ (char)getDecimal:(char)x;

//test-methods
+ (void)bitConversionTest;

@end
