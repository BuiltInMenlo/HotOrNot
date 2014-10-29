//
//  HONAnimatedBGsViewController.h
//  HotOrNot
//
//  Created by BIM  on 10/22/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONViewController.h"
#import "HONEmotionVO.h"

@class HONAnimatedBGsViewController;
@protocol HONAnimatedBGsViewControllerDelegate <NSObject>
- (void)animatedBGViewController:(HONAnimatedBGsViewController *)viewController didSelectEmotion:(HONEmotionVO *)emotionVO;
@end

@interface HONAnimatedBGsViewController : HONViewController <UIAlertViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIGestureRecognizerDelegate>
@property (nonatomic, assign) id <HONAnimatedBGsViewControllerDelegate> delegate;
@end
