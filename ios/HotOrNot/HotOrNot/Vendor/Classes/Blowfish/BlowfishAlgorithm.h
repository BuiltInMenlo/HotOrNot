//
//  BlowfishAlgorithm.h
//  BlowfishTest
//
//  Created by Prabu Arumugam on 14/03/13.
//  Copyright (c) 2013 CODEDING. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BitHelper.h"

enum BlowfishMode
{
    BlowfishModeNone,
    BlowfishModeECB, //electronic-code-book method
    BlowfishModeCBC  //cipher-block-chaining method
};

@interface BlowfishAlgorithm : NSObject
{
@private
    UInt32 bf_P[18];
    UInt32 bf_S0[256];
    UInt32 bf_S1[256];
    UInt32 bf_S2[256];
    UInt32 bf_S3[256];
    
    UInt32 xl_par;
    UInt32 xr_par;
}

//properties
@property (nonatomic) enum BlowfishMode Mode;
@property (nonatomic, retain) NSString *Key;
@property (nonatomic, retain) NSString *InitVector;

//methods
- (void)setupKey;
- (NSString*)encrypt:(NSString*)plainText;
- (NSString*)decrypt:(NSString*)cipherText;
- (NSData*)crypt_ECB:(unsigned char*)inputBytes inputLength:(int)inputLength decrypt:(BOOL)decrypt;
- (NSData*)crypt_CBC:(unsigned char*)inputBytes inputLength:(int)inputLength decrypt:(BOOL)decrypt;
- (void)xorBlock:(unsigned char*)block iv:(unsigned char*)iv;
- (void)blockEncrypt:(unsigned char*)block;
- (void)blockDecrypt:(unsigned char*)block;
- (void)setBlock:(unsigned char*)block;
- (void)getBlock:(unsigned char*)block;
- (void)encipher;
- (void)decipher;
- (UInt32)round:(UInt32)a b:(UInt32)b n:(UInt32)n;

//helper-methods

+ (enum BlowfishMode)buildModeEnum:(NSString*)modeString;

@end
