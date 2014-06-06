//
//  HONClubsTimelineViewController.h
//  HotOrNot
//
//  Created by Matt Holcombe on 04/25/2014 @ 10:58 .
//  Copyright (c) 2014 Built in Menlo, LLC. All rights reserved.
//


@interface HONClubsNewsFeedViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
- (id)initWithWrapperViewController:(UIViewController *)wrapperViewController;

- (void)refresh;
- (void)tare;
@end
