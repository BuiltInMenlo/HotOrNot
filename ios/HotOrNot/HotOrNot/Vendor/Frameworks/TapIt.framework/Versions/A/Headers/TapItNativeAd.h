//
//  TapItNativeAd.h
//  TapIt iOS SDK
//
//  Created by Carl Zornes on 11/20/14.
//
//

#import <Foundation/Foundation.h>

@interface TapItNativeAd : NSObject

/**
 An `NSString` that contains the ad title for the `TapItNativeAd`.
 */
- (NSString *)adTitle;

/**
 An `NSString` that contains the ad text for the `TapItNativeAd`.
 */
- (NSString *)adText;

/**
 An `NSString` that contains the ad HTML for the `TapItNativeAd`.
 */
- (NSString *)adHTML;

/**
 An `NSNumber` that contains the ad rating for the `TapItNativeAd`.
 */
- (NSNumber *)adRating;

/**
 An `NSString` that contains the ad icon URL for the `TapItNativeAd`.
 */
- (NSString *)adIconURL;

/**
 An `NSString` that contains the ad call to action for the `TapItNativeAd`.
 */
- (NSString *)adCTA;

/**
 An `NSString` that contains the ad click URL for the `TapItNativeAd`.
 */
- (NSString *)adClickURL;

/**
 An `NSString` that contains the ad impression URL for the `TapItNativeAd`.
 */
- (NSString *)adImpressionURL;

/**
 An `NSString` that contains the ad type for the `TapItNativeAd`.
 */
- (NSString *)adType;

/**
 An `NSString` that contains the ad dimension for the `TapItNativeAd`.
 */
- (NSString *)adDimension;

@end
