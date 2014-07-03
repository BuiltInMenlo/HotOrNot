//
//  PCModelObject.h
//  CandyStoreDemoApp
//
//  Created by PicoCandy Pte Ltd on 12/11/13.
//  Copyright (c) 2014 PicoCandy Pte Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PCModelObject : NSObject

+(id)objectFromJSON:(NSDictionary *)dict;
+(id)objectFromJSONString:(NSString *)json;
+(NSArray *)arrayFromJSON:(NSArray *)array;

-(id)initWIthJSON: (id)jsonObject;
-(id)encodeAsJSON;

- (void)serialize;
- (void)deserialize;

@end
