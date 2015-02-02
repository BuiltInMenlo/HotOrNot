//
//  TapItAppTracker.h
//  TapIt iOS SDK
//
//  Created by Nick Penteado on 4/11/12.
//  Updated by Carl Zornes on 10/24/13.
//  Copyright (c) 2013 TapIt!. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 `TapItAppTracker` implements a standard `TapItAppTracker` into your app. This is required for all ad requests.
 */

@interface TapItAppTracker : NSObject

///-----------------------
/// @name Required Methods
///-----------------------

/**
 This method creates the shared app tracker.
 */
+ (TapItAppTracker *)sharedAppTracker;

/**
 This method registers your application with the ad server.
 */
- (void)reportApplicationOpen;

///---------------
/// @name Other Methods
///---------------

///**
// Returns 'MaaSAdvertising'
// */
//+ (NSString *)serviceName;

@end
