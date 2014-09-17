//
//  NHGroupThese.h
//  TestApp
//
//  Created by Nicholas Hart on 7/24/13.
//  Copyright (c) 2013 Rhapsody International. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NHThreadThis;

@interface NHGroupThese : NSObject

- (id)initWithThreadThis: (NHThreadThis *) threadThis;

- (NHGroupThese *)doThis: (dispatch_block_t) block;
- (NHGroupThese *)doThis: (void (^)(size_t)) block iterations: (size_t) iterations;
- (NHGroupThese *)doThisAndWait: (dispatch_block_t) block;
- (NHGroupThese *)doThisBarrier: (dispatch_block_t) block;
- (NHGroupThese *)doThisBarrierAndWait: (dispatch_block_t) block;

- (NHGroupThese *)enterGroup;
- (NHGroupThese *)leaveGroup;

- (NHGroupThese *)notifyThis: (dispatch_block_t) block;

- (NHGroupThese *)waitForTimeout: (dispatch_time_t) timeout;
- (NHGroupThese *)waitForever;

@end
