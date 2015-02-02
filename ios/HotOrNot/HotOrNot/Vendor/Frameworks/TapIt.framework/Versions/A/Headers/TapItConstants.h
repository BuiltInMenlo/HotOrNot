//
//  TapItConstants.h
//  TapIt iOS SDK
//
//  Created by Nick Penteado on 4/13/12.
//  Updated by Carl Zornes on 12/12/14.
//  Copyright (c) 2013 TapIt!. All rights reserved.
//

#ifndef TapIt_iOS_Sample_TapItConstants_h
#define TapIt_iOS_Sample_TapItConstants_h

#define TAPIT_VERSION @"3.1"

/**
 `TapItAdType` defines the available ad types for interstitial ads.
 */
typedef enum {
    TapItBannerAdType       = 0x01,
    TapItFullscreenAdType   = 0x02,
    TapItVideoAdType        = 0x04,
    TapItOfferWallType      = 0x08,
} TapItAdType;

/**
 `TapItBannerHideDirection` defines the orientations in which you want to disable displaying ads.
 */
typedef enum {
    TapItBannerHideNone,
    TapItBannerHideLeft,
    TapItBannerHideRight,
    TapItBannerHideUp,
    TapItBannerHideDown,
} TapItBannerHideDirection;

/**
 `TapItVideoType` defines the available video types for video ads.
 */
typedef enum {
    TapItVideoTypeAll,
    TapItVideoTypePreroll,
    TapItVideoTypeMidroll,
    TapItVideoTypePostroll,
} TapItVideoType;

#define TAPIT_PARAM_KEY_BANNER_ROTATE_INTERVAL @"RotateBannerInterval"
#define TAPIT_PARAM_KEY_BANNER_ERROR_TIMEOUT_INTERVAL @"ErrorRetryInterval"

#define TapItDefaultLocationPrecision 6

#endif
