//
//  NSDictionary+NullReplacement.h
//  HotOrNot
//
//  Created by Matt Holcombe on 10/28/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

@interface NSDictionary (NullReplacement)
- (NSDictionary *)dictionaryByReplacingNullsWithBlanks;
@end
