//
//  TVASTAd.h
//  Video Ads SDK
//
//  Created by Kevin Truong on 4/30/13.
//
//  Declares TVASTAd interface that has the general representation of an ad.

#import <Foundation/Foundation.h>

typedef enum {
  kTVASTAdTypeVideo,
} TVASTAdType;

@interface TVASTAd : NSObject {

}

@property(readonly, assign) TVASTAdType adType;
@property(readonly, retain) NSString *adId;
@property(readonly, assign) float creativeWidth;
@property(readonly, assign) float creativeHeight;

/// The length of the media file in seconds. Returns -1 if the duration value
/// is not available.
@property(readonly, assign) float duration;

/// The URL of the media file chosen from the ad to play. Returns null if the
/// information is not available.
@property(readonly, retain) NSString *mediaUrl;


// Returns the current version string of this SDK.
+(NSString *) getSDKVersionString;

@end

