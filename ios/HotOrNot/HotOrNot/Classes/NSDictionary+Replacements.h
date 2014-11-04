//
//  NSDictionary+Replacements.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (Replacements)
- (void)defineObject:(id)object forUnknownKey:(NSString *)key;
- (void)removeObjectForExistingKey:(NSString *)key;
- (void)replaceObject:(id)object forExistingKey:(NSString *)key;
- (void)setObject:(id)object forNonExistingKey:(NSString *)key;
//- (void)swapObjectsForKeys:(const id [])keys;
- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB;
@end
