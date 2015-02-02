//
//  SharethroughSDKDFP.h
//  SharethroughSDK
//
//  Created by Engineer @editor.local on 9/4/14.
//  Copyright (c) 2014 Sharethrough. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "STRAdView.h"
#import "STRAdViewDelegate.h"
#import "UITableView+STR.h"
#import "UICollectionView+STR.h"

/**
 SharethroughSDK is the main interface to placing ads. There is a shared instance that can be accessed by [SharethroughSDK sharedInstance]. It can be used to place ads, most commonly through placeAdInView:placementKey:.
 */
@interface SharethroughSDKDFP : NSObject

/**
 The accessor for the SDK's shared instance.
 */
+ (instancetype)sharedInstance;

/**
 After creating a custom ad view that adheres to the STRAdView protocol and looks like the rest of your content, you can pass that view to placeAdInView to add the ad details.
 @param view The view to place ad data onto
 @param placementKey The unique identifier for the ad slot
 @param dfpPath The unique dfp path for the ad unit. Can be nil and it will be fetched from Sharethrough servers if available
 @param presentingViewController The view controller that will present the interactive ad controller if the user taps on the ad
 @param delegate Delegate for handling completion. This can be nil if you do not wish to customize success or failure behavior.
 @warning If you are placing the ad in a view returned by UITableView/UICollectionView's dequeue method (or any similar reuse mechanism), it is important that you register separate reuse identifier than your normal content cells. Using the same reuse identifier will result in artifacts left behind on content cells (such as ad interactivity behavior).
 */
- (void)placeAdInView:(UIView<STRAdView> *)view placementKey:(NSString *)placementKey dfpPath:(NSString*)dfpPath presentingViewController:(UIViewController *)presentingViewController delegate:(id<STRAdViewDelegate>)delegate;

/**
 If your app is using a basic UITableView that you want to present ads within, you may alternately use the following method to insert an ad. It is required that the reuse identifier be registered with the UITableView to return a UITableViewCell (or subclass) that conforms to the STRAdView protocol. This reuse identifier should be separate from the reuse identifier used for your content cells, even if they are registered with the same class or xib. A good place to call this function would be -viewDidLoad. Calling this method on the same table view will remove previously existing ad(s) and place an ad at the place specified by adStartingIndexPath.
 @param tableView The table view in which to inject an advertisement
 @param adCellReuseIdentifier The reuse identifier to use whenever displaying an ad cell; the reuse identifier must be registered with the table view with a cell that conforms to the STRAdView protocol
 @param placementKey The unique identifier for the ad to show
 @param presentingViewController The view controller that will present the interactive ad controller if the user taps on the ad
 @param adHeight The height of the adCell. This value will be unused if your delegate does not implement -tableView:heightForRowAtIndexPath: (the tableView will use rowHeight instead)
 @param adInitialIndexPath The inital index path to place the ad in. This index path should represent where the ad is, including the ad within the table view. This means that if you have 3 rows in a section, an index path of row 3 would in fact be valid. Index paths that are out of bounds will raise an exception. This should be the only index path computed with concern for there being an ad in the table view. Pass nil to let the SharethroughSDK choose a default location.
 
 @discussion The UITableView's dataSource methods of –tableView:commitEditingStyle:forRowAtIndexPath:, –tableView:canEditRowAtIndexPath:, –tableView:canMoveRowAtIndexPath:, –tableView:moveRowAtIndexPath:toIndexPath: are curerently not supported. Apps that wish to use these should instead use the more generic -placeAdInView:placementKey:presentingViewController:delegate:
 */
- (void)placeAdInTableView:(UITableView *)tableView adCellReuseIdentifier:(NSString *)adCellReuseIdentifier placementKey:(NSString *)placementKey presentingViewController:(UIViewController *)presentingViewController adHeight:(CGFloat)adHeight adInitialIndexPath:(NSIndexPath *)adInitialIndexPath;

/**
 If your app is using a basic UICollectionView that you want to present ads within, you may alternately use the following method to insert an ad. It is required that the reuse identifier be registered with the UIColectionView to return a UICollectionViewCell (or subclass) that conforms to the STRAdView protocol. This reuse identifier should be separate from the reuse identifier used for your content cells, even if they are registered with the same class or xib. A good place to call this function would be -viewDidLoad.
 
 Your collectionView's UICollectionViewLayout must be able to accomdate an ad cell, in addition it its content cells.
 
 @param collectionView           The collection view in which to inject an advertisment.
 @param adCellReuseIdentifier    The reuse identifier to use whenever displaying an ad cell; the reuse identifier must be registered with the table view with a cell that conforms to the STRAdView protocol
 @param placementKey             The unique identifier for the ad to show
 @param presentingViewController The view controller that will present the interactive ad controller if the user taps on the ad
 @param adSize                   The size of the adCell. This value will only be used if your collectionView delegate is a UICollectionViewDelegateFlowLayout and implements –collectionView:layout:sizeForItemAtIndexPath:
 @param adInitialIndexPath The inital index path to place the ad in. This index path should represent where the ad is, including the ad within the collection view. This means that if you have 3 items in a section, an index path with item 3 would in fact be valid. Index paths that are out of bounds will raise an exception. Pass nil to let the SharethroughSDK choose a default location.
 
 This is the only time the index path is computed taking into account the ad position. Future calls to the collection view should use STR's provided category methods (instead of UICollectionView's corresponding built-in methods). In using these category methods, index paths do not need to account for the extra ad cell.
 */
- (void)placeAdInCollectionView:(UICollectionView *)collectionView adCellReuseIdentifier:(NSString *)adCellReuseIdentifier placementKey:(NSString *)placementKey presentingViewController:(UIViewController *)presentingViewController adSize:(CGSize)adSize adInitialIndexPath:(NSIndexPath *)adInitialIndexPath;

/*
 This allows the app to configure the amount of time an ad is cached before a request for a new ad is made to the server. This defaults to 120 seconds and can be set as low as 20 seconds.
 
 @param seconds                 The number of seconds to set the timeout to. If less than 20 seconds, the timeout will be set to 20 seconds.
 @return the number of seconds the timeout is set to
 */

- (NSUInteger)setAdCacheTimeInSeconds:(NSUInteger)seconds;
@end
