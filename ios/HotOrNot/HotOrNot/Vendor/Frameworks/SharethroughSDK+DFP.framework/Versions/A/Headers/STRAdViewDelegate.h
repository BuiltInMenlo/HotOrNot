//
//  STRAdViewDelegate.h
//  SharethroughSDK
//
//  Created by sharethrough on 2/5/14.
//  Copyright (c) 2014 Sharethrough. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol STRAdView;

/**
 *  STRAdViewDelegate allows customized handling of success and failure cases after attempting to fetch an ad. Delegate can implement any number of the optional methods.
 */

@protocol STRAdViewDelegate <NSObject>

@optional
/**
 *  Delegate is notified of successful ad fetch and display.
 *
 *  @param adView       View in which the ad was placed.
 *  @param placementKey Placement key used to fetch this ad.
 */
- (void)adView:(id<STRAdView>)adView didFetchAdForPlacementKey:(NSString *)placementKey;

/**
 *  Delegate is notified of unsuccessful ad fetch and display.
 *  Could mean that there are no available advertisments for this placement key, or that there was a network error.
 *
 *  @param adView       View in which the ad was placed.
 *  @param placementKey Placement key used to fetch this ad.
 */
- (void)adView:(id<STRAdView>)adView didFailToFetchAdForPlacementKey:(NSString *)placementKey;

@end
