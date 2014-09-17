//
//  NHGroupThese.m
//  TestApp
//
//  Created by Nicholas Hart on 7/24/13.
//  Copyright (c) 2013 Rhapsody International. All rights reserved.
//

#import "NHGroupThese.h"
#import "NHThreadThis.h"

@interface NHThreadThis ()
- (dispatch_queue_t)dispatchQueue;
@end

@interface NHGroupThese ()
@property (nonatomic, strong) dispatch_group_t dispatchGroup;
@property (nonatomic, weak) NHThreadThis * threadThis;
@end

@implementation NHGroupThese

- (id)initWithThreadThis: (NHThreadThis *) threadThis {
    NSParameterAssert(threadThis);
    if ((self = [super init])) {
        self.threadThis = threadThis;
        self.dispatchGroup = dispatch_group_create();
        NSParameterAssert(self.dispatchGroup);
        if (!self.threadThis || !self.dispatchGroup) {
            self = nil; // let's not allow this class to be abused.
        }
    }
    return self;
}

- (NHGroupThese *)doThis: (dispatch_block_t) block {
    NSParameterAssert(block);
    dispatch_group_async(self.dispatchGroup, self.threadThis.dispatchQueue, block);
    return self;
}

- (NHGroupThese *)doThis: (void (^)(size_t)) block iterations: (size_t) iterations {
    NSParameterAssert(block);
    // for convenience only, since there is no dispatch_group_apply API...
    [self.threadThis doThis:block iterations:iterations];
    return self;
}

- (NHGroupThese *)doThisAndWait: (dispatch_block_t) block {
    NSParameterAssert(block);
    // for convenience only, since there is no dispatch_group_sync API...
    [self.threadThis doThisAndWait:block];
    return self;
}

- (NHGroupThese *)doThisBarrier: (dispatch_block_t) block {
    // for convenience only, since there is no dispatch_group_barrier_* API...
    [self.threadThis doThisBarrier:block];
    return self;
}

- (NHGroupThese *)doThisBarrierAndWait: (dispatch_block_t) block {
    // for convenience only, since there is no dispatch_group_barrier_* API...
    [self.threadThis doThisBarrierAndWait:block];
    return self;
}

- (NHGroupThese *)enterGroup {
    dispatch_group_enter(self.dispatchGroup);
    return self;
}

- (NHGroupThese *)leaveGroup {
    dispatch_group_leave(self.dispatchGroup);
    return self;
}

- (NHGroupThese *)notifyThis: (dispatch_block_t) block {
    NSParameterAssert(block);
    dispatch_group_notify(self.dispatchGroup, self.threadThis.dispatchQueue, block);
    return self;
}

- (NHGroupThese *)waitForTimeout: (dispatch_time_t) timeout {
    dispatch_group_wait(self.dispatchGroup, timeout);
    return self;
}

- (NHGroupThese *)waitForever {
    return [self waitForTimeout:DISPATCH_TIME_FOREVER];
}

@end
