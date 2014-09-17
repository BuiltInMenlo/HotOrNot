//
//  NHThreadThis.m
//  TestApp
//
//  Created by Nicholas Hart on 7/24/13.
//  Copyright (c) 2013 Rhapsody International. All rights reserved.
//

#import "NHThreadThis.h"

@interface NHThreadThis ()

@property (nonatomic, strong) dispatch_queue_t privateDispatchQueue;
@property (nonatomic, strong) dispatch_queue_t globalDispatchQueue;

- (dispatch_queue_t)dispatchQueue;

@end

@implementation NHThreadThis

+ (NHThreadThis*)backgroundThis {
    return [NHThreadThis backgroundThisWithPriority:DISPATCH_QUEUE_PRIORITY_DEFAULT];
}

+ (NHThreadThis*)backgroundThisWithPriority: (dispatch_queue_priority_t) priority {
    return [[NHThreadThis alloc] initWithGlobalQueuePriority:priority];
}

+ (NHThreadThis*)mainThis {
    return [[NHThreadThis alloc] initWithMainQueue];
}

+ (NHThreadThis*)backgroundThisWithDispatchQueue: (dispatch_queue_t) dispatchQueue {
    return [[NHThreadThis alloc] initWithDispatchQueue:dispatchQueue];
}

+ (NHThreadThis*)backgroundThisWithSerialQueueNamed: (NSString *) queueName {
    return [[NHThreadThis alloc] initThisWithQueueNamed:queueName attributes:DISPATCH_QUEUE_SERIAL];
}

+ (NHThreadThis*)backgroundThisWithConcurrentQueueNamed: (NSString *) queueName {
    return [[NHThreadThis alloc] initThisWithQueueNamed:queueName attributes:DISPATCH_QUEUE_CONCURRENT];
}

- (id)initWithDispatchQueue: (dispatch_queue_t) dispatchQueue {
    NSParameterAssert(dispatchQueue);
    if ((self = [super init])) {
        self.privateDispatchQueue = dispatchQueue;
        NSParameterAssert(self.privateDispatchQueue);
        if (!self.privateDispatchQueue) {
            self = nil; // let's not allow this class to be abused
        }
    }
    return self;
}

- (id)initWithGlobalQueuePriority: (dispatch_queue_priority_t) priority {
    NSParameterAssert(priority == DISPATCH_QUEUE_PRIORITY_HIGH ||
                      priority == DISPATCH_QUEUE_PRIORITY_DEFAULT ||
                      priority == DISPATCH_QUEUE_PRIORITY_LOW ||
                      priority == DISPATCH_QUEUE_PRIORITY_BACKGROUND);
    if ((self = [super init])) {
        self.globalDispatchQueue = dispatch_get_global_queue(priority, 0);
        NSParameterAssert(self.globalDispatchQueue);
        if (!self.globalDispatchQueue) {
            self = nil; // let's not allow this class to be abused
        }
    }
    return self;
}

- (id)initWithMainQueue {
    if ((self = [super init])) {
        self.globalDispatchQueue = dispatch_get_main_queue();
        NSParameterAssert(self.globalDispatchQueue);
        if (!self.globalDispatchQueue) {
            self = nil; // let's not allow this class to be abused
        }
    }
    return self;
}

- (id)initThisWithQueueNamed: (NSString *) queueName attributes: (dispatch_queue_attr_t) attributes {
    NSParameterAssert([queueName length]);
    NSParameterAssert(attributes == DISPATCH_QUEUE_SERIAL ||
                      attributes == DISPATCH_QUEUE_CONCURRENT);
    if ((self = [super init])) {
        self.privateDispatchQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], attributes);
        NSParameterAssert(self.privateDispatchQueue);
        if (!self.privateDispatchQueue) {
            self = nil; // let's not allow this class to be abused
        }
    }
    return self;
}

- (dispatch_queue_t)dispatchQueue {
    return self.privateDispatchQueue ? self.privateDispatchQueue : self.globalDispatchQueue;
}

- (NHThreadThis *)doThis: (dispatch_block_t) block {
    dispatch_queue_t dispatchQueue = [self dispatchQueue];
    NSParameterAssert(dispatchQueue);
    if (dispatchQueue) {
        dispatch_async(dispatchQueue, block);
    }
    return self;
}

- (NHThreadThis *)doThis: (void (^)(size_t)) block iterations: (size_t) iterations {
    dispatch_queue_t dispatchQueue = [self dispatchQueue];
    NSParameterAssert(dispatchQueue);
    if (dispatchQueue) {
        dispatch_apply(iterations, dispatchQueue, block);
    }
    return self;
}

- (NHThreadThis *)doThisAndWait: (dispatch_block_t) block {
    dispatch_queue_t dispatchQueue = [self dispatchQueue];
    NSParameterAssert(dispatchQueue);
    if (dispatchQueue) {
        dispatch_sync(dispatchQueue, block);
    }
    return self;
}

- (NHThreadThis *)doThisBarrier: (dispatch_block_t) block {
    // Use a private queue if you expect this behavior.  With a global queue it acts like dispatch_async.
    NSParameterAssert(self.privateDispatchQueue);
    if (self.privateDispatchQueue) {
        dispatch_barrier_async(self.privateDispatchQueue, block);
    }
    return self;
}

- (NHThreadThis *)doThisBarrierAndWait: (dispatch_block_t) block {
    // Use a private queue if you expect this behavior.  With a global queue it acts like dispatch_sync.
    NSParameterAssert(self.privateDispatchQueue);
    if (self.privateDispatchQueue) {
        dispatch_barrier_sync(self.privateDispatchQueue, block);
    }
    return self;
}

- (NHGroupThese *)groupThese {
    return [[NHGroupThese alloc] initWithThreadThis:self];
}

@end
