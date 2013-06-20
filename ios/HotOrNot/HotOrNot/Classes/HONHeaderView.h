//
//  HONHeaderView.h
//  HotOrNot
//
//  Created by Matthew Holcombe on 10.14.12.
//  Copyright (c) 2012 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONHeaderView : UIView
- (id)initWithTitle:(NSString *)title;
- (id)initAsVoteWall;
- (id)initAsModalWithTitle:(NSString *)title;
- (void)toggleRefresh:(BOOL)isRefreshing;
- (void)hideRefreshing;
- (void)leftAlignTitle;

@property (nonatomic, strong) NSString *title;
@property(nonatomic, strong) UIButton *refreshButton;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@end
