//
//  NSString+DataTypes.m
//  HotOrNot
//
//  Created by Matt Holcombe on 04/23/2014.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "NSString+DataTypes.h"

@implementation NSString (DataTypes)


unsigned long long unistrlen(unichar *chars) {
	unsigned long long length = 0llu;
	if(NULL == chars) return length;
	
	while(NULL != &chars[length])
		length++;
	
	return length;
}

- (NSString *)stringFromABAuthorizationStatus:(ABAuthorizationStatus)status {
	return ((status == kABAuthorizationStatusNotDetermined) ? @"NotDetermined" : (status == kABAuthorizationStatusDenied) ? @"Denied" : (status == kABAuthorizationStatusAuthorized) ? @"Authorized" : @"UNKNOWN");
}

- (NSString *)stringFromBOOL:(BOOL)boolVal {
	return ((boolVal) ? @"YES" : @"NO");
}

- (NSString *)stringFromClass:(NSObject *)object {
	return ([NSString stringWithFormat:@"%@", object.class]);
}

- (NSString *)stringFromCLAuthorizationStatus:(CLAuthorizationStatus)status {
	return ((status == kCLAuthorizationStatusAuthorized) ? @"Authorized" : (status == kCLAuthorizationStatusAuthorizedAlways) ? @"AuthorizedAlways" : (status == kCLAuthorizationStatusAuthorizedWhenInUse) ? @"AuthorizedWhenInUse" : (status == kCLAuthorizationStatusDenied) ? @"Denied" : (status == kCLAuthorizationStatusRestricted) ? @"Restricted" : (status == kCLAuthorizationStatusNotDetermined) ? @"NotDetermined" : @"UNKNOWN");
}

- (NSString *)stringFromCLLocation:(CLLocation *)location {
	return ([NSString stringWithFormat:@"%.04f, %.04f", location.coordinate.longitude, location.coordinate.latitude]);
}

- (NSString *)stringFromCGFloat:(CGFloat)floatVal {
	return ([[[NSString alloc] init] stringFromFloat:(float)floatVal]);
}

- (NSString *)stringFromDictionary:(NSDictionary *)dictionary {
	return ([NSString stringWithFormat:@"%@", dictionary]);
}

- (NSString *)stringFromDouble:(double)doubleVal {
	return ([[[NSString alloc] init] stringFromFloat:(double)doubleVal]);
}

- (NSString *)stringFromFloat:(float)floatVal {
	return ([NSString stringWithFormat:@"%f", floatVal]);
}

- (NSString *)stringFromIndexPath:(NSIndexPath *)indexPath {
	return ([NSString stringWithFormat:@"(%ld × %ld)", (long)indexPath.section, (long)indexPath.row]);
}

- (NSString *)stringFromInt:(int)intVal {
	return ([NSString stringWithFormat:@"%d", intVal]);
}

- (NSString *)stringFromHex:(unichar *)hexVal {
	return ([NSString stringWithCharacters:hexVal length:unistrlen(hexVal)]);
}

- (NSString *)stringFromNSNumber:(NSNumber *)number includeDecimal:(BOOL)isDecimal {
	return ((isDecimal) ? [@"" stringFromFloat:[number floatValue]] : [@"" stringFromInt:[number intValue]]);
}

@end
