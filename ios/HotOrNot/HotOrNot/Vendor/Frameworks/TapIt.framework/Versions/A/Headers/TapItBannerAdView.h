//
//  TapItBannerAdView.h
//  TapIt iOS SDK
//
//  Created by Nick Penteado on 4/11/12.
//  Updated by Carl Zornes on 10/23/13.
//  Copyright (c) 2013 TapIt!. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "TapItConstants.h"

@class TapItRequest;
@protocol TapItBannerAdViewDelegate;

/**
 `TapItBannerAdView` implements a standard `TapItBannerAdView` into your app.
 */

@interface TapItBannerAdView : UIView

///-----------------------
/// @name Required Methods
///-----------------------

/**
 Once a `TapItRequest` object is created and `TapItBannerAdView` added to your view, this function should be called to begin serving ads in your app.
 @param request The ad request with zone information and any custom parameters.
 */
- (BOOL)startServingAdsForRequest:(TapItRequest *)request;

///---------------
/// @name Optional
///---------------

/**
 Updates the location parameters for the current `TapItRequest`.
 
 @param location The location to send to the current `TapItRequest`. This should be obtained from the app delegate.
 */
- (void)updateLocation:(CLLocation *)location;

/**
 Hides ads from the view (sets the view's alpha to 0.0).
 */
- (void)hide;

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
 Override point to respond to orientation changes.
 */
- (void)repositionToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation;


/**
 An `id` that is used to identify the 'TapItBannerAdViewDelegate' delegate.
 */
@property (assign, nonatomic) id<TapItBannerAdViewDelegate> delegate;

/**
 A `BOOL` to signify whether or not you want the ad to animate in. The default value is `TRUE`.
 */
@property (assign, nonatomic) BOOL animated;

/**
 A `BOOL` to signify whether or not you want the ad to auto reposition to orientation changes. The default value is `TRUE`.
 */
@property (assign, nonatomic) BOOL autoReposition;

/**
 A `BOOL` to signify whether or not you want the ad to show a loading overlay once the ad is tapped. The default value is `TRUE`.
 */
@property (assign, nonatomic) BOOL showLoadingOverlay;

/**
 Deprecated attribute.
 */
@property (assign, nonatomic) BOOL shouldReloadAfterTap DEPRECATED_ATTRIBUTE;

/**
 A `BOOL` to signify whether or not the ad is currently serving ads.
 */
@property (readonly) BOOL isServingAds;

/**
 A `TapItBannerHideDirection` that sets the orientations in which you do not want ads displayed.
 */
@property (assign) TapItBannerHideDirection hideDirection;

/**
 The presenting `UIViewController`.
 */
@property (assign, nonatomic) UIViewController *presentingController;

/**
 An `NSUInteger` that sets the location precision information of the `TapItRequest`.
 */
@property NSUInteger locationPrecision;

@end

@protocol TapItBannerAdViewDelegate <NSObject>
@optional

/**
 Called before a new banner advertisement is loaded.
 
 @param bannerView The banner view that is about to load a new advertisement.
 */
- (void)tapitBannerAdViewWillLoadAd:(TapItBannerAdView *)bannerView;

/**
 Called when a new banner advertisement is loaded.
 
 @param bannerView The banner view that loaded a new advertisement.
 */
- (void)tapitBannerAdViewDidLoadAd:(TapItBannerAdView *)bannerView;

/**
 Called when a banner view fails to load a new advertisement.
 
 @param bannerView The banner view that failed to load an advertisement.
 @param error The error object that describes the problem.
 */
- (void)tapitBannerAdView:(TapItBannerAdView *)bannerView didFailToReceiveAdWithError:(NSError *)error;

/**
 Called before a banner view executes an action.
 
 @param bannerView The banner view that the user tapped.
 @param willLeave YES if another application will be launched to execute the action; NO if the action is going to be executed inside your appliaction.
 
 @return Your delegate returns YES if the banner action should execute; NO to prevent the banner action from executing.
 
 This method is called when the user taps the banner view. Your application controls whether the action is triggered. To allow the action to be triggered,
 return YES. To suppress the action, return NO. Your application should almost always allow actions to be triggered; preventing actions may alter the
 advertisements your application sees and reduce the revenue your application earns through TapIt.
 
 If the willLeave parameter is YES, then your application is moved to the background shortly after this method returns. In this situation, your method
 implementation does not need to perform additional work. If willLeave is set to NO, then the triggered action will cover your application’s user
 interface to show the advertising action. Although your application continues to run normally, your implementation of this method should disable
 activities that require user interaction while the action is executing. For example, a game might pause its game play until the user finishes
 watching the advertisement.
 */
- (BOOL)tapitBannerAdViewActionShouldBegin:(TapItBannerAdView *)bannerView willLeaveApplication:(BOOL)willLeave;

/**
 Called before a banner view finishes executing an action that covered your application's user interface.
 
 @param bannerView The banner view that will finish executing an action.
 */
- (void)tapitBannerAdViewActionWillFinish:(TapItBannerAdView *)bannerView;

/**
 Called after a banner view finishes executing an action that covered your application's user interface.
 
 @param bannerView The banner view that finished executing an action.
 */
- (void)tapitBannerAdViewActionDidFinish:(TapItBannerAdView *)bannerView;

@end
