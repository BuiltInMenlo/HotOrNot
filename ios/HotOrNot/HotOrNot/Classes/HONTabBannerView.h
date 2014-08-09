//
//  HONTabBannerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 08/09/2014 @ 12:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@class HONTabBannerView;
@protocol HONTabBannerViewDelegate <NSObject>

@end
@interface HONTabBannerView : UIView <UIScrollViewDelegate>
@property (nonatomic, assign) id <HONTabBannerViewDelegate> delegate;
@end
