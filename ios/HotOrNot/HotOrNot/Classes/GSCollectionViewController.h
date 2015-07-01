//
//  GSCollectionViewController.h
//  HotOrNot
//
//  Created by BIM  on 6/30/15.
//  Copyright (c) 2015 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "GSMessengerProperties.h"
#import "GSMessengerVO.h"

@class GSCollectionViewController;
@protocol GSCollectionViewControllerDelegate <NSObject>
@required
@optional
- (void)gsCollectionView:(GSCollectionViewController *)viewController didSelectMessenger:(GSMessengerVO *)messengerVO;
- (void)gsCollectionViewDidClose:(GSCollectionViewController *)viewController;
- (void)gsCollectionViewDidSkip:(GSCollectionViewController *)viewController;
@end

@interface GSCollectionViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
- (id)initWithAllMessengers;
- (id)initWithMessengers:(NSArray *)messengers;

@property (nonatomic, retain) NSDictionary *metaInfo;

@property (nonatomic, assign) id <GSCollectionViewControllerDelegate> delegate;
@end
