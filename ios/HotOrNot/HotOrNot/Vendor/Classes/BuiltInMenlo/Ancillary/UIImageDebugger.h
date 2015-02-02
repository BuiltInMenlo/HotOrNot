//
//  UIImageDebugger.h
//  HotOrNot
//
//  Created by BIM  on 1/29/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImageDebugger : NSObject
+ (void)startDebugging;
@end


@interface UIImage (UIViewDebugger)
+ (UIImage *)hs_xxz_imageNamed:(NSString *)name;
@end