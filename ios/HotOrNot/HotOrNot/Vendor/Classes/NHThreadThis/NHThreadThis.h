//
//  NHThreadThis.h
//  TestApp
//
//  Created by Nicholas Hart on 7/24/13.
//  Copyright (c) 2013 Rhapsody International. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NHGroupThese.h"

// @todo: add dispatch_io and dispatch_source support

@interface NHThreadThis : NSObject

// for reference...
//#define DISPATCH_QUEUE_PRIORITY_HIGH 2
//#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
//#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
//#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN

+ (NHThreadThis*)backgroundThis;
+ (NHThreadThis*)backgroundThisWithPriority: (dispatch_queue_priority_t) priority;
+ (NHThreadThis*)backgroundThisWithSerialQueueNamed: (NSString *) queueName;
+ (NHThreadThis*)backgroundThisWithConcurrentQueueNamed: (NSString *) queueName;
+ (NHThreadThis*)mainThis;
+ (NHThreadThis*)backgroundThisWithDispatchQueue: (dispatch_queue_t) dispatchQueue;

- (id)initWithDispatchQueue: (dispatch_queue_t) dispatchQueue;
- (id)initWithGlobalQueuePriority: (dispatch_queue_priority_t) priority;
- (id)initWithMainQueue;
- (id)initThisWithQueueNamed: (NSString *) queueName attributes: (dispatch_queue_attr_t) attributes;

- (NHThreadThis *)doThis: (dispatch_block_t) block;
- (NHThreadThis *)doThis: (void (^)(size_t)) block iterations: (size_t) iterations;
- (NHThreadThis *)doThisAndWait: (dispatch_block_t) block;
- (NHThreadThis *)doThisBarrier: (dispatch_block_t) block;
- (NHThreadThis *)doThisBarrierAndWait: (dispatch_block_t) block;

- (NHGroupThese *)groupThese;

@end
