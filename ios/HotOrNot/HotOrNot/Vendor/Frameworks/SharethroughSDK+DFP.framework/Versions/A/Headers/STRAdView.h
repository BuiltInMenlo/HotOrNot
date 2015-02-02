//
//  STRAdView.h
//  SharethroughSDK
//
//  Created by sharethrough on 1/16/14.
//  Copyright (c) 2014 Sharethrough. All rights reserved.
//

/**
 The STRAdView protocol is what your custom ad views are required to adhere to before an ad can be placed onto it. These getter methods may be fulfilled directly through properties that you could link from Interface Builder views, or you can simply define the getters. 
 
 If you have a content view that already has places for a title, description, etc. then you can subclass that view and have the subclass define the methods of the protocol, simply returning the correct view that matches the following getters.
 */
#import <Foundation/Foundation.h>

@protocol STRAdView <NSObject>

/**
 This method should return a UILabel (or subclass) that is appropriate for setting the ad title on.
 */
- (UILabel *)adTitle;

/**
 This method should return a UIImage (or subclass) that is appropriate for setting the ad thumbnail.
 */
- (UIImageView *)adThumbnail;

/**
 This method should return a UILabel (or subclass) that is appropriate for setting the string "Promoted by <brand name>".
 */
- (UILabel *)adSponsoredBy;

@optional

/**
 This optional method should return a UILabel (or subclass) that is appropriate for setting the ad description on. You may choose not to display the ad description.
 */
- (UILabel *)adDescription;

@end
