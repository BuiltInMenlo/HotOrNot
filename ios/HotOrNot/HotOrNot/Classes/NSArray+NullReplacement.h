//
//  NSArray+NullReplacement.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (NullReplacement)
- (NSArray *)arrayByReplacingNullsWithBlanks;
@end
