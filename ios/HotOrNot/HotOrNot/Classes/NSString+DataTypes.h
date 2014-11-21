//
//  NSString+DataTypes.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import <CoreLocation/CoreLocation.h>

@interface NSString (DataTypes)
unsigned long long unistrlen(unichar *chars);
- (NSString *)stringFromABAuthorizationStatus:(ABAuthorizationStatus)status;
- (NSString *)stringFromBOOL:(BOOL)boolVal;
- (NSString *)stringFromClass:(NSObject *)object;
- (NSString *)stringFromCLAuthorizationStatus:(CLAuthorizationStatus)status;
- (NSString *)stringFromCLLocation:(CLLocation *)location;
- (NSString *)stringFromCGFloat:(CGFloat)floatVal;
- (NSString *)stringFromDictionary:(NSDictionary *)dictionary;
- (NSString *)stringFromDouble:(double)doubleVal;
- (NSString *)stringFromFloat:(float)floatVal;
- (NSString *)stringFromIndexPath:(NSIndexPath *)indexPath;
- (NSString *)stringFromInt:(int)intVal;
- (NSString *)stringFromHex:(unichar *)hexVal;
- (NSString *)stringFromNSNumber:(NSNumber *)number includeDecimal:(BOOL)isDecimal;
@end
