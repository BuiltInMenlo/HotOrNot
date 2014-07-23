//
//  NSObject+PCObjectMap.h
//  CandyStoreDemoApp
//
//  Created by PicoCandy Pte Ltd on 12/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#define PCDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSS"
#define PCTimeZone @"UTC"

@interface NSObject (PCObjectMap)

// Universal Method
-(NSDictionary *)propertyDictionary;
-(NSString *)nameOfClass;

// id -> Object
+(id)objectOfClass:(NSString *)object fromJSON:(NSDictionary *)dict;
+(NSArray *)arrayFromJSON:(NSArray *)jsonArray ofObjects:(NSString *)obj;
+(NSDictionary *)dictionaryWithPropertiesOfObject:(id)obj;

//Object -> Data
-(NSDictionary *)objectDictionary;
-(NSData *)JSONData;
-(NSString *)JSONString;

// For mapping an array to properties
-(NSMutableDictionary *)getPropertyArrayMap;

-(NSString *)classOfPropertyNamed:(NSString *)propName;

// Copying an NSObject to new memory ref
// (basically initWithObject)
-(id)initWithObject:(NSObject *)oldObject error:(NSError **)error;

// Base64 Encode/Decode
+(NSString *)encodeBase64WithData:(NSData *)objData;
+(NSData *)base64DataFromString:(NSString *)string;

@end

@interface SOAPObject : NSObject
@property (nonatomic, retain) id Header;
@property (nonatomic, retain) id Body;
@end