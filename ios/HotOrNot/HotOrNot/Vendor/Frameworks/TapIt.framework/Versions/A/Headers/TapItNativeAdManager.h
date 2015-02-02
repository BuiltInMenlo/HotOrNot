//
//  TapItNativeAdManager.h
//  TapIt iOS SDK
//
//  Created by Carl Zornes on 10/15/14.
//  Copyright (c) 2013 TapIt!. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>
#import "TapItConstants.h"
#import "TapItNativeAd.h"

@class TapItRequest;
@protocol TapItNativeAdDelegate;

/**
 `TapItNativeAdManager` creates a standard `TapItNativeAdManager` object for your app.
 */

@interface TapItNativeAdManager : NSObject

///-----------------------
/// @name Required Methods
///-----------------------

/**
 Once a `TapItRequest` object is created this function should be called to begin requesting ads for your app.
 @param request The ad request with zone information and any custom parameters.
 */
- (BOOL)getAdsForRequest:(TapItRequest *)request;

/**
 This method should be called when a native advertisement is touched.
 @param nativeAd The native ad that was touched.
 */
- (void)nativeAdWasTouched:(TapItNativeAd *)nativeAd;

/**
 This method should be called when a native ad is shown to the user.
 @param nativeAd The native ad that was touched.
 */
- (void)logNativeAdImpression:(TapItNativeAd *)nativeAd;

///---------------
/// @name Optional
///---------------

/**
 Once a `TapItRequest` object is created this function should be called to begin requesting ads for your app.
 @param request The ad request with zone information and any custom parameters.
 */
- (BOOL)getAdsForRequest:(TapItRequest *)request withRequestedNumberOfAds:(int)numberOfAds;

/**
 Updates the location parameters for the current `TapItRequest`.
 
 @param location The location to send to the current `TapItRequest`. This should be obtained from the app delegate.
 */
- (void)updateLocation:(CLLocation *)location;

/**
 Cancels the current ad request.
 */
- (void)cancelAds;

/**
 Pauses the current ad request.
 */
- (void)pause;

/**
 Resumes a paused ad request.
 */
- (void)resume;

/**
 An `id` that is used to identify the 'TapItNativeAdDelegate' delegate.
 */
@property (assign, nonatomic) id<TapItNativeAdDelegate> delegate;


/**
 The presenting `UIViewController`.
 */
@property (assign, nonatomic) UIViewController *presentingController;

/**
 An `NSUInteger` that sets the location precision information of the `TapItRequest`.
 */
@property NSUInteger locationPrecision;

/**
 An `NSMutableArray` that contains all the native ads for the `TapItRequest`.
 */
@property (retain, nonatomic) NSMutableArray *allNativeAds;

@end

@protocol TapItNativeAdDelegate <NSObject>
@optional

/**
 Called before a new native advertisement is loaded.
 
 @param nativeAdManager The native ad manager that is about to load.
 */
- (void)tapitNativeAdManagerWillLoadAd:(TapItNativeAdManager *)nativeAdManager;

/**
 Called when a new native advertisement is loaded.
 
 @param nativeAdManager The native ad manager that was downloaded.
 */
- (void)tapitNativeAdManagerDidLoad:(TapItNativeAdManager *)nativeAdManager;

/**
 Called when a native advertisement fails to load.
 
 @param nativeAdManager The native ad manager that failed to load.
 @param error The error object that describes the problem.
 */
- (void)tapitNativeAdManager:(TapItNativeAdManager *)nativeAdManager didFailToReceiveAdWithError:(NSError *)error;

/**
 Called before a native ad executes an action.
 
 @param nativeAdManager The native ad manager that the user tapped.
 @param willLeave YES if another application will be launched to execute the action; NO if the action is going to be executed inside your appliaction.
 
 @return Your delegate returns YES if the native ad action should execute; NO to prevent the native ad action from executing.
 
 This method is called when the user taps the native ad. Your application controls whether the action is triggered. To allow the action to be triggered,
 return YES. To suppress the action, return NO. Your application should almost always allow actions to be triggered; preventing actions may alter the
 advertisements your application sees and reduce the revenue your application earns through TapIt.
 
 If the willLeave parameter is YES, then your application is moved to the background shortly after this method returns. In this situation, your method
 implementation does not need to perform additional work. If willLeave is set to NO, then the triggered action will cover your application’s user
 interface to show the advertising action. Although your application continues to run normally, your implementation of this method should disable
 activities that require user interaction while the action is executing. For example, a game might pause its game play until the user finishes
 watching the advertisement.
 */
- (BOOL)tapitNativeAdManagerActionShouldBegin:(TapItNativeAdManager *)nativeAdManager willLeaveApplication:(BOOL)willLeave;

/**
 Called before a native ad finishes executing an action that covered your application's user interface.
 
 @param nativeAdManager The native ad manager that will finish executing an action.
 */
- (void)tapitNativeAdManagerActionWillFinish:(TapItNativeAdManager *)nativeAdManager;

/**
 Called after a native ad finishes executing an action that covered your application's user interface.
 
 @param nativeAdManager The native ad manager that finished executing an action.
 */
- (void)tapitNativeAdManagerActionDidFinish:(TapItNativeAdManager *)nativeAdManager;

@end
