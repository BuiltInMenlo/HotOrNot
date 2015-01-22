//
//  NSUserDefaults+NullReplacement.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSMutableDictionary+Replacements.h"

@interface NSUserDefaults (Replacements)
- (BOOL)hasObjectForKey:(NSString *)key;

- (void)addObject:(id)object forKey:(NSString *)key;
- (void)defineObject:(id)object forKey:(NSString *)key;
//- (BOOL)hasObjectForKey:(NSString *)key;
- (void)replaceObject:(id)object forKey:(NSString *)key;
- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB;
- (void)addObjects:(NSArray *)objects withKeys:(NSArray *)keys;
- (void)purgeObjectsWithKeys:(NSArray *)keys;
- (void)replaceObjects:(NSArray *)objects withKeys:(NSArray *)keys;

@end