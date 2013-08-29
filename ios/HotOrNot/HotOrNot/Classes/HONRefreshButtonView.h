//
//  HONRefreshButtonView.h
//  HotOrNot
//
//  Created by Matt Holcombe on 8/5/13.
//  Copyright (c) 2013 Built in Menlo, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HONRefreshButtonView : UIView
- (id)initWithTarget:(id)target action:(SEL)action;
- (void)toggleRefresh:(BOOL)isRefreshing;
- (void)offsetFrame:(CGPoint)pos;
@end
