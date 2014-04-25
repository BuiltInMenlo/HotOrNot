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



- (id)initWithInt:(int)intVal {
	if ((self = [super init])) {
	}
	
	return ([self stringFromInt:intVal]);
}

- (NSString *)stringFromBOOL:(BOOL)boolVal {
	return ((boolVal) ? @"YES" : @"NO");
}

- (NSString *)stringFromCGFloat:(CGFloat)floatVal {
	return ([[[NSString alloc] init] stringFromFloat:(float)floatVal]);
}

- (NSString *)stringFromDouble:(double)doubleVal {
	return ([[[NSString alloc] init] stringFromFloat:(double)doubleVal]);
}

- (NSString *)stringFromFloat:(float)floatVal {
	return ([NSString stringWithFormat:@"%f", floatVal]);
}

- (NSString *)stringFromInt:(int)intVal {
	return ([NSString stringWithFormat:@"%d", intVal]);
}

- (NSString *)stringFromHex:(unichar *)hexVal {
	return ([NSString stringWithCharacters:hexVal length:unistrlen(hexVal)]);
}

@end