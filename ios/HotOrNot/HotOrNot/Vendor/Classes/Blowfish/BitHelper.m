//
//  BitHelper.m
//  BlowfishTest
//
//  Created by Prabu Arumugam on 15/03/13.
//  Copyright (c) 2013 CODEDING. All rights reserved.
//

#import "BitHelper.h"

@implementation BitHelper

////////////////
//helper-methods

+ (unsigned char)getByte0:(UInt32)w
{
    //gets the first byte in a uint
    return (unsigned char)(w / 256 / 256 / 256 % 256);
}

+ (unsigned char)getByte1:(UInt32)w
{
    //gets the second byte in a uint
    return (unsigned char)(w / 256 / 256 % 256);
}

+ (unsigned char)getByte2:(UInt32)w
{
    //gets the third byte in a uint
    return (unsigned char)(w / 256 % 256);
}

+ (unsigned char)getByte3:(UInt32)w
{
    //gets the fourth byte in a uint
    return (unsigned char)(w % 256);
}

+ (void)getBytesFromUInt32:(UInt32)val bytes:(unsigned char*)bytes
{
    bytes[0] = [self getByte3:val];
    bytes[1] = [self getByte2:val];
    bytes[2] = [self getByte1:val];
    bytes[3] = [self getByte0:val];
}

+ (UInt32)getUInt32FromBytes:(unsigned char*)bytes
{
    UInt32 value =
    ((bytes[0] & (uint)0xFF) << 0) |
    ((bytes[1] & (uint)0xFF) << 8) |
    ((bytes[2] & (uint)0xFF) << 16) |
    ((bytes[3] & (uint)0xFF) << 24);
    return value;
}

+ (NSString*)bytesToHex:(unsigned char*)bytes length:(int)length
{
    NSMutableString *hex = [NSMutableString new];
    for (int i=0; i < length; i++)
    {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    return hex;
}

+ (NSData*)hexToBytes:(NSString*)hex
{
    unsigned char r[hex.length / 2];
    for (int i = 0; i < hex.length - 1; i += 2)
    {
        char a = [self getDecimal:[hex characterAtIndex:i]];
        char b = [self getDecimal:[hex characterAtIndex:i + 1]];
        r[i / 2] = (char)(a * 16 + b);
    }
    
    NSData *hexData = [NSData dataWithBytes:&r length:hex.length / 2];
    return hexData;
}

//converts a single hex character to it's decimal value
+ (char)getDecimal:(char)x
{
    if (x <= '9' && x >= '0')
    {
        return (char)(x - '0');
    }
    else if (x <= 'z' && x >= 'a')
    {
        return (char)(x - 'a' + 10);
    }
    else if (x <= 'Z' && x >= 'A')
    {
        return (char)(x - 'A' + 10);
    }
    return 0;
}

//////////////
//test methods

+ (void)bitConversionTest
{
    NSString *text = @"test";
    NSData *data = [text dataUsingEncoding:NSASCIIStringEncoding];
    unsigned char *bytes = (unsigned char *)data.bytes;
    
    unsigned char block1[4];
    memset(block1, 0, 4);
    memcpy(block1, &bytes[1], 3);
    
    unsigned char newBytes[data.length];
    [data getBytes:&newBytes range:NSMakeRange(0, text.length)]; //blockcopy
    
    UInt32 bit32 = [BitHelper getUInt32FromBytes:bytes];
    NSLog(@"bit32: %d", (unsigned int)bit32);
    
    unsigned char convertedBytes[4];
    [self getBytesFromUInt32:bit32 bytes:convertedBytes];
    
    unsigned char copiedBytes[4];
    memset(&copiedBytes, 0, 4);
    memcpy(&copiedBytes, &convertedBytes[2], 2);
    
    for (int i = 0; i < data.length; i++)
    {
        char ch = bytes[i];
        NSLog(@"char: %d", ch);
        
        char ch_new = newBytes[i];
        NSLog(@"char_new: %d", ch_new);
        
        char ch_converted = convertedBytes[i];
        NSLog(@"char_converted: %d", ch_converted);
        
        char ch_copied = copiedBytes[i];
        NSLog(@"char_copied: %d", ch_copied);
    }
}

@end
