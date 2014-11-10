//
//  NSString+Formatting.h
//  HotOrNot
//
//  Created by BIM  on 10/30/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Formatting)
//- (instancetype)newStringByTrimmingFinalSubstring:(NSString *)substring;
- (BOOL)isValidEmailAddress;
- (NSString *)stringByTrimmingFinalSubstring:(NSString *)substring;
- (void)trimFinalSubstring:(NSString *)substring;
- (NSString *)normalizedPhoneNumber;
- (NSDictionary *)parseAsQueryString;
@end
