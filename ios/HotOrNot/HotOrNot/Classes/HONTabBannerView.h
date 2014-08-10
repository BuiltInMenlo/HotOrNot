//
//  HONTabBannerView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 08/09/2014 @ 12:29 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//

#import "HONUserClubVO.h"

@class HONTabBannerView;
@protocol HONTabBannerViewDelegate <NSObject>
- (void)tabBannerView:(HONTabBannerView *)bannerView joinAreaCodeClub:(HONUserClubVO *)clubVO;
- (void)tabBannerView:(HONTabBannerView *)bannerView joinFamilyClub:(HONUserClubVO *)clubVO;
- (void)tabBannerViewInviteContacts:(HONTabBannerView *)bannerView;
@end

@interface HONTabBannerView : UIView <UIScrollViewDelegate>
@property (nonatomic, assign) id <HONTabBannerViewDelegate> delegate;
@end
