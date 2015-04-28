//
//  NSString+URLEncoding.h
//  Pods
//
//  Created by Anthony Wong on 2014-08-05.
//  Copyright (c) 2014 Kik Interactive Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncoding)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;

@end
