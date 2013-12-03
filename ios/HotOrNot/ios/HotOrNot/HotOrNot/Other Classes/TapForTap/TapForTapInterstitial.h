//
//  TapForTapInterstitial.h
//  TapForTapAds
//
//  Created by Sami Samhuri on 12-09-05.
//  Copyright (c) 2012 Tap for Tap. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol TapForTapInterstitialDelegate <NSObject>
- (void) tapForTapInterstitialWasDismissed;
@end

////

@interface TapForTapInterstitial : NSObject

+ (void) prepare;
+ (BOOL) isReady;
+ (void) setDelegate: (id<TapForTapInterstitialDelegate>) delegate;
+ (void) showWithRootViewController: (UIViewController *)rootViewController;

- (BOOL) isReady;
- (void) showWithRootViewController: (UIViewController *)rootViewController;

@end
