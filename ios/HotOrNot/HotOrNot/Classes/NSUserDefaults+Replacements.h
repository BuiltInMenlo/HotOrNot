//
//  NSUserDefaults+NullReplacement.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (Replacements)
- (void)removeObjectForNonNullKey:(NSString *)key;
- (void)replaceObject:(id)object forNonNullKey:(NSString *)key;
- (void)setObject:(id)object forNullKey:(NSString *)key;
//- (void)swapObjectsForKeys:(const id [])keys;
- (void)swapObjectForKey:(NSString *)keyA withKey:(NSString *)keyB;
@end