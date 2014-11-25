//
//  HONHomeFeedToggleView.h
//  HotOrNot
//
//  Created by BIM  on 11/24/14.
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


typedef NS_ENUM(NSUInteger, HONHomeFeedType) {
	HONHomeFeedTypeRecent = 0,
	HONHomeFeedTypeTop,
	HONHomeFeedTypeOwned
};

@class HONHomeFeedToggleView;
@protocol HONHomeFeedToggleViewDelegate <NSObject>
- (void)homeFeedToggleView:(HONHomeFeedToggleView *)toggleView didSelectFeedType:(HONHomeFeedType)feedType;
@end

@interface HONHomeFeedToggleView : UIView
- (id)initAsType:(HONHomeFeedType)feedType;
- (void)toggleEnabled:(BOOL)isEnabled;

@property (nonatomic, assign) id <HONHomeFeedToggleViewDelegate> delegate;
@end
