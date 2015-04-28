//
//  NSString+URLEncoding.m
//  Pods
//
//  Created by Anthony Wong on 2014-08-05.
//  Copyright (c) 2014 Kik Interactive Inc. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    CFStringRef encodedCfString = CFURLCreateStringByAddingPercentEscapes(NULL,
                                                                          (CFStringRef)self,
                                                                          NULL,
                                                                          (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                                                          CFStringConvertNSStringEncodingToEncoding(encoding));
    
    NSString *string = (NSString *)CFBridgingRelease(encodedCfString);
    return string;
}
@end
